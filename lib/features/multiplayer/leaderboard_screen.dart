import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/match_provider.dart';
import '../../repositories/profile_repository.dart';

class LeaderboardScreen extends ConsumerWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final leaderboardAsync = ref.watch(leaderboardProvider);
    final profiles = ref.watch(profilesProvider);
    final activeId = ref.watch(activeProfileIdProvider);
    final activeProfile = profiles.isNotEmpty
        ? profiles.firstWhere((p) => p.id == activeId, orElse: () => profiles.first)
        : null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('ランキング'),
        elevation: 0,
      ),
      body: leaderboardAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('エラー: $err')),
        data: (leaderboard) {
          if (leaderboard.isEmpty) {
            return const Center(child: Text('ランキングがまだありません'));
          }

          final myRank = activeProfile != null
              ? leaderboard
                  .indexWhere((u) => u['userId'] == activeProfile.id)
              : -1;

          return CustomScrollView(
            slivers: [
              // トップ3表示
              SliverToBoxAdapter(
                child: _buildTopThree(leaderboard),
              ),
              SliverToBoxAdapter(child: const SizedBox(height: 24)),

              // 自分の順位（トップ3外の場合）
              if (myRank > 2 && activeProfile != null)
                SliverToBoxAdapter(
                  child: _buildMyRank(leaderboard, myRank, activeProfile),
                ),
              if (myRank > 2 && activeProfile != null)
                SliverToBoxAdapter(child: const SizedBox(height: 16)),

              // ランキング一覧（4位以降）
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final rank = index + 1;
                    if (rank <= 3) return const SizedBox.shrink();
                    if (rank > leaderboard.length) return null;

                    final user = leaderboard[index];
                    return _buildRankCard(rank, user);
                  },
                  childCount: leaderboard.length,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTopThree(List<Map<String, dynamic>> leaderboard) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        children: [
          const Text(
            'TOP 3',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (leaderboard.length > 1)
                _buildMedalCard(
                  rank: 2,
                  user: leaderboard[1],
                  medal: '🥈',
                  height: 140,
                ),
              if (leaderboard.isNotEmpty)
                _buildMedalCard(
                  rank: 1,
                  user: leaderboard[0],
                  medal: '🥇',
                  height: 180,
                ),
              if (leaderboard.length > 2)
                _buildMedalCard(
                  rank: 3,
                  user: leaderboard[2],
                  medal: '🥉',
                  height: 100,
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMedalCard({
    required int rank,
    required Map<String, dynamic> user,
    required String medal,
    required double height,
  }) {
    return SizedBox(
      height: height,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            medal,
            style: const TextStyle(fontSize: 40),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.amber.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.amber.shade200),
            ),
            child: Column(
              children: [
                Text(
                  user['userName'] ?? 'Player',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '${(user['ratingScore'] ?? 1500).toStringAsFixed(0)}',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMyRank(
    List<Map<String, dynamic>> leaderboard,
    int rank,
    dynamic myProfile,
  ) {
    final user = leaderboard[rank];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.blue.shade300, width: 2),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Text(
                  '#${rank + 1}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    myProfile.name ?? 'You',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'あなたの順位',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            Text(
              '${(user['ratingScore'] ?? 1500).toStringAsFixed(0)}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRankCard(int rank, Map<String, dynamic> user) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Text(
                    '#$rank',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user['userName'] ?? 'Player',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '勝率: ${((user['matchWins'] ?? 0) / (user['matchCount'] ?? 1) * 100).toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${(user['ratingScore'] ?? 1500).toStringAsFixed(0)}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
