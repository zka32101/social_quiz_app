import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

/// 「学習をはじめる」フロー専用の、純粋な解説（読み物）画面。
///
/// クイズ用の JSON データ（assets/data/quizzes_*.json）を再利用し、
/// 各問題の `question`（トピックとして表示）と `explanation`（解説文）だけを
/// カード形式で並べる。選択肢・採点は一切行わない。
///
/// 画面下部に「問題をとく」ボタンを置き、そこからのみ既存のクイズ画面へ
/// 遷移できる（学習フローからクイズへの唯一の入口）。
class SectionStudyScreen extends StatefulWidget {
  /// 画面タイトル（例: '地図記号'）
  final String title;

  /// クイズ JSON アセットのパス（例: 'assets/data/quizzes_grade3.json'）
  final String jsonAssetPath;

  /// フィルタ対象の subcategory / セクション ID
  final String sectionId;

  /// テーマカラー
  final Color color;

  /// 「問題をとく」ボタンから遷移するクイズ画面の go_router パス
  /// （例: '/grade3-quiz/map_symbols'）
  final String quizRoute;

  const SectionStudyScreen({
    super.key,
    required this.title,
    required this.jsonAssetPath,
    required this.sectionId,
    required this.color,
    required this.quizRoute,
  });

  @override
  State<SectionStudyScreen> createState() => _SectionStudyScreenState();
}

class _StudyItem {
  final String topic;
  final String explanation;
  const _StudyItem({required this.topic, required this.explanation});
}

class _SectionStudyScreenState extends State<SectionStudyScreen> {
  List<_StudyItem>? _items;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final raw = await rootBundle.loadString(widget.jsonAssetPath);
      final dynamic decoded = jsonDecode(raw);
      final List<dynamic> rawItems = decoded is List
          ? decoded
          : (decoded is Map && decoded['questions'] is List
              ? decoded['questions'] as List
              : const []);

      final items = rawItems
          .cast<Map<String, dynamic>>()
          .where((e) => e['subcategory'] == widget.sectionId)
          .map((e) => _StudyItem(
                topic: e['question'] as String? ?? '',
                explanation: e['explanation'] as String? ?? '',
              ))
          .where((e) => e.explanation.isNotEmpty)
          .toList();

      if (mounted) {
        setState(() => _items = items);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _error = e.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,
        backgroundColor: color,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _buildBody(color),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => context.push(widget.quizRoute),
              icon: const Icon(Icons.quiz, size: 18),
              label: const Text('問題をとく →'),
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                textStyle: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(Color color) {
    if (_error != null) {
      return Center(child: Text('読み込みに失敗しました: $_error'));
    }
    final items = _items;
    if (items == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (items.isEmpty) {
      return const Center(child: Text('学習コンテンツが見つかりませんでした'));
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      itemCount: items.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: color.withOpacity(0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: color.withOpacity(0.25)),
              ),
              child: Row(
                children: [
                  Icon(Icons.menu_book, color: color, size: 22),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'まずは読んで学ぼう。準備ができたら下の「問題をとく」からクイズに挑戦できるよ。',
                      style: TextStyle(
                        fontSize: 12,
                        color: color,
                        fontWeight: FontWeight.w600,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        final item = items[index - 1];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            clipBehavior: Clip.antiAlias,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 26,
                        height: 26,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '$index',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          item.topic,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF333333),
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    item.explanation,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF555555),
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
