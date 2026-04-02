import 'dart:async';

import 'package:multicast_dns/multicast_dns.dart';

import 'package:ssma/services/lan_sync/sync_models.dart';

class MdnsDiscoveryService {
  MdnsDiscoveryService({
    required this.deviceId,
    this.serviceType = '_isar_sync._tcp.local',
  });

  final String deviceId;
  final String serviceType;

  final MDnsClient _client = MDnsClient();
  final StreamController<List<SyncPeer>> _peersController =
      StreamController<List<SyncPeer>>.broadcast();

  Timer? _pollTimer;
  List<SyncPeer> _peers = const [];

  Stream<List<SyncPeer>> get peersStream => _peersController.stream;
  List<SyncPeer> get peers => List.unmodifiable(_peers);

  Future<void> start() async {
    await _client.start();
    await _refresh();
    _pollTimer ??=
        Timer.periodic(const Duration(seconds: 10), (_) => _refresh());
  }

  Future<void> stop() async {
    _pollTimer?.cancel();
    _pollTimer = null;
    _client.stop();
    await _peersController.close();
  }

  Future<void> refreshNow() async {
    await _refresh();
  }

  Future<void> _refresh() async {
    final peersByInstance = <String, SyncPeer>{};

    await for (final ptr in _client.lookup<PtrResourceRecord>(
      ResourceRecordQuery.serverPointer(serviceType),
    )) {
      await for (final srv in _client.lookup<SrvResourceRecord>(
        ResourceRecordQuery.service(ptr.domainName),
      )) {
        await for (final address in _client.lookup<IPAddressResourceRecord>(
          ResourceRecordQuery.addressIPv4(srv.target),
        )) {
          final instanceName = ptr.domainName;
          if (instanceName.contains(deviceId)) {
            continue;
          }

          peersByInstance[instanceName] = SyncPeer(
            instanceName: instanceName,
            host: srv.target,
            port: srv.port,
            address: address.address.address,
            lastSeen: DateTime.now().toUtc(),
          );
        }
      }
    }

    _peers = peersByInstance.values.toList()
      ..sort((a, b) => a.instanceName.compareTo(b.instanceName));
    _peersController.add(_peers);
  }
}
