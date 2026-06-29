import 'dart:io';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdService {
  static bool _initialized = false;

  // テスト用ID（本番は差し替え）
  static String get _bannerAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/6300978111'; // Android テスト
    }
    return 'ca-app-pub-3940256099942544/2934735716'; // iOS テスト
  }

  static String get _interstitialAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/1033173712'; // Android テスト
    }
    return 'ca-app-pub-3940256099942544/4411468910'; // iOS テスト
  }

  static String get _rewardedAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/5224354917'; // Android テスト
    }
    return 'ca-app-pub-3940256099942544/1712485313'; // iOS テスト
  }

  /// AdMob 初期化
  static Future<void> initialize() async {
    if (_initialized) return;
    await MobileAds.instance.initialize();
    _initialized = true;
  }

  /// バナー広告を作成
  BannerAd createBannerAd({
    AdSize size = AdSize.banner,
    required void Function(Ad, LoadAdError) onFailed,
    required void Function(Ad) onLoaded,
  }) {
    return BannerAd(
      adUnitId: _bannerAdUnitId,
      size: size,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: onLoaded,
        onAdFailedToLoad: onFailed,
      ),
    );
  }

  /// インタースティシャル広告をロード
  Future<InterstitialAd?> loadInterstitialAd() async {
    InterstitialAd? ad;
    final completer = _Completer<InterstitialAd?>();

    InterstitialAd.load(
      adUnitId: _interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (loadedAd) => completer.complete(loadedAd),
        onAdFailedToLoad: (_) => completer.complete(null),
      ),
    );

    return completer.future;
  }

  /// リワード広告をロード
  Future<RewardedAd?> loadRewardedAd() async {
    RewardedAd? ad;
    final completer = _Completer<RewardedAd?>();

    RewardedAd.load(
      adUnitId: _rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (loadedAd) => completer.complete(loadedAd),
        onAdFailedToLoad: (_) => completer.complete(null),
      ),
    );

    return completer.future;
  }
}

// 簡易 Completer ヘルパー
class _Completer<T> {
  T? _value;
  bool _completed = false;
  final List<void Function(T)> _callbacks = [];

  void complete(T value) {
    _value = value;
    _completed = true;
    for (final cb in _callbacks) cb(value);
  }

  Future<T> get future async {
    if (_completed) return _value as T;
    return Future.delayed(const Duration(milliseconds: 100), () => future);
  }
}
