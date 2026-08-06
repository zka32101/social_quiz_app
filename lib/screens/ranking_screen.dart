import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/ranking_entry_model.dart';
import '../models/user_stats_model.dart';
import '../providers/ranking_provider.dart';

const _rankingImagePath = 'assets/images/ranking';

class RankingScreen extends ConsumerWidget {
  const RankingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('ランキング'),
          centerTitle: true,
          bottom: const TabBar(
            tabs: [
              Tab(text: '全国ランキング'),
              Tab(text: '週間ランキング'),
            ],
          ),
        ),
        body: Column(
          children: [
            Image.asset(
              '$_rankingImagePath/ranking_header_banner.png',
              width: double.infinity,
              height: 120,
              fit: BoxFit.cover,
            ),
            const Expanded(
              child: TabBarView(
                children: [
                  RankingListView(rankingType: 'global'),
                  RankingListView(rankingType: 'weekly'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RankingListView extends ConsumerWidget {
  final String rankingType;

  const RankingListView({required this.rankingType, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rankingAsync = rankingType == 'global'
        ? ref.watch(globalRankingProvider)
        : ref.watch(weeklyRankingProvider);

    final currentStatsAsync = ref.watch(currentUserStatsProvider);
    final currentRankAsync = ref.watch(currentUserRankProvider);

    return rankingAsync.when(
      data: (entries) {
        if (entries.isEmpty) {
          return const Center(
            child: Text('ランキングデータがまだありません'),
          );
        }

        return ListView(
          children: [
            // 週間タブのみ：リセット案内バナー
            if (rankingType == 'weekly') const _WeeklyResetBanner(),

            // ユーザーの現在順位
            currentStatsAsync.when(
              data: (stats) {
                if (stats == null) return const SizedBox.shrink();
                final rank = currentRankAsync.asData?.value;
                return Column(
                  children: [
                    if (rank == 1) const _NumberOneJapanBanner(),
                    CurrentUserRankCard(stats: stats, rank: rank),
                  ],
                );
              },
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),

            // ランキングリスト
            ...entries.map(
              (entry) => RankingListTile(entry: entry),
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(
        child: Text('ランキングを読み込めません: $err'),
      ),
    );
  }
}

class _WeeklyResetBanner extends StatelessWidget {
  const _WeeklyResetBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Image.asset(
            '$_rankingImagePath/weekly_reset_notification.png',
            width: 28,
            height: 28,
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              '週間ランキングは毎週日曜0時にリセットされます',
              style: TextStyle(fontSize: 12, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}

class _NumberOneJapanBanner extends StatelessWidget {
  const _NumberOneJapanBanner();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.asset(
          '$_rankingImagePath/banner_number_one_japan.png',
          width: double.infinity,
          height: 140,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

class CurrentUserRankCard extends StatelessWidget {
  final UserStats stats;
  final int? rank;

  const CurrentUserRankCard({required this.stats, this.rank, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        border: Border.all(color: Colors.blue),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            rank != null ? 'あなたの順位: 全国$rank位' : 'あなたのスコア',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          Text(
            '${stats.totalScore} 点',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.blue,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _CorrectRateBar(correctRate: stats.correctRate),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _StatItem(label: '正解', value: '${stats.totalCorrect}'),
              _StatItem(
                label: '正解率',
                value: '${(stats.correctRate * 100).toStringAsFixed(1)}%',
              ),
              _StatItem(label: 'バッジ', value: '${stats.badgeCount}'),
            ],
          ),
        ],
      ),
    );
  }
}

class _CorrectRateBar extends StatelessWidget {
  final double correctRate;

  const _CorrectRateBar({required this.correctRate});

  @override
  Widget build(BuildContext context) {
    final ratio = correctRate.clamp(0.0, 1.0);
    return LayoutBuilder(
      builder: (context, constraints) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: Stack(
            children: [
              Container(height: 12, color: Colors.grey.shade200),
              SizedBox(
                width: constraints.maxWidth * ratio,
                height: 12,
                child: Image.asset(
                  '$_rankingImagePath/progress_bar_bg.png',
                  fit: BoxFit.cover,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;

  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

class RankingListTile extends StatelessWidget {
  final RankingEntry entry;

  const RankingListTile({required this.entry, super.key});

  @override
  Widget build(BuildContext context) {
    final frameAsset = _frameAssetForRank(entry.rank);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: entry.rank <= 3 ? _getRankColor(entry.rank) : Colors.grey.shade200,
          width: entry.rank <= 3 ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(8),
        image: frameAsset != null
            ? DecorationImage(
                image: AssetImage(frameAsset),
                fit: BoxFit.fill,
              )
            : null,
      ),
      child: Row(
        children: [
          // 順位アイコン（トップ3はメダル画像、それ以外は番号）
          _RankBadge(rank: entry.rank),
          const SizedBox(width: 12),

          // 名前 + 詳細
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.displayName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  '${entry.totalCorrect}問正解 (${(entry.correctRate * 100).toStringAsFixed(1)}%)',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),

          // スコア表示
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${entry.totalScore}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                'バッジ: ${entry.badgeCount}',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static String? _frameAssetForRank(int rank) {
    switch (rank) {
      case 1:
        return '$_rankingImagePath/frame_gold.png';
      case 2:
        return '$_rankingImagePath/frame_silver.png';
      case 3:
        return '$_rankingImagePath/frame_bronze.png';
      default:
        return null;
    }
  }

  static Color _getRankColor(int rank) {
    if (rank == 1) return Colors.amber;
    if (rank == 2) return Colors.grey.shade400;
    return Colors.orange.shade600;
  }
}

class _RankBadge extends StatelessWidget {
  final int rank;

  const _RankBadge({required this.rank});

  @override
  Widget build(BuildContext context) {
    final medalAsset = switch (rank) {
      1 => '$_rankingImagePath/medal_gold.png',
      2 => '$_rankingImagePath/medal_silver.png',
      3 => '$_rankingImagePath/medal_bronze.png',
      _ => null,
    };

    if (medalAsset != null) {
      return Image.asset(medalAsset, width: 40, height: 40);
    }

    return Container(
      width: 40,
      height: 40,
      decoration: const BoxDecoration(
        color: Colors.blue,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          '$rank',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
