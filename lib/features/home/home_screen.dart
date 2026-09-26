import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_core/shared_core.dart'
    show equippedItemsProvider, kCommonShopItems, screenTimeProvider, ScreenTimeLimitReachedWidget, FriendsListPage, DailyMissionPage, WeeklyBonusWidget, coinProvider, notificationProvider, NotificationBadge, NotificationListPage;
import '../../data/prefecture_data.dart';
import '../../data/kids_news.dart';
import '../../repositories/profile_repository.dart';
import '../../repositories/progress_repository.dart';
import '../../theme/app_theme.dart' show kSocialPrimary;
import '../../utils/constants.dart';
import '../../widgets/avatar_display_widget.dart';
import '../home/widgets/streak_banner.dart';
import '../home/widgets/daily_mission_card.dart';
import '../home/widgets/map_collection.dart';
import '../../providers/quiz_access_override_provider.dart';

/// 装着中のショップテーマ（category: '背景'）から背景色を取得。
/// 未装着、または themeData が無ければ null（デフォルト背景を使う）。
List<Color>? _equippedThemeColors(WidgetRef ref) {
  final themeId =
      ref.watch(equippedItemsProvider.select((s) => s.equippedByCategory['背景']));
  if (themeId == null) return null;
  final matches = kCommonShopItems.where((i) => i.id == themeId);
  final item = matches.isEmpty ? null : matches.first;
  final hexColors = item?.themeData?['colors'] as List<dynamic>?;
  if (hexColors == null) return null;
  return hexColors
      .map((h) => Color(int.parse((h as String).replaceFirst('#', '0xFF'))))
      .toList();
}

