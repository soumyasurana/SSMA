import 'package:shared_preferences/shared_preferences.dart';

class ChangeTrackerService {
  static const _changeSeqKey = 'lan_sync_next_change_seq';
  static const _pullCursorPrefix = 'lan_sync_last_pull_seq_';

  Future<int> nextChangeSeq() async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt(_changeSeqKey) ?? 0;
    final next = current + 1;
    await prefs.setInt(_changeSeqKey, next);
    return next;
  }

  Future<int> lastPulledSeq(String peerKey) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('$_pullCursorPrefix$peerKey') ?? 0;
  }

  Future<void> saveLastPulledSeq(String peerKey, int changeSeq) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('$_pullCursorPrefix$peerKey', changeSeq);
  }
}
