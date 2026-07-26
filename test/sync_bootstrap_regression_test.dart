import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ssma/models/product.dart';
import 'package:ssma/services/db_service.dart';
import 'package:ssma/sync/v2/services/change_journal.dart';
import 'package:ssma/sync/v2/sync_initializer_v2.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory testDir;

  setUpAll(() async {
    testDir = await Directory.systemTemp.createTemp('ssma_test_docs_');

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/path_provider'),
      (methodCall) async {
        if (methodCall.method == 'getApplicationDocumentsDirectory') {
          return testDir.path;
        }
        return null;
      },
    );
  });

  tearDownAll(() async {
    if (await testDir.exists()) {
      await testDir.delete(recursive: true);
    }
  });

  test('queued journal entries flush once sync becomes available', () async {
    try {
      await DBService.isar.close();
    } catch (_) {}

    await DBService.initializeIsar();
    syncV2 = null;

    final initializer = SyncInitializerV2();
    initializer.changeJournal = ChangeJournal(
      isar: DBService.isar,
      localDeviceId: 'test-device',
    );
    syncV2 = initializer;

    final beforeSeq = await initializer.changeJournal.getCurrentSeq();

    final product = Product()
      ..name = 'Buffer Test'
      ..salePrice = 10
      ..purchasePrice = 5
      ..quantity = 1
      ..deviceId = 'test-device';

    await DBService.addProduct(product);

    await DBService.flushPendingJournalEntries();

    final currentSeq = await initializer.changeJournal.getCurrentSeq();
    expect(currentSeq, beforeSeq + 1);
  });
}
