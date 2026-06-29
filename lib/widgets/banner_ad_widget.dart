import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../providers/purchase_provider.dart';
import '../services/ad_service.dart';

/// バナー広告ウィジェット（プレミアムは非表示）
class BannerAdWidget extends ConsumerStatefulWidget {
  const BannerAdWidget({super.key});

  @override
  ConsumerState<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends ConsumerState<BannerAdWidget> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  void _loadAd() {
    final adService = AdService();
    _bannerAd = adService.createBannerAd(
      onLoaded: (ad) {
        if (mounted) setState(() => _isLoaded = true);
      },
      onFailed: (ad, error) {
        ad.dispose();
        _bannerAd = null;
      },
    );
    _bannerAd!.load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // プレミアムユーザーには広告を非表示
    final premiumAsync = ref.watch(premiumStatusProvider);
    final isPremium = premiumAsync.valueOrNull ?? false;

    if (isPremium || !_isLoaded || _bannerAd == null) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: _bannerAd!.size.height.toDouble(),
      width: _bannerAd!.size.width.toDouble(),
      child: AdWidget(ad: _bannerAd!),
    );
  }
}
