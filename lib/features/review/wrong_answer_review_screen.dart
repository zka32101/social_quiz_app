import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/quiz_generator.dart';
import '../../data/quiz_mock_data.dart';
import '../../models/quiz.dart';
import '../../repositories/progress_repository.dart';

// ─────────────────────────────────────────────────────────────────────────────
// カテゴリ定義
// ─────────────────────────────────────────────────────────────────────────────

enum _ReviewCategory {
  grade3('小3社会', Icons.school, Colors.green),
  civics('公民', Icons.account_balance, Colors.blue),
  industry('産業', Icons.factory, Colors.orange),
  economics('経済・政治', Icons.account_balance_wallet, Colors.teal),
  international('国際', Icons.public, Colors.indigo),
  prefecture('都道府県クイズ', Icons.map, Colors.red),
  stage('ステージクイズ', Icons.emoji_events, Colors.purple),
  other('その他', Icons.help_outline, Colors.grey);

  const _ReviewCategory(this.label, this.icon, this.color);
  final String label;
  final IconData icon;
  final Color color;
}

_ReviewCategory _categoryFor(String id) {
  if (id.startsWith('g3_')) return _ReviewCategory.grade3;
  // civics_quiz_screen.dart / assets/data/quizzes_civics.json は 'cv_' 接頭辞
  // （'civ_' ではない）。過去のミスマッチで全件「その他」に落ちていたため修正。
  if (id.startsWith('cv_')) return _ReviewCategory.civics;
  if (id.startsWith('ind_')) return _ReviewCategory.industry;
  if (id.startsWith('eco_')) return _ReviewCategory.economics;
  if (id.startsWith('intl_')) return _ReviewCategory.international;
  // ステージクイズ: s1q1_v1, s2q3, s13q5 など
  if (RegExp(r'^s\d+q\d+').hasMatch(id)) return _ReviewCategory.stage;
  // 都道府県クイズ: {prefId}_q{n} or {prefId}_g{nn}
  if (RegExp(r'^[a-z]+_(q\d+|g\d+)$').hasMatch(id)) return _ReviewCategory.prefecture;
  return _ReviewCategory.other;
}

// ─────────────────────────────────────────────────────────────────────────────
// 間違い問題データ（ロード済み）
// ─────────────────────────────────────────────────────────────────────────────

class _WrongItem {
  final String id;
  final Quiz? quiz; // null の場合は問題文が見つからなかった
  final _ReviewCategory category;

  const _WrongItem({required this.id, this.quiz, required this.category});
}

// ─────────────────────────────────────────────────────────────────────────────
// ローカル JSON ロードヘルパー
// ─────────────────────────────────────────────────────────────────────────────

