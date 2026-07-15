import 'package:flutter_test/flutter_test.dart';
import 'package:ssma/models/item.dart';
import 'package:ssma/sync/conflict_resolver.dart';

void main() {
  group('ConflictResolver', () {
    test('Incoming item should win if existing is null', () {
      final incoming = Item()
        ..version = 1
        ..updatedAt = 1000
        ..deviceId = 'deviceA';

      final result = ConflictResolver.shouldApplyIncoming(null, incoming);
      expect(result, isTrue);
    });

    test('Higher version should win', () {
      final existing = Item()
        ..version = 1
        ..updatedAt = 2000
        ..deviceId = 'deviceB';

      final incoming = Item()
        ..version = 2
        ..updatedAt = 1000 // Even if older
        ..deviceId = 'deviceA';

      final result = ConflictResolver.shouldApplyIncoming(existing, incoming);
      expect(result, isTrue);

      final resultReverse = ConflictResolver.shouldApplyIncoming(incoming, existing);
      expect(resultReverse, isFalse);
    });

    test('Tie breaker: newer updatedAt wins if versions are equal', () {
      final existing = Item()
        ..version = 1
        ..updatedAt = 1000
        ..deviceId = 'deviceB';

      final incoming = Item()
        ..version = 1
        ..updatedAt = 2000
        ..deviceId = 'deviceA';

      final result = ConflictResolver.shouldApplyIncoming(existing, incoming);
      expect(result, isTrue);

      final resultReverse = ConflictResolver.shouldApplyIncoming(incoming, existing);
      expect(resultReverse, isFalse);
    });

    test('Final tie breaker: lexicographically larger deviceId wins if version and updatedAt are equal', () {
      final existing = Item()
        ..version = 1
        ..updatedAt = 1000
        ..deviceId = 'deviceA';

      final incoming = Item()
        ..version = 1
        ..updatedAt = 1000
        ..deviceId = 'deviceB'; // 'deviceB' > 'deviceA'

      final result = ConflictResolver.shouldApplyIncoming(existing, incoming);
      expect(result, isTrue); // 'deviceB' is lexicographically larger

      final resultReverse = ConflictResolver.shouldApplyIncoming(incoming, existing);
      expect(resultReverse, isFalse);
    });
  });
}
