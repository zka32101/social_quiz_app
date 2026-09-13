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
  final bool isNamePublic; // 名前公表フラグ（デフォルト: false）
  final int? grade; // 学年（1-6）。未同期のユーザーは null
  final DateTime? startedAt; // 学習開始日（プロフィール作成日を初回同期）
  final String subjectId; // 科目ID（デフォルト: 'social'）

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
    this.isNamePublic = false,
    this.grade,
    this.startedAt,
    this.subjectId = 'social',
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
      isNamePublic: data['isNamePublic'] as bool? ?? false,
      grade: data['grade'] as int?,
      startedAt: (data['startedAt'] as Timestamp?)?.toDate(),
      subjectId: data['subjectId'] as String? ?? 'social',
    );
  }

  // copyWith helper to create a modified copy
  RankingEntry copyWith({
    String? userId,
    String? displayName,
    String? profileImageUrl,
    int? totalScore,
    int? totalCorrect,
    int? totalPlayed,
    double? correctRate,
    int? badgeCount,
    int? rank,
    DateTime? updatedAt,
    bool? isNamePublic,
    int? grade,
    DateTime? startedAt,
    String? subjectId,
  }) {
    return RankingEntry(
      userId: userId ?? this.userId,
      displayName: displayName ?? this.displayName,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      totalScore: totalScore ?? this.totalScore,
      totalCorrect: totalCorrect ?? this.totalCorrect,
      totalPlayed: totalPlayed ?? this.totalPlayed,
      correctRate: correctRate ?? this.correctRate,
      badgeCount: badgeCount ?? this.badgeCount,
      rank: rank ?? this.rank,
      updatedAt: updatedAt ?? this.updatedAt,
      isNamePublic: isNamePublic ?? this.isNamePublic,
      grade: grade ?? this.grade,
      startedAt: startedAt ?? this.startedAt,
      subjectId: subjectId ?? this.subjectId,
    );
  }
}

class RankingType {
  static const String global = 'global';
  static const String weekly = 'weekly';
  static const String friends = 'friends';
  static const String sameGrade = 'same_grade';
  static const String sameGradeSamePeriod = 'same_grade_same_period';
}
