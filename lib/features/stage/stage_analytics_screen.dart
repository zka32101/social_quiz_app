import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/stage.dart';
import '../../services/quiz_history_service.dart';

/// ステージ別のクイズ分析詳細画面
class StageAnalyticsScreen extends ConsumerWidget {
  final int stageNo;
  final String stageName;

  const StageAnalyticsScreen({
    Key? key,
    required this.stageNo,
    required this.stageName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stageAttempts = ref.watch(stageQuizAttemptsProvider(stageNo));
    final stageStats = ref.watch(quizStatsProvider(stageNo));

    return Scaffold(
      appBar: AppBar(
        title: Text('$stageName - 詳細分析'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── 統計サマリー ───────────────────────────────────
            _StageStatsSummary(stats: stageStats),
            const SizedBox(height: 20),

            // ─── パフォーマンス指標 ──────────────────────────────
            _PerformanceMetrics(stats: stageStats),
            const SizedBox(height: 20),

            // ─── 試行履歴 ────────────────────────────────────────
            const Text(
              '試行履歴',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            stageAttempts.when(
              data: (attempts) {
                if (attempts.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 32),
                      child: Text(
                        'まだこのステージに挑戦していません',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: attempts.length,
                  itemBuilder: (context, index) {
                    final attempt = attempts[index];
                    return _AttemptHistoryTile(
                      index: index + 1,
                      attempt: attempt,
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(
                child: Text('エラー: $err'),
              ),
            ),
            const SizedBox(height: 20),

            // ─── 学習ガイダンス ──────────────────────────────────
            _LearningGuidance(stageNo: stageNo, stageName: stageName),
          ],
        ),
      ),
    );
  }
}

/// ステージ統計サマリーカード
class _StageStatsSummary extends StatelessWidget {
  final AsyncValue<QuizHistoryStats> stats;

  const _StageStatsSummary({required this.stats});

  @override
  Widget build(BuildContext context) {
    return stats.when(
      data: (stat) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.bar_chart, color: Colors.blue, size: 24),
                    const SizedBox(width: 8),
                    const Text(
                      'ステージ統計',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _StatBox(
                      label: '試行数',
                      value: stat.totalAttempts.toString(),
                      icon: Icons.repeat,
                      color: Colors.orange,
                    ),
                    _StatBox(
                      label: '正答率',
                      value: '${stat.averageAccuracy.toStringAsFixed(1)}%',
                      icon: Icons.check_circle,
                      color: Colors.green,
                    ),
                    _StatBox(
                      label: '満点回数',
                      value: stat.perfectAttempts.toString(),
                      icon: Icons.star,
                      color: Colors.amber,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('エラー: $err')),
    );
  }
}

/// パフォーマンス指標カード
class _PerformanceMetrics extends StatelessWidget {
  final AsyncValue<QuizHistoryStats> stats;

  const _PerformanceMetrics({required this.stats});

  @override
  Widget build(BuildContext context) {
    return stats.when(
      data: (stat) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.insights, color: Colors.purple, size: 24),
                    SizedBox(width: 8),
                    Text(
                      'パフォーマンス指標',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _MetricRow(
                  label: '正解数',
                  value: '${stat.totalCorrect}/${stat.totalQuestions}',
                  percentage: stat.averageAccuracy,
                ),
                const SizedBox(height: 12),
                _MetricRow(
                  label: '平均回答時間',
                  value: '${stat.averageTimePerQuestion.toStringAsFixed(1)}秒/問',
                  percentage: null,
                ),
                const SizedBox(height: 12),
                _MetricRow(
                  label: '最高スコア',
                  value: stat.bestScore.toString(),
                  percentage: null,
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info, color: Colors.blue[700], size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          stat.perfectAttempts > 0
                              ? '素晴らしい！${stat.perfectAttempts}回も完璧な成績を獲得しています'
                              : 'ステージを繰り返し挑戦して完璧を目指しましょう',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blue[700],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('エラー: $err')),
    );
  }
}

/// 学習ガイダンスカード
class _LearningGuidance extends StatelessWidget {
  final int stageNo;
  final String stageName;

  const _LearningGuidance({
    required this.stageNo,
    required this.stageName,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.lightbulb, color: Colors.yellow, size: 24),
                SizedBox(width: 8),
                Text(
                  '学習ガイダンス',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _GuidanceItem(
              icon: Icons.repeat,
              text: '繰り返し学習：このステージを何度も挑戦して知識を定着させましょう',
            ),
            const SizedBox(height: 8),
            _GuidanceItem(
              icon: Icons.schedule,
              text: '毎日挑戦：毎日少しずつ学習することで、より効果的に知識を習得できます',
            ),
            const SizedBox(height: 8),
            _GuidanceItem(
              icon: Icons.check_circle,
              text: '目標設定：このステージで正答率90%以上を目指してみましょう',
            ),
          ],
        ),
      ),
    );
  }
}

/// 試行履歴タイル
class _AttemptHistoryTile extends StatelessWidget {
  final int index;
  final attempt;

  const _AttemptHistoryTile({
    required this.index,
    required this.attempt,
  });

  @override
  Widget build(BuildContext context) {
    final accuracy = attempt.accuracyPercentage;
    Color accuracyColor;
    if (accuracy >= 90) {
      accuracyColor = Colors.green;
    } else if (accuracy >= 70) {
      accuracyColor = Colors.orange;
    } else {
      accuracyColor = Colors.red;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          // 試行番号
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                '$index',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // 詳細情報
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${attempt.correctCount}/${attempt.totalCount} 正解',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '${attempt.durationSeconds}秒 • ${attempt.totalScore}pt',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),

          // 正答率バッジ
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
  }
}

/// 単一統計ボックス
class _StatBox extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatBox({
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
            fontSize: 16,
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

/// メトリック行
class _MetricRow extends StatelessWidget {
  final String label;
  final String value;
  final double? percentage;

  const _MetricRow({
    required this.label,
    required this.value,
    required this.percentage,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        if (percentage != null) ...[
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percentage! / 100,
              minHeight: 6,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(
                percentage! >= 80
                    ? Colors.green
                    : percentage! >= 60
                        ? Colors.orange
                        : Colors.red,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// ガイダンスアイテム
class _GuidanceItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const _GuidanceItem({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.green, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 12),
          ),
        ),
      ],
    );
  }
}
