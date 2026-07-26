import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:isar/isar.dart';

import '../models/peer_device.dart';
import '../models/sync_change_log.dart';
import 'change_journal.dart';
import 'change_processor.dart';
import 'cursor_manager.dart';
import 'device_registry.dart';

class _PhaseResult {
  final int count;
  final int errors;
  _PhaseResult(this.count, this.errors);
}

/// The result of a full push+pull sync with one peer.
class SyncCycleResult {
  final String peerDeviceId;
  final bool success;
  final int changesSent;
  final int changesReceived;
  final int unresolvedErrors;
  final Duration duration;
  final String? errorMessage;

  const SyncCycleResult({
    required this.peerDeviceId,
    required this.success,
    required this.changesSent,
    required this.changesReceived,
    this.unresolvedErrors = 0,
    required this.duration,
    this.errorMessage,
  });

  @override
  String toString() =>
      'SyncCycleResult(peer=$peerDeviceId success=$success sent=$changesSent recv=$changesReceived errors=$unresolvedErrors '
      'duration=${duration.inMilliseconds}ms error=$errorMessage)';
}

/// The high-level sync orchestrator.
///
/// Coordinates pull → apply → push → commit for each paired peer.
///
/// Key guarantees:
///   • Cursors are only advanced after both sides acknowledge success.
///   • Interrupted sync resumes from the last committed cursor on next attempt.
///   • Each batch is paginated — no memory exhaustion with large histories.
///   • Each change is idempotent — duplicates are safely ignored.
///   • Only paired/trusted devices may sync.
class SyncManager {
  final Isar isar;
  final String localDeviceId;
  final ChangeJournal journal;
  final CursorManager cursorManager;
  final DeviceRegistry deviceRegistry;
  final ChangeProcessor changeProcessor;
  final SyncStatusNotifierV2 statusNotifier;

  static const int _batchSize = 200;
  static const int _maxRetries = 3;
  static const Duration _retryBackoffBase = Duration(seconds: 2);

  bool _isSyncing = false;
  Future<void>? _syncQueueTail;
  Completer<List<SyncCycleResult>>? _pendingSyncAllCompleter;

  SyncManager({
    required this.isar,
    required this.localDeviceId,
    required this.journal,
    required this.cursorManager,
    required this.deviceRegistry,
    required this.changeProcessor,
    required this.statusNotifier,
  });

  // -----------------------------------------------------------------------
  // Helper for IP cleaning (removes IPv6-mapped IPv4 prefix ::ffff:)
  // -----------------------------------------------------------------------

  static String _cleanIp(String ip) {
    var cleaned = ip.trim();
    if (cleaned.startsWith('::ffff:')) {
      cleaned = cleaned.substring(7);
    }
    return cleaned;
  }

  // -----------------------------------------------------------------------
  // Public API with Async Execution Queuing
  // -----------------------------------------------------------------------

  bool get isSyncing => _isSyncing;

  /// Enqueues a sync task onto the FIFO execution queue so concurrent requests
  /// are processed sequentially rather than being silently dropped.
  Future<T> _enqueueSyncTask<T>(Future<T> Function() taskAction) async {
    final previousTail = _syncQueueTail;
    final taskCompleter = Completer<void>();
    _syncQueueTail = taskCompleter.future;

    if (previousTail != null) {
      try {
        await previousTail;
      } catch (_) {}
    }

    _isSyncing = true;
    statusNotifier.setStatus(SyncStatusV2.syncing);

    try {
      return await taskAction();
    } finally {
      taskCompleter.complete();
      if (_syncQueueTail == taskCompleter.future) {
        _isSyncing = false;
      }
    }
  }

