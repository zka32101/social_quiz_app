import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_progress.dart';
import 'engagement_service.dart';

/// Engagement Service 使用例とベストプラクティス

// ─── Example 1: Daily Checkin 記録 ────────────────────────────────

/// 子どもがクイズを完了したとき、親のチェックインを記録
Future<void> exampleRecordDailyCheckin(
  WidgetRef ref,
  String parentId,
) async {
  final service = ref.read(engagementServiceProvider);

  // クイズ完了ロジックの後
  await service.recordDailyCheckin(parentId, DateTime.now());

  // 成功メッセージ
  print('親のチェックインを記録しました');
}

// ─── Example 2: Weekly Challenge 生成と進捗更新 ───────────────────

/// ウィークリーチャレンジの生成（通常は Cloud Scheduler が自動実行）
Future<void> exampleGenerateChallenge(
  WidgetRef ref,
  String parentId,
) async {
  final service = ref.read(engagementServiceProvider);

  // 親の弱い詐欺パターンに基づいてチャレンジ生成
  // 例：フィッシング詐欺に弱い親向け
  final challenge = await service.generateWeeklyChallenge(
    parentId,
    'phishing', // weakFraudPattern
  );

  print('チャレンジ生成: ${challenge['title']}');
  print('報酬: ${challenge['reward']} ポイント');
}

/// チャレンジの進捗を更新
Future<void> exampleUpdateChallengeProgress(
  WidgetRef ref,
  String parentId,
) async {
  final service = ref.read(engagementServiceProvider);
  final weekNumber = DateTime.now().weekOfYear.toString();

  // 親がクイズを3問完了
  await service.updateChallengeProgress(
    parentId,
    weekNumber,
    3, // completedQuizzes
  );

  print('チャレンジ進捗更新: 3問完了');
}

// ─── Example 3: Safety Score 計算と表示 ────────────────────────────

/// セーフティスコアを計算し、アドバイスを表示
class SafetyScoreWidget extends ConsumerWidget {
  final String parentId;

  const SafetyScoreWidget({
    required this.parentId,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final safetyScoreFuture = ref.watch(safetyScoreProvider(parentId));
    final service = ref.watch(engagementServiceProvider);

    return safetyScoreFuture.when(
      loading: () => const CircularProgressIndicator(),
      error: (error, stack) => Text('エラー: $error'),
      data: (safetyScore) {
        final advice = service.getSafetyAdvice(safetyScore);
        final scoreColor = safetyScore >= 85
            ? Colors.green
            : safetyScore >= 70
                ? Colors.orange
                : Colors.red;

        return Column(
          children: [
            Text(
              'セーフティスコア',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: scoreColor.withOpacity(0.1),
              ),
              child: Text(
                safetyScore.toStringAsFixed(1),
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: scoreColor,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    const Text('💡', style: TextStyle(fontSize: 20)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        advice,
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

// ─── Example 4: Milestone Detection & Badge Display ──────────────

/// マイルストーン検出とバッジ表示
class BadgesWidget extends ConsumerWidget {
  final String parentId;
  final UserProgress userProgress;

  const BadgesWidget({
    required this.parentId,
    required this.userProgress,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final milestonesFuture =
        ref.watch(milestonesProvider((parentId, userProgress)));
    final service = ref.watch(engagementServiceProvider);
    final badgeDefs = service.getBadgeDefinitions();

    return milestonesFuture.when(
      loading: () => const CircularProgressIndicator(),
      error: (error, stack) => Text('エラー: $error'),
      data: (badges) {
        if (badges.isEmpty) {
          return const Text('バッジはまだ獲得していません');
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '獲得バッジ (${badges.length})',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: badges.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                final badgeId = badges[index];
                final badgeDef = badgeDefs[badgeId];

                if (badgeDef == null) return const SizedBox();

                return GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text(badgeDef['name'] ?? ''),
                        content: Text(badgeDef['description'] ?? ''),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('閉じる'),
                          ),
                        ],
                      ),
                    );
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        badgeDef['emoji'] ?? '',
                        style: const TextStyle(fontSize: 32),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        badgeDef['name'] ?? '',
                        style: const TextStyle(fontSize: 11),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }
}

// ─── Example 5: Activity Logging ────────────────────────────────

/// 活動ログを記録（セーフティリスク評価用）
Future<void> exampleLogActivity(
  WidgetRef ref,
  String parentId,
) async {
  final service = ref.read(engagementServiceProvider);

  // 例1: 正常な活動
  await service.logActivity(
    parentId,
    'quiz_completed',
    {
      'score': 85,
      'category': 'phishing',
      'timestamp': DateTime.now().toIso8601String(),
    },
    'low',
  );

  // 例2: 疑わしい活動（詐欺っぽいリンククリック）
  await service.logActivity(
    parentId,
    'suspicious',
    {
      'type': 'unknown_link_click',
      'source': 'email',
      'timestamp': DateTime.now().toIso8601String(),
    },
    'high',
  );
}

// ─── Example 6: Streak Display Widget ────────────────────────────

/// ストリーク情報を表示するウィジェット
class StreakWidget extends ConsumerWidget {
  final String parentId;

  const StreakWidget({
    required this.parentId,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final streakDataFuture = ref.watch(streakDataProvider(parentId));

    return streakDataFuture.when(
      loading: () => const CircularProgressIndicator(),
      error: (error, stack) => Text('エラー: $error'),
      data: (streakData) {
        if (streakData == null) {
          return const Text('ストリーク情報がありません');
        }

        final currentStreak = streakData['currentStreak'] as int? ?? 0;
        final maxStreak = streakData['maxStreak'] as int? ?? 0;
        final totalCheckins = streakData['totalCheckins'] as int? ?? 0;

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Column(
                  children: [
                    const Text('🔥', style: TextStyle(fontSize: 32)),
                    const SizedBox(height: 4),
                    Text(
                      '$currentStreak日',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '現在のストリーク',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '最長: $maxStreak日',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '累計チェックイン: $totalCheckins回',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ─── Example 7: Parent Engagement Dashboard ──────────────────────

/// 親向けエンゲージメントダッシュボード
class ParentEngagementDashboard extends ConsumerWidget {
  final String parentId;
  final UserProgress userProgress;

  const ParentEngagementDashboard({
    required this.parentId,
    required this.userProgress,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── ストリーク ───────────────────────────────
          StreakWidget(parentId: parentId),
          const SizedBox(height: 24),

          // ─── セーフティスコア ─────────────────────────
          SafetyScoreWidget(parentId: parentId),
          const SizedBox(height: 24),

          // ─── バッジ ───────────────────────────────────
          BadgesWidget(
            parentId: parentId,
            userProgress: userProgress,
          ),
          const SizedBox(height: 24),

          // ─── アクション ────────────────────────────
          ElevatedButton.icon(
            onPressed: () {
              // チャレンジ開始ロジック
              _showChallengeSelection(context, ref, parentId);
            },
            icon: const Icon(Icons.school),
            label: const Text('ウィークリーチャレンジに挑戦'),
          ),
        ],
      ),
    );
  }

  void _showChallengeSelection(
    BuildContext context,
    WidgetRef ref,
    String parentId,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('チャレンジを選択'),
        content: const Text('どのカテゴリーを学びたいですか？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
        ],
      ),
    );
  }
}
