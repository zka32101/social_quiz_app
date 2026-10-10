/// 連続学習カレンダー用の学習日履歴（純関数）。
const int kStudyDatesKeepDays = 180;

String studyDateKey(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

DateTime? parseStudyDate(String s) {
  final p = s.split('-');
  if (p.length != 3) return null;
  final y = int.tryParse(p[0]), m = int.tryParse(p[1]), d = int.tryParse(p[2]);
  if (y == null || m == null || d == null) return null;
  return DateTime(y, m, d);
}

/// 学習日リストに今日を追記する。重複なし・昇順・直近 [kStudyDatesKeepDays] 日のみ。
/// [existing] が空で、既存ユーザー（[previousStreak] > 0 かつ [previousLastStudied] あり）の場合は
/// 最終学習日から遡って streak 日分をバックフィルする。
List<String> appendStudyDate({
  required List<String> existing,
  required DateTime today,
  int previousStreak = 0,
  DateTime? previousLastStudied,
}) {
  final set = <String>{...existing};
  if (existing.isEmpty && previousStreak > 0 && previousLastStudied != null) {
    final last = DateTime(previousLastStudied.year, previousLastStudied.month,
        previousLastStudied.day);
    for (var i = 0; i < previousStreak; i++) {
      set.add(studyDateKey(DateTime(last.year, last.month, last.day - i)));
    }
  }
  set.add(studyDateKey(DateTime(today.year, today.month, today.day)));
  final cutoff = studyDateKey(
      DateTime(today.year, today.month, today.day - kStudyDatesKeepDays));
  final out = set.where((k) => k.compareTo(cutoff) >= 0).toList()..sort();
  return out;
}

/// 連続して学習した日の「何日目か」(1始まり)。
Map<DateTime, int> streakRunPositions(Set<DateTime> days) {
  final norm = days.map((d) => DateTime(d.year, d.month, d.day)).toSet();
  final sorted = norm.toList()..sort();
  final out = <DateTime, int>{};
  for (final d in sorted) {
    final prev = DateTime(d.year, d.month, d.day - 1);
    out[d] = norm.contains(prev) ? (out[prev] ?? 0) + 1 : 1;
  }
  return out;
}

bool isStreakMilestone(int position) =>
    position == 7 || position == 14 || position == 30;
