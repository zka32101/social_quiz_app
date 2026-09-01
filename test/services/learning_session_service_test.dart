import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:social_quiz_app/models/user_progress.dart';
import 'package:social_quiz_app/repositories/progress_repository.dart';
import 'package:social_quiz_app/services/learning_session_service.dart';

class MockProgressRepository extends Mock implements ProgressRepository {}

void main() {
  group('LearningSessionService', () {
    late MockProgressRepository mockProgressRepository;
    late LearningSessionService service;

    setUp(() {
      mockProgressRepository = MockProgressRepository();
      service = LearningSessionService(progressRepo: mockProgressRepository);
    });

    test('endSession creates and stores a learning session', () async {
      // Arrange
      service.startSession('quiz');
      final initialProgress = UserProgress.initial('test_user');
      when(mockProgressRepository.loadLocal()).thenReturn(initialProgress);

      // Act
      await Future.delayed(const Duration(seconds: 1));
      await service.endSession();

      // Verify
      verify(mockProgressRepository.loadLocal()).called(greaterThan(0));
      verify(mockProgressRepository.saveLocal(any)).called(1);
    });

    test('getTodaysLearningMinutes calculates correctly', () {
      // Arrange
      final now = DateTime.now();
      final todayStart = DateTime(now.year, now.month, now.day);
      final session = LearningSession(
        id: 'test_session',
        startedAt: todayStart,
        endedAt: todayStart.add(const Duration(minutes: 30)),
        durationSeconds: 30 * 60,
        activityType: 'quiz',
      );

      final progress = UserProgress.initial('test_user').copyWith(
        learningSessions: [session],
      );

      when(mockProgressRepository.loadLocal()).thenReturn(progress);

      // Act
      final minutes = service.getTodaysLearningMinutes();

      // Assert
      expect(minutes, equals(30));
    });

    test('getWeeklyLearningMinutes aggregates correctly', () {
      // Arrange
      final now = DateTime.now();
      final weekStart = now.subtract(Duration(days: now.weekday - 1));

      final sessions = List.generate(7, (index) {
        final date = weekStart.add(Duration(days: index));
        return LearningSession(
          id: 'session_$index',
          startedAt: date,
          endedAt: date.add(const Duration(minutes: 10)),
          durationSeconds: 10 * 60,
          activityType: 'quiz',
        );
      });

      final progress = UserProgress.initial('test_user').copyWith(
        learningSessions: sessions,
      );

      when(mockProgressRepository.loadLocal()).thenReturn(progress);

      // Act
      final minutes = service.getWeeklyLearningMinutes();

      // Assert
      expect(minutes, equals(70)); // 7 days * 10 minutes
    });

    test('getWeeklyAverageLearningMinutes returns correct average', () {
      // Arrange
      final now = DateTime.now();
      final weekStart = now.subtract(Duration(days: now.weekday - 1));

      final sessions = List.generate(7, (index) {
        final date = weekStart.add(Duration(days: index));
        return LearningSession(
          id: 'session_$index',
          startedAt: date,
          endedAt: date.add(const Duration(minutes: 14)),
          durationSeconds: 14 * 60,
          activityType: 'quiz',
        );
      });

      final progress = UserProgress.initial('test_user').copyWith(
        learningSessions: sessions,
      );

      when(mockProgressRepository.loadLocal()).thenReturn(progress);

      // Act
      final avgMinutes = service.getWeeklyAverageLearningMinutes();

      // Assert
      expect(avgMinutes, equals(14)); // ~98/7 = ~14
    });
  });
}
