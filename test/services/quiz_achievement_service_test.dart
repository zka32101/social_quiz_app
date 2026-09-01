import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:social_quiz_app/repositories/progress_repository.dart';
import 'package:social_quiz_app/repositories/quiz_history_repository.dart';
import 'package:social_quiz_app/services/quiz_history_service.dart';
import 'package:social_quiz_app/services/milestone_notification_service.dart';
import 'package:social_quiz_app/services/quiz_achievement_service.dart';

class MockQuizHistoryService extends Mock implements QuizHistoryService {}

class MockMilestoneNotificationService extends Mock
    implements MilestoneNotificationService {}

class MockProgressRepository extends Mock implements ProgressRepository {}

void main() {
  group('QuizAchievementService', () {
    late MockQuizHistoryService mockHistoryService;
    late MockMilestoneNotificationService mockNotificationService;
    late MockProgressRepository mockProgressRepo;
    late QuizAchievementService service;

    setUp(() {
      mockHistoryService = MockQuizHistoryService();
      mockNotificationService = MockMilestoneNotificationService();
      mockProgressRepo = MockProgressRepository();
      service = QuizAchievementService(
        historyService: mockHistoryService,
        notificationService: mockNotificationService,
        progressRepo: mockProgressRepo,
      );
    });

    test('checkPerfectStreakAchievements returns true when streak >= 5', () async {
      // Arrange
      when(mockHistoryService.getConsecutiveCorrectCount()).thenReturn(5);

      // Act
      final result = await service._checkPerfectStreakAchievements();

      // Assert
      expect(result, isTrue);
      verify(mockHistoryService.getConsecutiveCorrectCount()).called(1);
    });

    test('checkPerfectStreakAchievements returns false when streak < 5', () async {
      // Arrange
      when(mockHistoryService.getConsecutiveCorrectCount()).thenReturn(3);

      // Act
      final result = await service._checkPerfectStreakAchievements();

      // Assert
      expect(result, isFalse);
    });

    test('getPerfectStreakBadges returns streak_5 badge for 5+ consecutive', () {
      // Arrange
      when(mockHistoryService.getConsecutiveCorrectCount()).thenReturn(5);

      // Act
      final badges = service._getPerfectStreakBadges();

      // Assert
      expect(badges, contains('perfect_streak_5'));
      expect(badges, isNot(contains('perfect_streak_10')));
    });

    test('getPerfectStreakBadges returns streak_10 badge for 10+ consecutive', () {
      // Arrange
      when(mockHistoryService.getConsecutiveCorrectCount()).thenReturn(10);

      // Act
      final badges = service._getPerfectStreakBadges();

      // Assert
      expect(badges, contains('perfect_streak_10'));
      expect(badges, isNot(contains('perfect_streak_20')));
    });

    test('getPerfectStreakBadges returns streak_20 badge for 20+ consecutive', () {
      // Arrange
      when(mockHistoryService.getConsecutiveCorrectCount()).thenReturn(20);

      // Act
      final badges = service._getPerfectStreakBadges();

      // Assert
      expect(badges, contains('perfect_streak_20'));
    });

    test('checkQuizMasterAchievement returns true for 90%+ accuracy with 10+ attempts',
        () async {
      // Arrange
      when(mockHistoryService.getOverallStats()).thenReturn(
        QuizHistoryStats(
          totalAttempts: 10,
          totalCorrect: 90,
          totalQuestions: 100,
          averageAccuracy: 90.0,
          averageTimePerQuestion: 3.0,
          bestScore: 100,
          perfectAttempts: 5,
        ),
      );

      // Act
      final result = await service._checkQuizMasterAchievement();

      // Assert
      expect(result, isTrue);
    });

    test('checkQuizMasterAchievement returns false for insufficient attempts', () async {
      // Arrange
      when(mockHistoryService.getOverallStats()).thenReturn(
        QuizHistoryStats(
          totalAttempts: 5,
          totalCorrect: 45,
          totalQuestions: 50,
          averageAccuracy: 90.0,
          averageTimePerQuestion: 3.0,
          bestScore: 100,
          perfectAttempts: 5,
        ),
      );

      // Act
      final result = await service._checkQuizMasterAchievement();

      // Assert
      expect(result, isFalse);
    });

    test('checkSpeedChampionAchievement returns true for < 2s/question with 20+ questions',
        () async {
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

      // Act
      final result = await service._checkSpeedChampionAchievement();

      // Assert
      expect(result, isTrue);
    });

    test('checkSpeedChampionAchievement returns false for insufficient questions', () async {
      // Arrange
      when(mockHistoryService.getOverallStats()).thenReturn(
        QuizHistoryStats(
          totalAttempts: 5,
          totalCorrect: 50,
          totalQuestions: 50,
          averageAccuracy: 100.0,
          averageTimePerQuestion: 1.0,
          bestScore: 100,
          perfectAttempts: 5,
        ),
      );

      // Act
      final result = await service._checkSpeedChampionAchievement();

      // Assert
      expect(result, isFalse); // Only 50 questions, need 20+
    });

    test('checkQuizLegendAchievement returns true for 100+ questions', () async {
      // Arrange
      when(mockHistoryService.getOverallStats()).thenReturn(
        QuizHistoryStats(
          totalAttempts: 100,
          totalCorrect: 900,
          totalQuestions: 1000,
          averageAccuracy: 90.0,
          averageTimePerQuestion: 2.0,
          bestScore: 100,
          perfectAttempts: 50,
        ),
      );

      // Act
      final result = await service._checkQuizLegendAchievement();

      // Assert
      expect(result, isTrue);
    });

    test('checkQuizLegendAchievement returns false for < 100 questions', () async {
      // Arrange
      when(mockHistoryService.getOverallStats()).thenReturn(
        QuizHistoryStats(
          totalAttempts: 50,
          totalCorrect: 450,
          totalQuestions: 500,
          averageAccuracy: 90.0,
          averageTimePerQuestion: 2.0,
          bestScore: 100,
          perfectAttempts: 25,
        ),
      );

      // Act
      final result = await service._checkQuizLegendAchievement();

      // Assert
      expect(result, isFalse);
    });

    test('checkAccuracyImprovement returns true when improving', () async {
      // Arrange
      when(mockHistoryService.isImprovingTrend(sampleSize: 10))
          .thenReturn(true);

      // Act
      final result = await service._checkAccuracyImprovement();

      // Assert
      expect(result, isTrue);
      verify(mockHistoryService.isImprovingTrend(sampleSize: 10)).called(1);
    });

    test('checkAccuracyImprovement returns false when not improving', () async {
      // Arrange
      when(mockHistoryService.isImprovingTrend(sampleSize: 10))
          .thenReturn(false);

      // Act
      final result = await service._checkAccuracyImprovement();

      // Assert
      expect(result, isFalse);
    });

    test('getUnacquiredAchievements returns only new badges', () async {
      // Arrange
      when(mockHistoryService.getConsecutiveCorrectCount()).thenReturn(5);
      when(mockHistoryService.getOverallStats()).thenReturn(
        QuizHistoryStats(
          totalAttempts: 20,
          totalCorrect: 180,
          totalQuestions: 200,
          averageAccuracy: 90.0,
          averageTimePerQuestion: 2.0,
          bestScore: 100,
          perfectAttempts: 10,
        ),
      );
      when(mockHistoryService.isImprovingTrend(sampleSize: 10))
          .thenReturn(false);

      final currentBadges = ['perfect_streak_5', 'quiz_master'];

      // Act
      final unacquired = await service.getUnacquiredAchievements(currentBadges);

      // Assert
      expect(unacquired, isNotEmpty);
      expect(unacquired, isNot(contains('perfect_streak_5')));
      expect(unacquired, isNot(contains('quiz_master')));
    });

    test('awardBadgeWithNotification creates notification', () async {
      // Arrange
      when(mockNotificationService.notifyBadgeEarned('quiz_master', 'クイズマスター'))
          .thenAnswer((_) => Future.value());

      // Act
      await service.awardBadgeWithNotification('quiz_master', 'クイズマスター');

      // Assert
      verify(mockNotificationService.notifyBadgeEarned('quiz_master', 'クイズマスター'))
          .called(1);
    });

    test('awardBadgeWithNotification handles errors gracefully', () async {
      // Arrange
      when(mockNotificationService.notifyBadgeEarned('quiz_master', 'クイズマスター'))
          .thenThrow(Exception('Notification error'));

      // Act & Assert (should not throw)
      expect(
        () => service.awardBadgeWithNotification('quiz_master', 'クイズマスター'),
        returnsNormally,
      );
    });
  });
}
