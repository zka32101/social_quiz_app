import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/daily_quiz_model.dart';
import '../providers/daily_quiz_provider.dart';

class DailyQuizScreen extends ConsumerWidget {
  const DailyQuizScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dailyQuizAsync = ref.watch(dailyQuizProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('今日のクイズ'),
        centerTitle: true,
      ),
      body: dailyQuizAsync.when(
        data: (quiz) {
          if (quiz == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.info_outline,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    '今日のクイズはありません',
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '明日をお楽しみに！',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            );
          }

          return DailyQuizContent(quiz: quiz);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              const Text('エラーが発生しました'),
              const SizedBox(height: 8),
              Text(err.toString()),
            ],
          ),
        ),
      ),
    );
  }
}

class DailyQuizContent extends ConsumerStatefulWidget {
  final DailyQuiz quiz;

  const DailyQuizContent({required this.quiz, Key? key}) : super(key: key);

  @override
  ConsumerState<DailyQuizContent> createState() => _DailyQuizContentState();
}

class _DailyQuizContentState extends ConsumerState<DailyQuizContent> {
  int? selectedIndex;
  bool? isCorrect;
  bool isSubmitted = false;
  // SharedPreferences から既存の回答状況を確認するまでは true。
  // これが完了する前に選択肢を操作できると、既に回答済みのクイズに
  // 再度回答してボーナスを二重付与できてしまうため、確認完了までは
  // ローディング表示にして選択肢を触れないようにする。
  bool _isCheckingAnswered = true;

  @override
  void initState() {
    super.initState();
    _checkIfAnswered();
  }

  Future<void> _checkIfAnswered() async {
    final service = ref.read(dailyQuizServiceProvider);
    final answered = await service.getAnswerStatus(quizId: widget.quiz.quizId);

    if (!mounted) return;

    if (answered == true) {
      final isCorrect =
          await service.getCorrectStatus(quizId: widget.quiz.quizId);
      if (!mounted) return;
      setState(() {
        isSubmitted = true;
        this.isCorrect = isCorrect;
        _isCheckingAnswered = false;
      });
    } else {
      setState(() {
        _isCheckingAnswered = false;
      });
    }
  }

  void _submitAnswer() {
    if (selectedIndex == null) return;

    final isCorrect = selectedIndex == widget.quiz.correctIndex;

    setState(() {
      this.isCorrect = isCorrect;
      isSubmitted = true;
    });

    if (isCorrect) {
      ref.read(dailyBonusPointsProvider.notifier).addBonus(50);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('正解！ +50ボーナスポイント'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    }

    // 回答履歴を保存
    final service = ref.read(dailyQuizServiceProvider);
    service.saveAnswer(
      quizId: widget.quiz.quizId,
      isCorrect: isCorrect,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isCheckingAnswered) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ヘッダー: 今日の日付 + カテゴリ
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '今日のクイズ',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatDate(widget.quiz.date),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                _CategoryBadge(category: widget.quiz.category),
              ],
            ),
            const SizedBox(height: 24),

            // 問題文
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                widget.quiz.question,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            const SizedBox(height: 24),

            // 選択肢
            ...List.generate(
              widget.quiz.options.length,
              (index) => GestureDetector(
                onTap: isSubmitted || selectedIndex != null
                    ? null
                    : () => setState(() => selectedIndex = index),
                child: _OptionTile(
                  option: widget.quiz.options[index],
                  isSelected: selectedIndex == index,
                  isCorrect: isCorrect,
                  isCorrectAnswer: index == widget.quiz.correctIndex,
                  isSubmitted: isSubmitted,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // 提出ボタン / 解説表示
            if (!isSubmitted)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: selectedIndex != null ? _submitAnswer : null,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    '答える',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              )
            else
              Column(
                children: [
                  // 結果表示
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isCorrect! ? Colors.green.shade50 : Colors.red.shade50,
                      border: Border.all(
                        color: isCorrect! ? Colors.green : Colors.red,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Text(
                          isCorrect! ? '✅' : '❌',
                          style: const TextStyle(fontSize: 32),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isCorrect! ? '正解！' : '不正解',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color:
                                      isCorrect! ? Colors.green : Colors.red,
                                ),
                              ),
                              if (isCorrect!)
                                const Text(
                                  '+50ボーナスポイント',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 解説
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '解説',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.quiz.explanation,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final today = DateTime.now();
    if (date.year == today.year &&
        date.month == today.month &&
        date.day == today.day) {
      return '今日';
    }
    return '${date.month}月${date.day}日';
  }
}

class _OptionTile extends StatelessWidget {
  final String option;
  final bool isSelected;
  final bool? isCorrect;
  final bool isCorrectAnswer;
  final bool isSubmitted;

  const _OptionTile({
    required this.option,
    required this.isSelected,
    required this.isCorrect,
    required this.isCorrectAnswer,
    required this.isSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    Color? backgroundColor;
    Color? borderColor = Colors.grey.shade300;
    bool? shouldHighlight;

    if (isSubmitted) {
      if (isCorrectAnswer) {
        backgroundColor = Colors.green.shade100;
        borderColor = Colors.green;
      } else if (isSelected && !isCorrect!) {
        backgroundColor = Colors.red.shade100;
        borderColor = Colors.red;
      }
    } else if (isSelected) {
      backgroundColor = Colors.blue.shade50;
      borderColor = Colors.blue;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        border: Border.all(
          color: borderColor,
          width: isSelected ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(12),
        color: backgroundColor ?? Colors.white,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        title: Text(option),
        trailing: isSubmitted
            ? isCorrectAnswer
                ? const Icon(Icons.check_circle, color: Colors.green)
                : isSelected && !isCorrect!
                    ? const Icon(Icons.cancel, color: Colors.red)
                    : null
            : isSelected
                ? const Icon(Icons.radio_button_checked, color: Colors.blue)
                : const Icon(Icons.radio_button_unchecked,
                    color: Colors.grey),
      ),
    );
  }
}

class _CategoryBadge extends StatelessWidget {
  final String category;

  const _CategoryBadge({required this.category});

  @override
  Widget build(BuildContext context) {
    final label = _getCategoryLabel(category);
    final color = _getCategoryColor(category);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _getCategoryLabel(String category) {
    const labels = {
      'event': '年中行事',
      'history': '歴史',
      'geography': '地理',
      'politics': '公民',
    };
    return labels[category] ?? category;
  }

  Color _getCategoryColor(String category) {
    const colors = {
      'event': Colors.purple,
      'history': Colors.brown,
      'geography': Colors.green,
      'politics': Colors.blue,
    };
    return colors[category] ?? Colors.grey;
  }
}
