import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:isar/isar.dart';

import 'package:ssma/models/change_log.dart';
import 'package:ssma/models/item.dart';
import 'package:ssma/services/db_service.dart';
import 'package:ssma/services/device_service.dart';
import 'package:ssma/services/lan_sync/change_tracker_service.dart';
import 'package:ssma/services/lan_sync/local_sync_server.dart';
import 'package:ssma/services/lan_sync/mdns_advertiser_service.dart';
import 'package:ssma/services/lan_sync/mdns_discovery_service.dart';
import 'package:ssma/services/lan_sync/sync_models.dart';

const bool kEnableSyncServer =
    bool.fromEnvironment('ENABLE_SYNC_SERVER', defaultValue: true);
const bool kEnableMdnsAdvertiser =
    bool.fromEnvironment('ENABLE_MDNS_ADVERTISER', defaultValue: true);
const bool kEnableMdnsDiscovery =
    bool.fromEnvironment('ENABLE_MDNS_DISCOVERY', defaultValue: true);
const bool kEnableBackgroundSync =
    bool.fromEnvironment('ENABLE_BACKGROUND_SYNC', defaultValue: true);

class SyncService {
  SyncService({
    http.Client? httpClient,
    this.port = 8080,
  }) : _httpClient = httpClient ?? http.Client();

  static const _serviceType = '_isar_sync._tcp.local';
  static const _chunkSize = 100;

  final int port;
  final http.Client _httpClient;
  final ChangeTrackerService _changeTracker = ChangeTrackerService();

  String? _deviceId;
  LocalSyncServer? _server;
  MdnsAdvertiserService? _advertiser;
  MdnsDiscoveryService? _discovery;
  Timer? _syncTimer;
  bool _started = false;
  bool _syncAllInFlight = false;
  final Set<String> _peerSyncInFlight = <String>{};

  Stream<List<SyncPeer>> get peersStream =>
      _discovery?.peersStream ?? const Stream.empty();

  List<SyncPeer> get peers => _discovery?.peers ?? const [];

  bool get isStarted => _started;

  Future<bool> start() async {
    if (_started) {
      return true;
    }

    try {
      await DBService.initializeIsar();
      _deviceId = await DeviceService.getDeviceId();
    } catch (error, stackTrace) {
      _log('Failed to initialize sync prerequisites', error, stackTrace);
      return false;
    }

    var anyComponentStarted = false;

    if (kEnableSyncServer) {
      try {
        _server = LocalSyncServer(
          deviceId: _deviceId!,
          port: port,
        );
        await _server!.start();
        anyComponentStarted = true;
      } catch (error, stackTrace) {
        _server = null;
        _log('Local sync server failed to start', error, stackTrace);
      }
    }

    if (kEnableMdnsAdvertiser) {
      try {
        _advertiser = MdnsAdvertiserService(
          deviceId: _deviceId!,
          port: port,
          serviceType: _serviceType,
        );
        await _advertiser!.start();
        anyComponentStarted = true;
      } catch (error, stackTrace) {
        _advertiser = null;
        _log('mDNS advertiser failed to start', error, stackTrace);
      }
    }

    if (kEnableMdnsDiscovery) {
      try {
        _discovery = MdnsDiscoveryService(
          deviceId: _deviceId!,
          serviceType: _serviceType,
        );
        await _discovery!.start();
        anyComponentStarted = true;
      } catch (error, stackTrace) {
        _discovery = null;
        _log('mDNS discovery failed to start', error, stackTrace);
      }
    }

    if (!anyComponentStarted) {
      _started = false;
      return false;
    }

    if (kEnableBackgroundSync) {
      _syncTimer = Timer.periodic(
        const Duration(seconds: 30),
        (_) => unawaited(_runScheduledSync()),
      );
    }

    _started = true;
    return true;
  }

  Future<void> stop() async {
    _syncTimer?.cancel();
    _syncTimer = null;
    await _discovery?.stop();
    await _advertiser?.stop();
    await _server?.stop();
    _started = false;
  }

  Future<void> sync() async {
    if (!_started || _syncAllInFlight || _discovery == null) {
      return;
    }

    _syncAllInFlight = true;
    try {
      await _discovery?.refreshNow();
      for (final peer in peers) {
        await syncWithPeer(peer);
      }
    } finally {
      _syncAllInFlight = false;
    }
  }

  Future<void> syncWithPeer(SyncPeer peer) async {
    final key = '${peer.address}:${peer.port}';
    if (_peerSyncInFlight.contains(key)) {
      return;
    }

    _peerSyncInFlight.add(key);
    try {
      final healthyPeer = await _resolvePeerHealth(peer);
      if (healthyPeer == null || healthyPeer.deviceId == _deviceId) {
        return;
      }

      await pushChanges(healthyPeer);
      await pullChanges(healthyPeer);
    } catch (_) {
      // Failed peers are retried on the next sync tick.
    } finally {
      _peerSyncInFlight.remove(key);
    }
  }

