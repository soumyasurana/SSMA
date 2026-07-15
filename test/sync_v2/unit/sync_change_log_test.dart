import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:ssma/sync/v2/models/sync_change_log.dart';

void main() {
  group('SyncChangeLog serialization', () {
    test('toJson / fromJson round-trip preserves all fields', () {
      final original = SyncChangeLog()
        ..changeId = 'test-change-id-123'
        ..changeSeq = 42
        ..entityType = 'Product'
        ..entityId = 'product-uuid-abc'
        ..operation = 'CREATE'
        ..entityVersion = 1
        ..originDeviceId = 'device-A'
        ..timestampMs = 1720000000000
        ..payload = jsonEncode({'id': 'product-uuid-abc', 'name': 'Widget'})
        ..previousChangeHash = null
        ..acknowledged = false;

      final json = original.toJson();
      final restored = SyncChangeLog.fromJson(json);

      expect(restored.changeId, original.changeId);
      expect(restored.changeSeq, original.changeSeq);
      expect(restored.entityType, original.entityType);
      expect(restored.entityId, original.entityId);
      expect(restored.operation, original.operation);
      expect(restored.entityVersion, original.entityVersion);
      expect(restored.originDeviceId, original.originDeviceId);
      expect(restored.timestampMs, original.timestampMs);
      expect(restored.payload, original.payload);
      expect(restored.previousChangeHash, isNull);
    });

    test('fromJson marks acknowledged=false for remote changes (not yet acked)', () {
      final json = {
        'changeId': 'x',
        'changeSeq': 1,
        'entityType': 'Sale',
        'entityId': 'sale-1',
        'operation': 'UPDATE',
        'entityVersion': 3,
        'originDeviceId': 'dev-B',
        'timestampMs': 1000,
        'payload': '{}',
        'previousChangeHash': null,
      };
      final log = SyncChangeLog.fromJson(json);
      // fromJson is used for incoming remote changes — should start as unacknowledged
      // until the local apply is confirmed
      expect(log.acknowledged, isFalse);
    });

    test('toJson includes all required sync protocol fields', () {
      final log = SyncChangeLog()
        ..changeId = 'cid'
        ..changeSeq = 1
        ..entityType = 'Customer'
        ..entityId = 'eid'
        ..operation = 'DELETE'
        ..entityVersion = 5
        ..originDeviceId = 'dev-X'
        ..timestampMs = 9999
        ..payload = '{}'
        ..previousChangeHash = 'sha256hash';

      final json = log.toJson();
      expect(json.containsKey('changeId'), isTrue);
      expect(json.containsKey('changeSeq'), isTrue);
      expect(json.containsKey('entityType'), isTrue);
      expect(json.containsKey('entityId'), isTrue);
      expect(json.containsKey('operation'), isTrue);
      expect(json.containsKey('entityVersion'), isTrue);
      expect(json.containsKey('originDeviceId'), isTrue);
      expect(json.containsKey('timestampMs'), isTrue);
      expect(json.containsKey('payload'), isTrue);
      expect(json.containsKey('previousChangeHash'), isTrue);
      expect(json['previousChangeHash'], 'sha256hash');
    });
  });

  group('SyncChangeLog — operation values', () {
    for (final op in ['CREATE', 'UPDATE', 'DELETE']) {
      test('valid operation: $op', () {
        final log = SyncChangeLog()
          ..changeId = 'id'
          ..changeSeq = 1
          ..entityType = 'T'
          ..entityId = 'e'
          ..operation = op
          ..entityVersion = 1
          ..originDeviceId = 'd'
          ..timestampMs = 1
          ..payload = '{}';
        expect(log.operation, op);
      });
    }
  });
}
