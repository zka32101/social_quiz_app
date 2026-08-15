import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/stage.dart';
import '../../models/quiz_data.dart';
import '../../repositories/stage_repository.dart';
import '../../repositories/progress_repository.dart';
import '../../utils/constants.dart';
import '../../widgets/japan_region_tap_map.dart';

/// マップタップゲーム画面
class MapTapGame extends ConsumerStatefulWidget {
  final Stage stage;
  final Quest quest;

  const MapTapGame({
    Key? key,
    required this.stage,
    required this.quest,
  }) : super(key: key);

  @override
  ConsumerState<MapTapGame> createState() => _MapTapGameState();
}

class _MapTapGameState extends ConsumerState<MapTapGame> {
  String? selectedRegion;
  bool isAnswered = false;
  bool isCorrect = false;

  // Store quiz data for dialog display
  late String _correctAnswer;
  late Map<String, String> _regionLabels;

  void _handleTap(String region, String correctAnswer, Map<String, String> regionLabels) {
    if (isAnswered) return;

    // Store quiz data for dialog display
    _correctAnswer = correctAnswer;
    _regionLabels = regionLabels;

    setState(() {
      selectedRegion = region;
      isAnswered = true;
      isCorrect = region == correctAnswer;
    });

    // 2秒後に結果画面へ遷移
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      _completeQuest();
    });
  }

  Future<void> _completeQuest() async {
    if (isCorrect) {
      await ref
          .read(userProgressProvider.notifier)
          .completeQuest(widget.stage.id, widget.quest.questNo);
      await ref
          .read(userProgressProvider.notifier)
          .addPoints(widget.quest.pointsReward);
      if (mounted) _showSuccessDialog(_regionLabels);
    } else {
      // 不正解を間違いノートに記録
      await ref
          .read(userProgressProvider.notifier)
          .addWrongAnswer(widget.quest.quizDataId);
      if (mounted) _showRetryDialog(_correctAnswer, _regionLabels);
    }
  }

  void _showSuccessDialog(Map<String, String> regionLabels) {
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
              '${regionLabels[selectedRegion]}を正確に選択できました！\n+${widget.quest.pointsReward}pt 獲得！',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
              textAlign: TextAlign.center,
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

  void _showRetryDialog(String correctAnswer, Map<String, String> regionLabels) {
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
              '${regionLabels[selectedRegion]}を選択しました。\n正解は${regionLabels[correctAnswer]}です。',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                selectedRegion = null;
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
          if (quizData is! MapTapQuiz) {
            return Center(
              child: Text('Invalid quiz type: expected map_tap, got ${quizData.quizType}'),
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
                  _buildQuestion(quizData.question),
                  const SizedBox(height: 24),

                  // 地図
                  _buildMap(quizData.availableRegions, quizData.regionLabels, quizData.correctAnswer),
                  const SizedBox(height: 24),

                  // 説明
                  _buildInstruction(),
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

  Widget _buildMap(List<String> availableRegions, Map<String, String> regionLabels, String correctAnswer) {
    return SizedBox(
      height: 340,
      child: JapanRegionTapMap(
        availableRegions: availableRegions,
        regionLabels: regionLabels,
        correctAnswer: correctAnswer,
        selectedRegion: selectedRegion,
        isAnswered: isAnswered,
        isCorrect: isCorrect,
        onRegionTapped: (region) => _handleTap(region, correctAnswer, regionLabels),
      ),
    );
  }

  Widget _buildInstruction() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange[200]!),
      ),
      child: const Row(
        children: [
          Icon(
            Icons.info,
            color: Colors.orange,
            size: 20,
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              '地図をタップして、正しい地域を選択してください。',
              style: TextStyle(
                fontSize: 14,
                color: Colors.orange,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

