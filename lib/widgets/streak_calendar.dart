import 'package:flutter/material.dart';
import '../utils/study_dates.dart';

/// 月ごとの連続学習カレンダー。学習日にスタンプ、7/14/30日目にコイン。
class StreakCalendar extends StatelessWidget {
  final Set<DateTime> studiedDays;
  final DateTime month;
  const StreakCalendar({super.key, required this.studiedDays, required this.month});

  @override
  Widget build(BuildContext context) {
    final first = DateTime(month.year, month.month, 1);
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final lead = first.weekday % 7; // 日曜始まり
    final rows = ((lead + daysInMonth) / 7).ceil();
    final pos = streakRunPositions(studiedDays);
    const wd = ['日', '月', '火', '水', '木', '金', '土'];

    Widget cell(int day) {
      final d = DateTime(month.year, month.month, day);
      final studied = pos.containsKey(d);
      final coin = studied && isStreakMilestone(pos[d]!);
      return AspectRatio(
        aspectRatio: 1,
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (studied)
              Positioned.fill(
                child: Image.asset(
                  coin
                      ? 'assets/reward/stamp_coin.webp'
                      : 'assets/reward/stamp_ring_rainbow.webp',
                  key: Key(coin ? 'stamp_coin_$day' : 'stamp_$day'),
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                ),
              ),
            FittedBox(
              child: Text('$day',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: studied ? FontWeight.bold : FontWeight.normal,
                    color: Colors.brown.shade800,
                  )),
            ),
          ],
        ),
      );
    }

    return Stack(
      children: [
        Positioned.fill(
          child: Image.asset(
            'assets/reward/calendar_frame.webp',
            fit: BoxFit.fill,
            errorBuilder: (_, __, ___) => const SizedBox.shrink(),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('${month.year}年${month.month}月',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Row(children: [
                for (final w in wd)
                  Expanded(
                      child: Center(
                          child: Text(w, style: const TextStyle(fontSize: 11)))),
              ]),
              for (var r = 0; r < rows; r++)
                Row(children: [
                  for (var c = 0; c < 7; c++)
                    Expanded(
                      child: () {
                        final day = r * 7 + c - lead + 1;
                        if (day < 1 || day > daysInMonth) {
                          return const AspectRatio(aspectRatio: 1);
                        }
                        return cell(day);
                      }(),
                    ),
                ]),
            ],
          ),
        ),
      ],
    );
  }
}

/// 月カレンダーのダイアログ（前月/翌月で移動）。
Future<void> showStreakCalendar(BuildContext context, Set<DateTime> days) {
  return showDialog<void>(
    context: context,
    builder: (ctx) {
      var month = DateTime(DateTime.now().year, DateTime.now().month);
      return StatefulBuilder(builder: (ctx, setState) {
        return Dialog(
          insetPadding: const EdgeInsets.all(12),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                StreakCalendar(studiedDays: days, month: month),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      key: const Key('cal_prev'),
                      icon: const Icon(Icons.chevron_left),
                      onPressed: () => setState(
                          () => month = DateTime(month.year, month.month - 1)),
                    ),
                    TextButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        child: const Text('閉じる')),
                    IconButton(
                      key: const Key('cal_next'),
                      icon: const Icon(Icons.chevron_right),
                      onPressed: () => setState(
                          () => month = DateTime(month.year, month.month + 1)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      });
    },
  );
}
