import 'package:cloud_firestore/cloud_firestore.dart';

class RankingEntry {
  final String userId;
  final String displayName;
  final String? profileImageUrl;
  final int totalScore;
  final int totalCorrect;
  final int totalPlayed;
  final double correctRate;
  final int badgeCount;
  final int rank;
  final DateTime updatedAt;

  RankingEntry({
    required this.userId,
    required this.displayName,
    this.profileImageUrl,
    required this.totalScore,
    required this.totalCorrect,
    required this.totalPlayed,
    required this.correctRate,
    required this.badgeCount,
    required this.rank,
    required this.updatedAt,
  });

  factory RankingEntry.fromFirestore(
    DocumentSnapshot doc,
    int rank,
  ) {
    final data = doc.data() as Map<String, dynamic>;
    return RankingEntry(
      userId: doc.id,
      displayName: data['displayName'] as String? ?? '名無しさん',
      profileImageUrl: data['profileImageUrl'] as String?,
      totalScore: data['totalScore'] as int? ?? 0,
      totalCorrect: data['totalCorrect'] as int? ?? 0,
      totalPlayed: data['totalPlayed'] as int? ?? 0,
      correctRate: (data['correctRate'] as num?)?.toDouble() ?? 0.0,
      badgeCount: data['badgeCount'] as int? ?? 0,
      rank: rank,
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}

class RankingType {
  static const String global = 'global';
  static const String weekly = 'weekly';
  static const String friends = 'friends';
}
