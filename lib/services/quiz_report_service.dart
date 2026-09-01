import 'package:intl/intl.dart';
import 'package:riverpod/riverpod.dart';
import 'package:social_quiz_app/services/quiz_history_service.dart';
import 'package:social_quiz_app/models/user_progress.dart';

/// クイズ分析レポート生成サービス
class QuizReportService {
  final QuizHistoryService _historyService;

  const QuizReportService({required QuizHistoryService historyService})
      : _historyService = historyService;

  /// 週間レポートを生成
  WeeklyReport generateWeeklyReport() {
    final weekAttempts = _historyService.getThisWeeksAttempts();
    final stats = _historyService.getOverallStats();

    // 日別の統計を計算
    final dailyStats = <String, DailyQuizStats>{};
    for (final attempt in weekAttempts) {
      final dateKey = DateFormat('yyyy-MM-dd').format(attempt.attemptedAt);
      dailyStats.putIfAbsent(
        dateKey,
        () => DailyQuizStats(date: attempt.attemptedAt, attempts: 0, correct: 0, total: 0),
      );
      final day = dailyStats[dateKey]!;
      day.attempts += 1;
      day.correct += attempt.correctCount;
      day.total += attempt.totalCount;
    }

    return WeeklyReport(
      weekStart: _getWeekStart(),
      weekEnd: _getWeekStart().add(const Duration(days: 7)),
      totalAttempts: weekAttempts.length,
      totalCorrect: weekAttempts.fold<int>(0, (sum, a) => sum + a.correctCount),
      totalQuestions: weekAttempts.fold<int>(0, (sum, a) => sum + a.totalCount),
      averageAccuracy: stats.averageAccuracy,
      dailyBreakdown: dailyStats,
      bestDayAccuracy: _getBestDayAccuracy(dailyStats),
      trend: _calculateTrend(weekAttempts),
    );
  }

  /// 月間レポートを生成
  MonthlyReport generateMonthlyReport() {
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);
    final monthEnd = monthStart.add(const Duration(days: 32));

    final monthAttempts = _historyService._repo.getByDateRange(monthStart, monthEnd);
    final stats = _historyService.getOverallStats();

    // 週別の統計を計算
    final weeklyStats = <int, WeeklyQuizStats>{};
    for (final attempt in monthAttempts) {
      final weekNum = _getWeekNumber(attempt.attemptedAt);
      weeklyStats.putIfAbsent(
        weekNum,
        () => WeeklyQuizStats(week: weekNum, attempts: 0, correct: 0, total: 0),
      );
      final week = weeklyStats[weekNum]!;
      week.attempts += 1;
      week.correct += attempt.correctCount;
      week.total += attempt.totalCount;
    }

