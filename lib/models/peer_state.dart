import 'package:isar/isar.dart';

part 'peer_state.g.dart';

@collection
class PeerState {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String peerId;

  late String peerIp;

  late int peerPort;

  @Index()
  late int lastSeen; // Milliseconds since epoch

  late int lastPulledChangeSeq;

  late String healthStatus; // E.g., 'healthy', 'unreachable'

  /// Timestamp (ms epoch) of the last *successful* full sync with this peer.
  /// 0 means we have never successfully synced with this peer.
  /// This is only updated after both pull and push complete without error,
  /// matching git semantics: lastSyncedAt reflects the last complete sync.
  int lastSyncedAt = 0;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'peerId': peerId,
      'peerIp': peerIp,
      'peerPort': peerPort,
      'lastSeen': lastSeen,
      'lastPulledChangeSeq': lastPulledChangeSeq,
      'healthStatus': healthStatus,
      'lastSyncedAt': lastSyncedAt,
    };
  }
}
