import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:isar/isar.dart';

import '../sync/v2/models/pairing_request.dart';
import '../sync/v2/models/peer_device.dart';
import '../sync/v2/models/sync_change_log.dart';
import '../sync/v2/models/sync_cursor.dart';
import '../sync/v2/services/change_journal.dart';
import '../sync/v2/services/cursor_manager.dart';
import '../sync/v2/services/device_discovery_service.dart';
import '../sync/v2/services/device_registry.dart';
import '../sync/v2/services/sync_manager.dart';
import '../sync/v2/sync_initializer_v2.dart';
import 'package:flutter/foundation.dart';
import 'package:collection/collection.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Design tokens
// ─────────────────────────────────────────────────────────────────────────────
const _bg = Color(0xFF0D0D14);
const _surface = Color(0xFF15151F);
const _card = Color(0xFF1A1A28);
const _border = Color(0xFF2A2A3D);
const _accent = Color(0xFF6C7EFF);
const _accentGlow = Color(0x336C7EFF);
const _green = Color(0xFF22D9A3);
const _greenGlow = Color(0x3322D9A3);
const _red = Color(0xFFFF5272);
const _orange = Color(0xFFFF9E4A);
const _textPrimary = Color(0xFFE8E8F5);
const _textSecondary = Color(0xFF7A7A9A);
const _textMuted = Color(0xFF4A4A6A);

/// Shared helper so the "pending changes for a peer" formula only lives in
/// one place instead of being duplicated between the parent screen and
/// [_DeviceCard].
int _pendingFor(int localSeq, SyncCursor? cursor) {
  if (cursor == null) return 0;
  final diff = localSeq - cursor.lastSentSeq;
  return diff < 0 ? 0 : diff;
}

// ─────────────────────────────────────────────────────────────────────────────
// Main screen
// ─────────────────────────────────────────────────────────────────────────────

class SyncSettingsScreenV2 extends StatefulWidget {
  const SyncSettingsScreenV2({super.key});

  @override
  State<SyncSettingsScreenV2> createState() => _SyncSettingsScreenV2State();
}

