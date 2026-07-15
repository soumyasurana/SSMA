/// The result of a conflict resolution.
enum ConflictOutcome {
  /// Apply the incoming (remote) change — remote wins.
  applyIncoming,

  /// Keep the existing (local) record — local wins.
  keepExisting,

  /// Neither — requires manual intervention (not yet implemented).
  requiresManualMerge,
}

/// The data passed to a conflict resolution strategy.
class ConflictContext {
  /// Entity type string (e.g. 'Product').
  final String entityType;

  /// UUID of the entity being compared.
  final String entityId;

  /// Version of the incoming (remote) record.
  final int incomingVersion;

  /// Version of the existing (local) record.
  final int existingVersion;

  /// Updated-at timestamp (ms) of the incoming record.
  final int incomingUpdatedAtMs;

  /// Updated-at timestamp (ms) of the existing record.
  final int existingUpdatedAtMs;

  /// Device ID of the incoming change origin.
  final String incomingDeviceId;

  /// Device ID that last modified the local record.
  final String existingDeviceId;

  const ConflictContext({
    required this.entityType,
    required this.entityId,
    required this.incomingVersion,
    required this.existingVersion,
    required this.incomingUpdatedAtMs,
    required this.existingUpdatedAtMs,
    required this.incomingDeviceId,
    required this.existingDeviceId,
  });
}

/// Abstract base for all conflict resolution strategies.
///
/// Implement this to add custom strategies (e.g. field-level merge, manual).
/// Register the strategy with [ConflictResolver] at initialization time.
abstract class ConflictStrategy {
  String get name;
  ConflictOutcome resolve(ConflictContext ctx);
}

// ---------------------------------------------------------------------------
// Built-in strategies
// ---------------------------------------------------------------------------

/// Strategy 1: Highest version number wins.
///
/// If versions are equal, falls back to timestamp comparison (Last-Write-Wins).
/// If timestamps are also equal, uses a deterministic lexicographic device-ID
/// tiebreaker to ensure all devices converge to the same resolution.
class HighestVersionWinsStrategy implements ConflictStrategy {
  const HighestVersionWinsStrategy();

  @override
  String get name => 'HighestVersionWins';

  @override
  ConflictOutcome resolve(ConflictContext ctx) {
    if (ctx.incomingVersion > ctx.existingVersion) return ConflictOutcome.applyIncoming;
    if (ctx.incomingVersion < ctx.existingVersion) return ConflictOutcome.keepExisting;
    // Version tie → fall back to timestamp
    if (ctx.incomingUpdatedAtMs > ctx.existingUpdatedAtMs) return ConflictOutcome.applyIncoming;
    if (ctx.incomingUpdatedAtMs < ctx.existingUpdatedAtMs) return ConflictOutcome.keepExisting;
    // Timestamp tie → deterministic lexicographic device-ID tiebreaker
    return _tieBreak(ctx);
  }
}

/// Strategy 2: Most recently modified record wins (wall-clock time).
///
/// Requires that [ConflictContext.incomingUpdatedAtMs] and
/// [ConflictContext.existingUpdatedAtMs] are reliably set.
class LastWriteWinsStrategy implements ConflictStrategy {
  const LastWriteWinsStrategy();

  @override
  String get name => 'LastWriteWins';

  @override
  ConflictOutcome resolve(ConflictContext ctx) {
    if (ctx.incomingUpdatedAtMs > ctx.existingUpdatedAtMs) {
      return ConflictOutcome.applyIncoming;
    }
    if (ctx.incomingUpdatedAtMs < ctx.existingUpdatedAtMs) {
      return ConflictOutcome.keepExisting;
    }
    return _tieBreak(ctx);
  }
}

/// Strategy 3: Local (server-side) record always wins.
class ServerWinsStrategy implements ConflictStrategy {
  const ServerWinsStrategy();

  @override
  String get name => 'ServerWins';

  @override
  ConflictOutcome resolve(ConflictContext ctx) => ConflictOutcome.keepExisting;
}

/// Strategy 4: Incoming (client) change always wins.
class ClientWinsStrategy implements ConflictStrategy {
  const ClientWinsStrategy();

  @override
  String get name => 'ClientWins';

  @override
  ConflictOutcome resolve(ConflictContext ctx) => ConflictOutcome.applyIncoming;
}

/// Deterministic lexicographic tie-breaker.
/// Larger device ID wins — ensures all devices arrive at the same outcome
/// for the same conflict without any coordination.
ConflictOutcome _tieBreak(ConflictContext ctx) {
  final cmp = ctx.incomingDeviceId.compareTo(ctx.existingDeviceId);
  return cmp > 0 ? ConflictOutcome.applyIncoming : ConflictOutcome.keepExisting;
}

// ---------------------------------------------------------------------------
// The resolver façade
// ---------------------------------------------------------------------------

/// The main conflict resolver.
///
/// Uses a pluggable [ConflictStrategy]. Swap the strategy at runtime
/// without changing the sync engine.
///
/// Usage:
/// ```dart
/// final resolver = ConflictResolver(strategy: LastWriteWinsStrategy());
/// final outcome = resolver.resolve(context);
/// if (outcome == ConflictOutcome.applyIncoming) { ... }
/// ```
class ConflictResolver {
  ConflictStrategy _strategy;

  ConflictResolver({ConflictStrategy? strategy})
      : _strategy = strategy ?? const HighestVersionWinsStrategy();

  /// The currently active strategy name.
  String get strategyName => _strategy.name;

  /// Swaps the active strategy at runtime.
  void setStrategy(ConflictStrategy strategy) {
    _strategy = strategy;
  }

  /// Resolves whether to apply an incoming change over an existing record.
  ///
  /// Returns [ConflictOutcome.applyIncoming] if the incoming change should
  /// overwrite the local record, [ConflictOutcome.keepExisting] otherwise.
  ConflictOutcome resolve(ConflictContext ctx) {
    // Fast path: no existing record → always apply
    // This check is done at the call site; here we handle true conflicts.
    return _strategy.resolve(ctx);
  }

  /// Convenience wrapper for the common case where the caller only needs
  /// a boolean "should I apply this?".
  bool shouldApplyIncoming(ConflictContext ctx) {
    return resolve(ctx) == ConflictOutcome.applyIncoming;
  }
}
