import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_progress.dart';
import '../repositories/progress_repository.dart';

/// 学習セッションを記録・管理するサービス
class LearningSessionService {
  final ProgressRepository progressRepo;

  LearningSessionService({required this.progressRepo});

  /// 学習セッションを開始
  /// 終了時に endSession を呼んで記録する
  DateTime _sessionStart = DateTime.now();
  String? _currentActivityType;

  void startSession(String? activityType) {
    _sessionStart = DateTime.now();
    _currentActivityType = activityType;
  }

  /// 学習セッションを終了して記録
  Future<void> endSession() async {
    final now = DateTime.now();
    final durationSeconds = now.difference(_sessionStart).inSeconds;

    // 最小1秒のセッションは無視
    if (durationSeconds < 1) return;

    final session = LearningSession(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      startedAt: _sessionStart,
      endedAt: now,
      durationSeconds: durationSeconds,
      activityType: _currentActivityType,
    );

    final current = progressRepo.loadLocal();
    final updated = current.copyWith(
      learningSessions: [...current.learningSessions, session],
    );
    progressRepo.saveLocal(updated);

    _currentActivityType = null;
  }

  /// 今日の学習時間を取得（分）
  int getTodaysLearningMinutes() {
    final current = progressRepo.loadLocal();
    return current.todaysLearningMinutes;
  }

  /// 今週の学習時間を取得（分）
  int getWeeklyLearningMinutes() {
    final current = progressRepo.loadLocal();
    return current.weeklyLearningMinutes;
  }

  /// 今週の平均学習時間を取得（分）
  int getWeeklyAverageLearningMinutes() {
    final current = progressRepo.loadLocal();
    return current.weeklyAverageLearningMinutes;
  }

  /// 総学習時間を取得（分）
  int getTotalLearningMinutes() {
    final current = progressRepo.loadLocal();
    return current.totalLearningMinutes;
  }

  /// 過去N日間の学習日数
  int getLearningDaysInRange(int days) {
    final current = progressRepo.loadLocal();
    final now = DateTime.now();
    final rangeStart = now.subtract(Duration(days: days));

    final uniqueDays = <DateTime>{};
    for (final session in current.learningSessions) {
      if (session.startedAt.isAfter(rangeStart)) {
        uniqueDays.add(DateTime(
          session.startedAt.year,
          session.startedAt.month,
          session.startedAt.day,
        ));
      }
    }
    return uniqueDays.length;
  }
}

/// LearningSessionService プロバイダー
final learningSessionServiceProvider = Provider<LearningSessionService>((ref) {
  final progressRepo = ref.watch(progressRepositoryProvider);
  return LearningSessionService(progressRepo: progressRepo);
});

/// 今日の学習時間プロバイダー（分）
final todaysLearningMinutesProvider = StateProvider<int>((ref) {
  final service = ref.watch(learningSessionServiceProvider);
  return service.getTodaysLearningMinutes();
});

/// 今週の学習時間プロバイダー（分）
final weeklyLearningMinutesProvider = StateProvider<int>((ref) {
  final service = ref.watch(learningSessionServiceProvider);
  return service.getWeeklyLearningMinutes();
});

/// 今週の平均学習時間プロバイダー（分）
final weeklyAverageLearningMinutesProvider = StateProvider<int>((ref) {
  final service = ref.watch(learningSessionServiceProvider);
  return service.getWeeklyAverageLearningMinutes();
});

/// 総学習時間プロバイダー（分）
final totalLearningMinutesProvider = StateProvider<int>((ref) {
  final service = ref.watch(learningSessionServiceProvider);
  return service.getTotalLearningMinutes();
});
