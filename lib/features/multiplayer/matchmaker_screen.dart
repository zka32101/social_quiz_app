import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/match.dart';
import '../../models/player_stats.dart';
import '../../providers/match_provider.dart';
import '../../providers/matchmaking_provider.dart';
import '../../repositories/profile_repository.dart';

class MatchmakerScreen extends ConsumerWidget {
  const MatchmakerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeProfile = ref.watch(activeProfileProvider);

    if (activeProfile == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('対戦')),
        body: const Center(child: Text('プロフィールを選択してください')),
      );
    }

    // プレイヤー統計を取得
    final statsAsync = ref.watch(playerStatsProvider({
      'userId': activeProfile.id,
      'userName': activeProfile.name,
      'userEmoji': activeProfile.emoji,
    }));

    return Scaffold(
      appBar: AppBar(
        title: const Text('対戦'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.leaderboard),
            tooltip: 'ランキング',
            onPressed: () => context.push('/leaderboard'),
          ),
        ],
      ),
      body: statsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('エラー: $e')),
        data: (stats) => _buildBody(context, ref, stats),
      ),
    );
  }

  Widget _buildBody(
      BuildContext context, WidgetRef ref, PlayerStats stats) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPlayerCard(stats),
          const SizedBox(height: 24),
          _buildMatchHistory(ref, stats.userId),
          const SizedBox(height: 24),
          _buildQuickMatchButton(context, stats),
        ],
      ),
    );
  }

  Widget _buildPlayerCard(PlayerStats stats) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade400, Colors.blue.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: const BoxDecoration(
              color: Colors.white24,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(stats.userEmoji,
                  style: const TextStyle(fontSize: 36)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  stats.userName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'レート: ${stats.ratingScore.toStringAsFixed(0)}',
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _buildStatChip('${stats.matchWins}勝', Colors.green.shade300),
              const SizedBox(height: 4),
              _buildStatChip('${stats.matchLosses}敗', Colors.red.shade300),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.3),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color, width: 1),
      ),
      child: Text(
        label,
        style: TextStyle(
            color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildMatchHistory(WidgetRef ref, String userId) {
    final historyAsync = ref.watch(userMatchHistoryProvider(userId));

    return historyAsync.when(
      loading: () =>
          const Center(child: CircularProgressIndicator(strokeWidth: 2)),
      error: (e, _) => Text('対戦履歴の取得に失敗: $e',
          style: const TextStyle(color: Colors.grey)),
      data: (matches) {
        if (matches.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Column(
                children: [
                  Icon(Icons.sports_score,
                      size: 48, color: Colors.grey.shade400),
                  const SizedBox(height: 8),
                  Text(
                    'まだ対戦がありません',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('最近の対戦',
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
                Text('${matches.length}戦',
                    style: TextStyle(
                        color: Colors.grey.shade600, fontSize: 13)),
              ],
            ),
            const SizedBox(height: 12),
            ...matches.take(5).map((m) => _buildMatchCard(m, userId)),
          ],
        );
      },
    );
  }

  Widget _buildMatchCard(Match match, String userId) {
    final isP1 = match.player1Id == userId;
    final myScore = isP1 ? match.player1Score : match.player2Score;
    final opponentScore = isP1 ? match.player2Score : match.player1Score;
    final isWin = match.winner == userId;
    final isDraw = match.winner == 'draw';

    final resultColor = isDraw
        ? Colors.orange
        : isWin
            ? Colors.green
            : Colors.red.shade400;
    final resultLabel = isDraw ? '引き分け' : isWin ? '勝利' : '敗北';

    final daysAgo = match.completedAt != null
        ? DateTime.now().difference(match.completedAt!).inDays
        : 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 6,
              height: 48,
              decoration: BoxDecoration(
                color: resultColor,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(resultLabel,
                      style: TextStyle(
                          color: resultColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 13)),
                  const SizedBox(height: 2),
                  Text('$myScore - $opponentScore',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            Text(
              daysAgo == 0 ? '今日' : '$daysAgo日前',
              style:
                  TextStyle(color: Colors.grey.shade500, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickMatchButton(BuildContext context, PlayerStats stats) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: const Icon(Icons.search),
        label: const Text(
          'クイックマッチ',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: Colors.purple,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: () => context.push(
          '/matching-waiting',
          extra: stats,
        ),
      ),
    );
  }
}
