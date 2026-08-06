import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'utils/constants.dart';
import 'features/splash/splash_screen.dart';
import 'features/home/home_screen.dart';
import 'screens/daily_quiz_screen.dart';
import 'screens/ranking_screen.dart';
import 'features/category/category_screen.dart';
import 'features/japan_map/japan_map_screen.dart';
import 'features/japan_map/prefecture_detail_screen.dart';
import 'features/badge/badge_screen.dart';
import 'features/shop/shop_screen.dart';
import 'features/prefecture/prefecture_list_screen.dart';
import 'features/prefecture/study_screen.dart';
import 'features/prefecture/quiz_screen.dart';
import 'features/prefecture/result_screen.dart';
import 'features/settings/settings_screen.dart';
import 'features/paywall/paywall_screen.dart';
import 'features/economics/economics_screen.dart';
import 'features/economics/economics_quiz_screen.dart';
import 'features/history/history_screen.dart';
import 'features/history/history_era_screen.dart';
import 'features/profile/profile_selection_screen.dart';
import 'features/profile/profile_creation_screen.dart';
import 'features/international/international_screen.dart';
import 'features/international/international_quiz_screen.dart';
import 'features/world_map/world_geography_screen.dart';
import 'features/world_map/world_quiz_screen.dart';
import 'features/how_to/how_to_screen.dart';
import 'features/grade3/grade3_screen.dart';
import 'features/grade3/grade3_quiz_screen.dart';
import 'features/grade4/grade4_screen.dart';
import 'features/grade4/grade4_quiz_screen.dart';
import 'features/grade4/region_map_screen.dart';
import 'features/environment/environment_screen.dart';
import 'features/environment/environment_quiz_screen.dart';
import 'features/civics/civics_screen.dart';
import 'features/civics/civics_quiz_screen.dart';
import 'features/industry/industry_screen.dart';
import 'features/industry/industry_quiz_screen.dart';
import 'features/review/wrong_answer_review_screen.dart';
import 'features/character/character_screen.dart';
import 'features/multiplayer/matchmaker_screen.dart';
import 'features/multiplayer/multiplayer_quiz_screen.dart';
import 'features/multiplayer/leaderboard_screen.dart';
import 'features/multiplayer/matching_waiting_screen.dart';
import 'features/settings/parent_report_screen.dart';
import 'models/player_stats.dart';
import 'theme/app_theme.dart';