/// 装着中のショップフレーム（category: 'フレーム'）のSVGアセットパスを取得。
String? _equippedFrameAsset(WidgetRef ref) {
  final frameId = ref
      .watch(equippedItemsProvider.select((s) => s.equippedByCategory['フレーム']));
  if (frameId == null) return null;
  final matches = kCommonShopItems.where((i) => i.id == frameId);
  return matches.isEmpty ? null : matches.first.assetPath;
}

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _showScrollToTop = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final shouldShow = _scrollController.offset > 400;
    if (shouldShow != _showScrollToTop) {
      setState(() => _showScrollToTop = shouldShow);
    }
  }

  void _scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    // 利用時間制限（スクリーンタイム管理）: 1日の上限に達していれば
    // ホーム画面の代わりに全画面オーバーレイを表示する。
    // ref.watch で状態変化（1分ごとの加算・保護者による一時解除）を
    // 反映させたうえで、判定自体は notifier.isLimitReached に委ねる。
    ref.watch(screenTimeProvider);
    final screenTimeNotifier = ref.read(screenTimeProvider.notifier);
    if (screenTimeNotifier.isLimitReached) {
      return const ScreenTimeLimitReachedWidget(primaryColor: kSocialPrimary);
    }

    final progress = ref.watch(progressProvider);

    // おまかせ：未完了の都道府県からランダム選出（日付固定シードで毎日同じ）
    PrefectureData? dailyPref;
    bool isDailyCompleted = false;
    if (AppConstants.enableOmakase) {
      const allPrefectures = PrefectureDataList.all;
      final uncompletedPrefs = allPrefectures
          .where((p) => !(progress.prefectureProgress[p.id]?.isCompleted ?? false))
          .toList();
      final today = DateTime.now();
      final seed = today.year * 10000 + today.month * 100 + today.day;
      final rng = Random(seed);
      dailyPref = uncompletedPrefs.isNotEmpty
          ? uncompletedPrefs[rng.nextInt(uncompletedPrefs.length)]
          : allPrefectures[rng.nextInt(allPrefectures.length)];
      isDailyCompleted =
          progress.prefectureProgress[dailyPref.id]?.isCompleted ?? false;
    }

    // 現在のプロフィールを取得
    final activeProfile = ref.watch(activeProfileProvider);

    // 装着中のショップテーマ・フレーム（未装着なら null でデフォルト表示）
    final themeColors = _equippedThemeColors(ref);
    final frameAsset = _equippedFrameAsset(ref);

    return Scaffold(
      backgroundColor: themeColors == null ? null : Colors.transparent,
      appBar: AppBar(
        title: activeProfile != null
            ? Row(
                children: [
                  // Item 6/8: emoji ベースの表示を Avatar 画像モデルへ統一
                  const AvatarDisplayTiny(),
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
          // ショップ（実装中のため非表示）
          if (AppConstants.enableShop)
            IconButton(
              icon: const Icon(Icons.store),
              tooltip: 'ショップ',
              onPressed: () => context.push('/shop'),
            ),
          // デイリーミッション
          if (AppConstants.enableDailyMissionButton)
            IconButton(
              icon: const Icon(Icons.assignment),
              tooltip: 'デイリーミッション',
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => DailyMissionPage(
                      primaryColor: kSocialPrimary,
                      appTitle: '小学コレ！社会',
                      filterSubject: 'social',
                    ),
                  ),
                );
              },
            ),
          // フレンドボタン（Phase 4.4 フレンド機能）
          IconButton(
            icon: const Icon(Icons.people),
            tooltip: 'フレンド',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const FriendsListPage()),
              );
            },
          ),
          // Phase 4.23: ローカル通知・リマインダーシステム
          GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const NotificationListPage()),
              );
            },
            child: const NotificationBadge(),
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
      body: Container(
        decoration: themeColors == null
            ? null
            : BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    themeColors.first.withValues(alpha: 0.25),
                    themeColors.last.withValues(alpha: 0.08),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
        child: ListView(
          controller: _scrollController,
          padding: const EdgeInsets.all(16.0),
          children: [
          // ── まなぶセクション ──────────────────────────────
          _MenuSectionHeader(label: 'ま な ぶ', icon: '📚'),
          const SizedBox(height: 12),
          // Phase 4.20: 週次ボーナスウィジェット
          WeeklyBonusWidget(
            onBonusClaimed: (coins) {
              ref.read(coinProvider.notifier).addCoins(coins);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('週次ボーナス獲得！ $coins コイン'),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          // ── 学習セクション（study screens: 解説・学習ハブ画面） ──
          const Text(
            '📚 学習をはじめる',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          // Item 1: カテゴリ一覧を直接ホームに統合（旧 /category 画面を統合）
          // 学習系（解説・学習ハブ）画面に遷移するカードのみを表示する
          const _CategoryGrid(categories: _studyCategories),
          const SizedBox(height: 24),

          // ── 問題セクション（quiz screens: クイズ・再挑戦画面） ──
          const Text(
            '✏️ 問題をとく',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          // クイズ・再挑戦系画面に遷移するカードのみを表示する
          const _CategoryGrid(categories: _quizCategories),
          const SizedBox(height: 8),
          // 今日のクイズボタン（AppConstants.enableDailyQuiz で無効化中）
          if (AppConstants.enableDailyQuiz) ...[
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.today),
                label: const Text('今日のクイズ'),
                onPressed: () => context.push('/daily-quiz'),
              ),
            ),
            const SizedBox(height: 12),
          ],
          // 対戦ボタン（AppConstants.enableMultiplayer で制御）
          if (AppConstants.enableMultiplayer) ...[
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
          ],
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
          const SizedBox(height: 24),
          // ── アバター表示 ───────────────────────────────────────
          Center(
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Column(
                  children: [
                    Stack(
                      alignment: Alignment.topCenter,
                      children: [
                        const AvatarDisplayLarge(showLabel: true),
                        // 装着中のフレームをアバター画像の上に重ねる
                        if (frameAsset != null)
                          IgnorePointer(
                            child: SvgPicture.asset(
                              frameAsset,
                              width: 144,
                              height: 144,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: 160,
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.edit),
                        label: const Text('変更'),
                        onPressed: () => context.push('/profile-settings'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          StreakBanner(streak: progress.streak),
          const SizedBox(height: 16),
          if (AppConstants.enableOmakase && dailyPref != null) ...[
            Builder(builder: (context) {
              final pref = dailyPref!;
              return DailyMissionCard(
                prefectureId: pref.id,
                prefectureName: '${pref.emoji} ${pref.name}',
                isCompleted: isDailyCompleted,
                onTap: () => context.push('/quiz/${pref.id}?daily=true'),
              );
            }),
            const SizedBox(height: 16),
          ],
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
                // 実際のアクセス権（サブスク or 無料期間中）と一致させる。
                hasAccess: ref.watch(canAccessSocialQuizzesProvider),
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
      ),
      floatingActionButton: _showScrollToTop
          ? FloatingActionButton(
              heroTag: 'scroll_to_top',
              tooltip: 'トップに戻る',
              onPressed: _scrollToTop,
              child: const Icon(Icons.arrow_upward),
            )
          : null,
    );
  }
}

// ─── メニューセクションヘッダー ──────────────────────────────────────

class _MenuSectionHeader extends StatelessWidget {
  final String label;
  final String icon;

  const _MenuSectionHeader({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          icon,
          style: const TextStyle(fontSize: 22),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        const Expanded(
          child: Padding(
            padding: EdgeInsets.only(left: 12),
            child: Divider(height: 1),
          ),
        ),
      ],
    );
  }
}

// ─── カテゴリ一覧グリッド（旧 category_screen.dart を統合） ──────────────

class _CategoryInfo {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final bool isNew;
  final String route;

  const _CategoryInfo({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    this.isNew = false,
    required this.route,
  });
}

// 学習（study/解説・学習ハブ）画面に遷移するカード。
// router.dart 上でこれらの route が指すのは、いずれもクイズに直接遷移せず、
// 学習コンテンツ・セクション一覧を表示する「学習ハブ」画面（例: Grade3Screen,
// WorldGeographyScreen 等）または地図学習画面（JapanMapScreen）である。
const List<_CategoryInfo> _studyCategories = [
  _CategoryInfo(
    title: '日本の地理',
    description: '都道府県・地方区分・特産物を覚えよう',
    icon: Icons.map,
    color: Colors.green,
    route: '/japan-map',
  ),
  _CategoryInfo(
    title: '世界の地理',
    description: '世界の国々・首都・地形を学ぼう',
    icon: Icons.public,
    color: Colors.blue,
    route: '/world-geography',
  ),
  _CategoryInfo(
    title: '小3 社会科',
    description: '地図記号・方位・昔のくらし・消防・警察',
    icon: Icons.school,
    color: Color(0xFF00ACC1),
    route: '/grade3',
  ),
  _CategoryInfo(
    title: '小4 社会科',
    description: '都道府県・地方区分・山川湖・防災',
    icon: Icons.map_outlined,
    color: Color(0xFF00897B),
    isNew: true,
    route: '/grade4',
  ),
  _CategoryInfo(
    title: '環境・SDGs',
    description: '地球温暖化・SDGs・3R・公害',
    icon: Icons.eco,
    color: Color(0xFF43A047),
    isNew: true,
    route: '/environment',
  ),
  _CategoryInfo(
    title: '小5 産業・環境',
    description: '農業・水産業・工業・公害・情報化社会',
    icon: Icons.factory,
    color: Color(0xFF00897B),
    route: '/industry',
  ),
  _CategoryInfo(
    title: '小6 公民',
    description: '憲法・三権分立・税金・選挙',
    icon: Icons.gavel,
    color: Color(0xFF6A1B9A),
    route: '/civics',
  ),
  _CategoryInfo(
    title: '経済・政治',
    description: '日本の経済と政治のしくみ',
    icon: Icons.account_balance,
    color: Colors.orange,
    route: '/economics',
  ),
  _CategoryInfo(
    title: '国際',
    description: '世界とのつながりを学ぼう',
    icon: Icons.language,
    color: Colors.purple,
    route: '/international',
  ),
  _CategoryInfo(
    title: '歴史',
    description: '日本の歴史の流れをつかもう',
    icon: Icons.history_edu,
    color: Colors.brown,
    route: '/history',
  ),
];

// 問題（quiz/クイズ・再挑戦）画面に直接遷移するカード。
// '/wrong-answer-review' は WrongAnswerReviewScreen（間違えた問題を解き直す
// クイズ画面）、'/world-quiz' は WorldQuizScreen（クイズ画面）に遷移する。
const List<_CategoryInfo> _quizCategories = [
  _CategoryInfo(
    title: 'まちがい復習',
    description: '間違えた問題をもう一度やり直そう',
    icon: Icons.replay,
    color: Color(0xFFE53935),
    route: '/wrong-answer-review',
  ),
  _CategoryInfo(
    title: '世界の地理クイズ',
    description: '世界の国々・首都・地形の問題にちょうせん',
    icon: Icons.quiz,
    color: Colors.indigo,
    route: '/world-quiz',
  ),
];

class _CategoryGrid extends StatelessWidget {
  final List<_CategoryInfo> categories;
  const _CategoryGrid({required this.categories});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.95,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) => _HomeCategoryCard(info: categories[index]),
    );
  }
}

class _HomeCategoryCard extends StatelessWidget {
  final _CategoryInfo info;
  const _HomeCategoryCard({required this.info});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push(info.route),
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(color: info.color.withValues(alpha: 0.08)),
              padding: const EdgeInsets.all(12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(info.icon, size: 40, color: info.color),
                  const SizedBox(height: 8),
                  Text(
                    info.title,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    info.description,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            if (info.isNew)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(color: Colors.orange.withOpacity(0.4), blurRadius: 4, offset: const Offset(0, 2)),
                    ],
                  ),
                  child: const Text(
                    'NEW',
                    style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
          ],
        ),
      ),
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