import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/daily_history.dart';
import '../providers/daily_history_provider.dart';

/// 日付別歴史イベントカード
class DailyHistoryCard extends ConsumerWidget {
  final DailyHistory history;
  final bool isCompleted;
  final bool isCorrect;
  final VoidCallback? onQuizTap;

  const DailyHistoryCard({
    Key? key,
    required this.history,
    required this.isCompleted,
    required this.isCorrect,
    this.onQuizTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final today = DateTime.now();
    final dateStr =
        '${today.year}年 ${today.month}月 ${today.day}日（${_getDayOfWeek(today)}）';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ヘッダー
            Text(
              dateStr,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 8),

            // イベント名（大きく）
            Row(
              children: [
                Text(
                  _getCategoryEmoji(history.category),
                  style: const TextStyle(fontSize: 24),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    history.eventName,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // イベント説明
            Text(
              history.eventDescription,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),

            // 背景知識（グレーボックス）
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '📚 背景知識',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Colors.grey[700],
                        ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    history.historicalContext,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ボーナス表示 & ボタン
            if (!isCompleted)
              Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.amber[50],
                      border: Border.all(color: Colors.amber[300]!),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '⭐ クイズに正解でボーナスコイン +10',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: Colors.amber[900],
                          ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: onQuizTap,
                      child: const Text('クイズに挑戦'),
                    ),
                  ),
                ],
              )
            else
              Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isCorrect ? Colors.green[50] : Colors.red[50],
                      border: Border.all(
                        color: isCorrect ? Colors.green[300]! : Colors.red[300]!,
                      ),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      children: [
                        Text(
                          isCorrect ? '✅' : '❌',
                          style: const TextStyle(fontSize: 20),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            isCorrect
                                ? '正解！ボーナス +10獲得'
                                : '残念... 明日もチャレンジ！',
                            style: Theme.of(context).textTheme.labelMedium,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => _showExplanation(context),
                          child: const Text('解説を読む'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: onQuizTap,
                          child: const Text('本編をプレイ'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  /// カテゴリに応じた絵文字を返す
  String _getCategoryEmoji(DailyHistoryCategory category) {
    return switch (category) {
      DailyHistoryCategory.kinenbi => '🎉',
      DailyHistoryCategory.event => '📜',
      DailyHistoryCategory.personBirthday => '👤',
      DailyHistoryCategory.culture => '🎌',
      DailyHistoryCategory.politics => '⚖️',
      DailyHistoryCategory.disaster => '⚠️',
    };
  }

  /// 曜日を返す
  String _getDayOfWeek(DateTime date) {
    const days = ['日', '月', '火', '水', '木', '金', '土'];
    return days[date.weekday % 7];
  }

  /// 解説を表示
  void _showExplanation(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(history.eventName),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${history.year}年',
                style: Theme.of(ctx).textTheme.labelMedium,
              ),
              const SizedBox(height: 8),
              Text(history.eventDescription),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '背景知識',
                      style: Theme.of(ctx).textTheme.labelSmall,
                    ),
                    const SizedBox(height: 6),
                    Text(history.historicalContext),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('閉じる'),
          ),
        ],
      ),
    );
  }
}
