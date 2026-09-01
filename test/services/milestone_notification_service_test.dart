import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:social_quiz_app/models/milestone_notification.dart';
import 'package:social_quiz_app/repositories/notification_repository.dart';
import 'package:social_quiz_app/services/milestone_notification_service.dart';

class MockNotificationRepository extends Mock implements NotificationRepository {}

void main() {
  group('MilestoneNotificationService', () {
    late MockNotificationRepository mockNotificationRepo;
    late MilestoneNotificationService service;

    setUp(() {
      mockNotificationRepo = MockNotificationRepository();
      service = MilestoneNotificationService(notificationRepo: mockNotificationRepo);
    });

    test('notifyStageCompleted creates correct notification', () async {
      // Act
      await service.notifyStageCompleted(1, 'ステージ1');

      // Verify
      verify(mockNotificationRepo.add(any)).called(1);

      final captured =
          verify(mockNotificationRepo.add(captureAny)).captured;
      final notification = captured.first as MilestoneNotification;

      expect(notification.type, equals('stage'));
      expect(notification.title, contains('ステージ 1'));
      expect(notification.metadata?['stageNo'], equals(1));
    });

    test('notifyBadgeEarned creates correct notification', () async {
      // Act
      await service.notifyBadgeEarned('badge_1', 'テストバッジ');

      // Verify
      verify(mockNotificationRepo.add(any)).called(1);

      final captured =
          verify(mockNotificationRepo.add(captureAny)).captured;
      final notification = captured.first as MilestoneNotification;

      expect(notification.type, equals('badge'));
      expect(notification.title, equals('バッジを獲得！'));
      expect(notification.metadata?['badgeId'], equals('badge_1'));
    });

    test('notifyStreakMilestone creates 7-day streak notification', () async {
      // Act
      await service.notifyStreakMilestone(7);

      // Verify
      verify(mockNotificationRepo.add(any)).called(1);

      final captured =
          verify(mockNotificationRepo.add(captureAny)).captured;
      final notification = captured.first as MilestoneNotification;

      expect(notification.type, equals('streak'));
      expect(notification.title, contains('7日'));
      expect(notification.message, contains('7日連続'));
    });

    test('notifyLearningTimeGoal notifies when goal achieved', () async {
      // Act
      await service.notifyLearningTimeGoal(30, 30);

      // Verify
      verify(mockNotificationRepo.add(any)).called(1);

      final captured =
          verify(mockNotificationRepo.add(captureAny)).captured;
      final notification = captured.first as MilestoneNotification;

      expect(notification.type, equals('learning_time'));
      expect(notification.title, contains('目標'));
    });

    test('notifyLearningTimeGoal does not notify when goal not achieved', () async {
      // Act
      await service.notifyLearningTimeGoal(15, 30);

      // Verify
      verifyNever(mockNotificationRepo.add(any));
    });

    test('notifyPrefectureCompleted creates correct notification', () async {
      // Act
      await service.notifyPrefectureCompleted('東京');

      // Verify
      verify(mockNotificationRepo.add(any)).called(1);

      final captured =
          verify(mockNotificationRepo.add(captureAny)).captured;
      final notification = captured.first as MilestoneNotification;

      expect(notification.type, equals('prefecture'));
      expect(notification.title, contains('東京'));
    });

    test('markAsRead delegates to repository', () async {
      // Act
      await service.markAsRead('notification_1');

      // Verify
      verify(mockNotificationRepo.markAsRead('notification_1')).called(1);
    });

    test('markAllAsRead delegates to repository', () async {
      // Act
      await service.markAllAsRead();

      // Verify
      verify(mockNotificationRepo.markAllAsRead()).called(1);
    });
  });
}
