import 'dart:convert';
import 'dart:io';

import 'package:isar/isar.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:ssma/models/change_log.dart';
import 'package:ssma/models/item.dart';
import 'package:ssma/services/db_service.dart';
import 'package:ssma/services/lan_sync/change_tracker_service.dart';
import 'package:ssma/services/lan_sync/sync_models.dart';

class LocalSyncServer {
  LocalSyncServer({
    required this.deviceId,
    this.port = 8080,
    ChangeTrackerService? changeTracker,
  }) : _changeTracker = changeTracker ?? ChangeTrackerService();

  final String deviceId;
  final int port;
  final ChangeTrackerService _changeTracker;

  static const int defaultChunkSize = 100;

  HttpServer? _server;

  bool get isRunning => _server != null;

  Future<void> start() async {
    if (_server != null) {
      return;
    }

    final handler = const Pipeline()
        .addMiddleware(logRequests())
        .addHandler(_handleRequest);

    _server = await shelf_io.serve(
      handler,
      InternetAddress.anyIPv4,
      port,
      shared: true,
    );
  }

  Future<void> stop() async {
    await _server?.close(force: true);
    _server = null;
  }

  Future<Response> _handleRequest(Request request) async {
    if (request.url.path == 'health' && request.method == 'GET') {
      return _jsonResponse({
        'deviceId': deviceId,
        'timestamp': DateTime.now().toUtc().toIso8601String(),
      });
    }

    if (request.url.path == 'sync/push' && request.method == 'POST') {
      final body = await request.readAsString();
      final json = body.isEmpty
          ? <String, dynamic>{}
          : Map<String, dynamic>.from(jsonDecode(body) as Map);
      final rawChanges = (json['changes'] as List<dynamic>? ?? const []);
      var applied = 0;

      for (final rawChange in rawChanges) {
        final change = SyncChange.fromJson(
          Map<String, dynamic>.from(rawChange as Map),
        );
        final merged = await _mergeIncomingChange(change);
        if (merged) {
          applied++;
        }
      }

      return _jsonResponse({
        'deviceId': deviceId,
        'applied': applied,
        'received': rawChanges.length,
        'timestamp': DateTime.now().toUtc().toIso8601String(),
      });
    }

    if (request.url.path == 'sync/pull' && request.method == 'GET') {
      final since =
          int.tryParse(request.url.queryParameters['since'] ?? '') ?? 0;
      final limit = int.tryParse(request.url.queryParameters['limit'] ?? '') ??
          defaultChunkSize;
      final changes = await _changesSince(
        since,
        limit: limit,
      );
      final nextCursor =
          changes.isEmpty ? since : changes.last.changeSeq;
      return _jsonResponse({
        'deviceId': deviceId,
        'timestamp': DateTime.now().toUtc().toIso8601String(),
        'nextCursor': nextCursor,
        'hasMore': changes.length >= limit,
        'changes': changes.map((change) => change.toJson()).toList(),
      });
    }

    return Response.notFound('Not found');
  }

  Future<List<SyncChange>> _changesSince(
    int since, {
    required int limit,
  }) async {
    final logs = (await DBService.isar.changeLogs.where().findAll())
      ..sort((a, b) => a.changeSeq.compareTo(b.changeSeq));
    final filteredLogs =
        logs.where((log) => log.changeSeq > since).take(limit).toList();

    final changes = <SyncChange>[];
    for (final log in filteredLogs) {
      Map<String, dynamic>? payload;
      if (log.collection == 'items') {
        final item =
            await DBService.isar.items.getByRecordId(log.recordId);
        payload = item?.toSyncJson();
      }

      changes.add(
        SyncChange(
          collection: log.collection,
          recordId: log.recordId,
          opId: log.opId,
          changeSeq: log.changeSeq,
          operation: log.operation.name,
          timestamp: log.timestamp,
          originDeviceId: log.originDeviceId,
          payload: payload,
        ),
      );
    }
    return changes;
  }

  Future<bool> _mergeIncomingChange(SyncChange change) async {
    if (change.collection != 'items' || change.payload == null) {
      return false;
    }

    final existingChange =
        await DBService.isar.changeLogs.filter().opIdEqualTo(change.opId).findFirst();
    if (existingChange != null) {
      return false;
    }

    final incomingItem = Item.fromSyncJson(change.payload!);
    final localItem =
        await DBService.isar.items.getByRecordId(change.recordId);

    if (!_shouldApplyIncomingItem(
      localItem: localItem,
      incomingItem: incomingItem,
    )) {
      return false;
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
            (entry) => entry.name == change.operation,
            orElse: () => ChangeOperation.update,
          ),
          timestamp: change.timestamp,
          originDeviceId: change.originDeviceId,
          synced: true,
        ),
      );
    });

    return true;
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

  Response _jsonResponse(Map<String, dynamic> body) {
    return Response.ok(
      jsonEncode(body),
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
      },
    );
  }
}
