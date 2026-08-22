import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:nsd/nsd.dart' as nsd;

import 'device_registry.dart';
import 'sync_manager.dart';

/// Discovers peers on the local network using mDNS/Bonjour (NSD).
///
/// Also runs periodic health checks and a /24 subnet fallback probe
/// for environments where mDNS multicast is blocked.
///
/// Every discovered device is registered in [DeviceRegistry].
/// Only paired devices will be synced — discovery only populates the registry.
class DeviceDiscoveryService {
  static const String _serviceType = '_ssmasync2._tcp';
  static const String _serviceVersion = '2';

  final String localDeviceId;
  final String localDeviceName;
  final String localPlatform;
  final String localAppVersion;
  final int port;
  final DeviceRegistry deviceRegistry;
  final SyncManager syncManager;

  nsd.Registration? _registration;
  nsd.Discovery? _discovery;
  Timer? _healthCheckTimer;
  Timer? _periodicSyncTimer;

  bool _isRunning = false;

  DeviceDiscoveryService({
    required this.localDeviceId,
    required this.localDeviceName,
    required this.localPlatform,
    required this.localAppVersion,
    required this.port,
    required this.deviceRegistry,
    required this.syncManager,
  });

  // -----------------------------------------------------------------------
  // Lifecycle
  // -----------------------------------------------------------------------

  Future<void> start() async {
    if (_isRunning) return;
    _isRunning = true;

    await _registerService();

    // Android NsdManager race: wait before starting discovery
    await Future.delayed(const Duration(seconds: 2));
    await _startDiscovery();

    // Periodic health checks every 15 seconds
    _healthCheckTimer =
        Timer.periodic(const Duration(seconds: 15), (_) => _runHealthChecks());

    // Periodic auto-sync every 30 seconds
    _periodicSyncTimer = Timer.periodic(
        const Duration(seconds: 30), (_) => syncManager.syncWithAllPeers());

    // Subnet fallback after 20 seconds if no peers found
    Future.delayed(const Duration(seconds: 20), _subnetFallbackIfNeeded);
  }

  Future<void> stop() async {
    _isRunning = false;
    _healthCheckTimer?.cancel();
    _periodicSyncTimer?.cancel();

    if (_discovery != null) {
      try {
        await nsd.stopDiscovery(_discovery!);
      } catch (_) {}
      _discovery = null;
    }
    if (_registration != null) {
      try {
        await nsd.unregister(_registration!);
      } catch (_) {}
      _registration = null;
    }
  }

  /// Manually triggers a network re-scan for peers.
  Future<void> rescan() async {
    if (!_isRunning) return;
    await _restartDiscovery();
  }

  // -----------------------------------------------------------------------
  // mDNS registration (advertise ourselves)
  // -----------------------------------------------------------------------

  Future<void> _registerService() async {
    try {
      _registration = await nsd.register(nsd.Service(
        name: 'ssma2_$localDeviceId',
        type: _serviceType,
        port: port,
        txt: {
          'deviceId': utf8.encode(localDeviceId),
          'deviceName': utf8.encode(localDeviceName),
          'platform': utf8.encode(localPlatform),
          'appVersion': utf8.encode(localAppVersion),
          'protocolVersion': utf8.encode(_serviceVersion),
        },
      ));
      debugPrint(
          '[Discovery]: ✅ mDNS registered as "ssma2_$localDeviceId" on port $port');
    } catch (e, st) {
      debugPrint('[Discovery]: ❌ mDNS registration failed: $e\n$st');
    }
  }

  // -----------------------------------------------------------------------
  // mDNS discovery (find peers)
  // -----------------------------------------------------------------------

  Future<void> _startDiscovery() async {
    try {
      _discovery = await nsd.startDiscovery(_serviceType,
          ipLookupType: nsd.IpLookupType.any);

      _discovery!
          .addListener(() => _handleDiscoveredServices(_discovery!.services));
      _handleDiscoveredServices(_discovery!.services);

      debugPrint('[Discovery]: ✅ mDNS discovery started for $_serviceType');

      // Re-scan after 3s to catch pre-existing advertisers (Android race)
      await Future.delayed(const Duration(seconds: 3));
      await _restartDiscovery();
    } catch (e, st) {
      debugPrint('[Discovery]: ❌ mDNS discovery failed: $e\n$st');
    }
  }

