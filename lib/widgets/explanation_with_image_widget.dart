import 'package:flutter/material.dart';
import '../utils/furigana_map.dart';
import 'ruby_text.dart';

/// 説明テキストを表示するカード
///
/// クイズの解説や学習ページで使用します。
///
/// 以前は関連画像を自動取得して表示していたが、問題内容と無関係な画像が
/// 表示されるケースが大半だったため、画像表示は廃止しテキストのみに統一した。
/// 呼び出し側の互換性のため imageKeyword/imageHeight/imageUrlOverride は
/// パラメータとして残しているが使用しない。
class ExplanationWithImage extends StatelessWidget {
  final String explanation;
  final String? imageKeyword;
  final double imageHeight;
  final EdgeInsets padding;
  final String? imageUrlOverride;

  const ExplanationWithImage({
    Key? key,
    required this.explanation,
    this.imageKeyword,
    this.imageHeight = 250,
    this.padding = const EdgeInsets.all(16),
    this.imageUrlOverride,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ExplanationCard(explanation: explanation, padding: padding);
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
          RubyParagraph(
            explanation.withRuby,
            textFontSize: 15,
            rubyFontSize: 9,
            textColor: Colors.black87,
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
          RubyParagraph(
            explanation.withRuby,
            textFontSize: 13,
            rubyFontSize: 8,
            textColor: Colors.black87,
          ),
        ],
      ),
    );
  }
}
