import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/daily_history_provider.dart';
import '../providers/map_provider.dart';
import '../widgets/daily_history_card.dart';
import 'map_screen.dart';

/// ホーム画面
class HomeScreen extends ConsumerWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dailyHistory = ref.watch(todayHistoryProvider);
    final isDailyCompleted = ref.watch(isDailyQuizCompletedProvider);
    final isDailyCorrect = ref.watch(isDailyQuizCorrectProvider);
    final clearedCount = ref.watch(clearedPrefectureCountProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('社会'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // プレイヤー情報バー
            Container(
              color: Colors.blue[50],
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'プレイヤー',
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Guest',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      clearedCount.when(
                        data: (count) => Text(
                          '都道府県: $count/47',
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                        loading: () => const Text('読込中...'),
                        error: (e, st) => const Text('-'),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // デイリーヒストリーカード
            dailyHistory.when(
              data: (history) {
                if (history == null) {
                  return Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'デイリークイズはまだ準備中です',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  );
                }

                return isDailyCompleted.when(
                  data: (completed) {
                    return isDailyCorrect.when(
                      data: (correct) {
                        return DailyHistoryCard(
                          history: history,
                          isCompleted: completed,
                          isCorrect: correct,
                          onQuizTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('クイズ機能は実装準備中です'),
                              ),
                            );
                          },
                        );
                      },
                      loading: () => const Padding(
                        padding: EdgeInsets.all(16),
                        child: CircularProgressIndicator(),
                      ),
                      error: (e, st) => Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text('エラー: $e'),
                      ),
                    );
                  },
                  loading: () => const Padding(
                    padding: EdgeInsets.all(16),
                    child: CircularProgressIndicator(),
                  ),
                  error: (e, st) => Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text('エラー: $e'),
                  ),
                );
              },
              loading: () => const Padding(
                padding: EdgeInsets.all(32),
                child: CircularProgressIndicator(),
              ),
              error: (e, st) => Padding(
                padding: const EdgeInsets.all(16),
                child: Text('デイリークイズの読み込みに失敗しました: $e'),
              ),
            ),

            const SizedBox(height: 20),

            // メインメニュー
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  // マップボタン
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (ctx) => const MapScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.map),
                    label: const Text('日本全国制覇！'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 56),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // クイズボタン（将来実装）
                  OutlinedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('クイズ機能は準備中です'),
                        ),
                      );
                    },
                    icon: const Icon(Icons.quiz),
                    label: const Text('クイズプレイ'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 56),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // スコアボタン（将来実装）
                  OutlinedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('スコア画面は準備中です'),
                        ),
                      );
                    },
                    icon: const Icon(Icons.bar_chart),
                    label: const Text('スコア確認'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 56),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // フッター
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.grey[100],
              child: Text(
                'v1.1.0 - 社会',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