    return MonthlyReport(
      year: now.year,
      month: now.month,
      monthName: DateFormat('M月', 'ja').format(now),
      totalAttempts: monthAttempts.length,
      totalCorrect: monthAttempts.fold<int>(0, (sum, a) => sum + a.correctCount),
      totalQuestions: monthAttempts.fold<int>(0, (sum, a) => sum + a.totalCount),
      averageAccuracy: stats.averageAccuracy,
      weeklyBreakdown: weeklyStats,
      improvementRate: _calculateMonthlyImprovement(monthAttempts),
    );
  }

  /// パフォーマンス分析レポートを生成
  PerformanceAnalysisReport generatePerformanceAnalysis() {
    final stats = _historyService.getOverallStats();
    final stageAccuracies = _historyService.getStageAccuracyMap();
    final bestStage = _historyService.getBestStage();
    final worstStage = _historyService.getWorstStage();
    final isImproving = _historyService.isImprovingTrend();

    return PerformanceAnalysisReport(
      overallAccuracy: stats.averageAccuracy,
      totalAttempts: stats.totalAttempts,
      totalCorrect: stats.totalCorrect,
      totalQuestions: stats.totalQuestions,
      bestScore: stats.bestScore,
      perfectAttempts: stats.perfectAttempts,
      perfectRate: stats.totalAttempts > 0
          ? (stats.perfectAttempts / stats.totalAttempts * 100)
          : 0.0,
      averageTimePerQuestion: stats.averageTimePerQuestion,
      stagePerformances: stageAccuracies,
      strongestStage: bestStage,
      weakestStage: worstStage,
      isImprovingTrend: isImproving,
      consecutiveCorrect: _historyService.getConsecutiveCorrectCount(),
      maxConsecutive: _historyService.getMaxConsecutiveCorrect(),
      recommendations: _generateRecommendations(stageAccuracies, bestStage, worstStage),
    );
  }

  /// 親向けのメール本文を生成
  String generateParentEmailBody({
    required String childName,
    required UserProgress progress,
    required DateTime reportDate,
  }) {
    final weeklyReport = generateWeeklyReport();
    final performanceReport = generatePerformanceAnalysis();
    final dateStr = DateFormat('M月d日', 'ja').format(reportDate);

    final buffer = StringBuffer();
    buffer.writeln('$childName さんの学習レポート - $dateStr');
    buffer.writeln('=' * 50);
    buffer.writeln('');

    // 概要
    buffer.writeln('📊 今週のクイズ成績');
    buffer.writeln('実施回数: ${weeklyReport.totalAttempts}回');
    buffer.writeln('正答率: ${weeklyReport.averageAccuracy.toStringAsFixed(1)}%');
    buffer.writeln('正解数: ${weeklyReport.totalCorrect}/${weeklyReport.totalQuestions}');
    buffer.writeln('');

    // パフォーマンス
    buffer.writeln('🎯 全体的なパフォーマンス');
    buffer.writeln('総クイズ数: ${performanceReport.totalAttempts}回');
    buffer.writeln('全体正答率: ${performanceReport.overallAccuracy.toStringAsFixed(1)}%');
    buffer.writeln('連続正解: ${performanceReport.consecutiveCorrect}回');
    buffer.writeln('最高連続: ${performanceReport.maxConsecutive}回');
    buffer.writeln('');

    // ステージ別パフォーマンス
    if (performanceReport.stagePerformances.isNotEmpty) {
      buffer.writeln('🎮 ステージ別正答率');
      performanceReport.stagePerformances.forEach((stage, accuracy) {
        buffer.writeln('  ステージ $stage: ${accuracy.toStringAsFixed(1)}%');
      });
      buffer.writeln('');
    }

    // 学習状況
    buffer.writeln('📈 学習状況');
    buffer.writeln('連続学習日数: ${progress.streak}日');
    buffer.writeln('総獲得ポイント: ${progress.totalPoints}pt');
    buffer.writeln('獲得バッジ: ${progress.badges.length}個');
    buffer.writeln('');

    // 推奨事項
    if (performanceReport.recommendations.isNotEmpty) {
      buffer.writeln('💡 学習ガイダンス');
      for (final rec in performanceReport.recommendations) {
        buffer.writeln('  • $rec');
      }
      buffer.writeln('');
    }

    // 改善状況
    if (performanceReport.isImprovingTrend) {
      buffer.writeln('✨ 素晴らしい！正答率が上昇傾向です');
    }

    buffer.writeln('');
    buffer.writeln('引き続き、楽しく学習してください！');

    return buffer.toString();
  }

  /// CSV形式の詳細レポートを生成
  String generateDetailedCSV() {
    final attempts = _historyService.getAllAttempts();
    final buffer = StringBuffer();

    // ヘッダー
    buffer.writeln('試行ID,日時,ステージ,正答数,総問題数,正答率,所要時間(秒),スコア');

    // データ行
    for (final attempt in attempts) {
      final accuracy = attempt.accuracyPercentage;
      buffer.writeln(
        '${attempt.id},'
        '${attempt.attemptedAt.toIso8601String()},'
        '${attempt.stageNo},'
        '${attempt.correctCount},'
        '${attempt.totalCount},'
        '${accuracy.toStringAsFixed(2)},'
        '${attempt.durationSeconds},'
        '${attempt.totalScore}',
      );
    }

    return buffer.toString();
  }

  // ─── ヘルパーメソッド ─────────────────────────────

  DateTime _getWeekStart() {
    final now = DateTime.now();
    return now.subtract(Duration(days: now.weekday - 1));
  }

  int _getWeekNumber(DateTime date) {
    final jan4 = DateTime(date.year, 1, 4);
    final dayOfWeek = jan4.weekday;
    final weekOne = jan4.subtract(Duration(days: dayOfWeek - 1));
    final diff = date.difference(weekOne).inDays;
    return (diff / 7).ceil();
  }

  double? _getBestDayAccuracy(Map<String, DailyQuizStats> dailyStats) {
    if (dailyStats.isEmpty) return null;

    double bestAccuracy = 0.0;
    for (final day in dailyStats.values) {
      if (day.total > 0) {
        final accuracy = (day.correct / day.total) * 100;
        if (accuracy > bestAccuracy) {
          bestAccuracy = accuracy;
        }
      }
    }
    return bestAccuracy;
  }

  TrendDirection _calculateTrend(List attempts) {
    if (attempts.length < 2) return TrendDirection.stable;

    final first = attempts.sublist(0, (attempts.length / 2).ceil());
    final second = attempts.sublist((attempts.length / 2).ceil());

    final firstAccuracy = first.isEmpty
        ? 0.0
        : (first.fold<int>(0, (sum, a) => sum + a.correctCount) /
                first.fold<int>(0, (sum, a) => sum + a.totalCount)) *
            100;

    final secondAccuracy = second.isEmpty
        ? 0.0
        : (second.fold<int>(0, (sum, a) => sum + a.correctCount) /
                second.fold<int>(0, (sum, a) => sum + a.totalCount)) *
            100;

    if (secondAccuracy > firstAccuracy + 5) {
      return TrendDirection.improving;
    } else if (secondAccuracy < firstAccuracy - 5) {
      return TrendDirection.declining;
    }
    return TrendDirection.stable;
  }

  double _calculateMonthlyImprovement(List attempts) {
    if (attempts.length < 2) return 0.0;

    final first = attempts.sublist(0, (attempts.length / 2).ceil());
    final second = attempts.sublist((attempts.length / 2).ceil());

    final firstAccuracy = first.isEmpty
        ? 0.0
        : (first.fold<int>(0, (sum, a) => sum + a.correctCount) /
                first.fold<int>(0, (sum, a) => sum + a.totalCount)) *
            100;

    final secondAccuracy = second.isEmpty
        ? 0.0
        : (second.fold<int>(0, (sum, a) => sum + a.correctCount) /
                second.fold<int>(0, (sum, a) => sum + a.totalCount)) *
            100;

    return secondAccuracy - firstAccuracy;
  }

  List<String> _generateRecommendations(
    Map<int, double> stageAccuracies,
    int? bestStage,
    int? worstStage,
  ) {
    final recommendations = <String>[];

    if (worstStage != null && stageAccuracies.containsKey(worstStage)) {
      recommendations.add('ステージ$worstStageの復習をおすすめします');
    }

    if (bestStage != null && stageAccuracies[bestStage]! >= 95) {
      recommendations.add('ステージ$bestStageでは素晴らしい成績です！');
    }

    if (_historyService.getOverallStats().averageAccuracy < 70) {
      recommendations.add('基礎からの復習をおすすめします');
    }

    return recommendations;
  }
}

