import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_core/providers/premium_provider.dart';
import 'package:shared_core/widgets/premium_gate_widget.dart';
import '../models/ranking_entry_model.dart';
import '../models/user_stats_model.dart';
import '../providers/ranking_provider.dart';

const _rankingImagePath = 'assets/images/ranking';
const _subjectId = 'social';
const _primaryColor = Colors.purple;

class RankingScreen extends ConsumerWidget {
  const RankingScreen({super.key});

  void _showSubscriptionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('プレミアム機能'),
        content: const Text(
          'この機能は月額¥120のプレミアム会員向けです。'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: RevenueCat の購入フロー
            },
            child: const Text('今すぐ購読'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final premiumState = ref.watch(premiumProvider);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('ランキング'),
          centerTitle: true,
          backgroundColor: _primaryColor,
          actions: [
            IconButton(
              icon: const Icon(Icons.people_outline),
              tooltip: '友達管理',
              onPressed: () => context.push('/friends'),
            ),
          ],
          bottom: TabBar(
            labelStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            unselectedLabelStyle: const TextStyle(
              fontSize: 14,
              color: Colors.white70,
            ),
            indicatorSize: TabBarIndicatorSize.tab,
            indicatorColor: Colors.white,
            tabs: [
              const Tab(text: 'フレンド'),
              Tab(
                text: 'プライベート ${premiumState.isSubscribed ? '' : '🔒'}',
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // フレンドランキング
            _FriendRankingView(),

            // プライベートマッチ（プレミアム限定）
            PremiumGateWidget(
              featureName: 'プライベートマッチ',
              onPremiumAccess: () => _showSubscriptionDialog(context),
              child: _PrivateMatchTabView(),
            ),
          ],
        ),
      ),
    );
  }
}

class _FriendRankingTabView extends ConsumerWidget {
  const _FriendRankingTabView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rankingAsync = ref.watch(friendsRankingProvider);

    return rankingAsync.when(
      data: (entries) {
        if (entries.isEmpty) {
          return const Center(
            child: Text('友達を追加するとここにランキングが表示されます'),
          );
        }

        return ListView.builder(
          itemCount: entries.length,
          itemBuilder: (context, index) {
            final entry = entries[index];
            return _FriendRankCard(
              entry: entry,
              index: index,
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(
        child: Text('ランキングを読み込めません: $err'),
      ),
    );
  }
}

class _FriendRankCard extends StatelessWidget {
  final RankingEntry entry;
  final int index;

  const _FriendRankCard({
    required this.entry,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final rank = index + 1;
    final frameAsset = _frameAssetForRank(rank);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: rank <= 3 ? _getRankColor(rank) : Colors.grey.shade200,
          width: rank <= 3 ? 2 : 1,
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
          _RankBadge(rank: rank),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.isNamePublic
                      ? entry.displayName
                      : 'プレイヤー #${entry.userId.substring(0, 4).toUpperCase()}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${entry.totalCorrect}問正解 (${(entry.correctRate * 100).toStringAsFixed(1)}%)',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
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
      return Image.asset(
        medalAsset,
        width: 40,
        height: 40,
        errorBuilder: (context, error, stackTrace) {
          return _RankCircleBadge(rank: rank);
        },
      );
    }

    return _RankCircleBadge(rank: rank);
  }
}

class _RankCircleBadge extends StatelessWidget {
  final int rank;

  const _RankCircleBadge({required this.rank});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: const BoxDecoration(
        color: _primaryColor,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          '$rank',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}

/// フレンドランキング表示（バナー付き）
class _FriendRankingView extends StatelessWidget {
  const _FriendRankingView();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Image.asset(
          '$_rankingImagePath/ranking_header_banner.png',
          width: double.infinity,
          height: 120,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              height: 120,
              color: _primaryColor.withOpacity(0.3),
              child: const Center(
                child: Icon(Icons.image_not_supported),
              ),
            );
          },
        ),
        const Expanded(
          child: _FriendRankingTabView(),
        ),
      ],
    );
  }
}

/// プライベートマッチ UI（プレミアム限定）
class _PrivateMatchTabView extends ConsumerWidget {
  const _PrivateMatchTabView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        // ヘッダーバナー
        Container(
          height: 120,
          color: _primaryColor.withOpacity(0.2),
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.lock_open, size: 32, color: _primaryColor),
                SizedBox(height: 8),
                Text(
                  'プライベートマッチ',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _primaryColor,
                  ),
                ),
              ],
            ),
          ),
        ),
        // プライベートマッチ機能パネル
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // 対戦相手選択カード
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'フレンドと対戦',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'フレンドを選択してプライベートマッチを開始できます',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // マッチ開始ボタン
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _startPrivateMatch(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'マッチを開始',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _startPrivateMatch(BuildContext context) async {
    // TODO: Firestore でプライベートマッチセッション作成
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('プライベートマッチを開始しました')),
    );
  }
}
