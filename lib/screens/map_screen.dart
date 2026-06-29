import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/map_provider.dart';

/// 日本一周マップ踏破画面
class MapScreen extends ConsumerWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressAsync = ref.watch(mapProgressProvider);
    final countAsync = ref.watch(clearedPrefectureCountProvider);
    final statesAsync = ref.watch(prefectureStatesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('日本全国制覇！'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 進捗バー
            progressAsync.when(
              data: (progress) => Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        countAsync.when(
                          data: (count) =>
                              Text('$count/47 都道府県', style: Theme.of(context).textTheme.titleMedium),
                          loading: () => const Text('読込中...'),
                          error: (e, st) => const Text('エラー'),
                        ),
                        countAsync.when(
                          data: (count) =>
                              Text('${(progress * 100).toStringAsFixed(1)}%'),
                          loading: () => const Text('...'),
                          error: (e, st) => const Text('-'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 12,
                        backgroundColor: Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation(
                          progress == 1.0 ? Colors.amber : Colors.blue,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              loading: () => const Padding(
                padding: EdgeInsets.all(16),
                child: LinearProgressIndicator(),
              ),
              error: (e, st) => Padding(
                padding: const EdgeInsets.all(16),
                child: Text('エラーが発生しました: $e'),
              ),
            ),
            const SizedBox(height: 16),
            // 地図プレースホルダー
            // 将来的に JapanMapWidget に置き換え
            statesAsync.when(
              data: (states) => _buildMapPlaceholder(context, states),
              loading: () => const Padding(
                padding: EdgeInsets.all(32),
                child: CircularProgressIndicator(),
              ),
              error: (e, st) => Padding(
                padding: const EdgeInsets.all(16),
                child: Text('地図データの読み込みに失敗しました'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 地図プレースホルダー（UIプレビュー用）
  Widget _buildMapPlaceholder(BuildContext context, Map<String, int> states) {
    // 地方ごとのクリア状態
    const regions = {
      '北海道': ['hokkaido'],
      '東北': [
        'aomori',
        'iwate',
        'miyagi',
        'akita',
        'yamagata',
        'fukushima',
      ],
      '関東': [
        'tokyo',
        'kanagawa',
        'saitama',
        'chiba',
        'ibaraki',
        'tochigi',
        'gunma',
      ],
      '中部': [
        'niigata',
        'toyama',
        'ishikawa',
        'fukui',
        'yamanashi',
        'nagano',
        'gifu',
        'shizuoka',
        'aichi',
      ],
      '関西': [
        'mie',
        'shiga',
        'kyoto',
        'osaka',
        'hyogo',
        'nara',
        'wakayama',
      ],
      '中国': ['tottori', 'shimane', 'okayama', 'hiroshima', 'yamaguchi'],
      '四国': ['tokushima', 'kagawa', 'ehime', 'kochi'],
      '九州': [
        'fukuoka',
        'saga',
        'nagasaki',
        'kumamoto',
        'oita',
        'miyazaki',
        'kagoshima',
        'okinawa',
      ],
    };

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: regions.entries.map((e) {
          final regionName = e.key;
          final prefectures = e.value;
          final clearedCount =
              prefectures.where((p) => (states[p] ?? 0) == 1).length;
          final isRegionCleared = clearedCount == prefectures.length;

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        regionName,
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      Text(
                        '$clearedCount/${prefectures.length}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: clearedCount / prefectures.length,
                      minHeight: 8,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation(
                        isRegionCleared ? Colors.amber : Colors.blue,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: prefectures.map((pref) {
                      final isCleared = (states[pref] ?? 0) == 1;
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: isCleared ? Colors.blue[100] : Colors.grey[300],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          isCleared ? '✓$pref' : pref,
                          style: TextStyle(
                            fontSize: 12,
                            color: isCleared ? Colors.blue[900] : Colors.grey[700],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