// ─── データモデル ─────────────────────────────────

class WeeklyReport {
  final DateTime weekStart;
  final DateTime weekEnd;
  final int totalAttempts;
  final int totalCorrect;
  final int totalQuestions;
  final double averageAccuracy;
  final Map<String, DailyQuizStats> dailyBreakdown;
  final double? bestDayAccuracy;
  final TrendDirection trend;

  WeeklyReport({
    required this.weekStart,
    required this.weekEnd,
    required this.totalAttempts,
    required this.totalCorrect,
    required this.totalQuestions,
    required this.averageAccuracy,
    required this.dailyBreakdown,
    required this.bestDayAccuracy,
    required this.trend,
  });
}

class MonthlyReport {
  final int year;
  final int month;
  final String monthName;
  final int totalAttempts;
  final int totalCorrect;
  final int totalQuestions;
  final double averageAccuracy;
  final Map<int, WeeklyQuizStats> weeklyBreakdown;
  final double improvementRate;

  MonthlyReport({
    required this.year,
    required this.month,
    required this.monthName,
    required this.totalAttempts,
    required this.totalCorrect,
    required this.totalQuestions,
    required this.averageAccuracy,
    required this.weeklyBreakdown,
    required this.improvementRate,
  });
}

class PerformanceAnalysisReport {
  final double overallAccuracy;
  final int totalAttempts;
  final int totalCorrect;
  final int totalQuestions;
  final int bestScore;
  final int perfectAttempts;
  final double perfectRate;
  final double averageTimePerQuestion;
  final Map<int, double> stagePerformances;
  final int? strongestStage;
  final int? weakestStage;
  final bool isImprovingTrend;
  final int consecutiveCorrect;
  final int maxConsecutive;
  final List<String> recommendations;

  PerformanceAnalysisReport({
    required this.overallAccuracy,
    required this.totalAttempts,
    required this.totalCorrect,
    required this.totalQuestions,
    required this.bestScore,
    required this.perfectAttempts,
    required this.perfectRate,
    required this.averageTimePerQuestion,
    required this.stagePerformances,
    required this.strongestStage,
    required this.weakestStage,
    required this.isImprovingTrend,
    required this.consecutiveCorrect,
    required this.maxConsecutive,
    required this.recommendations,
  });
}

class DailyQuizStats {
  final DateTime date;
  int attempts;
  int correct;
  int total;

  DailyQuizStats({
    required this.date,
    required this.attempts,
    required this.correct,
    required this.total,
  });

  double get accuracy => total > 0 ? (correct / total * 100) : 0.0;
}

class WeeklyQuizStats {
  final int week;
  int attempts;
  int correct;
  int total;

  WeeklyQuizStats({
    required this.week,
    required this.attempts,
    required this.correct,
    required this.total,
  });

  double get accuracy => total > 0 ? (correct / total * 100) : 0.0;
}

enum TrendDirection { improving, declining, stable }

// Riverpod プロバイダ
final quizReportServiceProvider = Provider((ref) {
  final historyService = ref.watch(quizHistoryServiceProvider);
  return QuizReportService(historyService: historyService);
});

final weeklyReportProvider = FutureProvider((ref) async {
  final service = ref.watch(quizReportServiceProvider);
  return service.generateWeeklyReport();
});

final monthlyReportProvider = FutureProvider((ref) async {
  final service = ref.watch(quizReportServiceProvider);
  return service.generateMonthlyReport();
});

final performanceAnalysisProvider = FutureProvider((ref) async {
  final service = ref.watch(quizReportServiceProvider);
  return service.generatePerformanceAnalysis();
});
