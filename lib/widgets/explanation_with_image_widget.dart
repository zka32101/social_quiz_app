import 'package:flutter/material.dart';
import '../data/explain_images.dart';

/// 説明テキストを表示するカード
///
/// クイズの解説や学習ページで使用します。
///
/// 以前の自動取得画像は廃止。現在は [category]/[subcategory] から
/// assets/images/explain/quiz/ のAI生成イラスト（lib/data/explain_images.dart）を
/// 引いて表示する。該当画像が無い場合はテキストのみ。
/// imageKeyword/imageHeight/imageUrlOverride は互換性のため残しており未使用。
class ExplanationWithImage extends StatelessWidget {
  final String explanation;
  final String? imageKeyword;
  final double imageHeight;
  final EdgeInsets padding;
  final String? imageUrlOverride;
  final String? category;
  final String? subcategory;

  const ExplanationWithImage({
    Key? key,
    required this.explanation,
    this.imageKeyword,
    this.imageHeight = 250,
    this.padding = const EdgeInsets.all(16),
    this.imageUrlOverride,
    this.category,
    this.subcategory,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final asset = quizExplainImage(category, subcategory);
    if (asset == null) {
      return ExplanationCard(explanation: explanation, padding: padding);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: Image.asset(
              asset,
              fit: BoxFit.cover,
              excludeFromSemantics: true,
              errorBuilder: (_, __, ___) => const SizedBox.shrink(),
            ),
          ),
        ),
        const SizedBox(height: 8),
        ExplanationCard(explanation: explanation, padding: padding),
      ],
    );
  }
}

/// シンプルな説明カード（画像なし）
class ExplanationCard extends StatelessWidget {
  final String explanation;
  final EdgeInsets padding;

  const ExplanationCard({
    Key? key,
    required this.explanation,
    this.padding = const EdgeInsets.all(16),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
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
            explanation,
            style: const TextStyle(
              fontSize: 15,
              height: 1.6,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}

/// 説明テキストを表示するカード（横並びレイアウト版・画像なし）
class ExplanationWithImageHorizontal extends StatelessWidget {
  final String explanation;
  final String? imageKeyword;
  final double imageWidth;
  final EdgeInsets padding;

  const ExplanationWithImageHorizontal({
    Key? key,
    required this.explanation,
    this.imageKeyword,
    this.imageWidth = 120,
    this.padding = const EdgeInsets.all(16),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '解説',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            explanation,
            style: const TextStyle(
              fontSize: 13,
              height: 1.6,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
