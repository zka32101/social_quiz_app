import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/milestone_notification.dart';

/// マイルストーン通知リポジトリ
class NotificationRepository {
  static const _boxName = 'notifications';
  static const _notificationsKey = 'milestones';

  Box get _box => Hive.box(_boxName);

  /// 全通知を取得
  List<MilestoneNotification> getAll() {
    final raw = _box.get(_notificationsKey) as String?;
    if (raw == null || raw.isEmpty) return [];

    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => MilestoneNotification.fromJson(e as Map<String, dynamic>))
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt)); // 新しい順
    } catch (_) {
      return [];
    }
  }

  /// 未読通知を取得
  List<MilestoneNotification> getUnread() {
    return getAll().where((n) => !n.isRead).toList();
  }

  /// 通知を追加
  Future<void> add(MilestoneNotification notification) async {
    final notifications = getAll();
    notifications.insert(0, notification); // 新しい順を保つ

    // 最新100件のみ保持（ストレージ節約）
    if (notifications.length > 100) {
      notifications.removeRange(100, notifications.length);
    }

    await _box.put(
      _notificationsKey,
      jsonEncode(notifications.map((n) => n.toJson()).toList()),
    );
  }

  /// 通知を既読にする
  Future<void> markAsRead(String notificationId) async {
    final notifications = getAll();
    final index = notifications.indexWhere((n) => n.id == notificationId);

    if (index != -1) {
      notifications[index] = notifications[index].copyWith(isRead: true);
      await _box.put(
        _notificationsKey,
        jsonEncode(notifications.map((n) => n.toJson()).toList()),
      );
    }
  }

  /// 全て既読にする
  Future<void> markAllAsRead() async {
    final notifications = getAll();
    for (int i = 0; i < notifications.length; i++) {
      notifications[i] = notifications[i].copyWith(isRead: true);
    }

    await _box.put(
      _notificationsKey,
      jsonEncode(notifications.map((n) => n.toJson()).toList()),
    );
  }

  /// 通知を削除
  Future<void> delete(String notificationId) async {
    final notifications = getAll().where((n) => n.id != notificationId).toList();

    await _box.put(
      _notificationsKey,
      jsonEncode(notifications.map((n) => n.toJson()).toList()),
    );
  }

  /// 全通知をクリア
  Future<void> clear() async {
    await _box.delete(_notificationsKey);
  }

  /// 未読通知数
  int getUnreadCount() {
    return getUnread().length;
  }
}

/// NotificationRepository プロバイダー
final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return NotificationRepository();
});

/// 全通知プロバイダー
final notificationsProvider = StateProvider<List<MilestoneNotification>>((ref) {
  final repo = ref.watch(notificationRepositoryProvider);
  return repo.getAll();
});

/// 未読通知プロバイダー
final unreadNotificationsProvider = StateProvider<List<MilestoneNotification>>((ref) {
  final repo = ref.watch(notificationRepositoryProvider);
  return repo.getUnread();
});

/// 未読通知数プロバイダー
final unreadCountProvider = StateProvider<int>((ref) {
  final repo = ref.watch(notificationRepositoryProvider);
  return repo.getUnreadCount();
});
