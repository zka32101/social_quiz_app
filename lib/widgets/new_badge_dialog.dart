import 'package:flutter/material.dart';

/// バッジ獲得時の達成演出ダイアログ（白ダイアログ + 星バースト + メダル + リボン）。
class NewBadgeDialog extends StatelessWidget {
  final String emoji;
  final String name;
  final VoidCallback? onClose;

  const NewBadgeDialog({
    super.key,
    required this.emoji,
    required this.name,
    this.onClose,
  });

  static Future<void> show(BuildContext context,
      {required String emoji, required String name}) {
    return showDialog<void>(
      context: context,
      builder: (ctx) => NewBadgeDialog(
        emoji: emoji,
        name: name,
        onClose: () => Navigator.of(ctx).pop(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: Colors.white,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FittedBox(
              fit: BoxFit.scaleDown,
              child: SizedBox(
                width: 260,
                height: 250,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Positioned(
                      top: 0,
                      child: Image.asset('assets/celebrate/celebrate_starburst.webp', width: 250),
                    ),
                    Positioned(
                      top: 55,
                      child: Image.asset('assets/celebrate/celebrate_medal.webp', width: 130),
                    ),
                    Positioned(
                      bottom: 0,
                      child: SizedBox(
                        width: 260,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Image.asset('assets/celebrate/celebrate_ribbon_banner.webp', width: 260),
                            const Text(
                              'おめでとう！',
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF461905),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '$emoji $name を獲得',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[800],
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onClose ?? () => Navigator.of(context).pop(),
              child: const Text('了解'),
            ),
          ],
        ),
      ),
    );
  }
}