  /// Triggers a sync with all paired peers.
  ///
  /// When [respectAutoSyncFlag] is true, only devices with auto-sync enabled
  /// are included. Manual "Sync Now" flows can pass false to sync every paired
  /// device regardless of its auto-sync toggle.
  Future<List<SyncCycleResult>> syncWithAllPeers(
      {bool respectAutoSyncFlag = true}) async {
    // Coalesce duplicate queued requests for syncWithAllPeers while a sync task is waiting in line
    if (_pendingSyncAllCompleter != null &&
        !_pendingSyncAllCompleter!.isCompleted) {
      debugPrint(
          '[SyncManager]: syncWithAllPeers request coalesced into existing queued task');
      return _pendingSyncAllCompleter!.future;
    }

    final completer = Completer<List<SyncCycleResult>>();
    _pendingSyncAllCompleter = completer;

    _enqueueSyncTask(() async {
      try {
        final res =
            await _doSyncWithAllPeers(respectAutoSyncFlag: respectAutoSyncFlag);
        if (!completer.isCompleted) completer.complete(res);
        return res;
      } catch (e, st) {
        if (!completer.isCompleted) completer.completeError(e, st);
        rethrow;
      } finally {
        if (_pendingSyncAllCompleter == completer) {
          _pendingSyncAllCompleter = null;
        }
      }
    });

    return completer.future;
  }

  Future<List<SyncCycleResult>> _doSyncWithAllPeers(
      {bool respectAutoSyncFlag = true}) async {
    final results = <SyncCycleResult>[];

    try {
      final peers = respectAutoSyncFlag
          ? await deviceRegistry.getAutoSyncTargets()
          : await deviceRegistry.getPairedDevices();
      debugPrint('[SyncManager]: starting sync with ${peers.length} peer(s) '
          '(respectAutoSyncFlag=$respectAutoSyncFlag)');

      for (final peer in peers) {
        final result = await _syncWithPeer(peer);
        results.add(result);
      }

      final anySuccess = results.any((r) => r.success);
      final anyFailure = results.any((r) => !r.success);
      if (results.isEmpty || (anySuccess && !anyFailure)) {
        statusNotifier.setStatus(SyncStatusV2.idle);
      } else if (anySuccess && anyFailure) {
        // Some peers synced, some failed — report partial error so the UI
        // doesn't silently hide the failing peers.
        final failedPeers = results
            .where((r) => !r.success)
            .map((r) => r.peerDeviceId)
            .join(', ');
        statusNotifier.setStatus(SyncStatusV2.error,
            error: 'Partial sync failure — failed peers: $failedPeers');
      } else {
        statusNotifier.setStatus(SyncStatusV2.error);
      }
    } catch (e, st) {
      debugPrint('[SyncManager]: ❌ syncWithAllPeers error: $e\n$st');
      statusNotifier.setStatus(SyncStatusV2.error);
    }

    return results;
  }

  /// Triggers a sync with a specific peer by device ID.
  Future<SyncCycleResult> syncWithDevice(String deviceId) async {
    return _enqueueSyncTask(() => _doSyncWithDevice(deviceId));
  }

  Future<SyncCycleResult> _doSyncWithDevice(String deviceId) async {
    try {
      final peer = await deviceRegistry.getDevice(deviceId);
      if (peer == null) {
        const message = 'Device not found in registry';
        statusNotifier.setStatus(SyncStatusV2.error, error: message);
        return SyncCycleResult(
          peerDeviceId: deviceId,
          success: false,
          changesSent: 0,
          changesReceived: 0,
          duration: Duration.zero,
          errorMessage: message,
        );
      }
      final result = await _syncWithPeer(peer);
      statusNotifier.setStatus(
          result.success ? SyncStatusV2.idle : SyncStatusV2.error,
          error: result.errorMessage);
      return result;
    } catch (e, st) {
      debugPrint('[SyncManager]: ❌ manual sync error: $e\n$st');
      statusNotifier.setStatus(SyncStatusV2.error, error: e.toString());
      return SyncCycleResult(
        peerDeviceId: deviceId,
        success: false,
        changesSent: 0,
        changesReceived: 0,
        duration: Duration.zero,
        errorMessage: e.toString(),
      );
    }
  }

  // -----------------------------------------------------------------------
  // Sync cycle (per peer)
  // -----------------------------------------------------------------------

