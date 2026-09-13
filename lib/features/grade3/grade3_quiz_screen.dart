import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../repositories/progress_repository.dart';
import '../../utils/constants.dart';
import '../../widgets/explanation_with_image_widget.dart' as explanation;

// ─── JSON data model ──────────────────────────────────────────────────────────

class _QuizQuestion {
  final String id;
  final String question;
  final List<String> options;
  final String correctAnswer;
  final String explanation;

  const _QuizQuestion({
    required this.id,
    required this.question,
    required this.options,
    required this.correctAnswer,
    required this.explanation,
  });

  factory _QuizQuestion.fromJson(Map<String, dynamic> json) {
    return _QuizQuestion(
      id: json['id'] as String,
      question: json['question'] as String,
      options: List<String>.from(json['options'] as List),
      correctAnswer: json['correctAnswer'] as String,
      explanation: json['explanation'] as String? ?? '',
    );
  }

  int get correctIndex => options.indexOf(correctAnswer);
}

// ─── Async loader provider ────────────────────────────────────────────────────

final grade3QuestionsProvider =
    FutureProvider.family<List<_QuizQuestion>, String>((ref, sectionId) async {
  final jsonString =
      await rootBundle.loadString('assets/data/quizzes_grade3.json');
  final dynamic decoded = jsonDecode(jsonString);

  List<dynamic> rawItems;
  if (decoded is List) {
    rawItems = decoded;
  } else if (decoded is Map && decoded.containsKey('questions')) {
    rawItems = decoded['questions'] as List;
  } else {
    rawItems = [];
  }

  final filtered = rawItems
      .cast<Map<String, dynamic>>()
      .where((item) {
        final subcategory = item['subcategory'] as String?;
        final category = item['category'] as String?;
        return (subcategory == sectionId) &&
            (category == null || category == 'grade3');
      })
      .map(_QuizQuestion.fromJson)
      .toList();

  return filtered;
});

// ─── Choice state enum ────────────────────────────────────────────────────────

enum _ChoiceState { normal, selected, correct, wrong }

// ─── Screen ──────────────────────────────────────────────────────────────────

class Grade3QuizScreen extends ConsumerStatefulWidget {
  final String sectionId;

  const Grade3QuizScreen({super.key, required this.sectionId});

  @override
  ConsumerState<Grade3QuizScreen> createState() => _Grade3QuizScreenState();
}

class _Grade3QuizScreenState extends ConsumerState<Grade3QuizScreen> {
  static const Color _primaryColor = Colors.indigo;

  int _currentIndex = 0;
  int? _selectedOptionIndex;
  bool _answered = false;
  int _correctCount = 0;
  bool _quizFinished = false;

  void _onSelectAnswer(int index, _QuizQuestion question) {
    if (_answered) return;
    setState(() {
      _selectedOptionIndex = index;
      _answered = true;
      if (index == question.correctIndex) {
        _correctCount++;
      }
    });
  }

  Future<void> _onNext(List<_QuizQuestion> questions) async {
    final question = questions[_currentIndex];
    final isWrong = _selectedOptionIndex != question.correctIndex;

    // Record wrong answer via progress provider
    if (isWrong) {
      ref.read(userProgressProvider.notifier).addWrongAnswer(question.id);
    }

    if (_currentIndex < questions.length - 1) {
      setState(() {
        _currentIndex++;
        _selectedOptionIndex = null;
        _answered = false;
      });
    } else {
      // Award points for correct answers (10 pts each)
      final points = _correctCount * AppConstants.pointsPerCorrectAnswer;
      // 他の教科（公民・産業など）と同様、正解1問につき5コインを付与する
      final coins = _correctCount * 5;
      final notifier = ref.read(userProgressProvider.notifier);
      if (points > 0) await notifier.addPoints(points);
      if (coins > 0) await notifier.addCoins(coins);
      if (!mounted) return;
      setState(() => _quizFinished = true);
    }
  }