Future<List<Quiz>> _loadJsonQuizzes(String assetPath) async {
  try {
    final raw = await rootBundle.loadString(assetPath);
    final decoded = json.decode(raw);
    List<dynamic>? list;
    if (decoded is Map<String, dynamic>) {
      list = decoded['quizzes'] as List<dynamic>?;
    } else if (decoded is List) {
      list = decoded;
    }
    if (list == null) return [];
    return list
        .map((e) => Quiz.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  } catch (_) {
    return [];
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 間違い復習ノート画面
// ─────────────────────────────────────────────────────────────────────────────

class WrongAnswerReviewScreen extends ConsumerStatefulWidget {
  const WrongAnswerReviewScreen({super.key});

  @override
  ConsumerState<WrongAnswerReviewScreen> createState() =>
      _WrongAnswerReviewScreenState();
}

class _WrongAnswerReviewScreenState
    extends ConsumerState<WrongAnswerReviewScreen> {
  // ロード状態
  bool _loading = true;

  // カテゴリ → 問題リスト
  final Map<_ReviewCategory, List<_WrongItem>> _grouped = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadWrongAnswers());
  }

  // ─── データロード ─────────────────────────────────────────────────────────

  Future<void> _loadWrongAnswers() async {
    if (!mounted) return;
    setState(() => _loading = true);

    final ids = ref.read(userProgressProvider).wrongAnswerIds;
    if (ids.isEmpty) {
      if (mounted) setState(() => _loading = false);
      return;
    }

    // ── 都道府県 JSON をまとめてロード（必要なものだけ） ──────────────────
    final prefIds = <String>{};
    for (final id in ids) {
      final cat = _categoryFor(id);
      if (cat == _ReviewCategory.prefecture) {
        // IDフォーマット: {prefId}_q{n} or {prefId}_g{nn}
        final prefId = id.split('_').first;
        prefIds.add(prefId);
      }
    }

    // 都道府県ごとのクイズキャッシュ: prefId → List<Quiz>
    final prefQuizCache = <String, List<Quiz>>{};
    // QuizGenerator で生成した問題のキャッシュ
    final generatedCache = <String, List<Quiz>>{};

    for (final prefId in prefIds) {
      // JSON アセットから読み込み（{prefId}.json には "quizzes" キー）
      final jsonQuizzes =
          await _loadJsonQuizzes('assets/data/$prefId.json');
      prefQuizCache[prefId] = jsonQuizzes;
      // QuizGenerator で生成（hokkaido_g01 形式の ID）
      generatedCache[prefId] = QuizGenerator.forPrefecture(prefId);
    }

    // ── 各 ID を解決 ─────────────────────────────────────────────────────
    final items = <_WrongItem>[];
    for (final id in ids) {
      final cat = _categoryFor(id);
      Quiz? found;

      if (cat == _ReviewCategory.prefecture) {
        final prefId = id.split('_').first;
        final allForPref = [
          ...?prefQuizCache[prefId],
          ...?generatedCache[prefId],
        ];
        try {
          found = allForPref.firstWhere((q) => q.id == id);
        } catch (_) {
          found = null;
        }
      } else if (cat == _ReviewCategory.stage) {
        // ステージクイズ: QuizMockData から変換（multiple_choice のみ）
        final raw = QuizMockData.allQuizzes[id];
        if (raw != null && raw['quizType'] == 'multiple_choice') {
          final opts = raw['options'] as List?;
          if (opts != null) {
            found = Quiz(
              id: id,
              stepNo: 1,
              question: raw['question'] as String? ?? '',
              choices: opts.cast<String>(),
              correctIndex: raw['correctIndex'] as int? ?? 0,
              explanation: raw['explanation'] as String? ?? '',
            );
          }
        }
      }
      // g3_ / cv_ / ind_ / eco_ / intl_ はこの画面のロード処理に
      // 組み込まれていないため quiz は null のまま（IDのみ表示）

      items.add(_WrongItem(id: id, quiz: found, category: cat));
    }

    // ── カテゴリ別にグルーピング ─────────────────────────────────────────
    final grouped = <_ReviewCategory, List<_WrongItem>>{};
    for (final item in items) {
      grouped.putIfAbsent(item.category, () => []).add(item);
    }

    if (mounted) {
      setState(() {
        _grouped
          ..clear()
          ..addAll(grouped);
        _loading = false;
      });
    }
  }

  // ─── 1件削除 ──────────────────────────────────────────────────────────────

  Future<void> _removeOne(String id) async {
    await ref.read(userProgressProvider.notifier).removeWrongAnswer(id);
    await _loadWrongAnswers();
  }

  // ─── 全削除確認 ───────────────────────────────────────────────────────────

  Future<void> _confirmClearAll(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('まちがいノートをクリア'),
        content: const Text('すべての間違い記録を削除しますか？\nこの操作は元に戻せません。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('キャンセル'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('全部削除'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      final ids = List<String>.from(
        ref.read(userProgressProvider).wrongAnswerIds,
      );
      for (final id in ids) {
        await ref.read(userProgressProvider.notifier).removeWrongAnswer(id);
      }
      await _loadWrongAnswers();
    }
  }

  // ─── ビルド ───────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    // wrongAnswerIds を watch して外部変更にも反応
    final wrongIds = ref.watch(userProgressProvider).wrongAnswerIds;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('まちがい復習ノート'),
        actions: [
          if (wrongIds.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Chip(
                label: Text(
                  'まちがい ${wrongIds.length} 問',
                  style: TextStyle(
                    color: colorScheme.onErrorContainer,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                backgroundColor: colorScheme.errorContainer,
                padding: EdgeInsets.zero,
                visualDensity: VisualDensity.compact,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              tooltip: '全部クリア',
              onPressed: () => _confirmClearAll(context),
            ),
          ],
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : wrongIds.isEmpty
              ? _buildEmpty(context)
              : _buildList(context),
      bottomNavigationBar: wrongIds.isNotEmpty
          ? SafeArea(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ElevatedButton.icon(
                  onPressed: () => context.push('/japan-map'),
                  icon: const Icon(Icons.map_outlined),
                  label: const Text('都道府県クイズをもう一度'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                  ),
                ),
              ),
            )
          : null,
    );
  }

  // ─── 空状態 ───────────────────────────────────────────────────────────────

  Widget _buildEmpty(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            '🎉',
            style: TextStyle(fontSize: 72),
          ),
          const SizedBox(height: 16),
          Text(
            'まちがいなし！よくできました',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            '間違えた問題はここに記録されます',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ─── リスト ───────────────────────────────────────────────────────────────

  Widget _buildList(BuildContext context) {
    final categories = _ReviewCategory.values
        .where((c) => _grouped.containsKey(c))
        .toList();

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 80),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final cat = categories[index];
        final items = _grouped[cat]!;
        return _CategorySection(
          category: cat,
          items: items,
          onRemove: _removeOne,
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// カテゴリセクション
// ─────────────────────────────────────────────────────────────────────────────

class _CategorySection extends StatelessWidget {
  const _CategorySection({
    required this.category,
    required this.items,
    required this.onRemove,
  });

  final _ReviewCategory category;
  final List<_WrongItem> items;
  final Future<void> Function(String id) onRemove;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // セクションヘッダー
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
          child: Row(
            children: [
              Icon(category.icon, size: 18, color: category.color),
              const SizedBox(width: 6),
              Text(
                category.label,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: category.color,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: category.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${items.length}問',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: category.color,
                  ),
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1, indent: 16),
        // 問題カード一覧
        ...items.map((item) => _WrongItemCard(item: item, onRemove: onRemove)),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 間違い問題カード（ExpansionTile）
// ─────────────────────────────────────────────────────────────────────────────

class _WrongItemCard extends StatelessWidget {
  const _WrongItemCard({required this.item, required this.onRemove});

  final _WrongItem item;
  final Future<void> Function(String id) onRemove;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final quiz = item.quiz;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant.withOpacity(0.5),
        ),
      ),
      child: quiz != null
          ? _buildExpandable(context, quiz)
          : _buildIdOnly(context),
    );
  }

  // クイズ詳細あり → ExpansionTile
  Widget _buildExpandable(BuildContext context, Quiz quiz) {
    final theme = Theme.of(context);

    return ExpansionTile(
      tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      childrenPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Icon(
        Icons.quiz_outlined,
        color: item.category.color,
        size: 20,
      ),
      title: Text(
        quiz.question,
        style: theme.textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w500,
        ),
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 2),
        child: Text(
          'ID: ${item.id}',
          style: theme.textTheme.labelSmall?.copyWith(color: Colors.grey),
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _DeleteButton(id: item.id, onRemove: onRemove),
          const Icon(Icons.expand_more, size: 20),
        ],
      ),
      children: [
        _AnswerDetail(quiz: quiz),
      ],
    );
  }

  // クイズ情報なし → ID のみ表示
  Widget _buildIdOnly(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      leading: Icon(
        Icons.help_outline,
        color: item.category.color,
        size: 20,
      ),
      title: Text(
        item.id,
        style: theme.textTheme.bodyMedium,
      ),
      subtitle: Text(
        '問題データを読み込めませんでした',
        style: theme.textTheme.labelSmall?.copyWith(color: Colors.grey),
      ),
      trailing: _DeleteButton(id: item.id, onRemove: onRemove),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 正解・解説エリア
// ─────────────────────────────────────────────────────────────────────────────

class _AnswerDetail extends StatelessWidget {
  const _AnswerDetail({required this.quiz});
  final Quiz quiz;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 全選択肢
        ...List.generate(quiz.choices.length, (i) {
          final isCorrect = i == quiz.correctIndex;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 3),
            child: Row(
              children: [
                Icon(
                  isCorrect ? Icons.check_circle : Icons.radio_button_unchecked,
                  size: 18,
                  color: isCorrect ? colorScheme.primary : Colors.grey,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    quiz.choices[i],
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isCorrect ? colorScheme.primary : null,
                      fontWeight:
                          isCorrect ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
        const SizedBox(height: 8),
        // 正解強調
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer.withOpacity(0.5),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '正解: ${quiz.correctAnswer}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        // 解説
        if (quiz.explanation.isNotEmpty) ...[
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: colorScheme.surfaceVariant.withOpacity(0.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '解説',
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  quiz.explanation,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 4),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 削除ボタン（小さいアイコンボタン）
// ─────────────────────────────────────────────────────────────────────────────

class _DeleteButton extends StatefulWidget {
  const _DeleteButton({required this.id, required this.onRemove});
  final String id;
  final Future<void> Function(String id) onRemove;

  @override
  State<_DeleteButton> createState() => _DeleteButtonState();
}

class _DeleteButtonState extends State<_DeleteButton> {
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: _busy
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.delete_outline, size: 20),
      tooltip: '削除',
      color: Colors.redAccent,
      onPressed: _busy
          ? null
          : () async {
              setState(() => _busy = true);
              await widget.onRemove(widget.id);
              if (mounted) setState(() => _busy = false);
            },
    );
  }
}
