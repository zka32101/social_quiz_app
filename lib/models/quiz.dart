/// クイズ問題モデル（新設計 v3.0）
class Quiz {
  final String id;
  final int stepNo;              // 関連するステップ番号 (1, 2, 3)
  final String question;
  final List<String> choices;    // 4択
  final int correctIndex;        // 正解のインデックス (0-3)
  final String explanation;
  final String? prefectureId;    // 都道府県ID（例：tokyo）
  final String? prefectureName;  // 都道府県名（例：東京都）

  const Quiz({
    required this.id,
    required this.stepNo,
    required this.question,
    required this.choices,
    required this.correctIndex,
    required this.explanation,
    this.prefectureId,
    this.prefectureName,
  });

  bool isCorrect(int selectedIndex) => selectedIndex == correctIndex;

  String get correctAnswer => choices[correctIndex];

  factory Quiz.fromJson(Map<String, dynamic> json) {
    return Quiz(
      id: json['id'] as String? ?? '',
      stepNo: json['stepNo'] as int? ?? 1,
      question: json['question'] as String? ?? '',
      choices: List<String>.from(json['choices'] as List? ?? []),
      correctIndex: json['correctIndex'] as int? ?? 0,
      explanation: json['explanation'] as String? ?? '',
      prefectureId: json['prefectureId'] as String?,
      prefectureName: json['prefectureName'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'stepNo': stepNo,
        'question': question,
        'choices': choices,
        'correctIndex': correctIndex,
        'explanation': explanation,
        'prefectureId': prefectureId,
        'prefectureName': prefectureName,
      };
}

/// クイズ結果（1問分）
class QuizAnswer {
  final String quizId;
  final int selectedIndex;
  final bool isCorrect;
  final int pointsEarned;

  const QuizAnswer({
    required this.quizId,
    required this.selectedIndex,
    required this.isCorrect,
    required this.pointsEarned,
  });
}

/// クイズセッション結果（10問分まとめ）
class QuizResult {
  final String prefectureId;
  final List<QuizAnswer> answers;
  final int totalPoints;
  final DateTime completedAt;

  const QuizResult({
    required this.prefectureId,
    required this.answers,
    required this.totalPoints,
    required this.completedAt,
  });

  int get correctCount => answers.where((a) => a.isCorrect).length;
  int get totalCount => answers.length;
  bool get isAllCorrect => correctCount == totalCount;
  double get percentage => totalCount > 0 ? correctCount / totalCount : 0.0;
}
