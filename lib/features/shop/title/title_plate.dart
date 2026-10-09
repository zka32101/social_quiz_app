import 'package:flutter/material.dart';

/// 称号プレート（教科別プレート画像の上に称号名を重ねる）。
/// 幅 [width] 程度。名前が長くても FittedBox で縮めて収める。
class TitlePlate extends StatelessWidget {
  const TitlePlate({super.key, required this.name, this.width = 96});

  static const asset = 'assets/title_plate/plate_shakai.webp';
  static const _aspect = 768 / 410;

  final String name;
  final double width;

  @override
  Widget build(BuildContext context) {
    final height = width / _aspect;
    return Semantics(
      label: '称号 $name',
      child: ExcludeSemantics(
        child: SizedBox(
          key: const ValueKey('title_plate'),
          width: width,
          height: height,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned.fill(
                child: Image.asset(asset, fit: BoxFit.fill, errorBuilder: (_, __, ___) => const SizedBox.shrink()),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: width * 0.17, vertical: height * 0.22),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    name,
                    maxLines: 1,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF4A3410)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
