import 'package:riverpod/riverpod.dart';
import 'package:social_quiz_app/models/quiz_attempt.dart';
import 'package:social_quiz_app/repositories/quiz_history_repository.dart';

/// クイズ履歴を管理し、統計情報を提供するサービス
class QuizHistoryService {
  final QuizHistoryRepository _repo;

  const QuizHistoryService({required QuizHistoryRepository repo}) : _repo = repo;

  /// クイズ試行を記録
  Future<void> recordAttempt(QuizAttempt attempt) async {
    await _repo.add(attempt);
  }

  /// 全試行履歴を取得
  List<QuizAttempt> getAllAttempts() {
    return _repo.getAll();
  }

  /// ステージ別の試行履歴
  List<QuizAttempt> getStageAttempts(int stageNo) {
    return _repo.getByStage(stageNo);
  }

  /// 最近のN件を取得
  List<QuizAttempt> getRecentAttempts({int limit = 10}) {
    return _repo.getRecent(limit: limit);
  }

  /// 今日の試行を取得
  List<QuizAttempt> getTodaysAttempts() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    return _repo.getByDateRange(today, tomorrow);
  }

  /// 今週の試行を取得
  List<QuizAttempt> getThisWeeksAttempts() {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekStartDate = DateTime(weekStart.year, weekStart.month, weekStart.day);
    final weekEnd = weekStartDate.add(const Duration(days: 7));
    return _repo.getByDateRange(weekStartDate, weekEnd);
  }

  /// 統計情報を取得（全体）
  QuizHistoryStats getOverallStats() {
    return _repo.getStats();
  }

  /// ステージ別の統計情報を取得
  QuizHistoryStats getStageStats(int stageNo) {
    return _repo.getStats(stageNo: stageNo);
  }

  /// 正答率の推移（最近10件）
  List<double> getAccuracyTrend({int limit = 10}) {
    final recent = getRecentAttempts(limit: limit);
    return recent.map((a) => a.accuracyPercentage).toList();
  }

  /// 改善傾向を判定（増加傾向: true）
  bool isImprovingTrend({int sampleSize = 5}) {
    final trend = getAccuracyTrend(limit: sampleSize);
    if (trend.length < 2) return false;

    // 最初の半分と後半の半分で比較
    final firstHalf = trend.sublist(0, (trend.length / 2).ceil());
    final secondHalf = trend.sublist((trend.length / 2).ceil());

    final firstAvg = firstHalf.isEmpty ? 0.0 : firstHalf.reduce((a, b) => a + b) / firstHalf.length;
    final secondAvg = secondHalf.isEmpty ? 0.0 : secondHalf.reduce((a, b) => a + b) / secondHalf.length;

    return secondAvg > firstAvg;
  }

  /// ステージ別の平均正答率
  Map<int, double> getStageAccuracyMap() {
    final attempts = getAllAttempts();
    final stages = <int>{};

    for (final attempt in attempts) {
      stages.add(attempt.stageNo);
    }

    final result = <int, double>{};
    for (final stage in stages) {
      final stats = getStageStats(stage);
      result[stage] = stats.averageAccuracy;
    }

    return result;
  }

  /// 最も得意なステージを取得
  int? getBestStage() {
    final map = getStageAccuracyMap();
    if (map.isEmpty) return null;

    int bestStage = 0;
    double bestAccuracy = 0.0;

    map.forEach((stage, accuracy) {
      if (accuracy > bestAccuracy) {
        bestAccuracy = accuracy;
        bestStage = stage;
      }
    });

    return bestStage;
  }

  /// 最も苦手なステージを取得
  int? getWorstStage() {
    final map = getStageAccuracyMap();
    if (map.isEmpty) return null;

    int worstStage = 0;
    double worstAccuracy = 100.0;

    map.forEach((stage, accuracy) {
      if (accuracy < worstAccuracy) {
        worstAccuracy = accuracy;
        worstStage = stage;
      }
    });

    return worstStage;
  }

  /// 連続正解回数（現在）
  int getConsecutiveCorrectCount() {
    final recent = getRecentAttempts(limit: 20);
    int count = 0;

    for (final attempt in recent) {
      if (attempt.isPerfect) {
        count++;
      } else {
        break;
      }
    }

    return count;
  }

  /// 最高連続正解回数
  int getMaxConsecutiveCorrect() {
    final attempts = getAllAttempts();
    if (attempts.isEmpty) return 0;

    int maxConsecutive = 0;
    int currentConsecutive = 0;

    for (final attempt in attempts.reversed) {
      if (attempt.isPerfect) {
        currentConsecutive++;
        maxConsecutive = currentConsecutive > maxConsecutive ? currentConsecutive : maxConsecutive;
      } else {
        currentConsecutive = 0;
      }
    }

    return maxConsecutive;
  }

  /// 試行削除
  Future<void> deleteAttempt(String id) async {
    await _repo.delete(id);
  }

  /// 全削除
  Future<void> clearHistory() async {
    await _repo.clear();
  }
}

// Riverpod プロバイダ
final quizHistoryServiceProvider = Provider((ref) {
  final repo = ref.watch(quizHistoryRepositoryProvider);
  return QuizHistoryService(repo: repo);
});

// 統計情報を監視するプロバイダ
final quizOverallStatsProvider = StateNotifierProvider<OverallStatsNotifier, QuizHistoryStats>((ref) {
  final service = ref.watch(quizHistoryServiceProvider);
  return OverallStatsNotifier(service, service.getOverallStats());
});

final accuracyTrendProvider = Provider((ref) {
  final service = ref.watch(quizHistoryServiceProvider);
  return service.getAccuracyTrend();
});

final isImprovingTrendProvider = Provider((ref) {
  final service = ref.watch(quizHistoryServiceProvider);
  return service.isImprovingTrend();
});

final bestStageProvider = Provider((ref) {
  final service = ref.watch(quizHistoryServiceProvider);
  return service.getBestStage();
});

final worstStageProvider = Provider((ref) {
  final service = ref.watch(quizHistoryServiceProvider);
  return service.getWorstStage();
});

final consecutiveCorrectCountProvider = Provider((ref) {
  final service = ref.watch(quizHistoryServiceProvider);
  return service.getConsecutiveCorrectCount();
});

final maxConsecutiveCorrectProvider = Provider((ref) {
  final service = ref.watch(quizHistoryServiceProvider);
  return service.getMaxConsecutiveCorrect();
});

class OverallStatsNotifier extends StateNotifier<QuizHistoryStats> {
  final QuizHistoryService _service;

  OverallStatsNotifier(this._service, QuizHistoryStats initialState) : super(initialState);

  Future<void> refresh() async {
    state = _service.getOverallStats();
  }

  Future<void> recordAttempt(QuizAttempt attempt) async {
    await _service.recordAttempt(attempt);
    state = _service.getOverallStats();
  }
}
