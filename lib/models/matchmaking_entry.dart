class MatchmakingEntry {
  final String userId;
  final String userName;
  final String userEmoji;
  final double ratingScore;
  final DateTime joinedAt;
  final String status; // 'waiting', 'matched', 'cancelled'
  final String? matchId;

  const MatchmakingEntry({
    required this.userId,
    required this.userName,
    required this.userEmoji,
    required this.ratingScore,
    required this.joinedAt,
    required this.status,
    this.matchId,
  });

  bool get isWaiting => status == 'waiting';
  bool get isMatched => status == 'matched';

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'userName': userName,
    'userEmoji': userEmoji,
    'ratingScore': ratingScore,
    'joinedAt': joinedAt.toIso8601String(),
    'status': status,
    if (matchId != null) 'matchId': matchId,
  };

  factory MatchmakingEntry.fromJson(Map<String, dynamic> json) =>
      MatchmakingEntry(
        userId: json['userId'] as String,
        userName: json['userName'] as String? ?? 'Player',
        userEmoji: json['userEmoji'] as String? ?? '👤',
        ratingScore: (json['ratingScore'] as num?)?.toDouble() ?? 1500.0,
        joinedAt: DateTime.parse(json['joinedAt'] as String),
        status: json['status'] as String? ?? 'waiting',
        matchId: json['matchId'] as String?,
      );
}
