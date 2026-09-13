/// クイズ1回の試行履歴
class QuizAttempt {
  final String id;
  final int stageNo;
  final String? prefectureId;
  final String? prefectureName;
  final DateTime attemptedAt;
  final int durationSeconds;      // この試行の所要時間
  final int totalScore;           // この試行で得たスコア
  final int correctCount;         // 正解数
  final int totalCount;           // 総問題数
  final List<int> userAnswers;    // ユーザーが選んだ選択肢インデックス [1, 2, 0, ...] など
  final List<int> correctAnswers; // 正解のインデックス [1, 1, 0, ...] など

  const QuizAttempt({
    required this.id,
    required this.stageNo,
    required this.attemptedAt,
    required this.durationSeconds,
    required this.totalScore,
    required this.correctCount,
    required this.totalCount,
    required this.userAnswers,
    required this.correctAnswers,
    this.prefectureId,
    this.prefectureName,
  });

  /// 正答率（パーセント）
  double get accuracyPercentage {
    return totalCount > 0 ? (correctCount / totalCount) * 100 : 0.0;
  }

  /// 平均回答時間（秒）
  double get averageTimePerQuestion {
    return totalCount > 0 ? durationSeconds / totalCount : 0.0;
  }

  /// 全問正解したか
  bool get isPerfect => correctCount == totalCount;

  factory QuizAttempt.fromJson(Map<String, dynamic> json) {
    return QuizAttempt(
      id: json['id'] as String? ?? '',
      stageNo: json['stageNo'] as int? ?? 1,
      prefectureId: json['prefectureId'] as String?,
      prefectureName: json['prefectureName'] as String?,
      attemptedAt: DateTime.tryParse(json['attemptedAt'] as String? ?? '') ?? DateTime.now(),
      durationSeconds: json['durationSeconds'] as int? ?? 0,
      totalScore: json['totalScore'] as int? ?? 0,
      correctCount: json['correctCount'] as int? ?? 0,
      totalCount: json['totalCount'] as int? ?? 0,
      userAnswers: List<int>.from(json['userAnswers'] as List? ?? []),
      correctAnswers: List<int>.from(json['correctAnswers'] as List? ?? []),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'stageNo': stageNo,
    'prefectureId': prefectureId,
    'prefectureName': prefectureName,
    'attemptedAt': attemptedAt.toIso8601String(),
    'durationSeconds': durationSeconds,
    'totalScore': totalScore,
    'correctCount': correctCount,
    'totalCount': totalCount,
    'userAnswers': userAnswers,
    'correctAnswers': correctAnswers,
  };
}
