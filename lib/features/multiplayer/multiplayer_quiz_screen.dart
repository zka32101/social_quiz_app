import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:math';
import '../../models/match.dart';
import '../../models/quiz.dart';
import '../../providers/match_provider.dart';
import '../../data/quiz_generator.dart';
import '../../data/prefecture_data.dart';

class MultiplayerQuizScreen extends ConsumerStatefulWidget {
  final String matchId;
  final String userId;

  const MultiplayerQuizScreen({
    required this.matchId,
    required this.userId,
    super.key,
  });

  @override
  ConsumerState<MultiplayerQuizScreen> createState() =>
      _MultiplayerQuizScreenState();
}

class _MultiplayerQuizScreenState extends ConsumerState<MultiplayerQuizScreen> {
  late List<Quiz> quizzes;
  int currentQuestionIndex = 0;
  int? selectedAnswerIndex;
  bool answered = false;

  @override
  void initState() {
    super.initState();
    _generateQuizzes();
  }

  void _generateQuizzes() {
    final allPrefs = PrefectureDataList.all;
    final random = Random();
    final selectedPrefs = <String>{};

    // ランダムに都道府県を選択してクイズ生成
    while (selectedPrefs.length < 3 && selectedPrefs.length < allPrefs.length) {
      final randPref = allPrefs[random.nextInt(allPrefs.length)];
      selectedPrefs.add(randPref.id);
    }

    final allQuizzes = <Quiz>[];
    for (final prefId in selectedPrefs) {
      allQuizzes.addAll(QuizGenerator.forPrefecture(prefId));
    }

    quizzes = allQuizzes..shuffle(random);
    quizzes = quizzes.take(10).toList();
  }

  void _answerQuestion(int index) {
    if (answered) return;

    setState(() {
      selectedAnswerIndex = index;
      answered = true;
    });

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        _nextQuestion();
      }
    });
  }

  void _nextQuestion() async {
    final currentQuiz = quizzes[currentQuestionIndex];
    final isCorrect =
        selectedAnswerIndex == currentQuiz.correctIndex;
    final match = ref.read(currentMatchProvider);
    final isPlayer1 = match?.player1Id == widget.userId;

    int newPlayer1Score = match?.player1Score ?? 0;
    int newPlayer2Score = match?.player2Score ?? 0;

    if (isCorrect) {
      if (isPlayer1) {
        newPlayer1Score += 1;
      } else {
        newPlayer2Score += 1;
      }
    }

    final isLastQuestion = currentQuestionIndex >= quizzes.length - 1;

    // スコア更新（最後の問題の場合はマッチを自動終了）
    await ref.read(currentMatchProvider.notifier).updateMatchState(
          matchId: widget.matchId,
          player1Score: newPlayer1Score,
          player2Score: newPlayer2Score,
          shouldComplete: isLastQuestion,
        );

    if (isLastQuestion) {
      if (mounted) {
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            context.go('/multiplayer');
          }
        });
      }
    } else {
      setState(() {
        currentQuestionIndex++;
        selectedAnswerIndex = null;
        answered = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final matchAsync = ref.watch(watchMatchProvider(widget.matchId));

    return matchAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (err, stack) => Scaffold(
        appBar: AppBar(title: const Text('エラー')),
        body: Center(child: Text('エラーが発生しました: $err')),
      ),
      data: (match) {
        if (match == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('マッチなし')),
            body: const Center(child: Text('マッチが見つかりません')),
          );
        }

        return _buildQuizScreen(context, match);
      },
    );
  }

  Widget _buildQuizScreen(BuildContext context, Match match) {
    final isPlayer1 = match.player1Id == widget.userId;
    final myScore = isPlayer1 ? match.player1Score : match.player2Score;
    final opponentScore =
        isPlayer1 ? match.player2Score : match.player1Score;

    return Scaffold(
      appBar: AppBar(
        title: const Text('対戦クイズ'),
        elevation: 0,
      ),
      body: Column(
        children: [
          // スコアボード
          _buildScoreBoard(
            myScore: myScore,
            opponentScore: opponentScore,
            totalQuestions: quizzes.length,
          ),
          const SizedBox(height: 16),
          Expanded(
            child: match.isCompleted
                ? _buildResultView(context, match)
                : _buildQuizView(),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreBoard({
    required int myScore,
    required int opponentScore,
    required int totalQuestions,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade400, Colors.blue.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildScoreCard(
            label: 'あなた',
            score: myScore,
            total: totalQuestions,
            backgroundColor: Colors.blue.shade100,
          ),
          Column(
            children: [
              Text(
                'vs',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$myScore - $opponentScore',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          _buildScoreCard(
            label: '相手',
            score: opponentScore,
            total: totalQuestions,
            backgroundColor: Colors.red.shade100,
          ),
        ],
      ),
    );
  }

  Widget _buildScoreCard({
    required String label,
    required int score,
    required int total,
    required Color backgroundColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            '$score/$total',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildQuizView() {
    if (quizzes.isEmpty) {
      return const Center(child: Text('クイズが見つかりません'));
    }

    final currentQuiz = quizzes[currentQuestionIndex];
    final options = currentQuiz.choices;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 問題番号と進捗
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '問題 ${currentQuestionIndex + 1}/${quizzes.length}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: (currentQuestionIndex + 1) / quizzes.length,
                  minHeight: 4,
                  color: Colors.blue,
                  backgroundColor: Colors.grey.shade300,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // 問題文
          Text(
            currentQuiz.question,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),

          // 選択肢
          ...List.generate(
            options.length,
            (index) {
              final isSelected = selectedAnswerIndex == index;
              final isCorrect = index == currentQuiz.correctIndex;
              final showResult = answered;

              Color backgroundColor = Colors.white;
              Color borderColor = Colors.grey.shade300;

              if (showResult) {
                if (isCorrect) {
                  backgroundColor = Colors.green.shade100;
                  borderColor = Colors.green;
                } else if (isSelected) {
                  backgroundColor = Colors.red.shade100;
                  borderColor = Colors.red;
                }
              } else if (isSelected) {
                backgroundColor = Colors.blue.shade100;
                borderColor = Colors.blue;
              }

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: GestureDetector(
                  onTap: answered ? null : () => _answerQuestion(index),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: backgroundColor,
                      border: Border.all(color: borderColor, width: 2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            options[index],
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                        if (showResult && isCorrect)
                          const Icon(Icons.check_circle, color: Colors.green),
                        if (showResult && isSelected && !isCorrect)
                          const Icon(Icons.close, color: Colors.red),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),

          if (answered)
            Padding(
              padding: const EdgeInsets.only(top: 24),
              child: Center(
                child: Text(
                  selectedAnswerIndex == quizzes[currentQuestionIndex].correctIndex
                      ? '✓ 正解！'
                      : '✗ 不正解',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: selectedAnswerIndex ==
                            quizzes[currentQuestionIndex]
                                .correctIndex
                        ? Colors.green
                        : Colors.red,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildResultView(BuildContext context, Match match) {
    final isWin = match.winner == widget.userId;
    final myScore = match.player1Id == widget.userId
        ? match.player1Score
        : match.player2Score;
    final opponentScore = match.player1Id == widget.userId
        ? match.player2Score
        : match.player1Score;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            isWin ? '🎉 勝利！' : '🏁 終了',
            style: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: isWin ? Colors.green : Colors.orange,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            '$myScore - $opponentScore',
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () => context.go('/multiplayer'),
            child: const Text('相手探しに戻る'),
          ),
        ],
      ),
    );
  }
}