  Future<void> _restartDiscovery() async {
    if (_discovery != null) {
      try {
        await nsd.stopDiscovery(_discovery!);
      } catch (_) {}
      _discovery = null;
    }
    await Future.delayed(const Duration(milliseconds: 500));
    try {
      _discovery = await nsd.startDiscovery(_serviceType,
          ipLookupType: nsd.IpLookupType.any);
      _discovery!
          .addListener(() => _handleDiscoveredServices(_discovery!.services));
      _handleDiscoveredServices(_discovery!.services);
      debugPrint('[Discovery]: ✅ mDNS re-scan complete');
    } catch (e) {
      debugPrint('[Discovery]: ❌ mDNS re-scan failed: $e');
    }
  }

  void _handleDiscoveredServices(List<nsd.Service> services) {
    for (final service in services) {
      if (service.name == null) continue;
      if (service.name!.contains(localDeviceId)) continue; // skip self

      _resolveAndRegister(service);
    }
  }

  Future<void> _resolveAndRegister(nsd.Service service) async {
    try {
      nsd.Service resolved = service;
      if (resolved.host == null ||
          resolved.addresses == null ||
          resolved.addresses!.isEmpty) {
        resolved = await nsd.resolve(service);
      }

      String? ip = _extractIp(resolved);
      if (ip == null) {
        if (resolved.host != null && !_isIpAddress(resolved.host!)) {
          final addrs = await InternetAddress.lookup(resolved.host!,
              type: InternetAddressType.IPv4);
          if (addrs.isNotEmpty) ip = addrs.first.address;
        } else {
          ip = resolved.host;
        }
      }

      if (ip == null || resolved.port == null) return;

      // Extract metadata from TXT records (NSD returns Uint8List? values — decode to String)
      final txt = resolved.txt ?? {};
      String decodeTxt(String key, String fallback) {
        final bytes = txt[key];
        if (bytes == null) return fallback;
        try {
          return utf8.decode(bytes);
        } catch (_) {
          return fallback;
        }
      }

      final remoteDeviceId = decodeTxt('deviceId', service.name ?? 'unknown');
      final deviceName = decodeTxt('deviceName', 'Unknown Device');
      final platform = decodeTxt('platform', 'unknown');
      final appVersion = decodeTxt('appVersion', '0.0.0');

      await deviceRegistry.upsertDevice(
        deviceId: remoteDeviceId,
        deviceName: deviceName,
        platform: platform,
        appVersion: appVersion,
        ip: ip,
        port: resolved.port!,
      );

      // Health check immediately after discovery
      await _checkPeerHealth(remoteDeviceId, ip, resolved.port!);
    } catch (e, st) {
      debugPrint(
          '[Discovery]: ❌ failed to resolve/register ${service.name}: $e\n$st');
    }
  }

  // -----------------------------------------------------------------------
  // Health checks
  // -----------------------------------------------------------------------

  static String _cleanIp(String ip) {
    var cleaned = ip.trim();
    if (cleaned.startsWith('::ffff:')) {
      cleaned = cleaned.substring(7);
    }
    return cleaned;
  }

  Future<void> _runHealthChecks() async {
    final devices = await deviceRegistry.getAllDevices();
    for (final device in devices) {
      if (device.lastKnownIp.isEmpty) continue;
      await _checkPeerHealth(
          device.deviceId, device.lastKnownIp, device.lastKnownPort);
    }
  }

