import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
import 'package:uuid/uuid.dart';

import '../models/peer_device.dart';
import '../models/pairing_request.dart';

/// Manages the device registry and pairing lifecycle.
///
/// Responsible for:
///   • Registering newly discovered devices
///   • Tracking device health and connection status
///   • Pairing/unpairing trusted devices
///   • Enforcing trust boundaries (only paired devices may sync)
class DeviceRegistry {
  final Isar isar;

  DeviceRegistry({required this.isar});

  // -----------------------------------------------------------------------
  // Device CRUD
  // -----------------------------------------------------------------------

  /// Upserts a device record.
  ///
  /// If the device is already known (by [PeerDevice.deviceId]), updates
  /// its IP and last-seen timestamp. Otherwise creates a new entry.
  ///
  /// New devices start as un-paired (trusted=false).
  Future<PeerDevice> upsertDevice({
    required String deviceId,
    required String deviceName,
    required String platform,
    required String appVersion,
    required String ip,
    required int port,
    String? osVersion,
  }) async {
    PeerDevice? device;

    await isar.writeTxn(() async {
      device =
          await isar.peerDevices.filter().deviceIdEqualTo(deviceId).findFirst();

      if (device == null) {
        device = PeerDevice()
          ..deviceId = deviceId
          ..deviceName = deviceName
          ..platform = platform
          ..appVersion = appVersion
          ..lastKnownIp = ip
          ..lastKnownPort = port
          ..lastSeenMs = DateTime.now().millisecondsSinceEpoch
          ..connectionStatus = 'unknown'
          ..isPaired = false
          ..registeredAtMs = DateTime.now().millisecondsSinceEpoch
          ..osVersion = osVersion
          // Dart bool defaults to false; set permission flags explicitly so
          // that getAutoSyncTargets() correctly returns this device after pairing.
          ..receiveEnabled = true
          ..sendEnabled = true
          ..autoSyncEnabled = true;

        debugPrint(
            '[DeviceRegistry]: ✨ new device registered: $deviceId ($deviceName)');
      } else {
        device!.lastKnownIp = ip;
        device!.lastKnownPort = port;
        device!.lastSeenMs = DateTime.now().millisecondsSinceEpoch;
        device!.deviceName = deviceName;
        device!.appVersion = appVersion;
        device!.osVersion = osVersion ?? device!.osVersion;
      }

      await isar.peerDevices.put(device!);
    });

    return device!;
  }

  /// Returns all known devices.
  Future<List<PeerDevice>> getAllDevices() =>
      isar.peerDevices.where().findAll();

  /// Returns only paired (trusted) devices.
  Future<List<PeerDevice>> getPairedDevices() =>
      isar.peerDevices.filter().isPairedEqualTo(true).findAll();

  /// Returns the device record for [deviceId], if it exists.
  Future<PeerDevice?> getDevice(String deviceId) =>
      isar.peerDevices.filter().deviceIdEqualTo(deviceId).findFirst();

  /// Returns all paired devices with [autoSyncEnabled = true].
  Future<List<PeerDevice>> getAutoSyncTargets() {
    return isar.peerDevices
        .filter()
        .isPairedEqualTo(true)
        .and()
        .autoSyncEnabledEqualTo(true)
        .findAll();
  }

  // -----------------------------------------------------------------------
  // Connection status
  // -----------------------------------------------------------------------

  Future<void> setConnectionStatus(String deviceId, String status) async {
    await isar.writeTxn(() async {
      final device =
          await isar.peerDevices.filter().deviceIdEqualTo(deviceId).findFirst();
      if (device != null) {
        device.connectionStatus = status;
        device.lastSeenMs = DateTime.now().millisecondsSinceEpoch;
        await isar.peerDevices.put(device);
      }
    });
  }

  /// Refreshes the stored network endpoint for a peer after a successful
  /// reachability check or re-discovery.
  Future<void> refreshConnection({
    required String deviceId,
    required String ip,
    required int port,
    String status = 'reachable',
  }) async {
    await isar.writeTxn(() async {
      final device =
          await isar.peerDevices.filter().deviceIdEqualTo(deviceId).findFirst();
      if (device != null) {
        if (ip.isNotEmpty) {
          device.lastKnownIp = ip;
        }
        device.lastKnownPort = port;
        device.connectionStatus = status;
        device.lastSeenMs = DateTime.now().millisecondsSinceEpoch;
        await isar.peerDevices.put(device);
      }
    });
  }

  Future<void> markLastSync(String deviceId) async {
    await isar.writeTxn(() async {
      final device =
          await isar.peerDevices.filter().deviceIdEqualTo(deviceId).findFirst();
      if (device != null) {
        device.lastSyncMs = DateTime.now().millisecondsSinceEpoch;
        await isar.peerDevices.put(device);
      }
    });
  }

