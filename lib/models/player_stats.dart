import 'dart:math' as math;

class PlayerStats {
  final String userId;
  final String userName;
  final String userEmoji;
  final double ratingScore;
  final int matchCount;
  final int matchWins;
  final int matchLosses;
  final DateTime? lastMatchAt;

  const PlayerStats({
    required this.userId,
    required this.userName,
    required this.userEmoji,
    this.ratingScore = 1500.0,
    this.matchCount = 0,
    this.matchWins = 0,
    this.matchLosses = 0,
    this.lastMatchAt,
  });

  double get winRate =>
      matchCount == 0 ? 0 : matchWins / matchCount;

  // Elo レーティング計算
  double calcNewRating({required bool isWin, required double opponentRating}) {
    const k = 32.0;
    final expected =
        1.0 / (1.0 + math.pow(10, (opponentRating - ratingScore) / 400));
    final actual = isWin ? 1.0 : 0.0;
    return (ratingScore + k * (actual - expected)).clamp(100.0, 3000.0);
  }

  PlayerStats copyWith({
    double? ratingScore,
    int? matchCount,
    int? matchWins,
    int? matchLosses,
    DateTime? lastMatchAt,
  }) {
    return PlayerStats(
      userId: userId,
      userName: userName,
      userEmoji: userEmoji,
      ratingScore: ratingScore ?? this.ratingScore,
      matchCount: matchCount ?? this.matchCount,
      matchWins: matchWins ?? this.matchWins,
      matchLosses: matchLosses ?? this.matchLosses,
      lastMatchAt: lastMatchAt ?? this.lastMatchAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'userName': userName,
    'userEmoji': userEmoji,
    'ratingScore': ratingScore,
    'matchCount': matchCount,
    'matchWins': matchWins,
    'matchLosses': matchLosses,
    'lastMatchAt': lastMatchAt?.toIso8601String(),
  };

  factory PlayerStats.fromJson(Map<String, dynamic> json) => PlayerStats(
    userId: json['userId'] as String,
    userName: json['userName'] as String? ?? 'Player',
    userEmoji: json['userEmoji'] as String? ?? '👤',
    ratingScore: (json['ratingScore'] as num?)?.toDouble() ?? 1500.0,
    matchCount: json['matchCount'] as int? ?? 0,
    matchWins: json['matchWins'] as int? ?? 0,
    matchLosses: json['matchLosses'] as int? ?? 0,
    lastMatchAt: json['lastMatchAt'] != null
        ? DateTime.tryParse(json['lastMatchAt'] as String)
        : null,
  );

  factory PlayerStats.initial({
    required String userId,
    required String userName,
    required String userEmoji,
  }) =>
      PlayerStats(
        userId: userId,
        userName: userName,
        userEmoji: userEmoji,
      );
}
