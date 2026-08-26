import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../repositories/progress_repository.dart';
import '../../utils/constants.dart';
import '../../data/industry_diagrams.dart';
import '../../widgets/diagrams/diagram_panel.dart';

// ─────────────────────────────────────────────────────────────
// Section title map
// ─────────────────────────────────────────────────────────────

const Map<String, String> _sectionTitles = {
  'agriculture': '農業',
  'fishery': '水産業',
  'manufacturing': '工業',
  'industrial_zones': '工業地帯',
  'food_self_sufficiency': '食料自給率',
  'pollution': '公害・環境問題',
  'information_society': '情報化社会',
};

// ─────────────────────────────────────────────────────────────
// Quiz Screen
// ─────────────────────────────────────────────────────────────

class IndustryQuizScreen extends ConsumerStatefulWidget {
  final String sectionId;

  const IndustryQuizScreen({super.key, required this.sectionId});

  @override
  ConsumerState<IndustryQuizScreen> createState() => _IndustryQuizScreenState();
}

class _IndustryQuizScreenState extends ConsumerState<IndustryQuizScreen> {
  static const Color _themeColor = Colors.teal;
  static const Color _themeDark = Color(0xFF00695C);

  List<Map<String, dynamic>>? _questions;
  bool _loading = true;
  String? _error;

  int _currentIndex = 0;
  int? _selectedIndex;
  bool _answered = false;
  int _correctCount = 0;
  int _totalCoins = 0;
  int _totalPoints = 0;
  bool _finished = false;

  String get _sectionTitle =>
      _sectionTitles[widget.sectionId] ?? '産業クイズ';

  @override
  void initState() {
    super.initState();
    _loadQuizzes(widget.sectionId);
  }

  Future<void> _loadQuizzes(String sectionId) async {
    try {
      final jsonStr =
          await rootBundle.loadString('assets/data/quizzes_industry.json');
      final List<dynamic> all = json.decode(jsonStr);
      final filtered = all
          .cast<Map<String, dynamic>>()
          .where((q) => q['subcategory'] == sectionId)
          .toList();
      if (mounted) {
        setState(() {
          _questions = filtered;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _loading = false;
        });
      }
    }
  }

  // ─── Helpers ──────────────────────────────────────────────

  List<String> _optionsOf(Map<String, dynamic> q) =>
      List<String>.from(q['options'] as List);

  int _correctIndexOf(Map<String, dynamic> q) {
    final opts = _optionsOf(q);
    final correct = q['correctAnswer'] as String;
    final index = opts.indexOf(correct);
    if (index == -1) {
      // correctAnswer が options のどれとも一致しない ＝ JSON のデータ不整合。
      // 「0番目を正解扱いする」を黙って行うと誤った採点に気づけないため、
      // デバッグ時に検知できるようログを残す（本番挙動は従来どおり0番目扱い）。
      assert(false,
          'quizzes_industry.json: correctAnswer "$correct" not found in options $opts (id: ${q['id']})');
      debugPrint(
          '⚠️ industry quiz data mismatch: correctAnswer "$correct" not in options (id: ${q['id']})');
      return 0;
    }
    return index;
  }