  Future<SyncCycleResult> _syncWithPeer(PeerDevice peer) async {
    final startTime = DateTime.now();
    final cleanedIp = _cleanIp(peer.lastKnownIp);
    int totalSent = 0;
    int totalReceived = 0;
    int totalErrors = 0;

    debugPrint(
        '[SyncManager]: → starting sync with ${peer.deviceId} ($cleanedIp:${peer.lastKnownPort})');

    // Trust check
    if (!peer.isPaired) {
      debugPrint('[SyncManager]: ⛔ ${peer.deviceId} is not paired — skipping');
      return SyncCycleResult(
        peerDeviceId: peer.deviceId,
        success: false,
        changesSent: 0,
        changesReceived: 0,
        duration: DateTime.now().difference(startTime),
        errorMessage: 'Device is not paired',
      );
    }

    // Permission check
    if (!peer.receiveEnabled && !peer.sendEnabled) {
      debugPrint(
          '[SyncManager]: ⛔ ${peer.deviceId} has both send and receive disabled — skipping');
      return SyncCycleResult(
        peerDeviceId: peer.deviceId,
        success: false,
        changesSent: 0,
        changesReceived: 0,
        duration: DateTime.now().difference(startTime),
        errorMessage: 'All sync permissions disabled for this device',
      );
    }

    await deviceRegistry.setConnectionStatus(peer.deviceId, 'syncing');

    // Phase 1: Handshake — Fast failure if unreachable/offline
    final handshakeOk = await _handshake(peer);
    if (!handshakeOk) {
      debugPrint('[SyncManager]: ❌ handshake failed with ${peer.deviceId}');
      await deviceRegistry.setConnectionStatus(peer.deviceId, 'unreachable');
      return SyncCycleResult(
        peerDeviceId: peer.deviceId,
        success: false,
        changesSent: 0,
        changesReceived: 0,
        duration: DateTime.now().difference(startTime),
        errorMessage: 'Handshake failed — unreachable or incompatible peer',
      );
    }
    debugPrint('[SyncManager]: ✅ handshake result with ${peer.deviceId}');

    for (int attempt = 1; attempt <= _maxRetries; attempt++) {
      try {
        // Phase 2: Pull (receive changes from peer)
        if (peer.receiveEnabled) {
          final res = await _pullPhase(peer);
          totalReceived = res.count;
          totalErrors += res.errors;
        }

        // Phase 3: Push (send our changes to peer)
        if (peer.sendEnabled) {
          final res = await _pushPhase(peer);
          totalSent = res.count;
          totalErrors += res.errors;
        }

        // Phase 4: Commit (update cursors and mark full sync)
        await cursorManager.recordFullSync(peer.deviceId);
        await deviceRegistry.markLastSync(peer.deviceId);
        await deviceRegistry.setConnectionStatus(peer.deviceId, 'reachable');

        final duration = DateTime.now().difference(startTime);
        debugPrint(
            '[SyncManager]: ✅ sync with ${peer.deviceId} complete — sent=$totalSent recv=$totalReceived errors=$totalErrors in ${duration.inMilliseconds}ms');

        return SyncCycleResult(
          peerDeviceId: peer.deviceId,
          success: totalErrors == 0,
          changesSent: totalSent,
          changesReceived: totalReceived,
          unresolvedErrors: totalErrors,
          duration: duration,
        );
      } catch (e, st) {
        debugPrint(
            '[SyncManager]: ❌ sync attempt $attempt/$_maxRetries with ${peer.deviceId}: $e\n$st');

        if (attempt < _maxRetries) {
          final backoff = _retryBackoffBase * pow(2, attempt - 1).toInt();
          debugPrint('[SyncManager]: retrying in ${backoff.inSeconds}s...');
          await Future.delayed(backoff);
        } else {
          await deviceRegistry.setConnectionStatus(
              peer.deviceId, 'unreachable');
          return SyncCycleResult(
            peerDeviceId: peer.deviceId,
            success: false,
            changesSent: totalSent,
            changesReceived: totalReceived,
            unresolvedErrors: totalErrors,
            duration: DateTime.now().difference(startTime),
            errorMessage: e.toString(),
          );
        }
      }
    }

    return SyncCycleResult(
      peerDeviceId: peer.deviceId,
      success: false,
      changesSent: 0,
      changesReceived: 0,
      unresolvedErrors: 0,
      duration: DateTime.now().difference(startTime),
      errorMessage: 'Exceeded max retries',
    );
  }

  // -----------------------------------------------------------------------
  // Handshake
  // -----------------------------------------------------------------------

