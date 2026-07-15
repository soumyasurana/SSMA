import 'dart:async';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import 'services/change_journal.dart';
import 'services/change_processor.dart';
import 'services/conflict_resolver.dart';
import 'services/cursor_manager.dart';
import 'services/device_discovery_service.dart';
import 'services/device_registry.dart';
import 'services/local_sync_server.dart';
import 'services/sync_manager.dart';
import '../../services/db_service.dart';

/// Top-level coordinator for the v2 sync subsystem.
///
/// Call [initialize] once at app startup (after DBService.initializeIsar).
/// Call [shutdown] in the app's dispose / background lifecycle hook.
///
/// All sub-services are exposed as public fields so UI screens and
/// other services can read state without additional indirection.
class SyncInitializerV2 with WidgetsBindingObserver {
  // -------------------------------------------------------------------------
  // Configuration
  // -------------------------------------------------------------------------

  final int port;
  String? _deviceId;
  String? _deviceName;
  final String appVersion = '1.0.0';

  // -------------------------------------------------------------------------
  // Public services (read-only from outside)
  // -------------------------------------------------------------------------

  late ChangeJournal changeJournal;
  late CursorManager cursorManager;
  late ConflictResolver conflictResolver;
  late ChangeProcessor changeProcessor;
  late DeviceRegistry deviceRegistry;
  late SyncManager syncManager;
  late LocalSyncServer syncServer;
  late DeviceDiscoveryService discoveryService;
  late SyncStatusNotifierV2 statusNotifier;

  // -------------------------------------------------------------------------
  // State
  // -------------------------------------------------------------------------

  String get deviceId => _deviceId ?? 'uninitialized';
  String get deviceName => _deviceName ?? 'This Device';
  bool _initialized = false;

  SyncInitializerV2({this.port = 8080});

  // -------------------------------------------------------------------------
  // Lifecycle
  // -------------------------------------------------------------------------

  Future<void> initialize() async {
    if (_initialized) return;

    // 1. Load or create persistent device identity
    _deviceId = await _loadOrCreateDeviceId();
    _deviceName = await _loadOrCreateDeviceName();

    final isar = DBService.isar;
    final localPlatform = _detectPlatform();

    // 2. Core services
    statusNotifier = SyncStatusNotifierV2();

    changeJournal = ChangeJournal(isar: isar, localDeviceId: _deviceId!);
    cursorManager = CursorManager(isar: isar);
    conflictResolver = ConflictResolver(); // defaults to HighestVersionWins
    changeProcessor = ChangeProcessor(
      isar: isar,
      journal: changeJournal,
      conflictResolver: conflictResolver,
    );
    deviceRegistry = DeviceRegistry(isar: isar);

    // 2b. Backfill the v2 journal for legacy rows that predate sync v2.
    await DBService.backfillSyncV2Journal(changeJournal);

    // 3. Sync manager
    syncManager = SyncManager(
      isar: isar,
      localDeviceId: _deviceId!,
      journal: changeJournal,
      cursorManager: cursorManager,
      deviceRegistry: deviceRegistry,
      changeProcessor: changeProcessor,
      statusNotifier: statusNotifier,
    );

    // 4. Entity registry (register all entity handlers)
    EntityRegistry.registerAll(isar: isar);

    // 5. Local HTTP server
    syncServer = LocalSyncServer(
      port: port,
      localDeviceId: _deviceId!,
      localDeviceName: _deviceName!,
      localPlatform: localPlatform,
      localAppVersion: appVersion,
      isar: isar,
      journal: changeJournal,
      changeProcessor: changeProcessor,
      cursorManager: cursorManager,
      deviceRegistry: deviceRegistry,
    );
    await syncServer.start();

    // 6. Device discovery (mDNS + subnet fallback + health checks)
    discoveryService = DeviceDiscoveryService(
      localDeviceId: _deviceId!,
      localDeviceName: _deviceName!,
      localPlatform: localPlatform,
      localAppVersion: appVersion,
      port: port,
      deviceRegistry: deviceRegistry,
      syncManager: syncManager,
    );
    await discoveryService.start();

    // 7. App lifecycle observer (trigger sync on resume)
    WidgetsBinding.instance.addObserver(this);

    _initialized = true;

    debugPrint(
        '[SyncInitializerV2]: ✅ initialized — deviceId=$_deviceId port=$port');
  }

  Future<void> shutdown() async {
    WidgetsBinding.instance.removeObserver(this);
    await discoveryService.stop();
    await syncServer.stop();
    _initialized = false;
    debugPrint('[SyncInitializerV2]: shutdown complete');
  }

  // -------------------------------------------------------------------------
  // App lifecycle
  // -------------------------------------------------------------------------

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _initialized) {
      debugPrint('[SyncInitializerV2]: app resumed — triggering sync');
      syncManager.syncWithAllPeers();
    }
  }

  // -------------------------------------------------------------------------
  // Device identity helpers
  // -------------------------------------------------------------------------

  static const _deviceIdKey = 'ssma_v2_device_id';
  static const _deviceNameKey = 'ssma_v2_device_name';

  Future<String> _loadOrCreateDeviceId() async {
    final prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString(_deviceIdKey);
    if (id == null) {
      id = const Uuid().v4();
      await prefs.setString(_deviceIdKey, id);
      debugPrint('[SyncInitializerV2]: created new deviceId: $id');
    }
    return id;
  }

  Future<String> _loadOrCreateDeviceName() async {
    final prefs = await SharedPreferences.getInstance();
    String? name = prefs.getString(_deviceNameKey);
    if (name == null) {
      name = _defaultDeviceName();
      await prefs.setString(_deviceNameKey, name);
    }
    return name;
  }

  Future<void> updateDeviceName(String newName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_deviceNameKey, newName);
    _deviceName = newName;
  }

  static String _defaultDeviceName() {
    if (Platform.isAndroid) return 'Android Device';
    if (Platform.isIOS) return 'iPhone';
    if (Platform.isMacOS) return 'Mac';
    if (Platform.isWindows) return 'Windows PC';
    if (Platform.isLinux) return 'Linux Device';
    return 'Unknown Device';
  }

  static String _detectPlatform() {
    if (Platform.isAndroid) return 'android';
    if (Platform.isIOS) return 'ios';
    if (Platform.isMacOS) return 'macos';
    if (Platform.isWindows) return 'windows';
    if (Platform.isLinux) return 'linux';
    return 'unknown';
  }

  // -------------------------------------------------------------------------
  // Convenience accessors for UI / DBService
  // -------------------------------------------------------------------------

  /// Triggers a debounced sync after a local mutation.
  void triggerDebouncedSync() {
    if (!_initialized) return;
    // Small delay so multiple rapid writes are batched together
    Future.delayed(const Duration(seconds: 3), () {
      if (_initialized) syncManager.syncWithAllPeers();
    });
  }

  /// Forces a full re-sync with all paired peers by resetting all cursors.
  Future<void> forceFullSync() async {
    final cursors = await cursorManager.getAllCursors();
    for (final c in cursors) {
      await cursorManager.resetCursor(c.remoteDeviceId);
    }
    await syncManager.syncWithAllPeers(respectAutoSyncFlag: false);
  }

  /// Returns the current maximum local change sequence.
  Future<int> getCurrentSeq() => changeJournal.getCurrentSeq();
}

/// Global singleton — mirrors the old [syncInitializer] pattern.
SyncInitializerV2? syncV2;
