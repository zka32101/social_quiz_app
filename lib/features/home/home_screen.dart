import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/prefecture_data.dart';
import '../../data/kids_news.dart';
import '../../repositories/profile_repository.dart';
import '../../repositories/progress_repository.dart';
import '../home/widgets/streak_banner.dart';
import '../home/widgets/daily_mission_card.dart';
import '../home/widgets/map_collection.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(progressProvider);

    // おまかせ：未完了の都道府県からランダム選出（日付固定シードで毎日同じ）
    const allPrefectures = PrefectureDataList.all;
    final uncompletedPrefs = allPrefectures
        .where((p) => !(progress.prefectureProgress[p.id]?.isCompleted ?? false))
        .toList();
    final today = DateTime.now();
    final seed = today.year * 10000 + today.month * 100 + today.day;
    final rng = Random(seed);
    final dailyPref = uncompletedPrefs.isNotEmpty
        ? uncompletedPrefs[rng.nextInt(uncompletedPrefs.length)]
        : allPrefectures[rng.nextInt(allPrefectures.length)];
    final isDailyCompleted =
        progress.prefectureProgress[dailyPref.id]?.isCompleted ?? false;

    // 現在のプロフィールを取得
    final activeProfile = ref.watch(activeProfileProvider);

    return Scaffold(
      appBar: AppBar(
        title: activeProfile != null
            ? Row(
                children: [
                  Text(activeProfile.emoji, style: const TextStyle(fontSize: 20)),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      activeProfile.name,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              )
            : const Text('小学コレ！社会'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.amber.shade700,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('🪙', style: TextStyle(fontSize: 14)),
                    const SizedBox(width: 2),
                    Text(
                      '${progress.coins}',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.switch_account),
            tooltip: 'プロフィール切替',
            onPressed: () => context.push('/profile-selection'),
          ),
          IconButton(
            icon: const Icon(Icons.face_retouching_natural),
            tooltip: 'キャラクター',
            onPressed: () => context.push('/characters'),
          ),
          IconButton(
            icon: const Icon(Icons.store),
            tooltip: 'ショップ',
            onPressed: () => context.push('/shop'),
          ),
          IconButton(
            icon: const Icon(Icons.help_outline),
            tooltip: '使い方',
            onPressed: () => context.push('/how-to'),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: '設定',
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.map),
              label: const Text(
                '学習をはじめる',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () => context.push('/category'),
            ),
          ),
          const SizedBox(height: 16),
          // 対戦ボタン
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.sports_score),
              label: const Text(
                'フレンドと対戦',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () => context.push('/multiplayer'),
            ),
          ),
          const SizedBox(height: 8),
          // 今日のクイズボタン
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton.icon(
              icon: const Icon(Icons.today),
              label: const Text('今日のクイズ'),
              onPressed: () => context.push('/daily-quiz'),
            ),
          ),
          const SizedBox(height: 8),
          // ランキングボタン
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton.icon(
              icon: Image.asset(
                'assets/images/ranking/button_view_ranking.png',
                width: 22,
                height: 22,
              ),
              label: const Text('ランキングを見る'),
              onPressed: () => context.push('/ranking'),
            ),
          ),
          const SizedBox(height: 16),
          // ── 新カテゴリ紹介 ───────────────────────────────────
          _NewCategoryBanner(),
          const SizedBox(height: 16),
          StreakBanner(streak: progress.streak),
          const SizedBox(height: 16),
          DailyMissionCard(
            prefectureId: dailyPref.id,
            prefectureName: '${dailyPref.emoji} ${dailyPref.name}',
            isCompleted: isDailyCompleted,
            onTap: () => context.push('/quiz/${dailyPref.id}?daily=true'),
          ),
          const SizedBox(height: 16),
          // 今日のニュース
          _KidsNewsCard(),
          const SizedBox(height: 16),
          // 都道府県制覇進捗カード
          _PrefectureProgressCard(progress: progress),
          const SizedBox(height: 16),
          // 都道府県コレクション（地方ごとのマス目表示）
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: MapCollection(
                prefectureProgress: progress.prefectureProgress,
                isPremium: progress.isPremium,
                onPrefectureTap: (prefId) => context.push('/study/$prefId'),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // まちがい復習カード
          if (progress.wrongAnswerIds.isNotEmpty)
            GestureDetector(
              onTap: () => context.push('/wrong-answer-review'),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFE53935), Color(0xFFC62828)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Text('📝', style: TextStyle(fontSize: 32)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('まちがい復習ノート',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                          Text('${progress.wrongAnswerIds.length} 問 たまっています',
                              style: const TextStyle(color: Colors.white70, fontSize: 13)),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
                  ],
                ),
              ),
            ),
          if (progress.wrongAnswerIds.isNotEmpty) const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(Icons.emoji_events, color: Colors.amber, size: 28),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('総獲得ポイント', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      Text('${progress.totalPoints} pt', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── 新カテゴリ紹介バナー ──────────────────────────────────────────

class _NewCategoryBanner extends StatelessWidget {
  static const _items = [
    (icon: '🗾', title: '小4 社会科', route: '/grade4', color: Color(0xFF00897B)),
    (icon: '🌍', title: '環境・SDGs', route: '/environment', color: Color(0xFF43A047)),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.orange,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text('NEW', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(width: 8),
            const Text('新しいカテゴリ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: _items.map((item) {
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: item.route == _items.last.route ? 0 : 8),
                child: GestureDetector(
                  onTap: () => context.push(item.route),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [item.color, item.color.withOpacity(0.75)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(color: item.color.withOpacity(0.3), blurRadius: 6, offset: const Offset(0, 3)),
                      ],
                    ),
                    child: Row(
                      children: [
                        Text(item.icon, style: const TextStyle(fontSize: 22)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            item.title,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const Icon(Icons.arrow_forward_ios, color: Colors.white70, size: 14),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

// ─── 都道府県制覇進捗カード ───────────────────────────────────────

class _PrefectureProgressCard extends StatelessWidget {
  final UserProgress progress;
  const _PrefectureProgressCard({required this.progress});

  @override
  Widget build(BuildContext context) {
    const total = 47;
    final completed = progress.prefectureProgress.values
        .where((p) => p.isCompleted)
        .length;
    final ratio = completed / total;

    // 達成度に応じたメッセージ
    final String message;
    final Color barColor;
    if (completed == 0) {
      message = 'さあ、日本地図を完成させよう！';
      barColor = Colors.blue.shade300;
    } else if (completed < 10) {
      message = 'まだまだこれから！続けよう 💪';
      barColor = Colors.blue.shade400;
    } else if (completed < 25) {
      message = 'いい調子！半分まであと少し 🔥';
      barColor = Colors.orange.shade400;
    } else if (completed < 47) {
      message = '後半戦！ゴールはもうすぐ ⭐';
      barColor = Colors.deepOrange.shade400;
    } else {
      message = '🎉 全都道府県制覇おめでとう！！';
      barColor = Colors.green.shade500;
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('🗾', style: TextStyle(fontSize: 22)),
                const SizedBox(width: 8),
                const Text(
                  '都道府県せいは',
                  style: TextStyle(fontSize: 13, color: Colors.grey),
                ),
                const Spacer(),
                Text(
                  '$completed / $total 県',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: ratio,
                minHeight: 10,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(barColor),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── 今日のニュース ───────────────────────────────────────

class _KidsNewsCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // 日付ベースでニュースをローテーション
    final today = DateTime.now();
    final seed = today.year * 10000 + today.month * 100 + today.day;
    final rng = Random(seed);
    final todayNews = kidsNewsList[rng.nextInt(kidsNewsList.length)];

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF81C784), Color(0xFF66BB6A)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('📰', style: TextStyle(fontSize: 20)),
                const SizedBox(width: 8),
                const Text(
                  '今日のニュース',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    todayNews.relevantCategory,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              todayNews.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.bold,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              todayNews.description,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}