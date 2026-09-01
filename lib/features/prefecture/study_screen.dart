import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/prefecture.dart';
import '../../repositories/content_repository.dart';
import '../../repositories/progress_repository.dart';
import '../../utils/constants.dart';
import '../../services/tts_service.dart';
import '../../widgets/explanation_with_image_widget.dart' as explanation;

class StudyScreen extends ConsumerStatefulWidget {
  final String prefectureId;
  final int initialStep;

  const StudyScreen({
    super.key,
    required this.prefectureId,
    this.initialStep = 1,
  });

  @override
  ConsumerState<StudyScreen> createState() => _StudyScreenState();
}

class _StudyScreenState extends ConsumerState<StudyScreen> {
  late PageController _pageController;
  int _currentCardIndex = 0;
  late int _currentStep;

  static const _stepTitles = {
    1: '基本情報',
    2: '産業',
    3: '文化・観光・先人',
  };

  @override
  void initState() {
    super.initState();
    _currentStep = widget.initialStep;
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final stepsAsync = ref.watch(studyStepsProvider(widget.prefectureId));

    return stepsAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        body: Center(child: Text('エラー: $e')),
      ),
      data: (steps) {
        if (steps.isEmpty) {
          return const Scaffold(
            body: Center(child: Text('コンテンツが見つかりませんでした')),
          );
        }
        final step = steps.firstWhere(
          (s) => s.stepNo == _currentStep,
          orElse: () => steps.first,
        );
        return _buildUI(context, steps, step);
      },
    );
  }

  Widget _buildUI(
      BuildContext context, List<StudyStep> allSteps, StudyStep step) {
    final cards = step.cards;

    if (cards.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text(_stepTitles[_currentStep] ?? 'STEP $_currentStep'),
        ),
        body: const Center(child: Text('この STEP のコンテンツは準備中です')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_stepTitles[_currentStep] ?? 'STEP $_currentStep'),
        actions: [
          IconButton(
            icon: const Icon(Icons.volume_up_rounded),
            tooltip: '読み上げ',
            onPressed: () {
              final card = cards[_currentCardIndex];
              final text = card.content ?? card.caption ?? card.statsLabel ?? '';
              if (text.isNotEmpty) {
                ref.read(ttsServiceProvider).speak(text);
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildStepProgress(),
          const SizedBox(height: 8),
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: cards.length,
              onPageChanged: (i) => setState(() => _currentCardIndex = i),
              itemBuilder: (context, i) => _buildCard(context, cards[i]),
            ),
          ),
          _buildBottomNav(context, cards.length, allSteps),
        ],
      ),
    );
  }

  Widget _buildStepProgress() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: List.generate(3, (i) {
          final stepNo = i + 1;
          final isActive = stepNo == _currentStep;
          final isDone = stepNo < _currentStep;
          return Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 3),
              height: 6,
              decoration: BoxDecoration(
                color: isDone
                    ? const Color(AppColors.primaryValue)
                    : isActive
                        ? Colors.blue
                        : Colors.grey[200],
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildCard(BuildContext context, ContentCard card) {
    final imageKeyword = _getImageKeywordForStep(_currentStep);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: switch (card.type) {
            CardType.text => SingleChildScrollView(
                child: explanation.ExplanationWithImage(
                  explanation: card.content ?? '',
                  imageKeyword: imageKeyword,
                  imageHeight: 200,
                  padding: const EdgeInsets.all(0),
                ),
              ),
            CardType.image => Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                        child:
                            Icon(Icons.image, size: 48, color: Colors.grey)),
                  ),
                  if (card.caption != null) ...[
                    const SizedBox(height: 12),
                    Text(card.caption!,
                        style: const TextStyle(color: Colors.grey)),
                  ],
                ],
              ),
            CardType.stats => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      card.statsLabel ?? '',
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      card.statsValue ?? '',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
          },
        ),
      ),
    );
  }

  String _getImageKeywordForStep(int stepNo) {
    switch (stepNo) {
      case 1:
        return '地図'; // Geographic map
      case 2:
        return '産業'; // Industry
      case 3:
        return '観光'; // Tourism/culture
      default:
        return '日本'; // Japan
    }
  }

  Widget _buildBottomNav(
      BuildContext context, int cardCount, List<StudyStep> allSteps) {
    final isLastCard = _currentCardIndex >= cardCount - 1;
    final isLastStep = _currentStep == allSteps.length;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // ページドット
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(cardCount, (i) {
              return Container(
                width: i == _currentCardIndex ? 16 : 8,
                height: 8,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                decoration: BoxDecoration(
                  color: i == _currentCardIndex
                      ? Theme.of(context).colorScheme.primary
                      : Colors.grey[300],
                  borderRadius: BorderRadius.circular(4),
                ),
              );
            }),
          ),
          const SizedBox(height: 16),
          // ナビゲーションボタン
          if (!isLastCard)
            ElevatedButton(
              onPressed: () {
                _pageController.nextPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
              ),
              child: const Text('次へ'),
            )
          else if (!isLastStep)
            ElevatedButton(
              onPressed: () => _completeStepAndNext(),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                backgroundColor: Colors.blue,
              ),
              child: Text('STEP ${_currentStep + 1} へ進む'),
            )
          else
            ElevatedButton.icon(
              onPressed: () => _completeStepAndStartQuiz(),
              icon: const Icon(Icons.quiz),
              label: const Text('クイズに挑戦！'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                backgroundColor: Colors.orange,
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _completeStepAndNext() async {
    await ref
        .read(userProgressProvider.notifier)
        .completeStep(widget.prefectureId, _currentStep);
    if (!mounted) return;
    setState(() {
      _currentStep++;
      _currentCardIndex = 0;
    });
    _pageController.jumpToPage(0);
  }

  Future<void> _completeStepAndStartQuiz() async {
    await ref
        .read(userProgressProvider.notifier)
        .completeStep(widget.prefectureId, _currentStep);
    if (!mounted) return;
    context.pushReplacement('/quiz/${widget.prefectureId}');
  }
}
