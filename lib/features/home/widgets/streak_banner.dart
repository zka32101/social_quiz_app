import 'package:flutter/material.dart';
import '../../../reward_assets.dart';
import '../../../utils/constants.dart';

class StreakBanner extends StatelessWidget {
  final int streak;

  const StreakBanner({super.key, required this.streak});

  @override
  Widget build(BuildContext context) {
    if (streak == 0) return const SizedBox.shrink();

    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF3CD),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: const Color(AppColors.accentValue).withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              streakFlameAsset(streak)!,
              key: const Key('streak_flame'),
              height: 28,
              errorBuilder: (_, __, ___) =>
                  const Text('🔥', style: TextStyle(fontSize: 22)),
            ),
            if (streakCrownAsset(streak) != null) ...[
              const SizedBox(width: 4),
              Image.asset(
                streakCrownAsset(streak)!,
                key: const Key('streak_crown'),
                height: 28,
                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              ),
            ],
            const SizedBox(width: 6),
            Text(
              '$streak日連続',
              style: const TextStyle(
                color: Color(0xFFF39C12),
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
