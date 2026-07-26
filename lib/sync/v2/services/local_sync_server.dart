import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart';

import '../models/sync_change_log.dart';
import '../sync_initializer_v2.dart' show syncV2;
import 'change_journal.dart';
import 'change_processor.dart';
import 'cursor_manager.dart';
import 'device_registry.dart';
import 'sync_manager.dart' show SyncStatusV2;

/// The local HTTP server that makes this device a sync endpoint.
///
/// Every device runs this server so that peers can pull from it and push to it.
/// Routes:
///   GET  /sync/v2/health        — liveness probe + device metadata
///   POST /sync/v2/handshake     — protocol negotiation
///   GET  /sync/v2/pull          — incremental pull (paginated)
///   POST /sync/v2/push          — receive a batch of changes
///   POST /sync/v2/pair/request  — initiate pairing
///   POST /sync/v2/pair/respond  — accept / reject pairing
///   GET  /sync/v2/diagnostics   — diagnostic info (debug only)
class LocalSyncServer {
  final int port;
  final String localDeviceId;
  final String localDeviceName;
  final String localPlatform;
  final String localAppVersion;
  final Isar isar;
  final ChangeJournal journal;
  final ChangeProcessor changeProcessor;
  final CursorManager cursorManager;
  final DeviceRegistry deviceRegistry;
  final Future<void> Function(String deviceId)? onPairingAccepted;

  HttpServer? _server;

  LocalSyncServer({
    required this.port,
    required this.localDeviceId,
    required this.localDeviceName,
    required this.localPlatform,
    required this.localAppVersion,
    required this.isar,
    required this.journal,
    required this.changeProcessor,
    required this.cursorManager,
    required this.deviceRegistry,
    this.onPairingAccepted,
  });

  // -----------------------------------------------------------------------
  // Lifecycle
  // -----------------------------------------------------------------------

  Future<void> start() async {
    final router = Router()
      ..get('/sync/v2/health', _healthHandler)
      ..post('/sync/v2/handshake', _handshakeHandler)
      ..get('/sync/v2/pull', _pullHandler)
      ..post('/sync/v2/push', _pushHandler)
      ..post('/sync/v2/pair/request', _pairRequestHandler)
      ..post('/sync/v2/pair/respond', _pairRespondHandler)
      ..get('/sync/v2/diagnostics', _diagnosticsHandler);

    final handler = const Pipeline()
        .addMiddleware(logRequests())
        .addMiddleware(_trustMiddleware())
        .addHandler(router.call);

    _server = await shelf_io.serve(handler, InternetAddress.anyIPv4, port);
    debugPrint(
        '[LocalSyncServer]: ✅ listening on ${_server!.address.address}:${_server!.port}');
  }

  Future<void> stop() async {
    await _server?.close(force: true);
    _server = null;
    debugPrint('[LocalSyncServer]: stopped');
  }

  // -----------------------------------------------------------------------
  // Trust middleware — exempt /health, /handshake, /pair from trust check
  // -----------------------------------------------------------------------

  Middleware _trustMiddleware() {
    return (Handler innerHandler) {
      return (Request request) async {
        final path = request.url.path;

        // These routes are public — required for discovery + pairing bootstrap
        if (path == 'sync/v2/health' ||
            path == 'sync/v2/handshake' ||
            path == 'sync/v2/pair/request' ||
            path == 'sync/v2/pair/respond') {
          return innerHandler(request);
        }

        // All other routes require the caller to be a trusted peer
        final senderDeviceId = request.headers['x-device-id'];
        if (senderDeviceId == null) {
          return Response.forbidden(
              jsonEncode({'error': 'Missing x-device-id header'}),
              headers: {'Content-Type': 'application/json'});
        }

        final trusted = await deviceRegistry.isTrusted(senderDeviceId);
        if (!trusted) {
          debugPrint(
              '[LocalSyncServer]: ⛔ rejected request from untrusted $senderDeviceId');
          return Response.forbidden(
              jsonEncode({'error': 'Device not paired — pairing required'}),
              headers: {'Content-Type': 'application/json'});
        }

        return innerHandler(request);
      };
    };
  }

  // -----------------------------------------------------------------------
  // GET /sync/v2/health
  // -----------------------------------------------------------------------