/// GoRouter 設定
final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.splash,
  routes: [
    GoRoute(
      path: AppRoutes.splash,
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: AppRoutes.home,
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/daily-quiz',
      builder: (context, state) => const DailyQuizScreen(),
    ),
    GoRoute(
      path: '/ranking',
      builder: (context, state) => const RankingScreen(),
    ),
    GoRoute(
      path: AppRoutes.prefectureList,
      builder: (context, state) => const PrefectureListScreen(),
    ),
    GoRoute(
      path: '/study/:prefectureId',
      builder: (context, state) {
        final prefId = state.pathParameters['prefectureId']!;
        final stepNo = int.tryParse(state.uri.queryParameters['step'] ?? '1') ?? 1;
        return StudyScreen(prefectureId: prefId, initialStep: stepNo);
      },
    ),
    GoRoute(
      path: '/quiz/:prefectureId',
      builder: (context, state) {
        final prefId = state.pathParameters['prefectureId']!;
        final daily = state.uri.queryParameters['daily'] == 'true';
        return QuizScreen(prefectureId: prefId, dailyMode: daily);
      },
    ),
    GoRoute(
      path: '/result/:prefectureId',
      builder: (context, state) {
        final prefId = state.pathParameters['prefectureId']!;
        final extra = state.extra as Map<String, dynamic>?;
        return ResultScreen(
          prefectureId: prefId,
          totalPoints: extra?['totalPoints'] as int? ?? 0,
          correctCount: extra?['correctCount'] as int? ?? 0,
          totalCount: extra?['totalCount'] as int? ?? 10,
          newBadgeId: extra?['newBadgeId'] as String?,
          coinsEarned: extra?['coinsEarned'] as int? ?? 0,
        );
      },
    ),
    GoRoute(
      path: '/category',
      builder: (context, state) => const CategoryScreen(),
    ),
    GoRoute(
      path: '/japan-map',
      builder: (context, state) => const JapanMapScreen(),
    ),
    GoRoute(
      path: '/prefecture/:prefectureId',
      builder: (context, state) {
        final prefId = state.pathParameters['prefectureId']!;
        return PrefectureDetailScreen(prefectureId: prefId);
      },
    ),
    GoRoute(
      path: '/badges',
      builder: (context, state) => const BadgeScreen(),
    ),
    GoRoute(
      path: '/shop',
      builder: (context, state) => const ShopScreen(),
    ),
    GoRoute(
      path: AppRoutes.settings,
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(
      path: AppRoutes.paywall,
      builder: (context, state) => const PaywallScreen(),
    ),
    GoRoute(
      path: '/economics',
      builder: (context, state) => const EconomicsScreen(),
    ),
    GoRoute(
      path: '/economics-quiz/:sectionId',
      builder: (context, state) => EconomicsQuizScreen(sectionId: state.pathParameters['sectionId']!),
    ),
    GoRoute(
      path: '/history',
      builder: (context, state) => const HistoryScreen(),
    ),
    GoRoute(
      path: '/history-era/:eraId',
      builder: (context, state) => HistoryEraScreen(eraId: state.pathParameters['eraId']!),
    ),
    GoRoute(
      path: '/profile-selection',
      builder: (context, state) => const ProfileSelectionScreen(),
    ),
    GoRoute(
      path: '/profile-create',
      builder: (context, state) => const ProfileCreationScreen(),
    ),
    GoRoute(
      path: '/international',
      builder: (context, state) => const InternationalScreen(),
    ),
    GoRoute(
      path: '/international-quiz/:sectionId',
      builder: (context, state) => InternationalQuizScreen(
        sectionId: state.pathParameters['sectionId']!,
      ),
    ),
    GoRoute(
      path: '/world-geography',
      builder: (context, state) => const WorldGeographyScreen(),
    ),
    GoRoute(
      path: '/world-quiz',
      builder: (context, state) => const WorldQuizScreen(),
    ),
    GoRoute(
      path: '/how-to',
      builder: (context, state) => const HowToScreen(),
    ),
    // ── 小3・公民・産業 ───────────────────────────────
    GoRoute(
      path: '/grade3',
      builder: (context, state) => const Grade3Screen(),
    ),
    GoRoute(
      path: '/grade3-quiz/:sectionId',
      builder: (context, state) => Grade3QuizScreen(
        sectionId: state.pathParameters['sectionId']!,
      ),
    ),
    // ── 小4・環境 ─────────────────────────────────────
    GoRoute(
      path: '/grade4',
      builder: (context, state) => const Grade4Screen(),
    ),
    GoRoute(
      path: '/grade4-quiz/:sectionId',
      builder: (context, state) => Grade4QuizScreen(
        sectionId: state.pathParameters['sectionId']!,
      ),
    ),
    GoRoute(
      path: '/region-map',
      builder: (context, state) => const RegionMapScreen(),
    ),
    GoRoute(
      path: '/environment',
      builder: (context, state) => const EnvironmentScreen(),
    ),
    GoRoute(
      path: '/environment-quiz/:sectionId',
      builder: (context, state) => EnvironmentQuizScreen(
        sectionId: state.pathParameters['sectionId']!,
      ),
    ),
    GoRoute(
      path: '/civics',
      builder: (context, state) => const CivicsScreen(),
    ),
    GoRoute(
      path: '/civics-quiz/:sectionId',
      builder: (context, state) => CivicsQuizScreen(
        sectionId: state.pathParameters['sectionId']!,
      ),
    ),
    GoRoute(
      path: '/industry',
      builder: (context, state) => const IndustryScreen(),
    ),
    GoRoute(
      path: '/industry-quiz/:sectionId',
      builder: (context, state) => IndustryQuizScreen(
        sectionId: state.pathParameters['sectionId']!,
      ),
    ),
    // ── 復習 ─────────────────────────────────────────
    GoRoute(
      path: '/wrong-answer-review',
      builder: (context, state) => const WrongAnswerReviewScreen(),
    ),
    // ── キャラクター ──────────────────────────────────
    GoRoute(
      path: '/characters',
      builder: (context, state) => const CharacterScreen(),
    ),
    // ── マルチプレイ ──────────────────────────────────
    GoRoute(
      path: '/multiplayer',
      builder: (context, state) => const MatchmakerScreen(),
    ),
    GoRoute(
      path: '/matching-waiting',
      builder: (context, state) {
        final stats = state.extra as PlayerStats;
        return MatchingWaitingScreen(myStats: stats);
      },
    ),
    GoRoute(
      path: '/multiplayer-quiz/:matchId',
      builder: (context, state) {
        final matchId = state.pathParameters['matchId']!;
        final userId = state.uri.queryParameters['userId'] ?? '';
        return MultiplayerQuizScreen(matchId: matchId, userId: userId);
      },
    ),
    GoRoute(
      path: '/leaderboard',
      builder: (context, state) => const LeaderboardScreen(),
    ),
    GoRoute(
      path: '/parent-report',
      builder: (context, state) => const ParentReportScreen(),
    ),
  ],
);

/// アプリのルートウィジェット
class SocialQuizApp extends StatelessWidget {
  const SocialQuizApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: buildSocialTheme(),
      routerConfig: appRouter,
    );
  }
}