class _SyncSettingsScreenV2State extends State<SyncSettingsScreenV2>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  late TabController _tabController;
  Timer? _refreshTimer;

  List<PeerDevice> _devices = [];
  List<SyncCursor> _cursors = [];
  List<PairingRequest> _pendingRequests = [];
  int _localSeq = 0;
  int _pendingChanges = 0;
  Map<String, dynamic> _diagnostics = {};
  bool _syncing = false;
  String? _lastError;
  DateTime? _lastSyncTime;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _tabController = TabController(length: 6, vsync: this);
    _refresh();
    _startRefreshTimer();

    syncV2?.statusNotifier.addListener(_onStatusChange);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _tabController.dispose();
    _refreshTimer?.cancel();
    syncV2?.statusNotifier.removeListener(_onStatusChange);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Stop polling while backgrounded, resume (and refresh immediately) when
    // the app comes back to the foreground. Avoids unnecessary work/battery
    // drain from a 4s timer ticking while the screen isn't visible.
    switch (state) {
      case AppLifecycleState.resumed:
        _refresh();
        _startRefreshTimer();
        break;
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        _refreshTimer?.cancel();
        break;
    }
  }

  void _startRefreshTimer() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(const Duration(seconds: 4), (_) => _refresh());
  }

  void _onStatusChange() {
    if (!mounted) return;
    setState(() {
      _syncing = syncV2?.statusNotifier.status == SyncStatusV2.syncing;
      _lastError = syncV2?.statusNotifier.lastError;
      _lastSyncTime = syncV2?.statusNotifier.lastSyncTime;
    });
  }

  Future<void> _refresh() async {
    if (syncV2 == null) return;
    try {
      final devices = await syncV2!.deviceRegistry.getAllDevices();
      final cursors = await syncV2!.cursorManager.getAllCursors();
      final pendingRequests = await syncV2!.deviceRegistry.getPendingPairingRequests();
      final seq = await syncV2!.changeJournal.getCurrentSeq();

      // Count unsent changes for all paired peers
      int pending = 0;
      for (final cursor in cursors) {
        pending += _pendingFor(seq, cursor);
      }

      final diag = await syncV2!.discoveryService.getDiagnostics();

      if (mounted) {
        setState(() {
          _devices = devices;
          _cursors = cursors;
          _pendingRequests = pendingRequests;
          _localSeq = seq;
          _pendingChanges = pending;
          _diagnostics = diag;
        });
      }
    } catch (e, st) {
      // Surface the failure instead of swallowing it silently — otherwise a
      // broken registry/cursor/discovery call just looks like "no devices"
      // with no way to tell what actually went wrong.
      debugPrint('SyncSettingsScreenV2._refresh failed: $e\n$st');
      if (mounted) {
        setState(() {
          _lastError = 'Failed to refresh sync status: $e';
        });
      }
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Build
  // ─────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: NestedScrollView(
        headerSliverBuilder: (ctx, innerBoxIsScrolled) => [_buildAppBar()],
        body: Column(
          children: [
            _buildTabBar(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _TabLocalDevice(syncV2: syncV2),
                  _TabPairedDevices(
                    devices: _devices,
                    cursors: _cursors,
                    pendingRequests: _pendingRequests,
                    localSeq: _localSeq,
                    registry: syncV2?.deviceRegistry,
                    onRefresh: _refresh,
                  ),
                  _TabSyncStatus(
                    localSeq: _localSeq,
                    pendingChanges: _pendingChanges,
                    lastSyncTime: _lastSyncTime,
                    lastError: _lastError,
                    syncing: _syncing,
                  ),
                  _TabStatistics(cursors: _cursors, devices: _devices),
                  _TabPermissions(devices: _devices, registry: syncV2?.deviceRegistry, onRefresh: _refresh),
                  _TabDiagnostics(diagnostics: _diagnostics, localSeq: _localSeq),
                ],
              ),
            ),
            _buildActionBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      pinned: true,
      backgroundColor: _surface,
      foregroundColor: _textPrimary,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [_accent, Color(0xFF9B59FF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(8),
                boxShadow: const [BoxShadow(color: _accentGlow, blurRadius: 12)],
              ),
              child: const Icon(Icons.sync_rounded, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 10),
            const Text(
              'Sync Engine v2',
              style: TextStyle(
                color: _textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1A1A35), _surface],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ),
      actions: [
        _SyncPulseIcon(syncing: _syncing),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: _surface,
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          color: _accentGlow,
          border: Border.all(color: _accent.withOpacity(0.4)),
        ),
        labelColor: _accent,
        unselectedLabelColor: _textSecondary,
        labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        tabs: const [
          Tab(text: 'THIS DEVICE'),
          Tab(text: 'PAIRED DEVICES'),
          Tab(text: 'SYNC STATUS'),
          Tab(text: 'STATISTICS'),
          Tab(text: 'PERMISSIONS'),
          Tab(text: 'DIAGNOSTICS'),
        ],
      ),
    );
  }

  Widget _buildActionBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: _surface,
        border: const Border(top: BorderSide(color: _border)),
      ),
      child: SafeArea(
        top: false,
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _ActionButton(
              icon: Icons.sync_rounded,
              label: 'Sync Now',
              color: _accent,
              loading: _syncing,
              onTap: () async {
                setState(() => _syncing = true);
                try {
                  await syncV2?.syncManager.syncWithAllPeers();
                } catch (e) {
                  if (mounted) setState(() => _lastError = 'Sync failed: $e');
                } finally {
                  await _refresh();
                  if (mounted) setState(() => _syncing = false);
                }
              },
            ),
            _ActionButton(
              icon: Icons.restart_alt_rounded,
              label: 'Force Full Sync',
              color: _orange,
              onTap: () async {
                final ok = await _confirmDialog(
                  'Force Full Sync',
                  'This resets all sync cursors to 0 and re-downloads everything. Proceed?',
                );
                if (ok && mounted) {
                  setState(() => _syncing = true);
                  try {
                    await syncV2?.forceFullSync();
                  } catch (e) {
                    if (mounted) setState(() => _lastError = 'Force full sync failed: $e');
                  } finally {
                    await _refresh();
                    if (mounted) setState(() => _syncing = false);
                  }
                }
              },
            ),
            _ActionButton(
              icon: Icons.radar_rounded,
              label: 'Discover Devices',
              color: _green,
              onTap: () async {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Scanning network for SSMA devices...')));
                await syncV2?.discoveryService.rescan();
              },
            ),
            _ActionButton(
              icon: Icons.add_link_rounded,
              label: 'Connect by IP',
              color: _textSecondary,
              onTap: () => _showConnectByIpDialog(),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> _confirmDialog(String title, String message) async {
    return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: _card,
            title: Text(title, style: const TextStyle(color: _textPrimary)),
            content: Text(message, style: const TextStyle(color: _textSecondary)),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text('Cancel', style: TextStyle(color: _textSecondary))),
              TextButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  child: const Text('Proceed', style: TextStyle(color: _accent))),
            ],
          ),
        ) ??
        false;
  }

  void _showConnectByIpDialog() {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: _card,
        title: const Text('Connect by IP', style: TextStyle(color: _textPrimary)),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          style: const TextStyle(color: _textPrimary),
          decoration: InputDecoration(
            hintText: '192.168.1.x',
            hintStyle: TextStyle(color: _textMuted),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: _border),
              borderRadius: BorderRadius.circular(8),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: _accent),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel', style: TextStyle(color: _textSecondary))),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final ip = ctrl.text.trim();
              if (ip.isEmpty) return;
              bool ok = false;
              String? error;
              try {
                ok = await syncV2?.discoveryService.connectByIp(ip) ?? false;
              } catch (e) {
                error = '$e';
              }
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(ok
                        ? '✅ Connected to device at $ip'
                        : error != null
                            ? '❌ Could not reach $ip — $error'
                            : '❌ Could not reach $ip — is SSMA running there?')));
              }
              await _refresh();
            },
            child: const Text('Connect', style: TextStyle(color: _accent)),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Tab 1: This Device