  Future<Response> _healthHandler(Request request) async {
    final currentSeq = await journal.getCurrentSeq();
    return _json({
      'deviceId': localDeviceId,
      'deviceName': localDeviceName,
      'platform': localPlatform,
      'appVersion': localAppVersion,
      'protocolVersion': 2,
      'currentSeq': currentSeq,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
  }

  // -----------------------------------------------------------------------
  // POST /sync/v2/handshake
  // -----------------------------------------------------------------------

  Future<Response> _handshakeHandler(Request request) async {
    try {
      final body =
          jsonDecode(await request.readAsString()) as Map<String, dynamic>;
      final peerDeviceId = body['deviceId'] as String?;
      final peerProtocol = body['protocolVersion'] as int? ?? 1;

      if (peerDeviceId == null) {
        return Response.badRequest(
            body: jsonEncode({'error': 'deviceId required'}),
            headers: {'Content-Type': 'application/json'});
      }

      if (peerProtocol < 2) {
        return Response(426,
            body: jsonEncode({
              'error': 'Protocol upgrade required. Minimum version: 2',
              'serverProtocol': 2,
            }),
            headers: {'Content-Type': 'application/json'});
      }

      final currentSeq = await journal.getCurrentSeq();
      final cursor = await cursorManager.getLastReceivedSeq(peerDeviceId);

      return _json({
        'deviceId': localDeviceId,
        'deviceName': localDeviceName,
        'platform': localPlatform,
        'appVersion': localAppVersion,
        'protocolVersion': 2,
        'currentSeq': currentSeq,
        'peerLastSeenSeq': cursor,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });
    } catch (e) {
      return Response.internalServerError(
          body: jsonEncode({'error': e.toString()}),
          headers: {'Content-Type': 'application/json'});
    }
  }

  // -----------------------------------------------------------------------
  // GET /sync/v2/pull?since=N&limit=M
  // -----------------------------------------------------------------------

  Future<Response> _pullHandler(Request request) async {
    final since =
        int.tryParse(request.url.queryParameters['since'] ?? '0') ?? 0;
    final limit =
        int.tryParse(request.url.queryParameters['limit'] ?? '200') ?? 200;
    final effectiveLimit = limit.clamp(1, 500);

    final changes = await journal.getChangesSince(since, limit: effectiveLimit);
    final nextCursor = changes.isNotEmpty ? changes.last.changeSeq : since;
    final hasMore = changes.length == effectiveLimit;
    final minSeq = await journal.getMinSeq();

    return _json({
      'changes': changes.map((c) => c.toJson()).toList(),
      'nextCursor': nextCursor,
      'hasMore': hasMore,
      'minSeq': minSeq,
      'currentSeq': await journal.getCurrentSeq(),
    });
  }

  // -----------------------------------------------------------------------
  // POST /sync/v2/push
  // -----------------------------------------------------------------------

  Future<Response> _pushHandler(Request request) async {
    try {
      final body =
          jsonDecode(await request.readAsString()) as Map<String, dynamic>;
      final senderDeviceId = body['senderDeviceId'] as String?;
      final rawChanges = body['changes'] as List<dynamic>? ?? [];

      if (senderDeviceId == null) {
        return Response.badRequest(
            body: jsonEncode({'error': 'senderDeviceId required'}),
            headers: {'Content-Type': 'application/json'});
      }

      // Permission check: does this device allow receiving data from the sender?
      // peer.receiveEnabled is OUR local flag — if false, we reject incoming
      // pushes from that device regardless of what the sender thinks.
      final peer = await deviceRegistry.getDevice(senderDeviceId);
      if (peer != null && !peer.receiveEnabled) {
        return Response.forbidden(
            jsonEncode({
              'error':
                  'receive_disabled — this device has disabled receiving from you'
            }),
            headers: {'Content-Type': 'application/json'});
      }

      final changes = rawChanges
          .map((e) =>
              SyncChangeLog.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();

      final result = await changeProcessor.processBatch(changes);

      if (result.applied > 0) {
        syncV2?.statusNotifier.setStatus(SyncStatusV2.idle);
      }

      return _json({
        'accepted': result.applied,
        'skipped': result.skipped,
        'conflicts': result.conflicts,
        'errors': result.errors,
        'lastProcessedSeq': result.lastProcessedSeq,
        'currentSeq': await journal.getCurrentSeq(),
      });
    } catch (e, st) {
      debugPrint('[LocalSyncServer]: ❌ push handler error: $e\n$st');
      return Response.internalServerError(
          body: jsonEncode({'error': e.toString()}),
          headers: {'Content-Type': 'application/json'});
    }
  }

  // -----------------------------------------------------------------------
  // POST /sync/v2/pair/request
  // -----------------------------------------------------------------------

  static String _cleanIp(String ip) {
    var cleaned = ip.trim();
    if (cleaned.startsWith('::ffff:')) {
      cleaned = cleaned.substring(7);
    }
    return cleaned;
  }

  Future<Response> _pairRequestHandler(Request request) async {
    try {
      final body =
          jsonDecode(await request.readAsString()) as Map<String, dynamic>;
      final initiatorDeviceId = body['deviceId'] as String?;
      final initiatorName = body['deviceName'] as String? ?? 'Unknown';
      final initiatorPlatform = body['platform'] as String? ?? 'unknown';
      final initiatorAppVersion = body['appVersion'] as String? ?? '0.0.0';
      final initiatorPort = body['port'] as int?;

      final connInfo =
          request.context['shelf.io.connection_info'] as HttpConnectionInfo?;
      final rawIp = request.headers['x-forwarded-for'] ??
          connInfo?.remoteAddress.address ??
          'unknown';
      final initiatorIp = _cleanIp(rawIp);

      if (initiatorDeviceId == null) {
        return Response.badRequest(
            body: jsonEncode({'error': 'deviceId required'}),
            headers: {'Content-Type': 'application/json'});
      }

      await deviceRegistry.upsertDevice(
        deviceId: initiatorDeviceId,
        deviceName: initiatorName,
        platform: initiatorPlatform,
        appVersion: initiatorAppVersion,
        ip: initiatorIp,
        port: initiatorPort ?? 8080,
      );

      await deviceRegistry.recordPairingRequest(
        initiatorDeviceId: initiatorDeviceId,
        initiatorDeviceName: initiatorName,
        initiatorPlatform: initiatorPlatform,
        initiatorIp: initiatorIp,
        initiatorPort: initiatorPort,
      );

      debugPrint(
          '[LocalSyncServer]: 🔔 Pairing request from $initiatorDeviceId ($initiatorName)');

      return _json({
        'status': 'pending',
        'message': 'Pairing request received. User approval required.',
      });
    } catch (e) {
      return Response.internalServerError(
          body: jsonEncode({'error': e.toString()}),
          headers: {'Content-Type': 'application/json'});
    }
  }

  // -----------------------------------------------------------------------
  // POST /sync/v2/pair/respond
  // -----------------------------------------------------------------------

  Future<Response> _pairRespondHandler(Request request) async {
    try {
      final body =
          jsonDecode(await request.readAsString()) as Map<String, dynamic>;
      final responderDeviceId = body['deviceId'] as String?;
      final accepted = body['accept'] as bool? ?? false; // matches sender's key

      if (responderDeviceId == null) {
        return Response.badRequest(
            body: jsonEncode({'error': 'deviceId required'}),
            headers: {'Content-Type': 'application/json'});
      }

      await deviceRegistry.resolveOutboundRequest(responderDeviceId, accepted);
      // Pairing is now trusted on both devices: the responder paired the
      // initiator before sending this callback, and resolveOutboundRequest
      // paired the responder locally. Start transfer here so it does not
      // depend on a settings-screen timer or the next periodic sync.
      if (accepted && onPairingAccepted != null) {
        unawaited(onPairingAccepted!(responderDeviceId));
      }

      return _json({'status': accepted ? 'accepted' : 'rejected'});
    } catch (e) {
      return Response.internalServerError(
          body: jsonEncode({'error': e.toString()}),
          headers: {'Content-Type': 'application/json'});
    }
  }

  // -----------------------------------------------------------------------
  // GET /sync/v2/diagnostics (debug only)
  // -----------------------------------------------------------------------

  Future<Response> _diagnosticsHandler(Request request) async {
    if (!kDebugMode) return Response.forbidden('{}');

    final currentSeq = await journal.getCurrentSeq();
    final minSeq = await journal.getMinSeq();
    final allDevices = await deviceRegistry.getAllDevices();

    return _json({
      'deviceId': localDeviceId,
      'currentSeq': currentSeq,
      'minSeq': minSeq,
      'knownDevices': allDevices.length,
      'pairedDevices': allDevices.where((d) => d.isPaired).length,
    });
  }

  // -----------------------------------------------------------------------
  // Helpers
  // -----------------------------------------------------------------------

  Response _json(Map<String, dynamic> body) {
    return Response.ok(
      jsonEncode(body),
      headers: {'Content-Type': 'application/json'},
    );
  }
}
