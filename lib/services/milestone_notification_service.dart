import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/milestone_notification.dart';
import '../models/user_progress.dart';
import '../repositories/notification_repository.dart';

/// マイルストーン通知サービス
/// ユーザーの成就を検出して通知を作成します
class MilestoneNotificationService {
  final NotificationRepository notificationRepo;

  MilestoneNotificationService({required this.notificationRepo});

  /// ステージ完了時の通知
  Future<void> notifyStageCompleted(int stageNo, String stageTitle) async {
    final notification = MilestoneNotification(
      id: 'stage_${stageNo}_${DateTime.now().millisecondsSinceEpoch}',
      title: 'ステージ $stageNo 完了！',
      message: '$stageTitle をマスターしました！おめでとう 🎉',
      type: 'stage',
      emoji: '🎯',
      createdAt: DateTime.now(),
      metadata: {'stageNo': stageNo, 'title': stageTitle},
    );
    await notificationRepo.add(notification);
  }

  /// バッジ獲得時の通知
  Future<void> notifyBadgeEarned(String badgeId, String badgeName) async {
    final notification = MilestoneNotification(
      id: 'badge_${badgeId}_${DateTime.now().millisecondsSinceEpoch}',
      title: 'バッジを獲得！',
      message: '「$badgeName」バッジをゲットしました！',
      type: 'badge',
      emoji: '🏆',
      createdAt: DateTime.now(),
      metadata: {'badgeId': badgeId, 'badgeName': badgeName},
    );
    await notificationRepo.add(notification);
  }

  /// ストリーク達成時の通知
  Future<void> notifyStreakMilestone(int days) async {
    final emoji = days >= 30 ? '🔥🔥🔥' : days >= 7 ? '🔥🔥' : '🔥';
    final message = days == 7
        ? '7日連続学習を達成！素晴らしい習慣ですね'
        : days == 30
            ? '30日連続学習！もう習慣が身についています'
            : '$days日連続学習達成！';

    final notification = MilestoneNotification(
      id: 'streak_${days}_${DateTime.now().millisecondsSinceEpoch}',
      title: '連続学習 $days日達成！',
      message: message,
      type: 'streak',
      emoji: emoji,
      createdAt: DateTime.now(),
      metadata: {'days': days},
    );
    await notificationRepo.add(notification);
  }

  /// 学習時間目標達成時の通知
  Future<void> notifyLearningTimeGoal(int dailyMinutes, int goalMinutes) async {
    if (dailyMinutes >= goalMinutes) {
      final notification = MilestoneNotification(
        id: 'time_${DateTime.now().millisecondsSinceEpoch}',
        title: '学習時間目標達成！',
        message: '本日の学習目標（${goalMinutes}分）を達成しました！',
        type: 'learning_time',
        emoji: '⭐',
        createdAt: DateTime.now(),
        metadata: {'actual': dailyMinutes, 'goal': goalMinutes},
      );
      await notificationRepo.add(notification);
    }
  }

  /// 都道府県制覇時の通知
  Future<void> notifyPrefectureCompleted(String prefName) async {
    final notification = MilestoneNotification(
      id: 'pref_${prefName}_${DateTime.now().millisecondsSinceEpoch}',
      title: '$prefName を制覇！',
      message: '$prefName についてすべてをマスターしました！',
      type: 'prefecture',
      emoji: '🗾',
      createdAt: DateTime.now(),
      metadata: {'prefName': prefName},
    );
    await notificationRepo.add(notification);
  }

  /// ポイント獲得時の通知
  Future<void> notifyPointsEarned(int points, String reason) async {
    final notification = MilestoneNotification(
      id: 'points_${DateTime.now().millisecondsSinceEpoch}',
      title: '$points ポイント獲得！',
      message: '$reason により $points ポイントをゲットしました！',
      type: 'points',
      emoji: '⭐',
      createdAt: DateTime.now(),
      metadata: {'points': points, 'reason': reason},
    );
    await notificationRepo.add(notification);
  }

  /// コイン獲得時の通知
  Future<void> notifyCoinsEarned(int coins, String reason) async {
    final notification = MilestoneNotification(
      id: 'coins_${DateTime.now().millisecondsSinceEpoch}',
      title: '$coins コイン獲得！',
      message: '$reason により $coins コインをゲットしました！',
      type: 'coins',
      emoji: '🪙',
      createdAt: DateTime.now(),
      metadata: {'coins': coins, 'reason': reason},
    );
    await notificationRepo.add(notification);
  }

  /// すべての未読通知を取得
  List<MilestoneNotification> getUnreadNotifications() {
    return notificationRepo.getUnread();
  }

  /// 通知を既読にする
  Future<void> markAsRead(String notificationId) {
    return notificationRepo.markAsRead(notificationId);
  }

  /// 全通知を既読にする
  Future<void> markAllAsRead() {
    return notificationRepo.markAllAsRead();
  }
}

/// MilestoneNotificationService プロバイダー
final milestoneNotificationServiceProvider =
    Provider<MilestoneNotificationService>((ref) {
  final notificationRepo = ref.watch(notificationRepositoryProvider);
  return MilestoneNotificationService(notificationRepo: notificationRepo);
});
