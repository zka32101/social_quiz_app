import 'package:flutter/material.dart';
import '../reward_assets.dart';

/// メインのごほうびシールの隣に出す小さなおまけシール（最大2個）。
class BonusStickers extends StatelessWidget {
  final BonusFlags flags;
  const BonusStickers({super.key, required this.flags});

  @override
  Widget build(BuildContext context) {
    final assets = bonusStickerAssets(
      firstAttempt: flags.firstAttempt,
      personalBest: flags.personalBest,
      firstPerfect: flags.firstPerfect,
    );
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final a in assets)
          Padding(
            padding: const EdgeInsets.only(left: 6),
            child: Image.asset(
              a,
              key: Key('bonus_$a'),
              height: 48,
              errorBuilder: (_, __, ___) => const SizedBox.shrink(),
            ),
          ),
      ],
    );
  }
}

/// メインシール + おまけシールを横並びにする。
Widget rewardStickerRow(Widget main, BonusFlags? flags) {
  if (flags == null) return main;
  return Row(
    mainAxisSize: MainAxisSize.min,
    mainAxisAlignment: MainAxisAlignment.center,
    children: [main, BonusStickers(flags: flags)],
  );
}
