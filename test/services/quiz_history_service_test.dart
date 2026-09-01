import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:social_quiz_app/models/quiz_attempt.dart';
import 'package:social_quiz_app/repositories/quiz_history_repository.dart';
import 'package:social_quiz_app/services/quiz_history_service.dart';

class MockQuizHistoryRepository extends Mock implements QuizHistoryRepository {}

void main() {
  group('QuizHistoryService', () {
    late MockQuizHistoryRepository mockRepo;
    late QuizHistoryService service;

    setUp(() {
      mockRepo = MockQuizHistoryRepository();
      service = QuizHistoryService(repo: mockRepo);
    });

    test('recordAttempt adds quiz attempt to repository', () async {
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
      when(mockRepo.add(attempt)).thenAnswer((_) => Future.value());

      // Act
      await service.recordAttempt(attempt);

      // Assert
      verify(mockRepo.add(attempt)).called(1);
    });

    test('getAllAttempts returns all attempts from repository', () {
      // Arrange
      final now = DateTime.now();
      final attempts = [
        QuizAttempt(
          id: 'attempt_1',
          stageNo: 1,
          attemptedAt: now,
          durationSeconds: 120,
          totalScore: 100,
          correctCount: 10,
          totalCount: 10,
          userAnswers: [0, 1, 2, 3, 0, 1, 2, 3, 0, 1],
          correctAnswers: [0, 1, 2, 3, 0, 1, 2, 3, 0, 1],
        ),
      ];
      when(mockRepo.getAll()).thenReturn(attempts);

      // Act
      final result = service.getAllAttempts();

      // Assert
      expect(result, equals(attempts));
      verify(mockRepo.getAll()).called(1);
    });

    test('getStageAttempts returns attempts for specific stage', () {
      // Arrange
      final now = DateTime.now();
      final attempts = [
        QuizAttempt(
          id: 'attempt_1',
          stageNo: 1,
          attemptedAt: now,
          durationSeconds: 120,
          totalScore: 100,
          correctCount: 10,
          totalCount: 10,
          userAnswers: [0, 1, 2, 3, 0, 1, 2, 3, 0, 1],
          correctAnswers: [0, 1, 2, 3, 0, 1, 2, 3, 0, 1],
        ),
      ];
      when(mockRepo.getByStage(1)).thenReturn(attempts);

      // Act
      final result = service.getStageAttempts(1);

      // Assert
      expect(result, equals(attempts));
      verify(mockRepo.getByStage(1)).called(1);
    });

    test('getRecentAttempts returns limited recent attempts', () {
      // Arrange
      final now = DateTime.now();
      final attempts = List.generate(
        5,
        (i) => QuizAttempt(
          id: 'attempt_$i',
          stageNo: 1,
          attemptedAt: now.subtract(Duration(minutes: i)),
          durationSeconds: 120,
          totalScore: 100,
          correctCount: 10,
          totalCount: 10,
          userAnswers: [0, 1, 2, 3, 0, 1, 2, 3, 0, 1],
          correctAnswers: [0, 1, 2, 3, 0, 1, 2, 3, 0, 1],
        ),
      );
      when(mockRepo.getRecent(limit: 5)).thenReturn(attempts);

      // Act
      final result = service.getRecentAttempts(limit: 5);

      // Assert
      expect(result, equals(attempts));
      verify(mockRepo.getRecent(limit: 5)).called(1);
    });

    test('getTodaysAttempts returns attempts from today only', () {
      // Arrange
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final tomorrow = today.add(const Duration(days: 1));

      final attempts = [
        QuizAttempt(
          id: 'attempt_1',
          stageNo: 1,
          attemptedAt: today.add(const Duration(hours: 10)),
          durationSeconds: 120,
          totalScore: 100,
          correctCount: 10,
          totalCount: 10,
          userAnswers: [0, 1, 2, 3, 0, 1, 2, 3, 0, 1],
          correctAnswers: [0, 1, 2, 3, 0, 1, 2, 3, 0, 1],
        ),
      ];
      when(mockRepo.getByDateRange(today, tomorrow)).thenReturn(attempts);

      // Act
      final result = service.getTodaysAttempts();

      // Assert
      expect(result, equals(attempts));
    });

    test('getOverallStats returns stats from repository', () {
      // Arrange
      final stats = QuizHistoryStats(
        totalAttempts: 10,
        totalCorrect: 90,
        totalQuestions: 100,
        averageAccuracy: 90.0,
        averageTimePerQuestion: 2.0,
        bestScore: 100,
        perfectAttempts: 5,
      );
      when(mockRepo.getStats()).thenReturn(stats);

      // Act
      final result = service.getOverallStats();

      // Assert
      expect(result.totalAttempts, equals(10));
      expect(result.averageAccuracy, equals(90.0));
      verify(mockRepo.getStats()).called(1);
    });

    test('getStageStats returns stats for specific stage', () {
      // Arrange
      final stats = QuizHistoryStats(
        totalAttempts: 5,
        totalCorrect: 50,
        totalQuestions: 50,
        averageAccuracy: 100.0,
        averageTimePerQuestion: 2.0,
        bestScore: 100,
        perfectAttempts: 5,
      );
      when(mockRepo.getStats(stageNo: 1)).thenReturn(stats);

      // Act
      final result = service.getStageStats(1);

      // Assert
      expect(result.averageAccuracy, equals(100.0));
      verify(mockRepo.getStats(stageNo: 1)).called(1);
    });

    test('getAccuracyTrend returns accuracy percentages in order', () {
      // Arrange
      final now = DateTime.now();
      final attempts = [
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
        QuizAttempt(
          id: 'attempt_2',
          stageNo: 1,
          attemptedAt: now.add(const Duration(minutes: 5)),
          durationSeconds: 120,
          totalScore: 100,
          correctCount: 9,
          totalCount: 10,
          userAnswers: [0, 1, 2, 3, 0, 1, 2, 3, 0, 1],
          correctAnswers: [0, 1, 2, 3, 0, 1, 2, 3, 0, 1],
        ),
      ];
      when(mockRepo.getRecent(limit: 10)).thenReturn(attempts);

      // Act
      final result = service.getAccuracyTrend();

      // Assert
      expect(result.length, equals(2));
      expect(result[0], equals(80.0)); // 8/10 * 100
      expect(result[1], equals(90.0)); // 9/10 * 100
    });

    test('isImprovingTrend returns true when accuracy increases', () {
      // Arrange
      final now = DateTime.now();
      final attempts = [
        // Oldest first
        QuizAttempt(
          id: 'attempt_1',
          stageNo: 1,
          attemptedAt: now,
          durationSeconds: 120,
          totalScore: 100,
          correctCount: 6,
          totalCount: 10,
          userAnswers: [0, 1, 2, 3, 0, 1, 2, 3, 0, 1],
          correctAnswers: [0, 1, 2, 3, 0, 1, 2, 3, 0, 1],
        ),
        QuizAttempt(
          id: 'attempt_2',
          stageNo: 1,
          attemptedAt: now.add(const Duration(minutes: 5)),
          durationSeconds: 120,
          totalScore: 100,
          correctCount: 9,
          totalCount: 10,
          userAnswers: [0, 1, 2, 3, 0, 1, 2, 3, 0, 1],
          correctAnswers: [0, 1, 2, 3, 0, 1, 2, 3, 0, 1],
        ),
      ];
      when(mockRepo.getRecent(limit: 5)).thenReturn(attempts);

      // Act
      final result = service.isImprovingTrend();

      // Assert
      expect(result, isTrue); // 60% -> 90% is improvement
    });

    test('getConsecutiveCorrectCount returns correct streak', () {
      // Arrange
      final now = DateTime.now();
      final attempts = [
        QuizAttempt(
          id: 'attempt_1',
          stageNo: 1,
          attemptedAt: now,
          durationSeconds: 120,
          totalScore: 100,
          correctCount: 10,
          totalCount: 10,
          userAnswers: [0, 1, 2, 3, 0, 1, 2, 3, 0, 1],
          correctAnswers: [0, 1, 2, 3, 0, 1, 2, 3, 0, 1],
        ),
        QuizAttempt(
          id: 'attempt_2',
          stageNo: 1,
          attemptedAt: now.add(const Duration(minutes: 5)),
          durationSeconds: 120,
          totalScore: 100,
          correctCount: 10,
          totalCount: 10,
          userAnswers: [0, 1, 2, 3, 0, 1, 2, 3, 0, 1],
          correctAnswers: [0, 1, 2, 3, 0, 1, 2, 3, 0, 1],
        ),
        QuizAttempt(
          id: 'attempt_3',
          stageNo: 1,
          attemptedAt: now.add(const Duration(minutes: 10)),
          durationSeconds: 120,
          totalScore: 100,
          correctCount: 9,
          totalCount: 10,
          userAnswers: [0, 1, 2, 3, 0, 1, 2, 3, 0, 1],
          correctAnswers: [0, 1, 2, 3, 0, 1, 2, 3, 0, 1],
        ),
      ];
      when(mockRepo.getRecent(limit: 20)).thenReturn(attempts);

      // Act
      final result = service.getConsecutiveCorrectCount();

      // Assert
      expect(result, equals(2)); // Two perfect attempts before a failure
    });

    test('deleteAttempt removes attempt from repository', () async {
      // Arrange
      when(mockRepo.delete('attempt_1')).thenAnswer((_) => Future.value());

      // Act
      await service.deleteAttempt('attempt_1');

      // Assert
      verify(mockRepo.delete('attempt_1')).called(1);
    });

    test('clearHistory clears all attempts', () async {
      // Arrange
      when(mockRepo.clear()).thenAnswer((_) => Future.value());

      // Act
      await service.clearHistory();

      // Assert
      verify(mockRepo.clear()).called(1);
    });
  });
}