// ─────────────────────────────────────────────────────────────────────────────

class _TabLocalDevice extends StatefulWidget {
  final SyncInitializerV2? syncV2;
  const _TabLocalDevice({required this.syncV2});

  @override
  State<_TabLocalDevice> createState() => _TabLocalDeviceState();
}

class _TabLocalDeviceState extends State<_TabLocalDevice> {
  bool _editingName = false;
  late TextEditingController _nameCtrl;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.syncV2?.deviceName ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final v2 = widget.syncV2;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _SectionHeader('Local Device Identity'),
        _InfoCard(children: [
          _InfoRow(
            icon: Icons.fingerprint_rounded,
            label: 'Device ID',
            value: v2?.deviceId ?? '—',
            copyable: true,
          ),
          _divider(),
          _editingName
              ? Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      const Icon(Icons.edit_rounded, color: _accent, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _nameCtrl,
                          autofocus: true,
                          style: const TextStyle(color: _textPrimary, fontSize: 14),
                          decoration: const InputDecoration(
                            hintText: 'Device Name',
                            hintStyle: TextStyle(color: _textMuted),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () async {
                          final name = _nameCtrl.text.trim();
                          if (name.isEmpty) return;
                          try {
                            await v2?.updateDeviceName(name);
                          } catch (e) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Could not rename device: $e')));
                            }
                            return;
                          }
                          if (mounted) setState(() => _editingName = false);
                        },
                        child: const Text('Save', style: TextStyle(color: _accent)),
                      ),
                    ],
                  ),
                )
              : _InfoRow(
                  icon: Icons.badge_rounded,
                  label: 'Device Name',
                  value: v2?.deviceName ?? '—',
                  trailing: IconButton(
                    icon: const Icon(Icons.edit_rounded, color: _textMuted, size: 16),
                    onPressed: () => setState(() => _editingName = true),
                  ),
                ),
          _divider(),
          _InfoRow(
            icon: Icons.phone_android_rounded,
            label: 'Platform',
            value: _detectPlatformLabel(),
          ),
          _divider(),
          _InfoRow(
            icon: Icons.info_rounded,
            label: 'App Version',
            value: v2?.appVersion ?? '1.0.0',
          ),
        ]),
        const SizedBox(height: 16),
        _SectionHeader('Sync Engine'),
        _InfoCard(children: [
          _InfoRow(
            icon: Icons.looks_two_rounded,
            label: 'Protocol Version',
            value: 'v2',
          ),
          _divider(),
          _InfoRow(
            icon: Icons.dns_rounded,
            label: 'Local Sync Port',
            value: '8080',
          ),
          _divider(),
          _InfoRow(
            icon: Icons.security_rounded,
            label: 'Trust Model',
            value: 'Pairing-based (device authentication)',
          ),
          _divider(),
          _InfoRow(
            icon: Icons.rule_rounded,
            label: 'Conflict Strategy',
            value: widget.syncV2?.conflictResolver.strategyName ?? 'Highest Version Wins',
          ),
        ]),
      ],
    );
  }

  String _detectPlatformLabel() {
    try {
      if (Theme.of(context).platform == TargetPlatform.android) return 'Android';
      if (Theme.of(context).platform == TargetPlatform.iOS) return 'iOS';
      if (Theme.of(context).platform == TargetPlatform.macOS) return 'macOS';
      if (Theme.of(context).platform == TargetPlatform.windows) return 'Windows';
      if (Theme.of(context).platform == TargetPlatform.linux) return 'Linux';
    } catch (_) {}
    return 'Unknown';
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Tab 2: Paired Devices
// ─────────────────────────────────────────────────────────────────────────────

class _TabPairedDevices extends StatelessWidget {
  final List<PeerDevice> devices;
  final List<SyncCursor> cursors;
  final List<PairingRequest> pendingRequests;
  final int localSeq;
  final DeviceRegistry? registry;
  final VoidCallback onRefresh;

  const _TabPairedDevices({
    required this.devices,
    required this.cursors,
    required this.pendingRequests,
    required this.localSeq,
    required this.registry,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    // Requests where a remote device asked *us* to pair — these need action.
    // Requests where isInitiator is true were sent by us and are just
    // waiting on the other device, so they're shown differently.
    final inbound = pendingRequests.where((r) => !r.isInitiator).toList();
    final outbound = pendingRequests.where((r) => r.isInitiator).toList();

    if (devices.isEmpty && pendingRequests.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.devices_rounded, color: _textMuted, size: 64),
            const SizedBox(height: 16),
            Text('No devices discovered yet', style: TextStyle(color: _textSecondary, fontSize: 16)),
            const SizedBox(height: 8),
            Text('Make sure other devices running SSMA\nare on the same Wi-Fi network',
                style: TextStyle(color: _textMuted, fontSize: 13), textAlign: TextAlign.center),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (inbound.isNotEmpty) ...[
          _SectionHeader('Pairing Requests'),
          ...inbound.map((r) => _InboundPairingRequestCard(
                request: r,
                registry: registry,
                onRefresh: onRefresh,
              )),
          const SizedBox(height: 8),
        ],
        if (outbound.isNotEmpty) ...[
          _SectionHeader('Sent Requests (awaiting response)'),
          ...outbound.map((r) => _OutboundPairingRequestCard(request: r)),
          const SizedBox(height: 8),
        ],
        if (devices.isNotEmpty) ...[
          if (inbound.isNotEmpty || outbound.isNotEmpty) _SectionHeader('Devices'),
          ...devices.map((d) => _DeviceCard(
                device: d,
                cursor: cursors.where((c) => c.remoteDeviceId == d.deviceId).firstOrNull,
                localSeq: localSeq,
                registry: registry,
                onRefresh: onRefresh,
              )),
        ],
      ],
    );
  }
}

