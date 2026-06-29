import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/stage.dart';
import '../../repositories/stage_repository.dart';
import '../../repositories/progress_repository.dart';
import '../../utils/constants.dart';
import 'quiz_execution_screen.dart';
import 'fill_blank_screen.dart';
import 'map_tap_game.dart';

/// ステージ詳細画面（クエスト一覧）
class StageDetailScreen extends ConsumerWidget {
  final String stageId;

  const StageDetailScreen({
    Key? key,
    required this.stageId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stageAsync = ref.watch(stageProvider(stageId));
    final questsAsync = ref.watch(questsByStageProvider(stageId));
    final userProgress = ref.watch(userProgressProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('ステージ詳細'),
        elevation: 0,
        backgroundColor: AppColors.primary,
      ),
      body: stageAsync.when(
        data: (stage) {
          if (stage == null) {
            return const Center(child: Text('ステージが見つかりません'));
          }

          final stageProgress = userProgress.getStageProgress(stageId);

          return questsAsync.when(
            data: (quests) {
              return _buildContent(context, ref, stage, quests, stageProgress);
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(
              child: Text('クエストを読み込めませんでした: $err'),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Text('ステージを読み込めませんでした: $err'),
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    Stage stage,
    List<Quest> quests,
    StageProgress stageProgress,
  ) {
    return CustomScrollView(
      slivers: [
        // ステージヘッダー
        SliverAppBar(
          pinned: true,
          expandedHeight: 200,
          backgroundColor: AppColors.primary,
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    stage.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    stage.description,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // 進捗表示
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${stageProgress.completedQuests.length}/${quests.length} 完了',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        '${stage.totalPoints}pt',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: quests.isEmpty ? 0.0 : stageProgress.completedQuests.length / quests.length,
                      minHeight: 8,
                      backgroundColor: Colors.white24,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // クエスト一覧
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                if (index >= quests.length) return null;

                final quest = quests[index];
                final isCompleted =
                    stageProgress.isQuestCompleted(quest.questNo);

                return _QuestTile(
                  quest: quest,
                  isCompleted: isCompleted,
                  onTap: () => _startQuest(
                    context,
                    ref,
                    stage,
                    quest,
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  void _startQuest(
    BuildContext context,
    WidgetRef ref,
    Stage stage,
    Quest quest,
  ) {
    Widget questScreen;

    // クエストタイプに応じて適切なスクリーンを選択
    switch (quest.type) {
      case 'multiple_choice':
        questScreen = QuizExecutionScreen(
          stage: stage,
          quest: quest,
        );
        break;
      case 'fill_blank':
        questScreen = FillBlankScreen(
          stage: stage,
          quest: quest,
        );
        break;
      case 'map_tap':
        questScreen = MapTapGame(
          stage: stage,
          quest: quest,
        );
        break;
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${quest.title}のクエストタイプが不明です'),
          ),
        );
        return;
    }

    // クエスト実行画面へナビゲート
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => questScreen,
      ),
    );
  }
}

/// クエストタイル
class _QuestTile extends StatelessWidget {
  final Quest quest;
  final bool isCompleted;
  final VoidCallback onTap;

  const _QuestTile({
    required this.quest,
    required this.isCompleted,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: isCompleted ? Colors.green[50] : Colors.white,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // クエスト番号
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isCompleted
                      ? AppColors.primary
                      : Colors.grey[300],
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: isCompleted
                      ? const Icon(Icons.check, color: Colors.white)
                      : Text(
                          '${quest.questNo}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 16),

              // クエスト情報
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      quest.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isCompleted ? Colors.grey : Colors.black,
                        decoration: isCompleted
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      quest.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: _getQuestTypeColor(),
                            borderRadius: BorderRadius.circular(3),
                          ),
                          child: Text(
                            _getQuestTypeLabel(),
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '+${quest.pointsReward}pt',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // 矢印
              const SizedBox(width: 8),
              Icon(
                Icons.arrow_forward,
                color: isCompleted ? Colors.grey[400] : AppColors.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getQuestTypeLabel() {
    switch (quest.type) {
      case 'map_tap':
        return 'マップ';
      case 'multiple_choice':
        return '選択肢';
      case 'fill_blank':
        return '穴埋め';
      default:
        return quest.type;
    }
  }

  Color _getQuestTypeColor() {
    switch (quest.type) {
      case 'map_tap':
        return Colors.blue;
      case 'multiple_choice':
        return Colors.orange;
      case 'fill_blank':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }
}
