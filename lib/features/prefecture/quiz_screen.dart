import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/quiz.dart';
import '../../data/badge_definitions.dart';
import '../../repositories/content_repository.dart';
import '../../repositories/progress_repository.dart';
import '../../data/prefecture_data.dart';
import '../../utils/constants.dart';
import '../../utils/furigana_map.dart';
import '../../widgets/ruby_text.dart';
import '../../services/tts_service.dart';
import '../../services/ranking_service.dart';

class QuizScreen extends ConsumerStatefulWidget {
  final String prefectureId;
  final bool dailyMode;

  const QuizScreen({super.key, required this.prefectureId, this.dailyMode = false});

  @override
  ConsumerState<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends ConsumerState<QuizScreen> {
  int _currentIndex = 0;
  int? _selectedIndex;
  bool _answered = false;
  int _totalPoints = 0;
  int _correctCount = 0;
  final List<QuizAnswer> _answers = [];

  @override
  Widget build(BuildContext context) {
    final quizzesAsync = ref.watch(quizzesProvider(widget.prefectureId));

    return quizzesAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        body: Center(child: Text('エラー: $e')),
      ),
      data: (quizzes) {
        final display = widget.dailyMode
            ? _filterTrivialQuizzes(quizzes)
            : quizzes;
        return _buildQuizUI(context, display);
      },
    );
  }

  Widget _buildQuizUI(
    BuildContext context,
    List<Quiz> quizzes,
  ) {
    if (quizzes.isEmpty) {
      return const Scaffold(
        body: Center(child: Text('クイズデータがありません')),
      );
    }

    final quiz = quizzes[_currentIndex];
    final progress = (_currentIndex + 1) / quizzes.length;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // グリーングラデーションヘッダー + プログレス
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF2ECC71), Color(0xFF27AE60)],
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
                        GestureDetector(
                          onTap: () => _confirmExit(context),
                          child: const Icon(Icons.close, color: Colors.white, size: 24),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          '小学コレ！社会 - クイズ',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '問題 ${_currentIndex + 1} / ${quizzes.length}',
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
                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ポイント表示
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
                    ],
                  ),
                  const SizedBox(height: 20),

                  // 問題アイコン + 問題文
                  const Center(
                    child: Text('❓', style: TextStyle(fontSize: 48)),
                  ),
                  const SizedBox(height: 16),
                  // 問題文（ふりがな付き）＋読み上げボタン
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: RubyText.fromAnnotated(
                          quiz.question.withRuby,
                          textFontSize: 20,
                          rubyFontSize: 10,
                          textColor: const Color(0xFF333333),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.volume_up_rounded),
                        color: const Color(0xFF27AE60),
                        tooltip: '読み上げ',
                        onPressed: () =>
                            ref.read(ttsServiceProvider).speak(quiz.question),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),

                  // 選択肢
                  ...quiz.choices.asMap().entries.map((entry) {
                    return _buildChoiceButton(context, quiz, entry.key, entry.value);
                  }),

                  // 解説（回答後）
                  if (_answered) ...[
                    const SizedBox(height: 16),
                    _buildExplanationCard(quiz),
                  ],

                ],
              ),
            ),
          ),

          // 次へボタン
          if (_answered)
            Padding(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton(
                onPressed: () => _nextQuestion(context, quizzes),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                ),
                child: Text(
                  _currentIndex < quizzes.length - 1 ? '次の問題へ' : '結果を見る',
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildChoiceButton(
      BuildContext context, Quiz quiz, int index, String choice) {
    Color bgColor = Colors.white;
    Color borderColor = const Color(0xFFE0E0E0);
    Color textColor = const Color(0xFF333333);
    Color labelBgColor = const Color(0xFF2ECC71);

    if (_answered) {
      if (index == quiz.correctIndex) {
        bgColor = const Color(AppColors.correctBgValue);
        borderColor = const Color(AppColors.correctValue);
        textColor = const Color(AppColors.correctValue);
        labelBgColor = const Color(AppColors.correctValue);
      } else if (index == _selectedIndex) {
        bgColor = const Color(AppColors.incorrectBgValue);
        borderColor = const Color(AppColors.incorrectValue);
        textColor = const Color(AppColors.incorrectValue);
        labelBgColor = const Color(AppColors.incorrectValue);
      } else {
        bgColor = Colors.white.withOpacity(0.6);
        labelBgColor = const Color(0xFFBBBBBB);
      }
    } else if (index == _selectedIndex) {
      bgColor = const Color(0xFFE8F8F5);
      borderColor = const Color(0xFF2ECC71);
      labelBgColor = const Color(0xFF27AE60);
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: _answered ? null : () => _selectAnswer(quiz, index),
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
              // A, B, C, D ラベル（グリーン角丸正方形）
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
                    fontWeight: (_answered && index == quiz.correctIndex)
                        ? FontWeight.bold
                        : FontWeight.w500,
                  ),
                ),
              ),
              if (_answered && index == quiz.correctIndex)
                const Text('✓', style: TextStyle(
                    color: Color(AppColors.correctValue), fontSize: 20)),
              if (_answered && index == _selectedIndex &&
                  index != quiz.correctIndex)
                const Text('✗', style: TextStyle(
                    color: Color(AppColors.incorrectValue), fontSize: 20)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExplanationCard(Quiz quiz) {
    final isCorrect = _selectedIndex == quiz.correctIndex;
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
                  color: isCorrect
                      ? const Color(AppColors.correctValue)
                      : const Color(AppColors.incorrectValue),
                  fontSize: 15,
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
                    '+10pt',
                    style: TextStyle(color: Colors.white, fontSize: 11),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          Text(
            quiz.explanation,
            style: const TextStyle(
                fontSize: 13, height: 1.5, color: Color(0xFF444444)),
          ),
        ],
      ),
    );
  }

  void _selectAnswer(Quiz quiz, int index) {
    final isCorrect = quiz.isCorrect(index);
    int points = 0;
    if (isCorrect) {
      points = AppConstants.pointsPerCorrectAnswer;
      _correctCount++;
    }

    setState(() {
      _selectedIndex = index;
      _answered = true;
      _totalPoints += points;
      _answers.add(QuizAnswer(
        quizId: quiz.id,
        selectedIndex: index,
        isCorrect: isCorrect,
        pointsEarned: points,
      ));
    });
  }

  void _nextQuestion(BuildContext context, List<Quiz> quizzes) {
    if (_currentIndex < quizzes.length - 1) {
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
    // ─── 全問正解ボーナス ─────────────────────────────────
    final bool allCorrect =
        _answers.isNotEmpty && _correctCount == _answers.length;
    if (allCorrect) {
      _totalPoints += AppConstants.pointsAllCorrectBonus;
    }

    // ─── コイン計算: 正解1問=5コイン + 全問正解20コインボーナス ─
    final int coinsEarned = _correctCount * 5 + (allCorrect ? 20 : 0);

    final notifier = ref.read(userProgressProvider.notifier);
    final currentProgress = ref.read(userProgressProvider);

    // ─── ポイント・コイン保存（State即時更新） ───────────────
    await notifier.addPoints(_totalPoints);
    await notifier.addCoins(coinsEarned);

    // ─── クイズ結果 + ストリーク保存（日付ベース） ───────────
    await notifier.saveQuizResult(widget.prefectureId, _correctCount);
    // 日付ベースのストリーク計算（今日すでに学習済みなら変わらず）
    final repo = ref.read(progressRepositoryProvider);
    final newStreak = repo.calculateNewStreak(
      currentProgress.streak,
      currentProgress.lastStudiedAt,
    );
    final streakBadgeId = await notifier.updateStreakWithBadge(newStreak);

    // ─── バッジ自動付与 ────────────────────────────────────
    String? newBadgeId = streakBadgeId; // ストリークバッジ優先

    // first_correct: 初めてクイズに正解
    if (_correctCount > 0 &&
        !ref.read(userProgressProvider).badges.contains('first_correct')) {
      await notifier.addBadge('first_correct');
      newBadgeId ??= 'first_correct';
    }

    // prefecture master: スコア7/10以上で都道府県マスターバッジ
    if (_correctCount >= 7) {
      final masterId = '${widget.prefectureId}_master';
      final progress = ref.read(userProgressProvider);
      if (!progress.badges.contains(masterId) &&
          BadgeDefinitions.findById(masterId) != null) {
        await notifier.addBadge(masterId);
        newBadgeId ??= masterId;
      }
    }

    // ─── ランキング更新 ────────────────────────────────────
    // pointsEarned は各問題の実際の獲得ポイントを渡す（不正解時は
    // RankingService 側でも加算しないが、ここでも 0 を渡し二重に防御する）
    final rankingService = RankingService();
    for (final answer in _answers) {
      await rankingService.updateUserStats(
        pointsEarned: answer.isCorrect ? answer.pointsEarned : 0,
        isCorrect: answer.isCorrect,
        categoryId: widget.prefectureId,
      );
    }

    if (!mounted) return;
    context.pushReplacement(
      '/result/${widget.prefectureId}',
      extra: {
        'totalPoints': _totalPoints,
        'correctCount': _correctCount,
        'totalCount': _answers.length,
        'newBadgeId': newBadgeId,
        'coinsEarned': coinsEarned,
      },
    );
  }

  // デイリーミッション用：都道府県名が答えになる問題を除外
  List<Quiz> _filterTrivialQuizzes(List<Quiz> quizzes) {
    try {
      final pref = PrefectureDataList.all.firstWhere(
        (p) => p.id == widget.prefectureId,
      );
      // 都/道/府/県 を除いた短縮名（例: "北海道" → "北海"、"東京都" → "東京"）
      final shortName = pref.name
          .replaceAll('都', '')
          .replaceAll('道', '')
          .replaceAll('府', '')
          .replaceAll('県', '');
      final filtered = quizzes.where((q) {
        final answer = q.correctAnswer;
        return !answer.contains(pref.name) && !answer.contains(shortName);
      }).toList();
      // 最低5問は残す
      return filtered.length >= 5 ? filtered : quizzes;
    } catch (_) {
      return quizzes;
    }
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
            child: const Text('中断する', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