  void _resetQuiz() {
    setState(() {
      _currentIndex = 0;
      _selectedOptionIndex = null;
      _answered = false;
      _correctCount = 0;
      _quizFinished = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final questionsAsync =
        ref.watch(grade3QuestionsProvider(widget.sectionId));

    return Scaffold(
      appBar: AppBar(
        title: Text(_sectionTitle(widget.sectionId)),
        backgroundColor: _primaryColor,
        foregroundColor: Colors.white,
      ),
      body: questionsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _buildError(error),
        data: (questions) {
          if (questions.isEmpty) {
            return _buildEmpty();
          }
          if (_quizFinished) {
            return _buildResult(questions.length);
          }
          return _buildQuiz(questions);
        },
      ),
    );
  }

  // ─── Quiz UI ──────────────────────────────────────────────────────────────

  Widget _buildQuiz(List<_QuizQuestion> questions) {
    final question = questions[_currentIndex];
    final total = questions.length;
    final progress = (_currentIndex + 1) / total;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // ─── Progress bar ─────────────────────────────────────
        _ProgressHeader(
          current: _currentIndex + 1,
          total: total,
          progress: progress,
          primaryColor: _primaryColor,
        ),
        const SizedBox(height: 16),

        // ─── Question card ────────────────────────────────────
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Text(
              question.question,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                height: 1.5,
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),

        // ─── Options ──────────────────────────────────────────
        for (int i = 0; i < question.options.length; i++)
          _ChoiceTile(
            label: String.fromCharCode(65 + i), // A B C D
            text: question.options[i],
            state: _choiceState(i, question),
            onTap: _answered ? null : () => _onSelectAnswer(i, question),
          ),

        // ─── Explanation after answer ─────────────────────────
        if (_answered && question.explanation.isNotEmpty) ...[
          const SizedBox(height: 12),
          explanation.ExplanationWithImage(
            explanation: question.explanation,
            imageKeyword: '地図',
            imageHeight: 180,
            padding: const EdgeInsets.all(0),
          ),
        ],

        // ─── Next / Finish button ──────────────────────────────
        if (_answered) ...[
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => _onNext(questions),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(50),
              backgroundColor: _primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            child: Text(
              _currentIndex < questions.length - 1 ? '次の問題へ' : '結果を見る',
            ),
          ),
        ],

        const SizedBox(height: 24),
      ],
    );
  }

  _ChoiceState _choiceState(int index, _QuizQuestion question) {
    if (!_answered) {
      return _selectedOptionIndex == index
          ? _ChoiceState.selected
          : _ChoiceState.normal;
    }
    if (index == question.correctIndex) return _ChoiceState.correct;
    if (index == _selectedOptionIndex) return _ChoiceState.wrong;
    return _ChoiceState.normal;
  }

  // ─── Result UI ────────────────────────────────────────────────────────────

  Widget _buildResult(int total) {
    final allCorrect = _correctCount == total;
    final points = _correctCount * AppConstants.pointsPerCorrectAnswer;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: allCorrect
                ? const Color(AppColors.correctBgValue)
                : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: allCorrect
                  ? const Color(AppColors.correctValue).withOpacity(0.4)
                  : Colors.grey.shade200,
            ),
          ),
          child: Column(
            children: [
              Text(
                allCorrect ? '🎉 全問正解！' : '📝 クイズ結果',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '$_correctCount / $total 正解',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: allCorrect
                      ? const Color(AppColors.correctValue)
                      : Colors.orange,
                ),
              ),
              const SizedBox(height: 8),
              if (allCorrect)
                const Text(
                  'すばらしい！全問正解です！',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(AppColors.correctValue),
                  ),
                )
              else
                Text(
                  'もう一度チャレンジしてみよう！',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              const SizedBox(height: 16),
              if (points > 0) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('⭐ ', style: TextStyle(fontSize: 18)),
                    Text(
                      '+$points ポイント',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(AppColors.primaryValue),
                      ),
                    ),
                  ],
                ),
              ],
              if (_correctCount > 0) ...[
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('🪙 ', style: TextStyle(fontSize: 18)),
                    Text(
                      '+${_correctCount * 5} コイン',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.amber,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 20),

        // ─── Actions ──────────────────────────────────────────
        ElevatedButton.icon(
          onPressed: _resetQuiz,
          icon: const Icon(Icons.replay),
          label: const Text('もう一度'),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size.fromHeight(50),
            backgroundColor: _primaryColor,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () => context.go('/grade3'),
          icon: const Icon(Icons.arrow_back),
          label: const Text('もどる'),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  // ─── Error / empty states ─────────────────────────────────────────────────

  Widget _buildError(Object error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 12),
            const Text(
              'クイズデータの読み込みに失敗しました',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () =>
                  ref.refresh(grade3QuestionsProvider(widget.sectionId)),
              child: const Text('もう一度読み込む'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.quiz_outlined, size: 48, color: Colors.grey),
            const SizedBox(height: 12),
            const Text(
              'このカテゴリーのクイズはまだありません',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () => context.go('/grade3'),
              icon: const Icon(Icons.arrow_back),
              label: const Text('もどる'),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Progress header ──────────────────────────────────────────────────────────

class _ProgressHeader extends StatelessWidget {
  final int current;
  final int total;
  final double progress;
  final Color primaryColor;

  const _ProgressHeader({
    required this.current,
    required this.total,
    required this.progress,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '問題 $current / $total',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF555555),
              ),
            ),
            Text(
              '${(progress * 100).toInt()}%',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: primaryColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            backgroundColor: const Color(0xFFE0E0E0),
            valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
          ),
        ),
      ],
    );
  }
}

