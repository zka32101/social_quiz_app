import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/stage.dart';
import '../../repositories/stage_repository.dart';
import '../../repositories/progress_repository.dart';
import '../../utils/constants.dart';
import 'stage_detail_screen.dart';

/// ステージ選択画面
class StageSelectionScreen extends ConsumerWidget {
  const StageSelectionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stagesAsync = ref.watch(allStagesProvider);
    final userProgress = ref.watch(userProgressProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('ステージを選ぶ'),
        elevation: 0,
        backgroundColor: AppColors.primary,
      ),
      body: stagesAsync.when(
        data: (stages) {
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: stages.length,
            itemBuilder: (context, index) {
              final stage = stages[index];
              final stageProgress = userProgress.getStageProgress(stage.id);

              return _StageCard(
                stage: stage,
                stageProgress: stageProgress,
                onTap: stageProgress.isUnlocked
                    ? () => _enterStage(context, stage, ref)
                    : null,
              );
            },
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (err, stack) => Center(
          child: Text('エラーが発生しました: $err'),
        ),
      ),
    );
  }

  void _enterStage(BuildContext context, Stage stage, WidgetRef ref) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => StageDetailScreen(stageId: stage.id),
      ),
    );
  }
}

/// ステージカード UI
class _StageCard extends StatelessWidget {
  final Stage stage;
  final StageProgress stageProgress;
  final VoidCallback? onTap;

  const _StageCard({
    required this.stage,
    required this.stageProgress,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isUnlocked = stageProgress.isUnlocked;
    final isCompleted = stageProgress.isCompleted;
    final completionPercent = (stageProgress.completedQuests.length / 5 * 100)
        .clamp(0, 100)
        .toStringAsFixed(0); // 仮に5クエストと仮定

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: isUnlocked ? 4 : 0,
      color: isUnlocked ? Colors.white : Colors.grey[200],
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ステージ番号とタイトル
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ステージ ${stage.stageNo}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          stage.title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // ロック/完了アイコン
                  if (!isUnlocked)
                    Icon(Icons.lock, color: Colors.grey[400], size: 28)
                  else if (isCompleted)
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.check, color: Colors.white),
                    )
                  else
                    Icon(Icons.arrow_forward, color: AppColors.primary),
                ],
              ),
              const SizedBox(height: 12),

              // 説明テキスト
              Text(
                stage.description,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 12),

              // 難易度表示
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Wrap(
                    spacing: 8,
                    children: [
                      _DifficultyBadge(level: stage.level),
                      _GradeBadge(gradeRange: stage.gradeRange),
                    ],
                  ),
                  // ポイント表示
                  if (isUnlocked)
                    Text(
                      '${stage.totalPoints}pt',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                ],
              ),

              // 進捗バー
              if (isUnlocked && !isCompleted) ...[
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: stageProgress.completedQuests.length / 5,
                    minHeight: 8,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$completionPercent% 完了',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// 難易度バッジ
class _DifficultyBadge extends StatelessWidget {
  final StageLevel level;

  const _DifficultyBadge({required this.level});

  @override
  Widget build(BuildContext context) {
    final levelLabel = _getLevelLabel();
    final color = _getLevelColor();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color),
      ),
      child: Text(
        levelLabel,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  String _getLevelLabel() {
    switch (level) {
      case StageLevel.beginner:
        return '初級';
      case StageLevel.intermediate:
        return '中級';
      case StageLevel.advanced:
        return '上級';
    }
  }

  Color _getLevelColor() {
    switch (level) {
      case StageLevel.beginner:
        return Colors.blue;
      case StageLevel.intermediate:
        return Colors.orange;
      case StageLevel.advanced:
        return Colors.red;
    }
  }
}

/// 対象学年バッジ
class _GradeBadge extends StatelessWidget {
  final String gradeRange;

  const _GradeBadge({required this.gradeRange});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.primary),
      ),
      child: Text(
        '${gradeRange}年生向け',
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: AppColors.primary,
        ),
      ),
    );
  }
}
