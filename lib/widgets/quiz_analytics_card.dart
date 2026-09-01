import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:social_quiz_app/services/quiz_history_service.dart';

/// クイズ分析パネル：最近のクイズパフォーマンスを表示
class QuizAnalyticsCard extends ConsumerWidget {
  const QuizAnalyticsCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recentAttempts = ref.watch(recentQuizAttemptsProvider(5));
    final stats = ref.watch(quizOverallStatsProvider);
    final isImproving = ref.watch(isImprovingTrendProvider);
    final consecutiveCorrect = ref.watch(consecutiveCorrectCountProvider);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ヘッダー
            Row(
              children: [
                const Icon(Icons.analytics, color: Colors.blue, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'クイズパフォーマンス',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'スコア・正答率・連続正解トラッキング',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                if (isImproving)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.trending_up, color: Colors.green[700], size: 14),
                        const SizedBox(width: 4),
                        Text(
                          '改善中',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.green[700],
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 16),

            // 統計情報
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _StatItem(
                    label: '正答率',
                    value: '${stats.averageAccuracy.toStringAsFixed(1)}%',
                    icon: Icons.check_circle,
                    color: Colors.blue,
                  ),
                  _StatItem(
                    label: '試行数',
                    value: stats.totalAttempts.toString(),
                    icon: Icons.repeat,
                    color: Colors.orange,
                  ),
                  _StatItem(
                    label: '連続正解',
                    value: consecutiveCorrect.toString(),
                    icon: Icons.local_fire_department,
                    color: Colors.red,
                  ),
                  _StatItem(
                    label: '最高スコア',
                    value: stats.bestScore.toString(),
                    icon: Icons.star,
                    color: Colors.amber,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 最近の試行
            if (recentAttempts.isNotEmpty) ...[
              const Text(
                '最近の5回の試行',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              ..._buildRecentAttempts(recentAttempts),
            ] else
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Text(
                    'まだクイズを挑戦していません',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildRecentAttempts(attempts) {
    return attempts.asMap().entries.map((entry) {
      final index = entry.key;
      final attempt = entry.value;
      final accuracy = attempt.accuracyPercentage;

      Color accuracyColor;
      if (accuracy >= 90) {
        accuracyColor = Colors.green;
      } else if (accuracy >= 70) {
        accuracyColor = Colors.orange;
      } else {
        accuracyColor = Colors.red;
      }

      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            // 順序
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(4),
              ),
              child: Center(
                child: Text(
                  '${index + 1}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // ステージ情報
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ステージ ${attempt.stageNo}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    '${attempt.correctCount}/${attempt.totalCount} 正解',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),

            // 正答率
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: accuracyColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '${accuracy.toStringAsFixed(0)}%',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: accuracyColor,
                ),
              ),
            ),

            // 完璧マーク
            if (attempt.isPerfect) ...[
              const SizedBox(width: 8),
              const Icon(
                Icons.favorite,
                color: Colors.red,
                size: 16,
              ),
            ],
          ],
        ),
      );
    }).toList();
  }
}

/// 統計情報を表示する小さいウィジェット
class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}
