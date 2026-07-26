import 'package:flutter_test/flutter_test.dart';
import 'package:ssma/sync/v2/services/conflict_resolver.dart';

ConflictContext _context({
  required int incomingVersion,
  required int existingVersion,
  required int incomingUpdatedAtMs,
  required int existingUpdatedAtMs,
  required String incomingDeviceId,
  required String existingDeviceId,
}) =>
    ConflictContext(
      entityType: 'Product',
      entityId: 'product-1',
      incomingVersion: incomingVersion,
      existingVersion: existingVersion,
      incomingUpdatedAtMs: incomingUpdatedAtMs,
      existingUpdatedAtMs: existingUpdatedAtMs,
      incomingDeviceId: incomingDeviceId,
      existingDeviceId: existingDeviceId,
    );

void main() {
  group('ConflictResolver', () {
    test('Higher version should win', () {
      final resolver = ConflictResolver();
      final result = resolver.shouldApplyIncoming(_context(
        incomingVersion: 2,
        existingVersion: 1,
        incomingUpdatedAtMs: 1000,
        existingUpdatedAtMs: 2000,
        incomingDeviceId: 'deviceA',
        existingDeviceId: 'deviceB',
      ));
      expect(result, isTrue);

      final resultReverse = resolver.shouldApplyIncoming(_context(
        incomingVersion: 1,
        existingVersion: 2,
        incomingUpdatedAtMs: 2000,
        existingUpdatedAtMs: 1000,
        incomingDeviceId: 'deviceB',
        existingDeviceId: 'deviceA',
      ));
      expect(resultReverse, isFalse);
    });

    test('Tie breaker: newer updatedAt wins if versions are equal', () {
      final resolver = ConflictResolver();
      final result = resolver.shouldApplyIncoming(_context(
        incomingVersion: 1,
        existingVersion: 1,
        incomingUpdatedAtMs: 2000,
        existingUpdatedAtMs: 1000,
        incomingDeviceId: 'deviceA',
        existingDeviceId: 'deviceB',
      ));
      expect(result, isTrue);

      final resultReverse = resolver.shouldApplyIncoming(_context(
        incomingVersion: 1,
        existingVersion: 1,
        incomingUpdatedAtMs: 1000,
        existingUpdatedAtMs: 2000,
        incomingDeviceId: 'deviceB',
        existingDeviceId: 'deviceA',
      ));
      expect(resultReverse, isFalse);
    });

    test(
        'Final tie breaker: lexicographically larger deviceId wins if version and updatedAt are equal',
        () {
      final resolver = ConflictResolver();
      final result = resolver.shouldApplyIncoming(_context(
        incomingVersion: 1,
        existingVersion: 1,
        incomingUpdatedAtMs: 1000,
        existingUpdatedAtMs: 1000,
        incomingDeviceId: 'deviceB',
        existingDeviceId: 'deviceA',
      ));
      expect(result, isTrue); // 'deviceB' is lexicographically larger

      final resultReverse = resolver.shouldApplyIncoming(_context(
        incomingVersion: 1,
        existingVersion: 1,
        incomingUpdatedAtMs: 1000,
        existingUpdatedAtMs: 1000,
        incomingDeviceId: 'deviceA',
        existingDeviceId: 'deviceB',
      ));
      expect(resultReverse, isFalse);
    });
  });
}
