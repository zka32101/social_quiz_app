import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:social_quiz_app/models/quiz_attempt.dart';
import 'package:social_quiz_app/models/user_progress.dart';
import 'package:social_quiz_app/repositories/quiz_history_repository.dart';
import 'package:social_quiz_app/services/quiz_history_service.dart';
import 'package:social_quiz_app/services/quiz_report_service.dart';

class MockQuizHistoryService extends Mock implements QuizHistoryService {}

void main() {
  group('QuizReportService', () {
    late MockQuizHistoryService mockHistoryService;
    late QuizReportService service;

    setUp(() {
      mockHistoryService = MockQuizHistoryService();
      service = QuizReportService(historyService: mockHistoryService);
    });

    test('generateWeeklyReport returns report with correct aggregation', () {
      // Arrange
      final now = DateTime.now();
      final weekAttempts = [
        QuizAttempt(
          id: 'attempt_1',
          stageNo: 1,
          attemptedAt: now,
          durationSeconds: 120,
          totalScore: 100,
          correctCount: 8,
          totalCount: 10,
          userAnswers: [0, 1, 2, 3, 0, 1, 2, 3, 0, 1],
          correctAnswers: [0, 1, 2, 3, 0, 1, 2, 3, 0, 1],
        ),
      ];

      when(mockHistoryService.getThisWeeksAttempts()).thenReturn(weekAttempts);
      when(mockHistoryService.getOverallStats()).thenReturn(
        QuizHistoryStats(
          totalAttempts: 1,
          totalCorrect: 8,
          totalQuestions: 10,
          averageAccuracy: 80.0,
          averageTimePerQuestion: 2.0,
          bestScore: 100,
          perfectAttempts: 0,
        ),
      );

      // Act
      final report = service.generateWeeklyReport();

      // Assert
      expect(report.totalAttempts, equals(1));
      expect(report.totalCorrect, equals(8));
      expect(report.totalQuestions, equals(10));
      expect(report.averageAccuracy, equals(80.0));
    });

    test('generateMonthlyReport includes weekly breakdown', () {
      // Arrange
      when(mockHistoryService._repo)
          .thenReturn(MockQuizHistoryRepository());

      when(mockHistoryService.getOverallStats()).thenReturn(
        QuizHistoryStats(
          totalAttempts: 4,
          totalCorrect: 36,
          totalQuestions: 40,
          averageAccuracy: 90.0,
          averageTimePerQuestion: 2.0,
          bestScore: 100,
          perfectAttempts: 2,
        ),
      );

      // Act
      final report = service.generateMonthlyReport();

      // Assert
      expect(report.month, isNotNull);
      expect(report.year, isNotNull);
      expect(report.averageAccuracy, equals(90.0));
    });

    test('generatePerformanceAnalysis returns complete analysis', () {
      // Arrange
      when(mockHistoryService.getOverallStats()).thenReturn(
        QuizHistoryStats(
          totalAttempts: 20,
          totalCorrect: 180,
          totalQuestions: 200,
          averageAccuracy: 90.0,
          averageTimePerQuestion: 1.5,
          bestScore: 100,
          perfectAttempts: 10,
        ),
      );
      when(mockHistoryService.getStageAccuracyMap()).thenReturn({
        1: 85.0,
        2: 90.0,
        3: 95.0,
      });
      when(mockHistoryService.getBestStage()).thenReturn(3);
      when(mockHistoryService.getWorstStage()).thenReturn(1);
      when(mockHistoryService.isImprovingTrend()).thenReturn(true);
      when(mockHistoryService.getConsecutiveCorrectCount()).thenReturn(5);
      when(mockHistoryService.getMaxConsecutiveCorrect()).thenReturn(12);

      // Act
      final report = service.generatePerformanceAnalysis();

      // Assert
      expect(report.overallAccuracy, equals(90.0));
      expect(report.totalAttempts, equals(20));
      expect(report.perfectRate, isNotZero);
      expect(report.strongestStage, equals(3));
      expect(report.weakestStage, equals(1));
      expect(report.isImprovingTrend, isTrue);
    });

    test('generateParentEmailBody includes all required sections', () {
      // Arrange
      final progress = UserProgress.initial('test_user').copyWith(
        streak: 7,
        totalPoints: 500,
        badges: ['badge_1', 'badge_2'],
      );

      when(mockHistoryService.getThisWeeksAttempts()).thenReturn([]);
      when(mockHistoryService.getOverallStats()).thenReturn(
        QuizHistoryStats(
          totalAttempts: 10,
          totalCorrect: 90,
          totalQuestions: 100,
          averageAccuracy: 90.0,
          averageTimePerQuestion: 2.0,
          bestScore: 100,
          perfectAttempts: 5,
        ),
      );
      when(mockHistoryService.getStageAccuracyMap()).thenReturn({});
      when(mockHistoryService.getBestStage()).thenReturn(null);
      when(mockHistoryService.getWorstStage()).thenReturn(null);
      when(mockHistoryService.isImprovingTrend()).thenReturn(false);
      when(mockHistoryService.getConsecutiveCorrectCount()).thenReturn(3);
      when(mockHistoryService.getMaxConsecutiveCorrect()).thenReturn(5);

      // Act
      final email = service.generateParentEmailBody(
        childName: 'Test Child',
        progress: progress,
        reportDate: DateTime.now(),
      );

      // Assert
      expect(email, contains('Test Child'));
      expect(email, contains('今週のクイズ成績'));
      expect(email, contains('全体的なパフォーマンス'));
      expect(email, contains('学習状況'));
    });

    test('generateDetailedCSV includes headers and data rows', () {
      // Arrange
      final attempt = QuizAttempt(
        id: 'attempt_1',
        stageNo: 1,
        attemptedAt: DateTime.now(),
        durationSeconds: 120,
        totalScore: 100,
        correctCount: 10,
        totalCount: 10,
        userAnswers: [0, 1, 2, 3, 0, 1, 2, 3, 0, 1],
        correctAnswers: [0, 1, 2, 3, 0, 1, 2, 3, 0, 1],
      );

      when(mockHistoryService.getAllAttempts()).thenReturn([attempt]);

      // Act
      final csv = service.generateDetailedCSV();

      // Assert
      expect(csv, contains('試行ID,日時,ステージ,正答数,総問題数,正答率'));
      expect(csv, contains('attempt_1'));
      expect(csv, contains('1,'));
    });

    test('DailyQuizStats calculates accuracy correctly', () {
      // Arrange & Act
      final day = DailyQuizStats(
        date: DateTime.now(),
        attempts: 5,
        correct: 4,
        total: 5,
      );

      // Assert
      expect(day.accuracy, equals(80.0));
    });

    test('WeeklyQuizStats calculates accuracy correctly', () {
      // Arrange & Act
      final week = WeeklyQuizStats(
        week: 1,
        attempts: 10,
        correct: 9,
        total: 10,
      );

      // Assert
      expect(week.accuracy, equals(90.0));
    });

    test('TrendDirection identifies improving trend', () {
      // Arrange
      final improving = [
        QuizAttempt(
          id: 'a',
          stageNo: 1,
          attemptedAt: DateTime.now(),
          durationSeconds: 60,
          totalScore: 50,
          correctCount: 5,
          totalCount: 10,
          userAnswers: [],
          correctAnswers: [],
        ),
        QuizAttempt(
          id: 'b',
          stageNo: 1,
          attemptedAt: DateTime.now().add(const Duration(hours: 1)),
          durationSeconds: 60,
          totalScore: 90,
          correctCount: 9,
          totalCount: 10,
          userAnswers: [],
          correctAnswers: [],
        ),
      ];

      // Act
      final trend = service._calculateTrend(improving);

      // Assert
      expect(trend, equals(TrendDirection.improving));
    });
  });
}

class MockQuizHistoryRepository extends Mock implements QuizHistoryRepository {
  @override
  List<QuizAttempt> getByDateRange(DateTime start, DateTime end) {
    return [];
  }
}
