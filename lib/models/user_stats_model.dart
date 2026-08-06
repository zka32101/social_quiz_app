import 'package:cloud_firestore/cloud_firestore.dart';

class UserStats {
  final String userId;
  final int totalScore;
  final int totalCorrect;
  final int totalPlayed;
  final double correctRate;
  final int longestStreak;
  final int currentStreak;
  final int badgeCount;
  final int bonusPointsEarned;
  final DateTime lastPlayedAt;

  UserStats({
    required this.userId,
    required this.totalScore,
    required this.totalCorrect,
    required this.totalPlayed,
    required this.correctRate,
    required this.longestStreak,
    required this.currentStreak,
    required this.badgeCount,
    required this.bonusPointsEarned,
    required this.lastPlayedAt,
  });

  factory UserStats.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final stats = data['stats'] as Map<String, dynamic>? ?? {};
    return UserStats(
      userId: doc.id,
      totalScore: stats['totalScore'] as int? ?? 0,
      totalCorrect: stats['totalCorrect'] as int? ?? 0,
      totalPlayed: stats['totalPlayed'] as int? ?? 0,
      correctRate: (stats['correctRate'] as num?)?.toDouble() ?? 0.0,
      longestStreak: stats['longestStreak'] as int? ?? 0,
      currentStreak: stats['currentStreak'] as int? ?? 0,
      badgeCount: stats['badgeCount'] as int? ?? 0,
      bonusPointsEarned: stats['bonusPointsEarned'] as int? ?? 0,
      lastPlayedAt: (data['lastPlayedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'stats': {
      'totalScore': totalScore,
      'totalCorrect': totalCorrect,
      'totalPlayed': totalPlayed,
      'correctRate': correctRate,
      'longestStreak': longestStreak,
      'currentStreak': currentStreak,
      'badgeCount': badgeCount,
      'bonusPointsEarned': bonusPointsEarned,
    },
    'lastPlayedAt': Timestamp.fromDate(lastPlayedAt),
    'updatedAt': FieldValue.serverTimestamp(),
  };
}