  // ─── Build ────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null || _questions == null || _questions!.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text(_sectionTitle),
          backgroundColor: _themeColor,
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Text(
            _error != null
                ? 'データの読み込みに失敗しました。\n$_error'
                : 'このセクションのクイズがまだありません。',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 15, color: Color(0xFF666666)),
          ),
        ),
      );
    }

    if (_finished) return _buildResultScreen(context);
    return _buildQuizScreen(context);
  }

  // ─── Quiz UI ──────────────────────────────────────────────

  Widget _buildQuizScreen(BuildContext context) {
    final questions = _questions!;
    final quiz = questions[_currentIndex];
    final progress = (_currentIndex + 1) / questions.length;
    final options = _optionsOf(quiz);
    final correctIdx = _correctIndexOf(quiz);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // ─── Gradient header ────────────────────────────────
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [_themeColor, _themeDark],
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          onPressed: () => _confirmExit(context),
                          icon: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 24,
                          ),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                              minWidth: 40, minHeight: 40),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _sectionTitle,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '問題 ${_currentIndex + 1} / ${questions.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 8,
                        backgroundColor: Colors.white.withOpacity(0.3),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Points display
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const Text('⭐', style: TextStyle(fontSize: 16)),
                      const SizedBox(width: 4),
                      Text(
                        '$_totalPoints pt',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Color(0xFF333333),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text('🪙', style: TextStyle(fontSize: 16)),
                      const SizedBox(width: 4),
                      Text(
                        '$_totalCoins',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Color(0xFF333333),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Diagram (shown once, before the first question of the
                  // section, for topics that have a visual explainer)
                  if (_currentIndex == 0 &&
                      industryDiagramFor(widget.sectionId) != null) ...[
                    DiagramPanel(
                      title: '図でみる：$_sectionTitle',
                      color: _themeColor,
                      diagram: industryDiagramFor(widget.sectionId)!,
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Question
                  const Center(
                    child: Text('❓', style: TextStyle(fontSize: 48)),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    quiz['question'] as String,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF333333),
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 28),

                  // Answer choices
                  ...options.asMap().entries.map((entry) {
                    return _buildChoiceButton(
                        entry.key, entry.value, correctIdx);
                  }),

                  // Feedback after answer
                  if (_answered) ...[
                    const SizedBox(height: 16),
                    _buildFeedbackCard(quiz, correctIdx, options),
                  ],
                ],
              ),
            ),
          ),

          // Next button
          if (_answered)
            Padding(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton(
                onPressed: () => _nextQuestion(context),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                  backgroundColor: _themeColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                child: Text(
                  _currentIndex < _questions!.length - 1 ? '次の問題へ' : '結果を見る',
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildChoiceButton(int index, String choice, int correctIdx) {
    Color bgColor = Colors.white;
    Color borderColor = const Color(0xFFE0E0E0);
    Color textColor = const Color(0xFF333333);
    Color labelBgColor = _themeColor;

    if (_answered) {
      if (index == correctIdx) {
        bgColor = const Color(AppColors.correctBgValue);
        borderColor = const Color(AppColors.correctValue);
        textColor = const Color(AppColors.correctValue);
        labelBgColor = const Color(AppColors.correctValue);
      } else if (index == _selectedIndex) {
        bgColor = const Color(AppColors.incorrectBgValue);
        borderColor = const Color(AppColors.incorrectValue);
        textColor = const Color(0xFFC0392B);
        labelBgColor = const Color(0xFFC0392B);
      } else {
        bgColor = Colors.white.withOpacity(0.6);
        labelBgColor = const Color(0xFFBBBBBB);
      }
    } else if (index == _selectedIndex) {
      bgColor = const Color(0xFFE0F2F1);
      borderColor = _themeColor;
      labelBgColor = _themeDark;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: _answered ? null : () => _selectAnswer(index, correctIdx),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: bgColor,
            border: Border.all(color: borderColor, width: 2),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: labelBgColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    String.fromCharCode(65 + index),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  choice,
                  style: TextStyle(
                    fontSize: 16,
                    color: textColor,
                    fontWeight: (_answered && index == correctIdx)
                        ? FontWeight.bold
                        : FontWeight.w500,
                  ),
                ),
              ),
              if (_answered && index == correctIdx)
                const Text(
                  '✓',
                  style: TextStyle(
                    color: Color(AppColors.correctValue),
                    fontSize: 20,
                  ),
                ),
              if (_answered &&
                  index == _selectedIndex &&
                  index != correctIdx)
                const Text(
                  '✗',
                  style: TextStyle(
                    color: Color(AppColors.incorrectValue),
                    fontSize: 20,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeedbackCard(
    Map<String, dynamic> quiz,
    int correctIdx,
    List<String> options,
  ) {
    final isCorrect = _selectedIndex == correctIdx;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isCorrect
            ? const Color(AppColors.correctBgValue)
            : const Color(AppColors.incorrectBgValue),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                isCorrect ? '✓ 正解！' : '✗ 不正解',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: isCorrect
                      ? const Color(AppColors.correctValue)
                      : const Color(AppColors.incorrectValue),
                ),
              ),
              if (isCorrect) ...[
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(AppColors.correctValue),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    '+5🪙 +10pt',
                    style: TextStyle(color: Colors.white, fontSize: 11),
                  ),
                ),
              ],
              if (!isCorrect) ...[
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '正解: ${options[correctIdx]}',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF444444),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ],
          ),
          if (quiz['explanation'] != null &&
              (quiz['explanation'] as String).isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              quiz['explanation'] as String,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF555555),
                height: 1.5,
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ─── Result screen ────────────────────────────────────────

  Widget _buildResultScreen(BuildContext context) {
    final total = _questions!.length;
    final percentage = total > 0 ? (_correctCount / total * 100).round() : 0;
    final emoji = percentage >= 80
        ? '🎉'
        : percentage >= 60
            ? '👍'
            : '📚';

    return Scaffold(
      backgroundColor: const Color(AppColors.bgLight),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Result banner
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [_themeColor, _themeDark],
                    ),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    children: [
                      Text(emoji, style: const TextStyle(fontSize: 64)),
                      const SizedBox(height: 12),
                      const Text(
                        'クイズ終了！',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _sectionTitle,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Score card
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 28,
                    ),
                    child: Column(
                      children: [
                        Text(
                          '$_correctCount / $total 問正解',
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF333333),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$percentage%',
                          style: TextStyle(
                            fontSize: 18,
                            color: _themeColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _ScorePill(
                              label: '獲得コイン',
                              value: '🪙 $_totalCoins',
                            ),
                            _ScorePill(
                              label: '獲得ポイント',
                              value: '⭐ $_totalPoints pt',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Retry button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      setState(() {
                        _currentIndex = 0;
                        _selectedIndex = null;
                        _answered = false;
                        _correctCount = 0;
                        _totalCoins = 0;
                        _totalPoints = 0;
                        _finished = false;
                      });
                    },
                    icon: const Icon(Icons.replay),
                    label: const Text('もう一度挑戦'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Home button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => context.go(AppRoutes.home),
                    icon: const Icon(Icons.home),
                    label: const Text('ホームへ戻る'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _themeColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─── Logic ───────────────────────────────────────────────

  void _selectAnswer(int index, int correctIdx) {
    final isCorrect = index == correctIdx;
    setState(() {
      _selectedIndex = index;
      _answered = true;
      if (isCorrect) {
        _correctCount++;
        _totalCoins += 5;
        _totalPoints += 10;
      }
    });

    if (!isCorrect) {
      final quiz = _questions![_currentIndex];
      final quizId = quiz['id'] as String? ?? '${widget.sectionId}_$_currentIndex';
      ref.read(userProgressProvider.notifier).addWrongAnswer(quizId);
    }
  }

  void _nextQuestion(BuildContext context) {
    if (_currentIndex < _questions!.length - 1) {
      setState(() {
        _currentIndex++;
        _selectedIndex = null;
        _answered = false;
      });
    } else {
      _finishQuiz();
    }
  }

  Future<void> _finishQuiz() async {
    final notifier = ref.read(userProgressProvider.notifier);
    await notifier.addCoins(_totalCoins);
    await notifier.addPoints(_totalPoints);

    if (!mounted) return;
    setState(() => _finished = true);
  }

  void _confirmExit(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('クイズを中断しますか？'),
        content: const Text('進捗はここまでが保存されます。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('続ける'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.go(AppRoutes.home);
            },
            child:
                const Text('中断する', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Helper widget
// ─────────────────────────────────────────────────────────────

class _ScorePill extends StatelessWidget {
  final String label;
  final String value;

  const _ScorePill({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: Color(0xFF616161)),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF333333),
          ),
        ),
      ],
    );
  }
}
