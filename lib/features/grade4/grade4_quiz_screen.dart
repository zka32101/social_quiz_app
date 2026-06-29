import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../repositories/progress_repository.dart';
import '../../utils/constants.dart';

class _Q {
  final String id;
  final String question;
  final List<String> options;
  final String correctAnswer;
  final String explanation;

  const _Q({
    required this.id,
    required this.question,
    required this.options,
    required this.correctAnswer,
    required this.explanation,
  });

  factory _Q.fromJson(Map<String, dynamic> j) => _Q(
    id: j['id'] as String,
    question: j['question'] as String,
    options: List<String>.from(j['options'] as List),
    correctAnswer: j['correctAnswer'] as String,
    explanation: j['explanation'] as String? ?? '',
  );

  int get correctIndex => options.indexOf(correctAnswer);
}

final _grade4QProvider =
    FutureProvider.family<List<_Q>, String>((ref, sectionId) async {
  final raw = await rootBundle.loadString('assets/data/quizzes_grade4.json');
  final list = jsonDecode(raw) as List;
  return list
      .cast<Map<String, dynamic>>()
      .where((e) => e['subcategory'] == sectionId)
      .map(_Q.fromJson)
      .toList();
});

String _sectionTitle(String id) {
  const titles = {
    'prefectures': '都道府県',
    'regions': '地方区分',
    'geography': '山・川・湖',
    'seasons': '気候・季節',
    'water': '水道・下水',
    'disaster': '災害・防災',
  };
  return titles[id] ?? id;
}

class Grade4QuizScreen extends ConsumerStatefulWidget {
  final String sectionId;

  const Grade4QuizScreen({super.key, required this.sectionId});

  @override
  ConsumerState<Grade4QuizScreen> createState() => _State();
}

class _State extends ConsumerState<Grade4QuizScreen> {
  static const Color _primary = Color(0xFF00897B);

  int _idx = 0;
  int? _sel;
  bool _answered = false;
  int _correct = 0;
  bool _finished = false;

  void _select(int i, _Q q) {
    if (_answered) return;
    setState(() {
      _sel = i;
      _answered = true;
      if (i == q.correctIndex) _correct++;
    });
  }

  Future<void> _next(List<_Q> qs) async {
    final q = qs[_idx];
    if (_sel != q.correctIndex) {
      ref.read(userProgressProvider.notifier).addWrongAnswer(q.id);
    }
    if (_idx < qs.length - 1) {
      setState(() { _idx++; _sel = null; _answered = false; });
    } else {
      final pts = _correct * AppConstants.pointsPerCorrectAnswer;
      if (pts > 0) await ref.read(userProgressProvider.notifier).addPoints(pts);
      setState(() => _finished = true);
    }
  }