  // -----------------------------------------------------------------------
  // Pairing
  // -----------------------------------------------------------------------

  /// Marks a device as paired and trusted.
  ///
  /// Also ensures [receiveEnabled], [sendEnabled], and [autoSyncEnabled] are
  /// set to true. This acts as a migration for devices already in the
  /// database that may have been registered with false defaults before the
  /// upsertDevice fix. Without this, a freshly-paired device would still be
  /// skipped by getAutoSyncTargets() until the user manually toggled the flags.
  Future<void> pairDevice(String deviceId) async {
    await isar.writeTxn(() async {
      final device =
          await isar.peerDevices.filter().deviceIdEqualTo(deviceId).findFirst();
      if (device != null) {
        device.isPaired = true;
        device.pairedAtMs = DateTime.now().millisecondsSinceEpoch;
        // Ensure permission flags are true — a device stored with false defaults
        // (before the upsertDevice fix) would otherwise never appear in
        // getAutoSyncTargets() and would silently skip all automatic syncing.
        device.receiveEnabled = true;
        device.sendEnabled = true;
        device.autoSyncEnabled = true;
        await isar.peerDevices.put(device);
        debugPrint('[DeviceRegistry]: ✅ Device $deviceId is now paired');
      } else {
        debugPrint(
            '[DeviceRegistry]: ⚠ pairDevice($deviceId) called but device is not in the registry yet — call upsertDevice first');
      }
    });
  }

  /// Removes trust from a device. Sync will be refused until re-paired.
  Future<void> unpairDevice(String deviceId) async {
    await isar.writeTxn(() async {
      final device =
          await isar.peerDevices.filter().deviceIdEqualTo(deviceId).findFirst();
      if (device != null) {
        device.isPaired = false;
        device.pairedAtMs = null;
        await isar.peerDevices.put(device);
        debugPrint('[DeviceRegistry]: 🔓 Device $deviceId has been unpaired');
      }
    });
  }

  /// Removes a device entirely from the registry.
  Future<void> removeDevice(String deviceId) async {
    await isar.writeTxn(() async {
      final device =
          await isar.peerDevices.filter().deviceIdEqualTo(deviceId).findFirst();
      if (device != null) {
        await isar.peerDevices.delete(device.id);
        debugPrint(
            '[DeviceRegistry]: 🗑 Device $deviceId removed from registry');
      }
    });
  }

  /// Resolves our own outbound pairing request to [targetDeviceId] once the
  /// peer's accept/reject decision arrives via a pair/respond callback.
  ///
  /// Unlike [respondToPairingRequest] (used for *inbound* requests, matched
  /// by requestId — a value we generated locally), outbound requests must be
  /// matched by the responding peer's deviceId, since the peer has no way of
  /// knowing the requestId we assigned to our own local record.
  Future<void> resolveOutboundRequest(
      String targetDeviceId, bool accepted) async {
    await isar.writeTxn(() async {
      final request = await isar.pairingRequests
          .filter()
          .isInitiatorEqualTo(true)
          .and()
          .targetDeviceIdEqualTo(targetDeviceId)
          .and()
          .statusEqualTo('pending')
          .findFirst();

      if (request == null) {
        debugPrint(
            '[DeviceRegistry]: ⚠ resolveOutboundRequest($targetDeviceId) — no matching pending outbound request found');
        return;
      }

      request.status = accepted ? 'accepted' : 'rejected';
      request.respondedAtMs = DateTime.now().millisecondsSinceEpoch;
      await isar.pairingRequests.put(request);
    });

    if (accepted) {
      await pairDevice(targetDeviceId);
    }
  }

  /// Renames a paired device.
  Future<void> renameDevice(String deviceId, String newName) async {
    await isar.writeTxn(() async {
      final device =
          await isar.peerDevices.filter().deviceIdEqualTo(deviceId).findFirst();
      if (device != null) {
        device.deviceName = newName;
        await isar.peerDevices.put(device);
      }
    });
  }

  // -----------------------------------------------------------------------
  // Permissions
  // -----------------------------------------------------------------------

  Future<void> updatePermissions(
    String deviceId, {
    bool? receiveEnabled,
    bool? sendEnabled,
    bool? autoSyncEnabled,
  }) async {
    await isar.writeTxn(() async {
      final device =
          await isar.peerDevices.filter().deviceIdEqualTo(deviceId).findFirst();
      if (device != null) {
        if (receiveEnabled != null) device.receiveEnabled = receiveEnabled;
        if (sendEnabled != null) device.sendEnabled = sendEnabled;
        if (autoSyncEnabled != null) device.autoSyncEnabled = autoSyncEnabled;
        await isar.peerDevices.put(device);
      }
    });
  }

