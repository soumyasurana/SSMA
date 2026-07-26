import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:ssma/sync/v2/models/sync_change_log.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Sync v2 integration contracts', () {
    testWidgets('journal messages round-trip with their origin intact',
        (tester) async {
      final change = SyncChangeLog()
        ..changeId = 'test-change'
        ..changeSeq = 1
        ..entityType = 'Product'
        ..entityId = 'product-1'
        ..operation = 'CREATE'
        ..entityVersion = 1
        ..originDeviceId = 'device-test-A'
        ..timestampMs = DateTime.now().millisecondsSinceEpoch
        ..payload = '{"id":"product-1"}';

      final decoded = SyncChangeLog.fromJson(change.toJson());
      expect(decoded.originDeviceId, 'device-test-A');
      expect(decoded.changeId, 'test-change');
    });
  });
}
