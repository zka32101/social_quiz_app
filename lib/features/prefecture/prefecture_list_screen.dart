import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/prefecture_data.dart';
import '../../models/prefecture.dart';
import '../../models/user_progress.dart';
import '../../repositories/content_repository.dart';
import '../../repositories/progress_repository.dart';
import '../../utils/constants.dart';

class PrefectureListScreen extends ConsumerWidget {
  const PrefectureListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefecturesAsync = ref.watch(prefecturesProvider);
    final userProgress = ref.watch(userProgressProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('都道府県を選ぶ')),
      body: prefecturesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('エラー: $e')),
        data: (prefectures) => _buildList(context, prefectures, userProgress),
      ),
    );
  }

  Widget _buildList(
    BuildContext context,
    List<Prefecture> prefectures,
    UserProgress userProgress,
  ) {
    // 地方ごとにグループ化
    final grouped = <String, List<Prefecture>>{};
    for (final pref in prefectures) {
      grouped.putIfAbsent(pref.region, () => []).add(pref);
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // 地方ごとの一覧
        for (final regionEntry in PrefectureDataList.regionLabels.entries) ...[
          if (grouped.containsKey(regionEntry.key)) ...[
            Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 8),
              child: Text(
                regionEntry.value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
            ),
            ...grouped[regionEntry.key]!.map((pref) {
              return _buildPrefectureCard(
                context,
                pref,
                userProgress.getProgress(pref.id),
              );
            }),
          ],
        ],
      ],
    );
  }

  Widget _buildPrefectureCard(
    BuildContext context,
    Prefecture pref,
    PrefectureProgress progress,
  ) {
    final isCompleted = progress.isCompleted;
    final stepsCompleted = progress.completedSteps.length;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => context.push('/study/${pref.id}'),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              // 都道府県アイコン
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: isCompleted
                      ? Colors.green.shade100
                      : Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Text(
                    isCompleted ? '⭐' : '🗾',
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              // 都道府県名・進捗
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pref.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: List.generate(3, (i) {
                        final stepCompleted =
                            progress.completedSteps.contains(i + 1);
                        return Container(
                          width: 20,
                          height: 6,
                          margin: const EdgeInsets.only(right: 4),
                          decoration: BoxDecoration(
                            color: stepCompleted
                                ? const Color(AppColors.primaryValue)
                                : Colors.grey[200],
                            borderRadius: BorderRadius.circular(3),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isCompleted
                          ? '制覇済み！ベストスコア: ${progress.quizBestScore}/10'
                          : stepsCompleted > 0
                              ? 'STEP $stepsCompleted/3 完了'
                              : 'まだ学習していない',
                      style: TextStyle(
                        fontSize: 12,
                        color: isCompleted ? Colors.green : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