  Future<void> _checkPeerHealth(String deviceId, String ip, int port) async {
    final cleanedIp = _cleanIp(ip);
    final url = Uri.parse('http://$cleanedIp:$port/sync/v2/health');
    try {
      final response = await http.get(url).timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        await deviceRegistry.refreshConnection(
          deviceId: deviceId,
          ip: cleanedIp,
          port: port,
          status: 'reachable',
        );
      } else {
        await deviceRegistry.setConnectionStatus(deviceId, 'unreachable');
      }
    } catch (_) {
      await deviceRegistry.setConnectionStatus(deviceId, 'unreachable');
    }
  }

  // -----------------------------------------------------------------------
  // Subnet fallback probe
  // -----------------------------------------------------------------------

  Future<void> _subnetFallbackIfNeeded() async {
    final known = await deviceRegistry.getAllDevices();
    if (known.isNotEmpty) return;

    debugPrint(
        '[Discovery]: ⚠ No peers via mDNS — starting /24 subnet probe...');
    await _subnetFallbackProbe();
  }

  Future<void> _subnetFallbackProbe() async {
    try {
      final interfaces = await NetworkInterface.list(
          type: InternetAddressType.IPv4, includeLinkLocal: false);
      String? ownIp;
      for (final iface in interfaces) {
        for (final addr in iface.addresses) {
          final a = addr.address;
          if (a.startsWith('192.168.') ||
              a.startsWith('10.') ||
              a.startsWith('172.')) {
            ownIp = a;
            break;
          }
        }
        if (ownIp != null) break;
      }

      if (ownIp == null) return;
      final parts = ownIp.split('.');
      if (parts.length != 4) return;
      final subnet = '${parts[0]}.${parts[1]}.${parts[2]}';

      final futures = <Future<void>>[];
      for (int i = 1; i <= 254; i++) {
        final ip = '$subnet.$i';
        if (ip == ownIp) continue;
        futures.add(_probeSubnetHost(ip));
      }
      await Future.wait(futures, eagerError: false);
      debugPrint('[Discovery]: ✅ Subnet probe complete');
    } catch (e) {
      debugPrint('[Discovery]: ❌ Subnet probe error: $e');
    }
  }

  Future<void> _probeSubnetHost(String ip) async {
    try {
      final response = await http
          .get(Uri.parse('http://$ip:$port/sync/v2/health'))
          .timeout(const Duration(seconds: 2));
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        final remoteDeviceId = body['deviceId'] as String? ?? 'fallback_$ip';
        if (remoteDeviceId == localDeviceId) return;

        // Avoid creating duplicate fallback entries if device already known
        final existing = await deviceRegistry.getDevice(remoteDeviceId);
        if (existing != null) return;

        await deviceRegistry.upsertDevice(
          deviceId: remoteDeviceId,
          deviceName: body['deviceName'] as String? ?? 'Device @ $ip',
          platform: body['platform'] as String? ?? 'unknown',
          appVersion: body['appVersion'] as String? ?? '0.0.0',
          ip: ip,
          port: port,
        );

        await deviceRegistry.setConnectionStatus(remoteDeviceId, 'reachable');
        debugPrint(
            '[Discovery]: 🎯 Found peer via subnet probe: $ip → $remoteDeviceId');
      }
    } on TimeoutException {
      // Expected for most IPs
    } catch (_) {
      // Connection refused, etc. — silent
    }
  }

  // -----------------------------------------------------------------------
  // Manual connect by IP
  // -----------------------------------------------------------------------

  /// Allows the user to manually connect to a device by IP address.
  Future<bool> connectByIp(String ip, {int? customPort}) async {
    final cleanedIp = _cleanIp(ip);
    final targetPort = customPort ?? port;
    try {
      final response = await http
          .get(Uri.parse('http://$cleanedIp:$targetPort/sync/v2/health'))
          .timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        final remoteDeviceId = body['deviceId'] as String? ?? 'manual_$cleanedIp';
        if (remoteDeviceId == localDeviceId) return false;

        await deviceRegistry.upsertDevice(
          deviceId: remoteDeviceId,
          deviceName: body['deviceName'] as String? ?? 'Device @ $cleanedIp',
          platform: body['platform'] as String? ?? 'unknown',
          appVersion: body['appVersion'] as String? ?? '0.0.0',
          ip: cleanedIp,
          port: targetPort,
        );
        await deviceRegistry.setConnectionStatus(remoteDeviceId, 'reachable');
        debugPrint(
            '[Discovery]: ✅ Manual connect succeeded: $cleanedIp → $remoteDeviceId');
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('[Discovery]: ❌ Manual connect to $cleanedIp failed: $e');
      return false;
    }
  }

  // -----------------------------------------------------------------------
  // Pairing
  // -----------------------------------------------------------------------

  /// Sends an outbound pairing request to a peer discovered on the network.
  ///
  /// POSTs our local device identity to the peer's LocalSyncServer at
  /// `/sync/v2/pair/request`. The receiving device is expected to record
  /// this as an inbound request via `DeviceRegistry.recordPairingRequest`
  /// (isInitiator: false), which then surfaces in that device's own
  /// pending-requests list for the user to accept or reject.
  ///
  /// Returns true only if the peer acknowledged receipt (HTTP 200/201) —
  /// this does NOT mean the peer accepted the pairing, only that the
  /// request was successfully delivered.
  Future<bool> sendPairingRequest(String ip, int port) async {
    final cleanedIp = _cleanIp(ip);
    final url = Uri.parse('http://$cleanedIp:$port/sync/v2/pair/request');
    try {
      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'deviceId': localDeviceId,
              'deviceName': localDeviceName,
              'platform': localPlatform,
              'appVersion': localAppVersion,
              // Our own local sync server port, so the peer knows where to
              // send a pair/response callback once the user acts on it.
              'port': this.port,
            }),
          )
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint('[Discovery]: ✅ Pairing request delivered to $cleanedIp:$port');
        return true;
      }
      debugPrint(
          '[Discovery]: ❌ Pairing request to $cleanedIp:$port rejected: HTTP ${response.statusCode}');
      return false;
    } on TimeoutException {
      debugPrint('[Discovery]: ⏱️ Pairing request to $cleanedIp:$port timed out');
      return false;
    } catch (e) {
      debugPrint('[Discovery]: ❌ Pairing request to $cleanedIp:$port errored: $e');
      return false;
    }
  }

  Future<bool> sendPairingResponse({
    required String ip,
    required int port,
    required bool accept,
  }) async {
    final cleanedIp = _cleanIp(ip);
    final url = Uri.parse('http://$cleanedIp:$port/sync/v2/pair/respond');
    try {
      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'deviceId': localDeviceId,
              'deviceName': localDeviceName,
              'platform': localPlatform,
              'appVersion': localAppVersion,
              'accept': accept,
            }),
          )
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint(
            '[Discovery]: ✅ Pairing response (accept=$accept) delivered to $cleanedIp:$port');
        return true;
      }
      debugPrint(
          '[Discovery]: ❌ Pairing response to $cleanedIp:$port rejected: HTTP ${response.statusCode}');
      return false;
    } on TimeoutException {
      debugPrint('[Discovery]: ⏱️ Pairing response to $cleanedIp:$port timed out');
      return false;
    } catch (e) {
      debugPrint('[Discovery]: ❌ Pairing response to $cleanedIp:$port errored: $e');
      return false;
    }
  }

  // -----------------------------------------------------------------------
  // Diagnostics
  // -----------------------------------------------------------------------

  Future<Map<String, dynamic>> getDiagnostics() async {
    final allDevices = await deviceRegistry.getAllDevices();
    final paired = allDevices.where((d) => d.isPaired).length;
    final reachable =
        allDevices.where((d) => d.connectionStatus == 'reachable').length;

    return {
      'advertiserRunning': _registration != null,
      'discoveryRunning': _discovery != null,
      'serviceType': _serviceType,
      'port': port,
      'totalKnownDevices': allDevices.length,
      'pairedDevices': paired,
      'reachableDevices': reachable,
    };
  }

  // -----------------------------------------------------------------------
  // Helpers
  // -----------------------------------------------------------------------

  String? _extractIp(nsd.Service service) {
    if (service.addresses == null) return null;
    for (final addr in service.addresses!) {
      if (addr.type == InternetAddressType.IPv4) return _cleanIp(addr.address);
    }
    return null;
  }

  bool _isIpAddress(String host) =>
      RegExp(r'^(\d{1,3}\.){3}\d{1,3}$').hasMatch(host);
}
