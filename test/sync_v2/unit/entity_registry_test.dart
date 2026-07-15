import 'package:flutter_test/flutter_test.dart';
import 'package:ssma/sync/v2/services/change_processor.dart';
import 'package:ssma/sync/v2/services/conflict_resolver.dart';

void main() {
  group('EntityRegistry', () {
    setUp(() {
      // Clear and re-register for each test isolation
      // (Real Isar tests need isar_flutter_libs; these test the registry logic only)
    });

    test('registers a handler by entity type', () {
      EntityRegistry.register(_FakeHandler('Widget'));
      expect(EntityRegistry.get('Widget'), isNotNull);
      expect(EntityRegistry.get('Widget')!.entityType, 'Widget');
    });

    test('returns null for unregistered entity type', () {
      expect(EntityRegistry.get('NonExistentEntity'), isNull);
    });

    test('overwrites existing handler on re-registration', () {
      EntityRegistry.register(_FakeHandler('Widget'));
      final h2 = _FakeHandler('Widget');
      EntityRegistry.register(h2);
      expect(EntityRegistry.get('Widget'), same(h2));
    });

    test('registeredTypes reflects all registered handlers', () {
      EntityRegistry.register(_FakeHandler('Alpha'));
      EntityRegistry.register(_FakeHandler('Beta'));
      expect(EntityRegistry.registeredTypes, containsAll(['Alpha', 'Beta']));
    });
  });

  group('ChangeProcessorResult', () {
    test('toString includes all counters', () {
      final result = const ChangeProcessorResult(
        applied: 10,
        skipped: 2,
        conflicts: 1,
        errors: 0,
      );
      final s = result.toString();
      expect(s, contains('applied=10'));
      expect(s, contains('skipped=2'));
      expect(s, contains('conflicts=1'));
      expect(s, contains('errors=0'));
    });
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// Test stub
// ─────────────────────────────────────────────────────────────────────────────

class _FakeHandler implements EntitySyncHandler {
  @override
  final String entityType;

  _FakeHandler(this.entityType);

  @override
  Future<void> applyChange(payload, operation, conflictResolver, isar) async {}
}
