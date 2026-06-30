import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:ssma/main.dart';
import 'package:ssma/models/change_log.dart';
import 'package:ssma/models/peer_state.dart';
import 'package:ssma/models/item.dart';
import 'package:ssma/sync/sync_status.dart';

class SyncSettingsScreen extends StatefulWidget {
  const SyncSettingsScreen({super.key});

  @override
  State<SyncSettingsScreen> createState() => _SyncSettingsScreenState();
}

class _SyncSettingsScreenState extends State<SyncSettingsScreen> {
  Timer? _refreshTimer;
  String _localIp = 'Loading...';
  int _connectedPeers = 0;
  int _currentChangeSeq = 0;
  int _pendingOps = 0;
  Map<String, dynamic> _diagnostics = {};
  final TextEditingController _itemController = TextEditingController();
  List<Item> _testItems = [];

  @override
  void initState() {
    super.initState();
    _fetchLocalIp();
    _refreshStats();
    _refreshTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      _refreshStats();
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _itemController.dispose();
    super.dispose();
  }

  Future<void> _fetchLocalIp() async {
    try {
      final interfaces = await NetworkInterface.list(
          type: InternetAddressType.IPv4, includeLinkLocal: false);
      if (interfaces.isNotEmpty) {
        final address = interfaces.first.addresses.first.address;
        if (mounted) {
          setState(() {
            _localIp = address;
          });
          debugPrint('SyncSettingsScreen Init: Device ID: \${syncInitializer?.deviceId}, Local IP: \$_localIp');
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _localIp = 'Unknown';
        });
      }
    }
  }

  Future<void> _refreshStats() async {
    if (syncInitializer == null) return;
    
    final isar = syncInitializer!.isarService.isar;
    final deviceId = syncInitializer!.deviceId;

    try {
      final peersCount = await isar.peerStates
          .filter()
          .healthStatusEqualTo('healthy')
          .count();

      final maxLog = await isar.changeLogs
          .where()
          .sortByChangeSeqDesc()
          .findFirst();
      final changeSeq = maxLog?.changeSeq ?? 0;

      final pendingCount = await isar.changeLogs
          .filter()
          .syncedEqualTo(false)
          .and()
          .originDeviceIdEqualTo(deviceId)
          .count();

      final diags = await syncInitializer!.discoveryService.getDiscoveryDiagnostics();

      // Retrieve all local items from Isar to display
      final items = await isar.items.where().findAll();

      debugPrint('SyncSettingsScreen: Connected Peers: $peersCount, Current ChangeSeq: $changeSeq, Pending Ops: $pendingCount (isarHash=${isar.hashCode})');

      if (mounted) {
        setState(() {
          _connectedPeers = peersCount;
          _currentChangeSeq = changeSeq;
          _pendingOps = pendingCount;
          _diagnostics = diags;
          _testItems = items;
        });
      }
    } catch (e) {
      debugPrint('Error refreshing sync stats: $e');
    }
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: ListTile(
        leading: Icon(icon, color: Colors.indigo, size: 32),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        trailing: Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (syncInitializer == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('LAN Sync Settings')),
        body: const Center(child: Text('Sync architecture is not initialized.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('LAN Sync Settings'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshStats,
          )
        ],
      ),
      body: ListenableBuilder(
        listenable: syncInitializer!.statusNotifier,
        builder: (context, _) {
          final status = syncInitializer!.statusNotifier.status;
          final isSyncing = status == SyncStatus.syncing;

          return ListView(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            children: [
              _buildStatCard('Sync Status', status.name.toUpperCase(), Icons.cloud),
              _buildStatCard('Device ID', syncInitializer!.deviceId.split('-').first, Icons.perm_device_information),
              _buildStatCard('Local IP', _localIp, Icons.wifi),
              _buildStatCard('Connected Peers', '$_connectedPeers', Icons.people),
              _buildStatCard('Current ChangeSeq', '$_currentChangeSeq', Icons.history),
              _buildStatCard('Pending Operations', '$_pendingOps', Icons.pending_actions),
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
                child: Text('Discovery Diagnostics', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.indigo)),
              ),
              _buildStatCard('mDNS Advertiser', _diagnostics['advertiserRunning'] == true ? '✅ Running' : '⛔ Stopped', Icons.broadcast_on_personal),
              _buildStatCard('Advertised Name', '${_diagnostics['advertisedServiceName'] ?? '-'}', Icons.label),
              _buildStatCard('Advertised Type', '${_diagnostics['advertisedServiceType'] ?? '-'}', Icons.label_important),
              _buildStatCard('Advertised Port', '${_diagnostics['advertisedPort'] ?? 0}', Icons.settings_ethernet),
              _buildStatCard('mDNS Discovery', _diagnostics['discoveryRunning'] == true ? '✅ Running' : '⛔ Stopped', Icons.search),
              _buildStatCard('Advertised Count', '${_diagnostics['advertisedServiceCount'] ?? 0}', Icons.podcasts),
              _buildStatCard('Discovered Services', '${_diagnostics['discoveredServiceCount'] ?? 0}', Icons.radar),
              _buildStatCard('Registered DB Peers', '${_diagnostics['registeredPeerCount'] ?? 0}', Icons.dns),
              _buildStatCard('Healthy Peers (DB)', '${_diagnostics['healthyPeerCount'] ?? 0}', Icons.check_circle),
              _buildStatCard('Last Health Check', '${_diagnostics['lastHealthCheckResult'] ?? 'none'}', Icons.monitor_heart),
              if ((_diagnostics['lastHealthCheckError'] ?? '').toString().isNotEmpty)
                _buildStatCard('Last Health Error', '${_diagnostics['lastHealthCheckError'] ?? ''}', Icons.error_outline),
              _buildStatCard('Last Resolved IP', '${_diagnostics['lastResolvedIp'] ?? '-'}', Icons.lan),
              _buildStatCard('Last Resolved Port', '${_diagnostics['lastResolvedPort'] ?? 0}', Icons.router),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: ElevatedButton.icon(
                  onPressed: isSyncing
                      ? null
                      : () {
                          syncInitializer!.syncEngine.triggerSync();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Manual sync triggered')),
                          );
                        },
                  icon: isSyncing 
                      ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.sync),
                  label: Text(isSyncing ? 'Syncing...' : 'Sync Now', style: const TextStyle(fontSize: 16)),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
                child: Text(
                  'Test Items (LAN Sync Verification)',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.indigo),
                ),
              ),
              Card(
                margin: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _itemController,
                              decoration: const InputDecoration(
                                labelText: 'New Item Name',
                                border: OutlineInputBorder(),
                                isDense: true,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () async {
                              final name = _itemController.text.trim();
                              if (name.isNotEmpty) {
                                final item = Item()
                                  ..name = name
                                  ..version = 1
                                  ..updatedAt = DateTime.now().millisecondsSinceEpoch
                                  ..deviceId = syncInitializer!.deviceId
                                  ..isDeleted = false;
                                await syncInitializer!.isarService.saveItem(item);
                                _itemController.clear();
                                _refreshStats();
                                if (!context.mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Created item "$name"')),
                                );
                              }
                            },
                            child: const Text('Add'),
                          )
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (_testItems.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8.0),
                          child: Text('No items in local DB.', style: TextStyle(color: Colors.grey)),
                        )
                      else
                        // Column avoids the nested-ListView semantics/hit-test lifecycle
                        // mismatch that causes RenderIndexedSemantics exceptions during
                        // rapid rebuilds. shrinkWrap+NeverScrollableScrollPhysics already
                        // made the ListView behave identically to a Column.
                        Column(
                          children: _testItems.map((item) {
                            final displayStatus = item.isDeleted ? 'Deleted (Tombstone)' : 'Active';
                            final textStyle = item.isDeleted
                                ? const TextStyle(decoration: TextDecoration.lineThrough, color: Colors.grey)
                                : const TextStyle(fontWeight: FontWeight.bold);

                            return ListTile(
                              title: Text(item.name, style: textStyle),
                              subtitle: Text(
                                'ID: ${item.id} | Ver: ${item.version} | Status: $displayStatus\n'
                                'Device: ${item.deviceId.split("-").first}',
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit, color: Colors.blue),
                                    onPressed: item.isDeleted
                                        ? null
                                        : () => _showEditDialog(item),
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      item.isDeleted ? Icons.restore : Icons.delete,
                                      color: item.isDeleted ? Colors.green : Colors.red,
                                    ),
                                    onPressed: () async {
                                      if (item.isDeleted) {
                                        item.isDeleted = false;
                                        item.version += 1;
                                        await syncInitializer!.isarService.saveItem(item);
                                        _refreshStats();
                                        if (!context.mounted) return;
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text('Restored item "${item.name}"')),
                                        );
                                      } else {
                                        await syncInitializer!.isarService.deleteItem(item.id);
                                        _refreshStats();
                                        if (!context.mounted) return;
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text('Deleted item "${item.name}" (Tombstone)')),
                                        );
                                      }
                                    },
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _showEditDialog(Item item) async {
    final controller = TextEditingController(text: item.name);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Item Name'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(labelText: 'Item Name'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final newName = controller.text.trim();
                if (newName.isNotEmpty) {
                  item.name = newName;
                  item.version += 1;
                  await syncInitializer!.isarService.saveItem(item);
                  if (!context.mounted) return;
                  Navigator.pop(context);
                  _refreshStats();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Updated item to "$newName"')),
                  );
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}
