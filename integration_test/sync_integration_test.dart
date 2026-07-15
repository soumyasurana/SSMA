import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:path_provider/path_provider.dart';
import 'package:isar/isar.dart';

import 'package:ssma/sync/sync_initializer.dart';
import 'package:ssma/models/item.dart';
import 'package:ssma/models/change_log.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Sync Integration Tests', () {
    late SyncInitializer syncA;

    setUpAll() async {
      // Initialize Isar natively for integration tests
      await Isar.initializeIsarCore(download: true);
    }

    setUp(() async {
      syncA = SyncInitializer(deviceId: 'device-test-A', port: 8081);
      await syncA.initialize();
    });

    tearDown(() async {
      await syncA.shutdown();
      await syncA.isarService.isar.close(deleteFromDisk: true);
    });

    testWidgets('Local DB saves item and generates changelog', (tester) async {
      final item = Item()
        ..name = 'Integration Test Item'
        ..version = 1
        ..updatedAt = DateTime.now().millisecondsSinceEpoch
        ..deviceId = syncA.deviceId
        ..isDeleted = false;

      await syncA.isarService.saveItem(item);

      // Verify item saved
      final savedItems = await syncA.isarService.isar.items.where().findAll();
      expect(savedItems.length, 1);
      expect(savedItems.first.name, 'Integration Test Item');

      // Verify changelog generated
      final logs = await syncA.isarService.isar.changeLogs.where().findAll();
      expect(logs.length, 1);
      expect(logs.first.collection, 'Item');
      expect(logs.first.operationType, 'CREATE');
      expect(logs.first.changeSeq, 1);
    });
  });
}
