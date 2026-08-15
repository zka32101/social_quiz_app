import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/stage.dart';
import '../../models/quiz_data.dart';
import '../../repositories/stage_repository.dart';
import '../../repositories/progress_repository.dart';
import '../../utils/constants.dart';

/// 穴埋め問題画面
class FillBlankScreen extends ConsumerStatefulWidget {
  final Stage stage;
  final Quest quest;

  const FillBlankScreen({
    Key? key,
    required this.stage,
    required this.quest,
  }) : super(key: key);

  @override
  ConsumerState<FillBlankScreen> createState() => _FillBlankScreenState();
}

class _FillBlankScreenState extends ConsumerState<FillBlankScreen> {
  late TextEditingController _controller;
  bool isAnswered = false;
  bool isCorrect = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _checkAnswer(String correctAnswer) {
    final userAnswer = _controller.text.trim();
    final isMatchCorrect = userAnswer == correctAnswer;

    setState(() {
      isAnswered = true;
      isCorrect = isMatchCorrect;
    });

    // 2秒後に結果画面へ遷移
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      _completeQuest(correctAnswer);
    });
  }

  Future<void> _completeQuest(String correctAnswer) async {
    if (isCorrect) {
      // クエスト完了を記録
      await ref
          .read(userProgressProvider.notifier)
          .completeQuest(widget.stage.id, widget.quest.questNo);

      // ポイント追加
      await ref
          .read(userProgressProvider.notifier)
          .addPoints(widget.quest.pointsReward);

      // 成功画面を表示
      if (mounted) {
        _showSuccessDialog();
      }
    } else {
      // 不正解時の再試行オプション
      if (mounted) {
        _showRetryDialog(correctAnswer);
      }
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.green[50],
        title: const Text(
          '正解！',
          style: TextStyle(
            color: Colors.green,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.check_circle,
              size: 80,
              color: Colors.green,
            ),
            const SizedBox(height: 16),
            Text(
              '+${widget.quest.pointsReward}pt 獲得！',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
            ),
            child: const Text('次へ'),
          ),
        ],
      ),
    );
  }

  void _showRetryDialog(String correctAnswer) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.red[50],
        title: const Text(
          '不正解',
          style: TextStyle(
            color: Colors.red,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cancel,
              size: 80,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              '正解は：$correctAnswer',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // 再試行
              setState(() {
                _controller.clear();
                isAnswered = false;
                isCorrect = false;
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
            ),
            child: const Text('もう一度'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey,
            ),
            child: const Text('スキップ'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final quizDataAsync = ref.watch(quizDataProvider(widget.quest.quizDataId));

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.stage.title} - ${widget.quest.title}'),
        backgroundColor: AppColors.primary,
        elevation: 0,
      ),
      body: quizDataAsync.when(
        data: (quizData) {
          if (quizData is! FillBlankQuiz) {
            return Center(
              child: Text('Invalid quiz type: expected fill_blank, got ${quizData.quizType}'),
            );
          }

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 進捗表示
                  _buildProgressBar(),
                  const SizedBox(height: 24),

                  // 問題文
                  _buildProblem(quizData.problemText),
                  const SizedBox(height: 24),

                  // 入力フィールド
                  _buildInputField(),
                  const SizedBox(height: 24),

                  // 回答ボタン
                  _buildSubmitButton(quizData.correctAnswer),
                ],
              ),
            ),
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (err, stack) => Center(
          child: Text('クイズの読み込みに失敗しました: $err'),
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'クエスト ${widget.quest.questNo}',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            Text(
              '+${widget.quest.pointsReward}pt',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: widget.stage.quests.isEmpty
                ? 0.0
                : widget.quest.questNo / widget.stage.quests.length,
            minHeight: 8,
            backgroundColor: Colors.grey[300],
            valueColor: const AlwaysStoppedAnimation<Color>(
              AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProblem(String problemText) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.purple[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.purple[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '問題',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.purple,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.quest.description,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.purple[100]!),
            ),
            child: Text(
              problemText,
              style: const TextStyle(
                fontSize: 16,
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '答え',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _controller,
          enabled: !isAnswered,
          decoration: InputDecoration(
            hintText: '答えを入力してください',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: const EdgeInsets.all(16),
            filled: true,
            fillColor: isAnswered
                ? Colors.grey[100]
                : Colors.white,
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: AppColors.primary,
                width: 2,
              ),
            ),
          ),
          style: const TextStyle(fontSize: 16),
        ),
      ],
    );
  }

  Widget _buildSubmitButton(String correctAnswer) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isAnswered ? null : () => _checkAnswer(correctAnswer),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          disabledBackgroundColor: Colors.grey[400],
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: const Text(
          '回答を確認',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
