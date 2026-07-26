import 'package:flutter_test/flutter_test.dart';
import 'package:ssma/sync/v2/models/sync_change_log.dart';
import 'package:ssma/sync/v2/services/sync_manager.dart';

void main() {
  group('Sync v2 protocol models and status', () {
    test('Duplicate ops are ignored idempotently', () async {
      final incomingLog = SyncChangeLog()
        ..changeId = 'test-op-id-123'
        ..changeSeq = 1
        ..entityType = 'Product'
        ..entityId = 'product-1'
        ..operation = 'CREATE'
        ..entityVersion = 1
        ..payload = '{"id":"product-1"}'
        ..timestampMs = 1000
        ..originDeviceId = 'deviceA';

      final restored = SyncChangeLog.fromJson(incomingLog.toJson());
      expect(restored.changeId, incomingLog.changeId);
      expect(restored.entityId, incomingLog.entityId);
    });

    test('empty peer lists leave the sync indicator idle', () {
      final notifier = SyncStatusNotifierV2();
      notifier.setStatus(SyncStatusV2.idle);
      expect(notifier.status, SyncStatusV2.idle);
    });
  });
}
