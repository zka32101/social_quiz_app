import 'package:cloud_firestore/cloud_firestore.dart';

/// Base abstract class for all quiz data types
abstract class QuizData {
  final String id;               // quiz_stage1_quest1_v1
  final String questId;          // stage1_quest1
  final String quizType;         // multiple_choice | fill_blank | map_tap
  final String? question;        // Problem text (optional)
  final String? explanation;     // Answer explanation
  final DateTime createdAt;

  QuizData({
    required this.id,
    required this.questId,
    required this.quizType,
    this.question,
    this.explanation,
    required this.createdAt,
  });

  /// Factory constructor to deserialize from Firestore data
  factory QuizData.fromFirestore(Map<String, dynamic> data) {
    final type = data['quizType'] as String?;

    switch (type) {
      case 'multiple_choice':
        return MultipleChoiceQuiz.fromMap(data);
      case 'fill_blank':
        return FillBlankQuiz.fromMap(data);
      case 'map_tap':
        return MapTapQuiz.fromMap(data);
      default:
        throw UnknownQuizTypeException(type ?? 'unknown');
    }
  }

  /// Serialize to Firestore-compatible Map
  Map<String, dynamic> toMap();
}

/// Quiz type: Multiple choice (4 options A/B/C/D)
class MultipleChoiceQuiz extends QuizData {
  final List<String> options;    // 4 items: ['A', 'B', 'C', 'D']
  final int correctIndex;        // 0-3

  MultipleChoiceQuiz({
    required String id,
    required String questId,
    required this.options,
    required this.correctIndex,
    String? question,
    String? explanation,
    required DateTime createdAt,
  }) : super(
    id: id,
    questId: questId,
    quizType: 'multiple_choice',
    question: question,
    explanation: explanation,
    createdAt: createdAt,
  );

  factory MultipleChoiceQuiz.fromMap(Map<String, dynamic> data) {
    return MultipleChoiceQuiz(
      id: data['id'] as String,
      questId: data['questId'] as String,
      options: List<String>.from(data['options'] as List),
      correctIndex: data['correctIndex'] as int,
      question: data['question'] as String?,
      explanation: data['explanation'] as String?,
      createdAt: _parseDateTime(data['createdAt']),
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'questId': questId,
      'quizType': quizType,
      'question': question,
      'explanation': explanation,
      'options': options,
      'correctIndex': correctIndex,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

/// Quiz type: Fill in the blank
class FillBlankQuiz extends QuizData {
  final String correctAnswer;           // Expected text
  final String problemText;             // "日本の最北端は___です"
  final List<String>? acceptableVariants; // ['北海道', '北海']
  final List<String>? hints;
  final bool caseSensitive;             // true for geography, false for others

  FillBlankQuiz({
    required String id,
    required String questId,
    required this.correctAnswer,
    required this.problemText,
    this.acceptableVariants,
    this.hints,
    this.caseSensitive = true,
    String? question,
    String? explanation,
    required DateTime createdAt,
  }) : super(
    id: id,
    questId: questId,
    quizType: 'fill_blank',
    question: question,
    explanation: explanation,
    createdAt: createdAt,
  );

  factory FillBlankQuiz.fromMap(Map<String, dynamic> data) {
    return FillBlankQuiz(
      id: data['id'] as String,
      questId: data['questId'] as String,
      correctAnswer: data['correctAnswer'] as String,
      problemText: data['problemText'] as String,
      acceptableVariants: data['acceptableVariants'] != null
          ? List<String>.from(data['acceptableVariants'] as List)
          : null,
      hints: data['hints'] != null ? List<String>.from(data['hints'] as List) : null,
      caseSensitive: data['caseSensitive'] as bool? ?? true,
      question: data['question'] as String?,
      explanation: data['explanation'] as String?,
      createdAt: _parseDateTime(data['createdAt']),
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'questId': questId,
      'quizType': quizType,
      'question': question,
      'explanation': explanation,
      'correctAnswer': correctAnswer,
      'problemText': problemText,
      'acceptableVariants': acceptableVariants,
      'hints': hints,
      'caseSensitive': caseSensitive,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

/// Quiz type: Map tapping (select a region)
class MapTapQuiz extends QuizData {
  final String correctAnswer;           // 'hokkaido'
  final List<String> availableRegions;  // Filter which regions to show
  final Map<String, String> regionLabels; // {hokkaido: '北海道', ...}

  MapTapQuiz({
    required String id,
    required String questId,
    required this.correctAnswer,
    required this.availableRegions,
    required this.regionLabels,
    String? question,
    String? explanation,
    required DateTime createdAt,
  }) : super(
    id: id,
    questId: questId,
    quizType: 'map_tap',
    question: question,
    explanation: explanation,
    createdAt: createdAt,
  );

  factory MapTapQuiz.fromMap(Map<String, dynamic> data) {
    return MapTapQuiz(
      id: data['id'] as String,
      questId: data['questId'] as String,
      correctAnswer: data['correctAnswer'] as String,
      availableRegions: List<String>.from(data['availableRegions'] as List),
      regionLabels: Map<String, String>.from(data['regionLabels'] as Map),
      question: data['question'] as String?,
      explanation: data['explanation'] as String?,
      createdAt: _parseDateTime(data['createdAt']),
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'questId': questId,
      'quizType': quizType,
      'question': question,
      'explanation': explanation,
      'correctAnswer': correctAnswer,
      'availableRegions': availableRegions,
      'regionLabels': regionLabels,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

/// Helper function to parse DateTime from Firestore
DateTime _parseDateTime(dynamic value) {
  if (value is Timestamp) {
    return value.toDate();
  } else if (value is String) {
    return DateTime.parse(value);
  } else {
    return DateTime.now();
  }
}

/// Exception for unknown quiz types
class UnknownQuizTypeException implements Exception {
  final String type;
  UnknownQuizTypeException(this.type);

  @override
  String toString() => 'UnknownQuizTypeException: Unknown quiz type "$type"';
}
