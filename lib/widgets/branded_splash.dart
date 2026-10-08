import 'package:flutter/material.dart';

/// 小学コレ！シリーズ共通の起動画面（白背景・1枚構成）。
///
/// 中央にアプリアイコンと小さな読み込み表示、下寄りにシリーズロゴ、最下部に組織ロゴ。
/// 起動中の画面（初期化前）とアプリ内スプラッシュの両方でこのウィジェットを使う。
/// ロゴが白背景前提のため、ダークモードでも背景は白固定。
class BrandedSplash extends StatelessWidget {
  const BrandedSplash({super.key});

  static const Color splashBackground = Color(0xFFFFFFFF);
  static const Color progressColor = Color(0xFF263250);

  static const String appIconAsset = 'assets/branding/app_icon.png';
  static const String seriesLogoAsset = 'assets/branding/series_logo.png';
  static const String orgLogoAsset = 'assets/branding/yourwish_logo.png';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: splashBackground,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(26),
                      child: Image.asset(appIconAsset,
                          key: const ValueKey('splash_app_icon'),
                          width: 112,
                          height: 112,
                          fit: BoxFit.cover),
                    ),
                    const SizedBox(height: 28),
                    const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                          strokeWidth: 2.5, color: progressColor),
                    ),
                  ],
                ),
              ),
            ),
            Image.asset(seriesLogoAsset,
                key: const ValueKey('splash_series_logo'),
                width: 180,
                fit: BoxFit.contain),
            const SizedBox(height: 24),
            Image.asset(orgLogoAsset,
                key: const ValueKey('splash_org_logo'),
                width: 52,
                height: 52,
                fit: BoxFit.contain),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
