import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/stage.dart';
import '../../models/quiz_data.dart';
import '../../repositories/stage_repository.dart';
import '../../repositories/progress_repository.dart';
import '../../utils/constants.dart';
import '../../widgets/explanation_with_image_widget.dart' as explanation;
import 'stage_clear_screen.dart';

/// クイズ実行画面（選択肢式問題）
class QuizExecutionScreen extends ConsumerStatefulWidget {
  final Stage stage;
  final Quest quest;

  const QuizExecutionScreen({
    Key? key,
    required this.stage,
    required this.quest,
  }) : super(key: key);

  @override
  ConsumerState<QuizExecutionScreen> createState() =>
      _QuizExecutionScreenState();
}

class _QuizExecutionScreenState extends ConsumerState<QuizExecutionScreen> {
  int? selectedIndex;
  bool isAnswered = false;
  bool isCorrect = false;
  String? _explanation;
  int _correctIndex = 0;
  List<String> _options = [];

  void _handleAnswer(
      int index, int correctIndex, List<String> options, String? explanation) {
    if (isAnswered) return;

    setState(() {
      selectedIndex = index;
      isAnswered = true;
      isCorrect = index == correctIndex;
      _explanation = explanation;
      _correctIndex = correctIndex;
      _options = List.from(options);
    });
  }

  Future<void> _onNext() async {
    await ref
        .read(userProgressProvider.notifier)
        .completeQuest(widget.stage.id, widget.quest.questNo);
    await ref
        .read(userProgressProvider.notifier)
        .addPoints(widget.quest.pointsReward);

    if (!mounted) return;

    // ステージ全クエスト完了チェック
    final progress = ref.read(userProgressProvider);
    final stageProgress = progress.stageProgress[widget.stage.id];
    final completedCount = stageProgress?.completedQuests.length ?? 0;
    final totalQuests = widget.stage.quests.length;

    if (totalQuests > 0 && completedCount >= totalQuests) {
      // ステージクリア画面へ（このクイズ画面と置き換え）
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => StageClearScreen(stage: widget.stage),
        ),
      );
    } else {
      Navigator.of(context).pop();
    }
  }

  Future<void> _onSkip() async {
    await ref
        .read(userProgressProvider.notifier)
        .addWrongAnswer(widget.quest.quizDataId);
    if (mounted) Navigator.of(context).pop();
  }

  void _onRetry() {
    setState(() {
      selectedIndex = null;
      isAnswered = false;
      isCorrect = false;
      _explanation = null;
    });
  }

  String _getImageKeywordForStage(String stageId) {
    // Map stage ID to appropriate image keyword
    const stageKeywords = {
      'stage_prefecture': '地図',
      'stage_history': '歴史',
      'stage_civics': '政治',
      'stage_industry': '産業',
      'stage_world': '経済',
    };
    return stageKeywords[stageId] ?? '社会';
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
          if (quizData is! MultipleChoiceQuiz) {
            return Center(
              child: Text(
                  'Invalid quiz type: expected multiple_choice, got ${quizData.quizType}'),
            );
          }

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProgressBar(),
                  const SizedBox(height: 24),
                  _buildQuestion(quizData.question),
                  const SizedBox(height: 24),
                  _buildOptions(
                      quizData.options, quizData.correctIndex, quizData.explanation),
                  if (isAnswered) ...[
                    const SizedBox(height: 16),
                    _ResultBanner(
                      isCorrect: isCorrect,
                      correctAnswer: _options.isNotEmpty
                          ? _options[_correctIndex]
                          : '',
                      pointsReward: widget.quest.pointsReward,
                    ),
                    if (_explanation != null && _explanation!.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      explanation.ExplanationWithImage(
                        explanation: _explanation!,
                        imageKeyword: _getImageKeywordForStage(widget.stage.id),
                        imageHeight: 200,
                        padding: const EdgeInsets.all(0),
                      ),
                    ],
                    const SizedBox(height: 24),
                    _buildActionButtons(),
                    const SizedBox(height: 24),
                  ],
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

  Widget _buildActionButtons() {
    if (isCorrect) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          icon: const Icon(Icons.arrow_forward),
          label: const Text('次へ', style: TextStyle(fontSize: 16)),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          onPressed: _onNext,
        ),
      );
    }
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: _onSkip,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text('スキップ'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: ElevatedButton.icon(
            icon: const Icon(Icons.refresh),
            label: const Text('もう一度', style: TextStyle(fontSize: 16)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            onPressed: _onRetry,
          ),
        ),
      ],
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

  Widget _buildQuestion(String? question) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '問題',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            question ?? widget.quest.description,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptions(
      List<String> options, int correctIndex, String? explanation) {
    return Column(
      children: List.generate(
        options.length,
        (index) => _OptionTile(
          label: String.fromCharCode(65 + index), // A, B, C, D
          text: options[index],
          isSelected: selectedIndex == index,
          isCorrect: isAnswered && index == correctIndex,
          isWrong: isAnswered && selectedIndex == index && !isCorrect,
          onTap: () =>
              _handleAnswer(index, correctIndex, options, explanation),
        ),
      ),
    );
  }
}

/// 結果バナー（正解・不正解）
class _ResultBanner extends StatelessWidget {
  final bool isCorrect;
  final String correctAnswer;
  final int pointsReward;

  const _ResultBanner({
    required this.isCorrect,
    required this.correctAnswer,
    required this.pointsReward,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isCorrect ? Colors.green : Colors.red,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            isCorrect ? Icons.check_circle : Icons.cancel,
            color: Colors.white,
            size: 36,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isCorrect ? '正解！' : '不正解...',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (isCorrect)
                  Text(
                    '+${pointsReward}pt 獲得！',
                    style: const TextStyle(
                        color: Colors.white70, fontSize: 14),
                  )
                else
                  Text(
                    '正解は：$correctAnswer',
                    style: const TextStyle(
                        color: Colors.white, fontSize: 14),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 選択肢タイル
class _OptionTile extends StatelessWidget {
  final String label;
  final String text;
  final bool isSelected;
  final bool isCorrect;
  final bool isWrong;
  final VoidCallback onTap;

  const _OptionTile({
    required this.label,
    required this.text,
    required this.isSelected,
    required this.isCorrect,
    required this.isWrong,
    required this.onTap,
  });

  Color _getBackgroundColor() {
    if (isCorrect) return Colors.green[100]!;
    if (isWrong) return Colors.red[100]!;
    if (isSelected) return Colors.blue[100]!;
    return Colors.white;
  }

  Color _getBorderColor() {
    if (isCorrect) return Colors.green;
    if (isWrong) return Colors.red;
    if (isSelected) return Colors.blue;
    return Colors.grey[300]!;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        color: _getBackgroundColor(),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(
            color: _getBorderColor(),
            width: 2,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _getBorderColor(),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    label,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  text,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: isWrong ? Colors.red : Colors.black87,
                  ),
                ),
              ),
              if (isCorrect)
                const Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 28,
                )
              else if (isWrong)
                const Icon(
                  Icons.cancel,
                  color: Colors.red,
                  size: 28,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
