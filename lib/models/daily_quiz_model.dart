/// 今日のニュースクイズモデル
class DailyQuiz {
  final String quizId;
  final String question;
  final List<String> options;
  final int correctIndex;
  final String explanation;
  final String category;      // "event", "history", "geography", "politics"
  final String difficulty;    // "easy", "medium", "hard"
  final DateTime date;
  final bool isAnswered;
  final bool isCorrect;
  final int bonusPoints;

  DailyQuiz({
    required this.quizId,
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.explanation,
    required this.category,
    required this.difficulty,
    required this.date,
    this.isAnswered = false,
    this.isCorrect = false,
    this.bonusPoints = 50,
  });

  factory DailyQuiz.fromJson(Map<String, dynamic> json) {
    return DailyQuiz(
      quizId: json['quiz_id'] as String? ?? '',
      question: json['question'] as String? ?? '',
      options: List<String>.from(json['options'] as List? ?? []),
      correctIndex: json['correct_index'] as int? ?? 0,
      explanation: json['explanation'] as String? ?? '',
      category: json['category'] as String? ?? 'event',
      difficulty: json['difficulty'] as String? ?? 'easy',
      date: json['date'] != null
          ? DateTime.parse(json['date'] as String)
          : DateTime.now(),
      bonusPoints: json['bonus_points'] as int? ?? 50,
    );
  }

  Map<String, dynamic> toJson() => {
    'quiz_id': quizId,
    'question': question,
    'options': options,
    'correct_index': correctIndex,
    'explanation': explanation,
    'category': category,
    'difficulty': difficulty,
    'date': date.toIso8601String(),
    'bonus_points': bonusPoints,
  };

  DailyQuiz copyWith({
    bool? isAnswered,
    bool? isCorrect,
  }) {
    return DailyQuiz(
      quizId: quizId,
      question: question,
      options: options,
      correctIndex: correctIndex,
      explanation: explanation,
      category: category,
      difficulty: difficulty,
      date: date,
      isAnswered: isAnswered ?? this.isAnswered,
      isCorrect: isCorrect ?? this.isCorrect,
      bonusPoints: bonusPoints,
    );
  }
}