// ─── Choice tile ──────────────────────────────────────────────────────────────

class _ChoiceTile extends StatelessWidget {
  final String label;
  final String text;
  final _ChoiceState state;
  final VoidCallback? onTap;

  const _ChoiceTile({
    required this.label,
    required this.text,
    required this.state,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color borderColor;
    Color labelColor;

    switch (state) {
      case _ChoiceState.correct:
        bgColor = const Color(AppColors.correctBgValue);
        borderColor = const Color(AppColors.correctValue);
        labelColor = const Color(AppColors.correctValue);
      case _ChoiceState.wrong:
        bgColor = const Color(AppColors.incorrectBgValue);
        borderColor = const Color(AppColors.incorrectValue);
        labelColor = const Color(AppColors.incorrectValue);
      case _ChoiceState.selected:
        bgColor = const Color(0xFFE8EAF6); // indigo-50
        borderColor = Colors.indigo;
        labelColor = Colors.indigo;
      case _ChoiceState.normal:
        bgColor = Colors.white;
        borderColor = Colors.grey.shade300;
        labelColor = Colors.grey.shade600;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor, width: 1.5),
        ),
        child: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: borderColor.withOpacity(0.15),
                shape: BoxShape.circle,
                border: Border.all(color: borderColor),
              ),
              child: Center(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: labelColor,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(fontSize: 14, height: 1.4),
              ),
            ),
            if (state == _ChoiceState.correct)
              const Icon(
                Icons.check_circle,
                color: Color(AppColors.correctValue),
                size: 20,
              ),
            if (state == _ChoiceState.wrong)
              const Icon(
                Icons.cancel,
                color: Color(AppColors.incorrectValue),
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}

// ─── Helpers ──────────────────────────────────────────────────────────────────

String _sectionTitle(String sectionId) {
  switch (sectionId) {
    case 'map_symbols':
      return '地図記号クイズ';
    case 'directions':
      return '方位クイズ';
    case 'old_life':
      return '昔のくらしクイズ';
    case 'public_services':
      return '消防・警察クイズ';
    case 'supermarket':
      return 'スーパーの工夫クイズ';
    default:
      return 'クイズ';
  }
}