class _InboundPairingRequestCard extends StatelessWidget {
  final PairingRequest request;
  final DeviceRegistry? registry;
  final VoidCallback onRefresh;

  const _InboundPairingRequestCard({
    required this.request,
    required this.registry,
    required this.onRefresh,
  });

  Future<void> _respond(BuildContext context, bool accept) async {
    try {
      await registry?.respondToPairingRequest(request.requestId, accept);
      if (accept) {
        // respondToPairingRequest only updates the PairingRequest's status —
        // it doesn't mark the device as trusted. That's a separate step.
        await registry?.pairDevice(request.initiatorDeviceId);
      }
      await syncV2?.discoveryService.sendPairingResponse(
        ip: request.initiatorIp,
        port: request.initiatorPort ?? 8080,
        accept: accept,
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Could not respond to request: $e')));
      }
    }
    onRefresh();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _accent.withOpacity(0.4)),
        boxShadow: const [BoxShadow(color: _accentGlow, blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.link_rounded, color: _accent, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${request.initiatorDeviceName} wants to pair',
                  style: const TextStyle(color: _textPrimary, fontSize: 14, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${request.initiatorPlatform} · ${request.initiatorIp}',
            style: const TextStyle(color: _textSecondary, fontSize: 12),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _SmallButton(
                label: 'Accept',
                icon: Icons.check_rounded,
                color: _green,
                onTap: () => _respond(context, true),
              ),
              const SizedBox(width: 8),
              _SmallButton(
                label: 'Reject',
                icon: Icons.close_rounded,
                color: _red,
                onTap: () => _respond(context, false),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _OutboundPairingRequestCard extends StatelessWidget {
  final PairingRequest request;
  const _OutboundPairingRequestCard({required this.request});

  @override
  Widget build(BuildContext context) {
    // NOTE: when isInitiator is true, `initiatorDeviceId`/`initiatorDeviceName`
    // refer to THIS device (the sender), not the peer it was sent to.
    // DeviceRegistry.recordPairingRequest doesn't currently capture which
    // peer an outbound request targets, so there's no field here to name
    // the recipient. If you want "waiting for <peer>" text, PairingRequest
    // needs a target-device field populated when the outbound request is
    // recorded — share pairing_request.dart and I'll add it properly.
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _border),
      ),
      child: const Row(
        children: [
          SizedBox(
              width: 16, height: 16, child: CircularProgressIndicator(color: _orange, strokeWidth: 2)),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Pairing request sent — waiting for the other device to respond...',
              style: TextStyle(color: _textSecondary, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

class _DeviceCard extends StatefulWidget {
  final PeerDevice device;
  final SyncCursor? cursor;
  final int localSeq;
  final DeviceRegistry? registry;
  final VoidCallback onRefresh;

  const _DeviceCard({
    required this.device,
    required this.cursor,
    required this.localSeq,
    required this.registry,
    required this.onRefresh,
  });

  @override
  State<_DeviceCard> createState() => _DeviceCardState();
}

class _DeviceCardState extends State<_DeviceCard> {
  bool _pairingInFlight = false;

  Color _statusColor() {
    return switch (widget.device.connectionStatus) {
      'reachable' => _green,
      'syncing' => _accent,
      'unreachable' => _red,
      _ => _textMuted,
    };
  }

  IconData _statusIcon() {
    return switch (widget.device.connectionStatus) {
      'reachable' => Icons.wifi_rounded,
      'syncing' => Icons.sync_rounded,
      'unreachable' => Icons.wifi_off_rounded,
      _ => Icons.help_outline_rounded,
    };
  }

  String _lastSeen() {
    final ms = widget.device.lastSeenMs;
    if (ms == 0) return 'Never';
    final dt = DateTime.fromMillisecondsSinceEpoch(ms);
    final diff = DateTime.now().difference(dt);
    if (diff.inSeconds < 60) return '${diff.inSeconds}s ago';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  @override
  Widget build(BuildContext context) {
    final device = widget.device;
    final pendingForPeer = _pendingFor(widget.localSeq, widget.cursor);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: device.isPaired ? _accent.withOpacity(0.3) : _border),
        boxShadow: device.isPaired
            ? [BoxShadow(color: _accentGlow, blurRadius: 8, spreadRadius: 0)]
            : null,
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                // Platform icon
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: _statusColor().withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: _statusColor().withOpacity(0.3)),
                  ),
                  child: Icon(_platformIcon(), color: _statusColor(), size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(device.deviceName,
                              style: const TextStyle(
                                  color: _textPrimary, fontSize: 15, fontWeight: FontWeight.w600)),
                          const SizedBox(width: 6),
                          if (device.isPaired)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: _accentGlow,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text('PAIRED',
                                  style: TextStyle(color: _accent, fontSize: 9, fontWeight: FontWeight.w700)),
                            ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(device.lastKnownIp,
                          style: const TextStyle(color: _textSecondary, fontSize: 12)),
                    ],
                  ),
                ),
                // Status indicator
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _statusColor().withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _statusColor().withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(_statusIcon(), color: _statusColor(), size: 12),
                      const SizedBox(width: 4),
                      Text(
                        device.connectionStatus.toUpperCase(),
                        style: TextStyle(color: _statusColor(), fontSize: 10, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Stats row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: _surface.withOpacity(0.6),
              border: const Border(top: BorderSide(color: _border)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _MiniStat(label: 'Last Seen', value: _lastSeen()),
                _MiniStat(
                  label: 'Sync Cursor',
                  value: widget.cursor != null ? '${widget.cursor!.lastReceivedSeq}' : '—',
                ),
                _MiniStat(
                  label: 'Pending',
                  value: '$pendingForPeer changes',
                  valueColor: pendingForPeer > 0 ? _orange : _green,
                ),
                _MiniStat(
                  label: 'Total Received',
                  value: '${widget.cursor?.totalReceived ?? 0}',
                ),
              ],
            ),
          ),
          // Actions
          if (device.isPaired)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
              child: Row(
                children: [
                  _SmallButton(
                    label: 'Sync Now',
                    icon: Icons.sync_rounded,
                    color: _accent,
                    onTap: () async {
                      try {
                        await syncV2?.syncManager.syncWithDevice(device.deviceId);
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context)
                              .showSnackBar(SnackBar(content: Text('Sync failed: $e')));
                        }
                      }
                      widget.onRefresh();
                    },
                  ),
                  const SizedBox(width: 8),
                  _SmallButton(
                    label: 'Reset Cursor',
                    icon: Icons.restart_alt_rounded,
                    color: _orange,
                    onTap: () async {
                      final ok = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              backgroundColor: _card,
                              title: const Text('Reset Cursor', style: TextStyle(color: _textPrimary)),
                              content: const Text('This resets the sync cursor to 0 and re-downloads everything for this device. Proceed?', style: TextStyle(color: _textSecondary)),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel', style: TextStyle(color: _textSecondary))),
                                TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Proceed', style: TextStyle(color: _accent))),
                              ],
                            ),
                          ) ?? false;
                      if (!ok || !mounted) return;
                      try {
                        await syncV2?.cursorManager.resetCursor(device.deviceId);
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context)
                              .showSnackBar(SnackBar(content: Text('Could not reset cursor: $e')));
                        }
                      }
                      widget.onRefresh();
                    },
                  ),
                  const SizedBox(width: 8),
                  _SmallButton(
                    label: 'Unpair',
                    icon: Icons.link_off_rounded,
                    color: _red,
                    onTap: () async {
                      try {
                        await widget.registry?.unpairDevice(device.deviceId);
                        await syncV2?.cursorManager.deleteCursor(device.deviceId);
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context)
                              .showSnackBar(SnackBar(content: Text('Could not unpair: $e')));
                        }
                      }
                      widget.onRefresh();
                    },
                  ),
                ],
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
              child: Row(
                children: [
                  _SmallButton(
                    label: _pairingInFlight ? 'Sending...' : 'Request Pairing',
                    icon: Icons.link_rounded,
                    color: _green,
                    onTap: _pairingInFlight ? () {} : () => _requestPairing(context),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  IconData _platformIcon() {
    return switch (widget.device.platform) {
      'android' => Icons.android_rounded,
      'ios' => Icons.phone_iphone_rounded,
      'macos' => Icons.laptop_mac_rounded,
      'windows' => Icons.computer_rounded,
      _ => Icons.devices_rounded,
    };
  }

  Future<void> _requestPairing(BuildContext context) async {
    final local = syncV2;
    if (local == null) return;

    setState(() => _pairingInFlight = true);
    try {
      // 1. Actually deliver the request to the peer over the network.
      final delivered = await local.discoveryService.sendPairingRequest(
        widget.device.lastKnownIp,
        widget.device.lastKnownPort,
      );

      // 2. Only record it locally as an outbound request if it was actually
      //    delivered — otherwise we'd show a "pending" request the peer
      //    never received.
      if (delivered) {
        await widget.registry?.recordPairingRequest(
          initiatorDeviceId: local.deviceId,
          initiatorDeviceName: local.deviceName,
          initiatorPlatform: defaultTargetPlatform.name,
          initiatorIp: '', // local device's own LAN IP isn't exposed here yet
          isInitiator: true,
          targetDeviceId: widget.device.deviceId,
          targetDeviceName: widget.device.deviceName,
        );
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(delivered
            ? 'Pairing request sent to ${widget.device.deviceName}'
            : '❌ Could not reach ${widget.device.deviceName} — is it online?'),
      ));
      widget.onRefresh();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('❌ Pairing request failed: $e')));
    } finally {
      if (mounted) setState(() => _pairingInFlight = false);
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Tab 3: Sync Status
// ─────────────────────────────────────────────────────────────────────────────

class _TabSyncStatus extends StatelessWidget {
  final int localSeq;
  final int pendingChanges;
  final DateTime? lastSyncTime;
  final String? lastError;
  final bool syncing;

  const _TabSyncStatus({
    required this.localSeq,
    required this.pendingChanges,
    required this.lastSyncTime,
    required this.lastError,
    required this.syncing,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Main status card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: syncing
                  ? [_accentGlow, Colors.transparent]
                  : lastError != null
                      ? [_red.withOpacity(0.15), Colors.transparent]
                      : [_greenGlow, Colors.transparent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            color: _card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: syncing ? _accent : (lastError != null ? _red : _green),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              if (syncing)
                const SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(color: _accent, strokeWidth: 2.5))
              else
                Icon(
                  lastError != null ? Icons.error_outline_rounded : Icons.check_circle_outline_rounded,
                  color: lastError != null ? _red : _green,
                  size: 28,
                ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      syncing ? 'Syncing...' : (lastError != null ? 'Last sync failed' : 'Sync up to date'),
                      style: TextStyle(
                        color: syncing ? _accent : (lastError != null ? _red : _green),
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (lastSyncTime != null)
                      Text(
                        'Last sync: ${_formatTime(lastSyncTime!)}',
                        style: const TextStyle(color: _textSecondary, fontSize: 12),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _SectionHeader('Change Journal'),
        _InfoCard(children: [
          _InfoRow(
            icon: Icons.commit_rounded,
            label: 'Current Sequence',
            value: '#$localSeq',
          ),
          _divider(),
          _InfoRow(
            icon: Icons.upload_rounded,
            label: 'Pending Uploads',
            value: '$pendingChanges changes',
            valueColor: pendingChanges > 0 ? _orange : _green,
          ),
        ]),
        if (lastError != null) ...[
          const SizedBox(height: 16),
          _SectionHeader('Last Error'),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: _red.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _red.withOpacity(0.3)),
            ),
            child: Text(lastError!, style: const TextStyle(color: _red, fontSize: 13, height: 1.5)),
          ),
        ],
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Tab 4: Statistics
// ─────────────────────────────────────────────────────────────────────────────

class _TabStatistics extends StatelessWidget {
  final List<SyncCursor> cursors;
  final List<PeerDevice> devices;

  const _TabStatistics({required this.cursors, required this.devices});

  @override
  Widget build(BuildContext context) {
    final totalSent = cursors.fold(0, (sum, c) => sum + c.totalSent);
    final totalReceived = cursors.fold(0, (sum, c) => sum + c.totalReceived);
    final paired = devices.where((d) => d.isPaired).length;
    final reachable = devices.where((d) => d.connectionStatus == 'reachable').length;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _SectionHeader('Network Overview'),
        GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 1.6,
          children: [
            _StatTile(label: 'Total Devices', value: '${devices.length}', icon: Icons.devices_rounded, color: _accent),
            _StatTile(label: 'Paired', value: '$paired', icon: Icons.link_rounded, color: _green),
            _StatTile(label: 'Reachable', value: '$reachable', icon: Icons.wifi_rounded, color: _orange),
            _StatTile(label: 'Offline', value: '${devices.length - reachable}', icon: Icons.wifi_off_rounded, color: _red),
          ],
        ),
        const SizedBox(height: 16),
        _SectionHeader('Data Transfer'),
        GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 1.6,
          children: [
            _StatTile(label: 'Changes Sent', value: '$totalSent', icon: Icons.upload_rounded, color: _accent),
            _StatTile(label: 'Changes Received', value: '$totalReceived', icon: Icons.download_rounded, color: _green),
          ],
        ),
        if (cursors.isNotEmpty) ...[
          const SizedBox(height: 16),
          _SectionHeader('Per-Device Cursors'),
          ...cursors.map((c) {
            final device = devices.where((d) => d.deviceId == c.remoteDeviceId).firstOrNull;
            return _InfoCard(
              margin: const EdgeInsets.only(bottom: 10),
              children: [
                _InfoRow(icon: Icons.devices_rounded, label: device?.deviceName ?? c.remoteDeviceId.substring(0, 8), value: ''),
                _divider(),
                _InfoRow(icon: Icons.download_rounded, label: 'Last Received Seq', value: '#${c.lastReceivedSeq}'),
                _divider(),
                _InfoRow(icon: Icons.upload_rounded, label: 'Last Sent Seq', value: '#${c.lastSentSeq}'),
                _divider(),
                _InfoRow(icon: Icons.history_rounded, label: 'Total Received', value: '${c.totalReceived}'),
                _divider(),
                _InfoRow(icon: Icons.history_rounded, label: 'Total Sent', value: '${c.totalSent}'),
              ],
            );
          }),
        ],
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Tab 5: Permissions
// ─────────────────────────────────────────────────────────────────────────────

class _TabPermissions extends StatelessWidget {
  final List<PeerDevice> devices;
  final DeviceRegistry? registry;
  final VoidCallback onRefresh;

  const _TabPermissions({required this.devices, required this.registry, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    final paired = devices.where((d) => d.isPaired).toList();

    if (paired.isEmpty) {
      return const Center(
        child: Text('No paired devices to configure', style: TextStyle(color: _textSecondary)),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: paired
          .map((d) => _PermissionCard(device: d, registry: registry, onRefresh: onRefresh))
          .toList(),
    );
  }
}

class _PermissionCard extends StatelessWidget {
  final PeerDevice device;
  final DeviceRegistry? registry;
  final VoidCallback onRefresh;

  const _PermissionCard({required this.device, required this.registry, required this.onRefresh});

  Future<void> _updatePermission(
    BuildContext context, {
    bool? receiveEnabled,
    bool? sendEnabled,
    bool? autoSyncEnabled,
  }) async {
    try {
      await registry?.updatePermissions(
        device.deviceId,
        receiveEnabled: receiveEnabled,
        sendEnabled: sendEnabled,
        autoSyncEnabled: autoSyncEnabled,
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Could not update permission: $e')));
      }
    }
    onRefresh();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _border),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                const Icon(Icons.devices_rounded, color: _accent, size: 20),
                const SizedBox(width: 10),
                Text(device.deviceName,
                    style: const TextStyle(color: _textPrimary, fontSize: 15, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          _PermToggle(
            label: 'Receive Changes',
            subtitle: 'Accept incoming data from this device',
            value: device.receiveEnabled,
            onChanged: (v) => _updatePermission(context, receiveEnabled: v),
          ),
          _divider(),
          _PermToggle(
            label: 'Send Changes',
            subtitle: 'Push our data to this device',
            value: device.sendEnabled,
            onChanged: (v) => _updatePermission(context, sendEnabled: v),
          ),
          _divider(),
          _PermToggle(
            label: 'Auto Sync',
            subtitle: 'Sync automatically when device is reachable',
            value: device.autoSyncEnabled,
            onChanged: (v) => _updatePermission(context, autoSyncEnabled: v),
          ),
        ],
      ),
    );
  }
}

class _PermToggle extends StatelessWidget {
  final String label;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _PermToggle({
    required this.label,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(color: _textPrimary, fontSize: 13)),
                Text(subtitle, style: const TextStyle(color: _textMuted, fontSize: 11)),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: _accent,
            trackColor: WidgetStateProperty.resolveWith(
              (states) => states.contains(WidgetState.selected) ? _accentGlow : _border,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Tab 6: Diagnostics
// ─────────────────────────────────────────────────────────────────────────────

class _TabDiagnostics extends StatelessWidget {
  final Map<String, dynamic> diagnostics;
  final int localSeq;

  const _TabDiagnostics({required this.diagnostics, required this.localSeq});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _SectionHeader('Network'),
        _InfoCard(children: [
          _InfoRow(
            icon: Icons.broadcast_on_home_rounded,
            label: 'mDNS Advertiser',
            value: diagnostics['advertiserRunning'] == true ? 'Running' : 'Stopped',
            valueColor: diagnostics['advertiserRunning'] == true ? _green : _red,
          ),
          _divider(),
          _InfoRow(
            icon: Icons.radar_rounded,
            label: 'mDNS Discovery',
            value: diagnostics['discoveryRunning'] == true ? 'Scanning' : 'Stopped',
            valueColor: diagnostics['discoveryRunning'] == true ? _green : _red,
          ),
          _divider(),
          _InfoRow(
            icon: Icons.wifi_rounded,
            label: 'Service Type',
            value: diagnostics['serviceType']?.toString() ?? '—',
          ),
          _divider(),
          _InfoRow(
            icon: Icons.router_rounded,
            label: 'Sync Port',
            value: diagnostics['port']?.toString() ?? '8080',
          ),
        ]),
        const SizedBox(height: 16),
        _SectionHeader('Change Journal'),
        _InfoCard(children: [
          _InfoRow(icon: Icons.commit_rounded, label: 'Current Sequence', value: '#$localSeq'),
          _divider(),
          _InfoRow(
            icon: Icons.devices_rounded,
            label: 'Known Devices',
            value: '${diagnostics['totalKnownDevices'] ?? 0}',
          ),
          _divider(),
          _InfoRow(
            icon: Icons.link_rounded,
            label: 'Paired Devices',
            value: '${diagnostics['pairedDevices'] ?? 0}',
          ),
          _divider(),
          _InfoRow(
            icon: Icons.wifi_rounded,
            label: 'Reachable Devices',
            value: '${diagnostics['reachableDevices'] ?? 0}',
          ),
        ]),
        const SizedBox(height: 16),
        _SectionHeader('Protocol'),
        _InfoCard(children: [
          _InfoRow(icon: Icons.numbers_rounded, label: 'Protocol Version', value: 'v2'),
          _divider(),
          _InfoRow(icon: Icons.security_rounded, label: 'Replay Protection', value: 'changeId UUID dedup'),
          _divider(),
          _InfoRow(icon: Icons.compress_rounded, label: 'Batch Size', value: '200 changes/request'),
          _divider(),
          _InfoRow(icon: Icons.history_rounded, label: 'Resume Strategy', value: 'Cursor-safe, never resets'),
        ]),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared widgets
// ─────────────────────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 8, top: 4),
        child: Text(
          title.toUpperCase(),
          style: const TextStyle(
            color: _textMuted,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
          ),
        ),
      );
}

class _InfoCard extends StatelessWidget {
  final List<Widget> children;
  final EdgeInsets? margin;
  const _InfoCard({required this.children, this.margin});

  @override
  Widget build(BuildContext context) => Container(
        margin: margin ?? const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: _card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        ),
      );
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;
  final bool copyable;
  final Widget? trailing;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
    this.copyable = false,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      child: Row(
        children: [
          Icon(icon, color: _textMuted, size: 16),
          const SizedBox(width: 10),
          Expanded(
            child: Text(label, style: const TextStyle(color: _textSecondary, fontSize: 13)),
          ),
          if (trailing != null)
            trailing!
          else
            GestureDetector(
              onTap: copyable
                  ? () {
                      Clipboard.setData(ClipboardData(text: value));
                      ScaffoldMessenger.of(context)
                          .showSnackBar(const SnackBar(content: Text('Copied to clipboard')));
                    }
                  : null,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(
                      value,
                      style: TextStyle(
                        color: valueColor ?? _textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ),
                  if (copyable) ...[
                    const SizedBox(width: 4),
                    const Icon(Icons.copy_rounded, color: _textMuted, size: 12),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }
}

Widget _divider() => Container(height: 1, color: _border.withOpacity(0.5));

class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatTile({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: _card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.25)),
          boxShadow: [BoxShadow(color: color.withOpacity(0.08), blurRadius: 8)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, color: color, size: 22),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value,
                    style: TextStyle(color: color, fontSize: 22, fontWeight: FontWeight.w700)),
                Text(label, style: const TextStyle(color: _textSecondary, fontSize: 11)),
              ],
            ),
          ],
        ),
      );
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _MiniStat({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) => Column(
        children: [
          Text(value,
              style: TextStyle(
                  color: valueColor ?? _textPrimary, fontSize: 13, fontWeight: FontWeight.w600)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(color: _textMuted, fontSize: 10)),
        ],
      );
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final bool loading;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: loading ? null : onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: color.withOpacity(0.35)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (loading)
                SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(color: color, strokeWidth: 2))
              else
                Icon(icon, color: color, size: 16),
              const SizedBox(width: 6),
              Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      );
}

class _SmallButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _SmallButton({required this.label, required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withOpacity(0.35)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 12),
              const SizedBox(width: 4),
              Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      );
}

class _SyncPulseIcon extends StatefulWidget {
  final bool syncing;
  const _SyncPulseIcon({required this.syncing});

  @override
  State<_SyncPulseIcon> createState() => _SyncPulseIconState();
}

class _SyncPulseIconState extends State<_SyncPulseIcon> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 1))..repeat();
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.syncing) {
      return const Icon(Icons.sync_rounded, color: _textMuted, size: 22);
    }
    return RotationTransition(
      turns: _anim,
      child: const Icon(Icons.sync_rounded, color: _accent, size: 22),
    );
  }
}

String _formatTime(DateTime dt) {
  final now = DateTime.now();
  final diff = now.difference(dt);
  if (diff.inSeconds < 60) return '${diff.inSeconds}s ago';
  if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
  return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
}