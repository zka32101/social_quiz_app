import 'package:flutter/material.dart';

/// AI生成の説明イラスト（16:9）を表示する。読み込めない場合は何も表示しない。
class ExplainHeroImage extends StatelessWidget {
  final String? asset;
  final EdgeInsets padding;

  const ExplainHeroImage({
    super.key,
    required this.asset,
    this.padding = const EdgeInsets.fromLTRB(16, 12, 16, 0),
  });

  @override
  Widget build(BuildContext context) {
    final a = asset;
    if (a == null) return const SizedBox.shrink();
    return Padding(
      padding: padding,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: Image.asset(
            a,
            fit: BoxFit.cover,
            excludeFromSemantics: true,
            errorBuilder: (_, __, ___) => const SizedBox.shrink(),
          ),
        ),
      ),
    );
  }
}
