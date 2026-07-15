import 'package:flutter_test/flutter_test.dart';
import 'package:ssma/sync/v2/services/conflict_resolver.dart';

void main() {
  group('ConflictResolver — HighestVersionWins (default)', () {
    late ConflictResolver resolver;

    setUp(() {
      resolver = ConflictResolver();
    });

    test('higher incoming version → apply incoming', () {
      final ctx = _ctx(incomingVersion: 5, existingVersion: 3);
      expect(resolver.resolve(ctx), ConflictOutcome.applyIncoming);
    });

    test('lower incoming version → keep existing', () {
      final ctx = _ctx(incomingVersion: 2, existingVersion: 4);
      expect(resolver.resolve(ctx), ConflictOutcome.keepExisting);
    });

    test('equal version, newer incoming timestamp → apply incoming', () {
      final ctx = _ctx(
        incomingVersion: 3,
        existingVersion: 3,
        incomingUpdatedAtMs: 2000,
        existingUpdatedAtMs: 1000,
      );
      expect(resolver.resolve(ctx), ConflictOutcome.applyIncoming);
    });

    test('equal version, older incoming timestamp → keep existing', () {
      final ctx = _ctx(
        incomingVersion: 3,
        existingVersion: 3,
        incomingUpdatedAtMs: 500,
        existingUpdatedAtMs: 1000,
      );
      expect(resolver.resolve(ctx), ConflictOutcome.keepExisting);
    });

    test('fully tied → deterministic lexicographic tiebreaker', () {
      // "zzz" > "aaa" lexicographically → incoming (zzz) wins
      final ctx = _ctx(
        incomingVersion: 3,
        existingVersion: 3,
        incomingUpdatedAtMs: 1000,
        existingUpdatedAtMs: 1000,
        incomingDeviceId: 'zzz-device',
        existingDeviceId: 'aaa-device',
      );
      expect(resolver.resolve(ctx), ConflictOutcome.applyIncoming);
    });

    test('shouldApplyIncoming — convenience wrapper', () {
      final ctx = _ctx(incomingVersion: 10, existingVersion: 1);
      expect(resolver.shouldApplyIncoming(ctx), isTrue);
    });
  });

  group('ConflictResolver — LastWriteWins', () {
    late ConflictResolver resolver;

    setUp(() {
      resolver = ConflictResolver(strategy: const LastWriteWinsStrategy());
    });

    test('newer incoming timestamp wins', () {
      final ctx = _ctx(incomingUpdatedAtMs: 9999, existingUpdatedAtMs: 1000);
      expect(resolver.resolve(ctx), ConflictOutcome.applyIncoming);
    });

    test('newer existing timestamp wins', () {
      final ctx = _ctx(incomingUpdatedAtMs: 100, existingUpdatedAtMs: 5000);
      expect(resolver.resolve(ctx), ConflictOutcome.keepExisting);
    });
  });

  group('ConflictResolver — ServerWins / ClientWins', () {
    test('ServerWins always keeps existing', () {
      final resolver = ConflictResolver(strategy: const ServerWinsStrategy());
      expect(resolver.resolve(_ctx(incomingVersion: 999)), ConflictOutcome.keepExisting);
    });

    test('ClientWins always applies incoming', () {
      final resolver = ConflictResolver(strategy: const ClientWinsStrategy());
      expect(resolver.resolve(_ctx(existingVersion: 999)), ConflictOutcome.applyIncoming);
    });
  });

  group('ConflictResolver — strategy swap', () {
    test('strategy can be swapped at runtime', () {
      final resolver = ConflictResolver(); // default: HighestVersionWins
      expect(resolver.strategyName, 'HighestVersionWins');

      resolver.setStrategy(const LastWriteWinsStrategy());
      expect(resolver.strategyName, 'LastWriteWins');
    });
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// Helper factory
// ─────────────────────────────────────────────────────────────────────────────

ConflictContext _ctx({
  String entityType = 'Product',
  String entityId = 'entity-123',
  int incomingVersion = 1,
  int existingVersion = 1,
  int incomingUpdatedAtMs = 1000,
  int existingUpdatedAtMs = 1000,
  String incomingDeviceId = 'device-B',
  String existingDeviceId = 'device-A',
}) {
  return ConflictContext(
    entityType: entityType,
    entityId: entityId,
    incomingVersion: incomingVersion,
    existingVersion: existingVersion,
    incomingUpdatedAtMs: incomingUpdatedAtMs,
    existingUpdatedAtMs: existingUpdatedAtMs,
    incomingDeviceId: incomingDeviceId,
    existingDeviceId: existingDeviceId,
  );
}