  void _reset() => setState(() {
    _idx = 0; _sel = null; _answered = false; _correct = 0; _finished = false;
  });

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(_grade4QProvider(widget.sectionId));
    return Scaffold(
      appBar: AppBar(
        title: Text(_sectionTitle(widget.sectionId)),
        backgroundColor: _primary,
        foregroundColor: Colors.white,
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('エラー: $e')),
        data: (qs) {
          if (qs.isEmpty) return const Center(child: Text('問題がありません'));
          if (_finished) return _buildResult(qs.length);
          return _buildQuiz(qs);
        },
      ),
    );
  }

  Widget _buildQuiz(List<_Q> qs) {
    final q = qs[_idx];
    return Column(
      children: [
        // 進捗バー（固定）
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Row(
            children: [
              Text('${_idx + 1} / ${qs.length}',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
              const SizedBox(width: 8),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: _idx / qs.length, end: (_idx + 1) / qs.length),
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeOut,
                    builder: (_, v, __) => LinearProgressIndicator(
                      value: v,
                      color: _primary,
                      backgroundColor: Colors.grey.shade200,
                      minHeight: 7,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        // 問題（アニメーション付き）
        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, anim) => SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.08, 0),
                end: Offset.zero,
              ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOut)),
              child: FadeTransition(opacity: anim, child: child),
            ),
            child: _QuizBody(
              key: ValueKey(_idx),
              q: q,
              sel: _sel,
              answered: _answered,
              isLast: _idx == qs.length - 1,
              primary: _primary,
              onSelect: (i) => _select(i, q),
              onNext: () => _next(qs),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResult(int total) {
    final pct = (_correct / total * 100).round();
    final stars = pct >= 90 ? 3 : pct >= 60 ? 2 : pct >= 30 ? 1 : 0;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // スター
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (i) => _AnimatedStar(
                filled: i < stars,
                delay: Duration(milliseconds: 200 * i),
                color: _primary,
              )),
            ),
            const SizedBox(height: 20),
            Text('$_correct / $total 問 正解',
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('$pct%',
                style: TextStyle(
                    fontSize: 44,
                    fontWeight: FontWeight.bold,
                    color: pct >= 80 ? Colors.green : pct >= 60 ? Colors.orange : Colors.red)),
            const SizedBox(height: 8),
            Text(
              pct >= 90 ? 'すばらしい！完璧に近い！' : pct >= 60 ? 'よくできました！' : 'もう一度チャレンジしよう！',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton(onPressed: _reset, child: const Text('もう一度')),
                const SizedBox(width: 16),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: _primary),
                  onPressed: () => context.pop(),
                  child: const Text('もどる', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── 問題本体（AnimatedSwitcher のキー対象） ────────────────────────────

class _QuizBody extends StatelessWidget {
  final _Q q;
  final int? sel;
  final bool answered;
  final bool isLast;
  final Color primary;
  final void Function(int) onSelect;
  final VoidCallback onNext;

  const _QuizBody({
    super.key,
    required this.q,
    required this.sel,
    required this.answered,
    required this.isLast,
    required this.primary,
    required this.onSelect,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      children: [
        Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Text(q.question,
                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
          ),
        ),
        const SizedBox(height: 14),
        ...List.generate(q.options.length, (i) {
          final isCorrect = i == q.correctIndex;
          final isSelected = sel == i;
          Color bg = Colors.white;
          Color border = Colors.grey.shade300;
          if (answered) {
            if (isCorrect) { bg = Colors.green.shade50; border = Colors.green; }
            else if (isSelected) { bg = Colors.red.shade50; border = Colors.red; }
          }
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: GestureDetector(
              onTap: answered ? null : () => onSelect(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: bg,
                  border: Border.all(color: border, width: 1.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Expanded(child: Text(q.options[i], style: const TextStyle(fontSize: 15))),
                    if (answered && isCorrect) const Icon(Icons.check_circle, color: Colors.green, size: 20),
                    if (answered && isSelected && !isCorrect) const Icon(Icons.cancel, color: Colors.red, size: 20),
                  ],
                ),
              ),
            ),
          );
        }),
        if (answered)
          Card(
            color: Colors.blue.shade50,
            margin: const EdgeInsets.only(top: 4),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    sel == q.correctIndex ? '✅ 正解！' : '❌ 不正解',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: sel == q.correctIndex ? Colors.green : Colors.red,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(q.explanation, style: const TextStyle(fontSize: 13)),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: primary),
                      onPressed: onNext,
                      child: Text(
                        isLast ? '結果を見る' : '次の問題へ',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

// ─── アニメーションスター ────────────────────────────────────────────

class _AnimatedStar extends StatefulWidget {
  final bool filled;
  final Duration delay;
  final Color color;

  const _AnimatedStar({required this.filled, required this.delay, required this.color});

  @override
  State<_AnimatedStar> createState() => _AnimatedStarState();
}

class _AnimatedStarState extends State<_AnimatedStar> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _scale = CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut);
    Future.delayed(widget.delay, () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scale,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Icon(
          widget.filled ? Icons.star_rounded : Icons.star_outline_rounded,
          size: 56,
          color: widget.filled ? Colors.amber : Colors.grey.shade300,
        ),
      ),
    );
  }
}