  Future<bool> _handshake(PeerDevice peer) async {
    final cleanedIp = _cleanIp(peer.lastKnownIp);
    final url =
        Uri.parse('http://$cleanedIp:${peer.lastKnownPort}/sync/v2/handshake');
    try {
      final response = await http
          .post(
            url,
            headers: {
              'Content-Type': 'application/json',
              'x-device-id': localDeviceId,
            },
            body: jsonEncode({
              'deviceId': localDeviceId,
              'protocolVersion': 2,
              'appVersion': '1.0.0',
            }),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        final peerProtocol = body['protocolVersion'] as int? ?? 1;
        if (peerProtocol < 2) {
          debugPrint(
              '[SyncManager]: ⚠ peer ${peer.deviceId} uses protocol v$peerProtocol < 2 — skipping');
          return false;
        }
        return true;
      }
      return false;
    } on TimeoutException {
      return false;
    } catch (_) {
      return false;
    }
  }

  // -----------------------------------------------------------------------
  // Pull phase
  // -----------------------------------------------------------------------

  /// Pulls all changes from [peer] that are newer than our cursor.
  /// Returns the total number of changes received.
  Future<_PhaseResult> _pullPhase(PeerDevice peer) async {
    int cursor = await cursorManager.getLastReceivedSeq(peer.deviceId);
    int totalReceived = 0;
    int pagesProcessed = 0;
    int totalErrors = 0;

    debugPrint('[SyncManager]: ← PULL from ${peer.deviceId} since seq=$cursor');

    while (true) {
      final cleanedIp = _cleanIp(peer.lastKnownIp);
      final url = Uri.parse(
        'http://$cleanedIp:${peer.lastKnownPort}'
        '/sync/v2/pull?since=$cursor&limit=$_batchSize',
      );

      final response = await http.get(
        url,
        headers: {'x-device-id': localDeviceId},
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode != 200) {
        throw Exception('PULL HTTP ${response.statusCode}: ${response.body}');
      }

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final List<dynamic> rawChanges = body['changes'] ?? [];
      final bool hasMore = body['hasMore'] ?? false;
      final int peerMinSeq = body['minSeq'] ?? 0;

      // Detect compaction gap: peer has pruned the next change we would ask
      // for. A fresh cursor at 0 with peerMinSeq=1 is normal and must pull
      // seq 1, not loop forever resetting to 0.
      final nextRequestedSeq = cursor + 1;
      if (peerMinSeq > 0 && nextRequestedSeq < peerMinSeq) {
        debugPrint(
            '[SyncManager]: ⚠ peer ${peer.deviceId} minSeq=$peerMinSeq > our cursor=$cursor '
            '(peer history was compacted). Resetting to peerMinSeq-1.');
        cursor = peerMinSeq - 1;
        await cursorManager.advanceReceiveCursor(
          remoteDeviceId: peer.deviceId,
          newSeq: cursor,
          changeCount: 0,
        );
        continue;
      }

      final changes = rawChanges
          .map((e) =>
              SyncChangeLog.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();

      if (changes.isNotEmpty) {
        final result = await changeProcessor.processBatch(changes);
        totalReceived += result.applied;
        totalErrors += result.errors;

        // Only a contiguous successfully handled prefix may be acknowledged.
        // Advancing to nextCursor after an error silently loses the failed
        // change and breaks resumable delivery.
        final actualNewSeq = result.lastProcessedSeq;
        if (actualNewSeq > cursor) {
          await cursorManager.advanceReceiveCursor(
            remoteDeviceId: peer.deviceId,
            newSeq: actualNewSeq,
            changeCount: result.applied,
          );
          cursor = actualNewSeq;
        }

        pagesProcessed++;
        debugPrint(
            '[SyncManager]: ← pulled page $pagesProcessed: ${changes.length} changes, cursor now $cursor');

        if (result.errors > 0) {
          debugPrint(
              '[SyncManager]: ← PULL page had ${result.errors} error(s); '
              'leaving the failed entry for retry');
          break;
        }
      }

      if (!hasMore || changes.isEmpty) break;
    }

    debugPrint(
        '[SyncManager]: ← PULL complete: $totalReceived changes from ${peer.deviceId}');
    return _PhaseResult(totalReceived, totalErrors);
  }

  // -----------------------------------------------------------------------
  // Push phase
  // -----------------------------------------------------------------------

  /// Pushes all journal changes that the peer hasn't seen yet.
  ///
  /// The journal intentionally includes changes replayed from other peers.
  /// Sending the full journal lets the P2P network converge even when every
  /// device is not directly connected to every other device. Duplicate
  /// changeIds are ignored by receivers, so echoing a peer's own change back
  /// to it is safe.
  /// Returns the total number of changes sent.
  Future<_PhaseResult> _pushPhase(PeerDevice peer) async {
    final cursor = await cursorManager.getCursor(peer.deviceId);
    int fromSeq = cursor.lastSentSeq;
    int totalSent = 0;
    int totalErrors = 0;

    debugPrint('[SyncManager]: → PUSH to ${peer.deviceId} since seq=$fromSeq');

    while (true) {
      final batch = await journal.getChangesSince(fromSeq, limit: _batchSize);
      if (batch.isEmpty) break;

      final cleanedIp = _cleanIp(peer.lastKnownIp);
      final url =
          Uri.parse('http://$cleanedIp:${peer.lastKnownPort}/sync/v2/push');

      final response = await http
          .post(
            url,
            headers: {
              'Content-Type': 'application/json',
              'x-device-id': localDeviceId,
            },
            body: jsonEncode({
              'senderDeviceId': localDeviceId,
              'changes': batch.map((c) => c.toJson()).toList(),
            }),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode != 200) {
        throw Exception('PUSH HTTP ${response.statusCode}: ${response.body}');
      }

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final int errors = body['errors'] ?? 0;
      final int lastProcessedSeq = body['lastProcessedSeq'] ?? -1;

      int seqToAdvance = batch.last.changeSeq;
      if (errors > 0 && lastProcessedSeq != -1) {
        seqToAdvance = lastProcessedSeq;
      } else if (errors > 0 && lastProcessedSeq == -1) {
        // First change failed, do not advance
        seqToAdvance = fromSeq;
      }

      final acceptedCount = (body['accepted'] as int?) ?? 0;
      final skippedCount = (body['skipped'] as int?) ?? 0;
      final conflictsCount = (body['conflicts'] as int?) ?? 0;
      final actualProcessed = acceptedCount + skippedCount + conflictsCount;

      // Advance our send cursor after peer confirms receipt
      if (seqToAdvance > fromSeq) {
        await cursorManager.advanceSendCursor(
          remoteDeviceId: peer.deviceId,
          newSeq: seqToAdvance,
          changeCount: actualProcessed,
        );
        fromSeq = seqToAdvance;
        totalSent += actualProcessed;
      }

      // Mark acknowledged for changes peer successfully processed
      final idsToAck = batch
          .where((c) => c.changeSeq <= seqToAdvance)
          .map((c) => c.id)
          .toList();
      if (idsToAck.isNotEmpty) {
        await journal.markAcknowledged(idsToAck);
      }

      debugPrint(
          '[SyncManager]: → pushed batch to ${peer.deviceId}, cursor=$fromSeq, errors=$errors');

      if (errors > 0) {
        totalErrors += errors;
        break; // stop pushing if peer reported errors
      }

      if (batch.length < _batchSize) break; // last page
    }

    debugPrint(
        '[SyncManager]: → PUSH complete: $totalSent changes to ${peer.deviceId}');
    return _PhaseResult(totalSent, totalErrors);
  }
}

// ---------------------------------------------------------------------------
// Status notifier
// ---------------------------------------------------------------------------

enum SyncStatusV2 { idle, syncing, offline, error }

class SyncStatusNotifierV2 extends ChangeNotifier {
  SyncStatusV2 _status = SyncStatusV2.idle;
  String? _lastError;
  DateTime? _lastSyncTime;

  SyncStatusV2 get status => _status;
  String? get lastError => _lastError;
  DateTime? get lastSyncTime => _lastSyncTime;

  void setStatus(SyncStatusV2 status, {String? error}) {
    _status = status;
    if (error != null) _lastError = error;
    if (status == SyncStatusV2.idle) {
      _lastSyncTime = DateTime.now();
      // Only clear the error when the sync genuinely completed cleanly.
      // If an error string was passed alongside idle (shouldn't happen, but
      // defensive), preserve it rather than wiping it.
      if (error == null) _lastError = null;
    }
    notifyListeners();
  }
}