  // -----------------------------------------------------------------------
  // Pairing requests
  // -----------------------------------------------------------------------

  /// Records a pairing request — either one we received (isInitiator:
  /// false, `initiator*` fields describe the remote sender) or one we sent
  /// (isInitiator: true, `initiator*` fields describe ourselves and
  /// `target*` fields describe the peer we're waiting on).
  ///
  /// [initiatorPort] should be populated whenever we're recording an
  /// *inbound* request (isInitiator: false) so we have a way to call the
  /// sender back once the user accepts/rejects. For outbound requests
  /// (isInitiator: true) it isn't needed since the initiator IS us.
  Future<PairingRequest> recordPairingRequest({
    required String initiatorDeviceId,
    required String initiatorDeviceName,
    required String initiatorPlatform,
    required String initiatorIp,
    int? initiatorPort,
    bool isInitiator = false,
    String? targetDeviceId,
    String? targetDeviceName,
  }) async {
    // Pairing requests are retried when a response is delayed.  Keep one
    // pending record per direction/device instead of filling the UI with
    // duplicates and making callback resolution ambiguous.
    final existing = await (isInitiator
        ? isar.pairingRequests
            .filter()
            .isInitiatorEqualTo(true)
            .and()
            .targetDeviceIdEqualTo(targetDeviceId ?? '')
            .and()
            .statusEqualTo('pending')
            .findFirst()
        : isar.pairingRequests
            .filter()
            .isInitiatorEqualTo(false)
            .and()
            .initiatorDeviceIdEqualTo(initiatorDeviceId)
            .and()
            .statusEqualTo('pending')
            .findFirst());
    if (existing != null) return existing;

    final request = PairingRequest()
      ..requestId = const Uuid().v4()
      ..initiatorDeviceId = initiatorDeviceId
      ..initiatorDeviceName = initiatorDeviceName
      ..initiatorPlatform = initiatorPlatform
      ..initiatorIp = initiatorIp
      ..initiatorPort = initiatorPort
      ..targetDeviceId = targetDeviceId
      ..targetDeviceName = targetDeviceName
      ..status = 'pending'
      ..receivedAtMs = DateTime.now().millisecondsSinceEpoch
      ..isInitiator = isInitiator;

    await isar.writeTxn(() => isar.pairingRequests.put(request));
    return request;
  }

  /// Marks an outbound request as failed when it could not be delivered.
  /// This avoids a permanently pending request that the peer never received.
  Future<void> failOutboundRequest(String targetDeviceId) async {
    await isar.writeTxn(() async {
      final request = await getOutboundRequestFor(targetDeviceId);
      if (request != null) {
        request.status = 'failed';
        request.respondedAtMs = DateTime.now().millisecondsSinceEpoch;
        await isar.pairingRequests.put(request);
      }
    });
  }

  Future<List<PairingRequest>> getPendingPairingRequests() =>
      isar.pairingRequests.filter().statusEqualTo('pending').findAll();

  /// Finds the pending outbound request we sent to [targetDeviceId], if any.
  ///
  /// Used when a pair/response callback arrives, to resolve which of our
  /// own outbound requests it corresponds to (matched by the responding
  /// peer's deviceId rather than requestId, since the response comes from
  /// the peer's own request record, not ours).
  Future<PairingRequest?> getOutboundRequestFor(String targetDeviceId) {
    return isar.pairingRequests
        .filter()
        .isInitiatorEqualTo(true)
        .and()
        .targetDeviceIdEqualTo(targetDeviceId)
        .and()
        .statusEqualTo('pending')
        .findFirst();
  }

  Future<void> respondToPairingRequest(String requestId, bool accept) async {
    await isar.writeTxn(() async {
      final request = await isar.pairingRequests
          .filter()
          .requestIdEqualTo(requestId)
          .findFirst();
      if (request != null) {
        request.status = accept ? 'accepted' : 'rejected';
        request.respondedAtMs = DateTime.now().millisecondsSinceEpoch;
        await isar.pairingRequests.put(request);
      }
    });
  }

  // -----------------------------------------------------------------------
  // Trust check
  // -----------------------------------------------------------------------

  /// Returns true if [deviceId] is currently paired and trusted.
  Future<bool> isTrusted(String deviceId) async {
    final device =
        await isar.peerDevices.filter().deviceIdEqualTo(deviceId).findFirst();
    return device?.isPaired ?? false;
  }
}
