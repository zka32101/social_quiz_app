import 'package:cloud_firestore/cloud_firestore.dart';

/// 各都道府県の学習進捗
class PrefectureProgress {
  final String prefectureId;
  final List<int> completedSteps; // [1, 2, 3]
  final int quizBestScore;        // 0-10
  final bool isCompleted;
  final DateTime? completedAt;

  const PrefectureProgress({
    required this.prefectureId,
    required this.completedSteps,
    required this.quizBestScore,
    required this.isCompleted,
    this.completedAt,
  });

  bool isStepCompleted(int stepNo) => completedSteps.contains(stepNo);

  PrefectureProgress copyWith({
    List<int>? completedSteps,
    int? quizBestScore,
    bool? isCompleted,
    DateTime? completedAt,
  }) {
    return PrefectureProgress(
      prefectureId: prefectureId,
      completedSteps: completedSteps ?? this.completedSteps,
      quizBestScore: quizBestScore ?? this.quizBestScore,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  factory PrefectureProgress.empty(String prefectureId) {
    return PrefectureProgress(
      prefectureId: prefectureId,
      completedSteps: [],
      quizBestScore: 0,
      isCompleted: false,
    );
  }

  factory PrefectureProgress.fromJson(Map<String, dynamic> json) {
    return PrefectureProgress(
      prefectureId: json['prefectureId'] as String? ?? '',
      completedSteps: List<int>.from(json['completedSteps'] as List? ?? []),
      quizBestScore: json['quizBestScore'] as int? ?? 0,
      isCompleted: json['isCompleted'] as bool? ?? false,
      completedAt: (json['completedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toJson() => {
        'prefectureId': prefectureId,
        'completedSteps': completedSteps,
        'quizBestScore': quizBestScore,
        'isCompleted': isCompleted,
        'completedAt':
            completedAt != null ? Timestamp.fromDate(completedAt!) : null,
      };
}

/// 各ステージの学習進捗
class StageProgress {
  final String stageId;
  final int stageNo;
  final List<int> completedQuests; // [1, 2, 3]
  final bool isUnlocked;
  final bool isCompleted;
  final DateTime? unlockedAt;
  final DateTime? completedAt;

  const StageProgress({
    required this.stageId,
    required this.stageNo,
    required this.completedQuests,
    required this.isUnlocked,
    required this.isCompleted,
    this.unlockedAt,
    this.completedAt,
  });

  bool isQuestCompleted(int questNo) => completedQuests.contains(questNo);

  StageProgress copyWith({
    List<int>? completedQuests,
    bool? isUnlocked,
    bool? isCompleted,
    DateTime? unlockedAt,
    DateTime? completedAt,
  }) {
    return StageProgress(
      stageId: stageId,
      stageNo: stageNo,
      completedQuests: completedQuests ?? this.completedQuests,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      isCompleted: isCompleted ?? this.isCompleted,
      unlockedAt: unlockedAt ?? this.unlockedAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  factory StageProgress.empty(String stageId, int stageNo) {
    return StageProgress(
      stageId: stageId,
      stageNo: stageNo,
      completedQuests: [],
      isUnlocked: stageNo == 1, // Stage 1はデフォルト開放
      isCompleted: false,
    );
  }

  factory StageProgress.fromJson(Map<String, dynamic> json) {
    return StageProgress(
      stageId: json['stageId'] as String? ?? '',
      stageNo: json['stageNo'] as int? ?? 1,
      completedQuests: List<int>.from(json['completedQuests'] as List? ?? []),
      isUnlocked: json['isUnlocked'] as bool? ?? false,
      isCompleted: json['isCompleted'] as bool? ?? false,
      unlockedAt: json['unlockedAt'] != null
          ? DateTime.tryParse(json['unlockedAt'] as String)
          : null,
      completedAt: json['completedAt'] != null
          ? DateTime.tryParse(json['completedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'stageId': stageId,
        'stageNo': stageNo,
        'completedQuests': completedQuests,
        'isUnlocked': isUnlocked,
        'isCompleted': isCompleted,
        'unlockedAt': unlockedAt?.toIso8601String(),
        'completedAt': completedAt?.toIso8601String(),
      };
}

/// ユーザー全体の進捗データ
class UserProgress {
  final String userId;
  final int grade;             // 1-6
  final bool isPremium;
  final int totalPoints;
  final int streak;            // 連続学習日数
  final DateTime? lastStudiedAt;
  final String? parentEmail;
  final List<String> badges;   // ["hokkaido_master", ...]
  final Map<String, PrefectureProgress> prefectureProgress;
  final Map<String, StageProgress> stageProgress;
  // 新フィールド
  final int coins;             // コイン残高
  final String? trialStartDate; // 試用期間開始日（ISO8601）
  final List<String> wrongAnswerIds; // 間違えたクイズIDリスト

  const UserProgress({
    required this.userId,
    required this.grade,
    required this.isPremium,
    required this.totalPoints,
    required this.streak,
    this.lastStudiedAt,
    this.parentEmail,
    required this.badges,
    required this.prefectureProgress,
    required this.stageProgress,
    this.coins = 0,
    this.trialStartDate,
    this.wrongAnswerIds = const [],
  });

  /// 試用期間が有効か（常に true — 全コンテンツ無料）
  bool get isTrialActive => true;

  /// コンテンツへのアクセス権（常に true — 全コンテンツ無料）
  bool get hasAccess => true;

  /// 試用期間残日数（使わないが互換のために残す）
  int get trialDaysRemaining => 99;

  factory UserProgress.initial(String userId) {
    return UserProgress(
      userId: userId,
      grade: 4,
      isPremium: false,
      totalPoints: 0,
      streak: 0,
      badges: [],
      prefectureProgress: {},
      stageProgress: {
        'stage_1': StageProgress.empty('stage_1', 1), // Stage 1は開放済み
      },
      wrongAnswerIds: [],
    );
  }

  int get completedPrefectureCount =>
      prefectureProgress.values.where((p) => p.isCompleted).length;

  int get completedStageCount =>
      stageProgress.values.where((s) => s.isCompleted).length;

  int get unlockedStageCount =>
      stageProgress.values.where((s) => s.isUnlocked).length;

  PrefectureProgress getProgress(String prefectureId) {
    return prefectureProgress[prefectureId] ??
        PrefectureProgress.empty(prefectureId);
  }

  StageProgress getStageProgress(String stageId) {
    return stageProgress[stageId] ??
        StageProgress.empty(
          stageId,
          int.tryParse(stageId.replaceAll('stage_', '')) ?? 1,
        );
  }

  /// 次に開放すべきステージを取得
  String? getNextStageToUnlock() {
    for (int i = 1; i <= 20; i++) {
      final stageId = 'stage_$i';
      final progress = stageProgress[stageId];
      if (progress == null || !progress.isUnlocked) {
        return stageId;
      }
    }
    return null; // 全ステージ開放済み
  }

  UserProgress copyWith({
    int? grade,
    bool? isPremium,
    int? totalPoints,
    int? streak,
    DateTime? lastStudiedAt,
    String? parentEmail,
    List<String>? badges,
    Map<String, PrefectureProgress>? prefectureProgress,
    Map<String, StageProgress>? stageProgress,
    int? coins,
    String? trialStartDate,
    List<String>? wrongAnswerIds,
  }) {
    return UserProgress(
      userId: userId,
      grade: grade ?? this.grade,
      isPremium: isPremium ?? this.isPremium,
      totalPoints: totalPoints ?? this.totalPoints,
      streak: streak ?? this.streak,
      lastStudiedAt: lastStudiedAt ?? this.lastStudiedAt,
      parentEmail: parentEmail ?? this.parentEmail,
      badges: badges ?? this.badges,
      prefectureProgress: prefectureProgress ?? this.prefectureProgress,
      stageProgress: stageProgress ?? this.stageProgress,
      coins: coins ?? this.coins,
      trialStartDate: trialStartDate ?? this.trialStartDate,
      wrongAnswerIds: wrongAnswerIds ?? this.wrongAnswerIds,
    );
  }

  factory UserProgress.fromFirestore(Map<String, dynamic> json, String uid) {
    final progressMap = <String, PrefectureProgress>{};
    final raw = json['progress'] as Map<String, dynamic>?;
    raw?.forEach((key, value) {
      if (value is Map<String, dynamic>) {
        progressMap[key] = PrefectureProgress.fromJson(value);
      }
    });

    final stageProgressMap = <String, StageProgress>{};
    final stageRaw = json['stageProgress'] as Map<String, dynamic>?;
    stageRaw?.forEach((key, value) {
      if (value is Map<String, dynamic>) {
        stageProgressMap[key] = StageProgress.fromJson(value);
      }
    });

    return UserProgress(
      userId: uid,
      grade: json['grade'] as int? ?? 4,
      isPremium: json['isPremium'] as bool? ?? false,
      totalPoints: json['totalPoints'] as int? ?? 0,
      streak: json['streak'] as int? ?? 0,
      lastStudiedAt: (json['lastStudiedAt'] as Timestamp?)?.toDate(),
      parentEmail: json['parentEmail'] as String?,
      badges: List<String>.from(json['badges'] as List? ?? []),
      prefectureProgress: progressMap,
      stageProgress:
          stageProgressMap.isEmpty ? {'stage_1': StageProgress.empty('stage_1', 1)} : stageProgressMap,
      wrongAnswerIds: List<String>.from(json['wrongAnswerIds'] as List? ?? []),
    );
  }
}
