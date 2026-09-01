/// マイルストーン通知（達成内容を通知）
class MilestoneNotification {
  final String id;
  final String title;           // 「ステージ 1 完了！」など
  final String message;         // 詳細メッセージ
  final String type;            // 'badge', 'stage', 'learning_time', 'streak' など
  final String? emoji;          // 絵文字表示（オプション）
  final DateTime createdAt;
  final bool isRead;
  final Map<String, dynamic>? metadata; // 拡張データ（badgeId, stageNo など）

  const MilestoneNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    this.emoji,
    required this.createdAt,
    this.isRead = false,
    this.metadata,
  });

  MilestoneNotification copyWith({
    String? id,
    String? title,
    String? message,
    String? type,
    String? emoji,
    DateTime? createdAt,
    bool? isRead,
    Map<String, dynamic>? metadata,
  }) {
    return MilestoneNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      emoji: emoji ?? this.emoji,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
      metadata: metadata ?? this.metadata,
    );
  }

  factory MilestoneNotification.fromJson(Map<String, dynamic> json) {
    return MilestoneNotification(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      message: json['message'] as String? ?? '',
      type: json['type'] as String? ?? '',
      emoji: json['emoji'] as String?,
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
      isRead: json['isRead'] as bool? ?? false,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'message': message,
    'type': type,
    'emoji': emoji,
    'createdAt': createdAt.toIso8601String(),
    'isRead': isRead,
    'metadata': metadata,
  };
}
