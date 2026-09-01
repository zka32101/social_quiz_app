import 'package:riverpod/riverpod.dart';
import 'package:social_quiz_app/repositories/progress_repository.dart';
import 'package:social_quiz_app/services/quiz_history_service.dart';
import 'package:social_quiz_app/services/milestone_notification_service.dart';

/// クイズのマイルストーン達成を自動検出し、バッジを授与するサービス
class QuizAchievementService {
  final QuizHistoryService _historyService;
  final MilestoneNotificationService _notificationService;
  final ProgressRepository _progressRepo;

  const QuizAchievementService({
    required QuizHistoryService historyService,
    required MilestoneNotificationService notificationService,
    required ProgressRepository progressRepo,
  })  : _historyService = historyService,
        _notificationService = notificationService,
        _progressRepo = progressRepo;

  /// 達成可能なすべてのバッジをチェック
  Future<List<String>> checkAndAwardAchievements() async {
    final awardedBadges = <String>[];

    // 各達成条件をチェック
    if (await _checkPerfectStreakAchievements()) {
      awardedBadges.addAll(_getPerfectStreakBadges());
    }

    if (await _checkQuizMasterAchievement()) {
      awardedBadges.add('quiz_master');
    }

    if (await _checkSpeedChampionAchievement()) {
      awardedBadges.add('speed_champion');
    }

    if (await _checkQuizLegendAchievement()) {
      awardedBadges.add('quiz_legend');
    }

    if (await _checkAccuracyImprovement()) {
      awardedBadges.add('improvement_expert');
    }

    if (await _checkConsecutiveQuestMaster()) {
      awardedBadges.add('quest_master');
    }

    return awardedBadges;
  }

  /// Perfect Streak達成をチェック (5+, 10+, 20+)
  Future<bool> _checkPerfectStreakAchievements() async {
    final consecutiveCount = _historyService.getConsecutiveCorrectCount();
    return consecutiveCount >= 5;
  }

  /// Perfect Streakの段階別バッジを取得
  List<String> _getPerfectStreakBadges() {
    final consecutiveCount = _historyService.getConsecutiveCorrectCount();
    final badges = <String>[];

    if (consecutiveCount >= 20) {
      badges.add('perfect_streak_20');
    } else if (consecutiveCount >= 10) {
      badges.add('perfect_streak_10');
    } else if (consecutiveCount >= 5) {
      badges.add('perfect_streak_5');
    }

    return badges;
  }

  /// Quiz Master: 90%+ 正答率を達成
  Future<bool> _checkQuizMasterAchievement() async {
    final stats = _historyService.getOverallStats();
    return stats.averageAccuracy >= 90.0 && stats.totalAttempts >= 10;
  }

  /// Speed Champion: 平均2秒以下/問で回答
  Future<bool> _checkSpeedChampionAchievement() async {
    final stats = _historyService.getOverallStats();
    // 平均回答時間 < 2秒かつ、最低20問以上の実績
    return stats.averageTimePerQuestion < 2.0 &&
        stats.totalQuestions >= 20;
  }

  /// Quiz Legend: 100問以上実施
  Future<bool> _checkQuizLegendAchievement() async {
    final stats = _historyService.getOverallStats();
    return stats.totalQuestions >= 100;
  }

  /// 改善の達人: 改善傾向を継続している
  Future<bool> _checkAccuracyImprovement() async {
    return _historyService.isImprovingTrend(sampleSize: 10);
  }

  /// クエストマスター: ステージクイズで90%+ 正答率
  Future<bool> _checkConsecutiveQuestMaster() async {
    final stats = _historyService.getOverallStats();
    return stats.totalAttempts >= 50 && stats.averageAccuracy >= 90.0;
  }

  /// 条件を満たしたバッジを取得（未授与のもののみ）
  Future<List<String>> getUnacquiredAchievements(List<String> currentBadges) async {
    final allPossible = await checkAndAwardAchievements();
    return allPossible
        .where((badge) => !currentBadges.contains(badge))
        .toList();
  }

  /// バッジを授与してNotificationを作成
  Future<void> awardBadgeWithNotification(
    String badgeId,
    String badgeName,
  ) async {
    try {
      // 通知を作成（バッジのメタデータ付き）
      await _notificationService.notifyBadgeEarned(badgeId, badgeName);
    } catch (e) {
      debugPrint('バッジ授与通知の作成に失敗: $e');
    }
  }
}

/// Riverpod プロバイダ
final quizAchievementServiceProvider = Provider((ref) {
  final historyService = ref.watch(quizHistoryServiceProvider);
  final notificationService = ref.watch(milestoneNotificationServiceProvider);
  final progressRepo = ref.watch(progressRepositoryProvider);

  return QuizAchievementService(
    historyService: historyService,
    notificationService: notificationService,
    progressRepo: progressRepo,
  );
});

/// 新規達成可能なバッジをチェック
final unacquiredAchievementsProvider =
    FutureProvider.family<List<String>, List<String>>((ref, currentBadges) async {
  final service = ref.watch(quizAchievementServiceProvider);
  return service.getUnacquiredAchievements(currentBadges);
});

/// 完璧な連続チェーンをチェック
final perfectStreakCheckProvider = FutureProvider<int>((ref) async {
  final service = ref.watch(quizAchievementServiceProvider);
  return service._historyService.getConsecutiveCorrectCount();
});

/// Quiz Master条件チェック
final quizMasterCheckProvider = FutureProvider<bool>((ref) async {
  final service = ref.watch(quizAchievementServiceProvider);
  return service._checkQuizMasterAchievement();
});

/// Speed Champion条件チェック
final speedChampionCheckProvider = FutureProvider<bool>((ref) async {
  final service = ref.watch(quizAchievementServiceProvider);
  return service._checkSpeedChampionAchievement();
});

/// Quiz Legend条件チェック
final quizLegendCheckProvider = FutureProvider<bool>((ref) async {
  final service = ref.watch(quizAchievementServiceProvider);
  return service._checkQuizLegendAchievement();
});

/// 改善の達人条件チェック
final improvementExpertCheckProvider = FutureProvider<bool>((ref) async {
  final service = ref.watch(quizAchievementServiceProvider);
  return service._checkAccuracyImprovement();
});