  Future<void> pushChanges(SyncPeer peer) async {
    final unsynced = (await DBService.isar.changeLogs.where().findAll())
      ..sort((a, b) => a.changeSeq.compareTo(b.changeSeq));
    final pendingLogs = unsynced.where((log) => !log.synced).toList();

    if (pendingLogs.isEmpty) {
      return;
    }

    for (var index = 0; index < pendingLogs.length; index += _chunkSize) {
      final chunk = pendingLogs.skip(index).take(_chunkSize).toList();
      final changes = <SyncChange>[];
      for (final log in chunk) {
        if (log.collection != 'items') {
          continue;
        }

        final item = await DBService.isar.items.getByRecordId(log.recordId);
        changes.add(
          SyncChange(
            collection: log.collection,
            recordId: log.recordId,
            opId: log.opId,
            changeSeq: log.changeSeq,
            operation: log.operation.name,
            timestamp: log.timestamp,
            originDeviceId: log.originDeviceId,
            payload: item?.toSyncJson(),
          ),
        );
      }

      if (changes.isEmpty) {
        continue;
      }

      final response = await _httpClient.post(
        Uri.parse('${peer.baseUrl}/sync/push'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'deviceId': _deviceId,
          'changes': changes.map((change) => change.toJson()).toList(),
        }),
      );

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception('Push failed with status ${response.statusCode}');
      }

      await DBService.isar.writeTxn(() async {
        for (final log in chunk) {
          log.synced = true;
        }
        await DBService.isar.changeLogs.putAll(chunk);
      });
    }
  }

  Future<void> pullChanges(SyncPeer peer) async {
    final peerKey = '${peer.address}:${peer.port}';
    var cursor = await _changeTracker.lastPulledSeq(peerKey);
    var hasMore = true;

    while (hasMore) {
      final response = await _httpClient.get(
        Uri.parse('${peer.baseUrl}/sync/pull?since=$cursor&limit=$_chunkSize'),
      );

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception('Pull failed with status ${response.statusCode}');
      }

      final body = Map<String, dynamic>.from(
        jsonDecode(response.body) as Map,
      );
      final rawChanges = body['changes'] as List<dynamic>? ?? const [];

      for (final rawChange in rawChanges) {
        final change = SyncChange.fromJson(
          Map<String, dynamic>.from(rawChange as Map),
        );
        await applyChange(change);
      }

      cursor = (body['nextCursor'] as num?)?.toInt() ?? cursor;
      await _changeTracker.saveLastPulledSeq(peerKey, cursor);
      hasMore = body['hasMore'] as bool? ?? false;
      if (rawChanges.isEmpty) {
        hasMore = false;
      }
    }
  }

  Future<void> applyChange(SyncChange change) async {
    if (change.collection != 'items' || change.payload == null) {
      return;
    }

    final existingChange =
        await DBService.isar.changeLogs.filter().opIdEqualTo(change.opId).findFirst();
    if (existingChange != null) {
      return;
    }

    final incomingItem = Item.fromSyncJson(change.payload!);
    final localItem =
        await DBService.isar.items.getByRecordId(change.recordId);

    if (!_shouldApplyIncomingItem(
      localItem: localItem,
      incomingItem: incomingItem,
    )) {
      return;
    }
    final changeSeq = await _changeTracker.nextChangeSeq();

    await DBService.isar.writeTxn(() async {
      if (localItem != null) {
        incomingItem.id = localItem.id;
      }

      await DBService.isar.items.putByRecordId(incomingItem);
      await DBService.isar.changeLogs.put(
        ChangeLog.create(
          collection: change.collection,
          recordId: change.recordId,
          opId: change.opId,
          changeSeq: changeSeq,
          operation: ChangeOperation.values.firstWhere(
            (value) => value.name == change.operation,
            orElse: () => ChangeOperation.update,
          ),
          timestamp: change.timestamp,
          originDeviceId: change.originDeviceId,
          synced: true,
        ),
      );
    });
  }

  Future<SyncPeer?> _resolvePeerHealth(SyncPeer peer) async {
    final response = await _httpClient
        .get(Uri.parse('${peer.baseUrl}/health'))
        .timeout(const Duration(seconds: 3));
    if (response.statusCode != 200) {
      return null;
    }

    final body = Map<String, dynamic>.from(
      jsonDecode(response.body) as Map,
    );
    return peer.copyWith(
      deviceId: body['deviceId'] as String?,
      lastSeen: DateTime.now().toUtc(),
    );
  }

  Future<void> _runScheduledSync() async {
    try {
      await sync();
    } catch (error, stackTrace) {
      _log('Scheduled sync failed', error, stackTrace);
    }
  }

  bool _shouldApplyIncomingItem({
    required Item? localItem,
    required Item incomingItem,
  }) {
    if (localItem == null) {
      return true;
    }

    if (incomingItem.version != localItem.version) {
      return incomingItem.version > localItem.version;
    }

    if (incomingItem.updatedAt != localItem.updatedAt) {
      return incomingItem.updatedAt.isAfter(localItem.updatedAt);
    }

    return incomingItem.deviceId.compareTo(localItem.deviceId) > 0;
  }

  void _log(String message, Object error, StackTrace stackTrace) {
    debugPrint('$message: $error');
    if (kDebugMode) {
      debugPrintStack(stackTrace: stackTrace);
    }
  }
}
