import 'dart:async';
import 'dart:io';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../utils/constants.dart';

class PurchaseService {
  static bool _initialized = false;
  static final _customerInfoController =
      StreamController<CustomerInfo>.broadcast();

  /// RevenueCat 初期化
  static Future<void> initialize() async {
    if (_initialized) return;

    final apiKey = Platform.isIOS
        ? AppConstants.revenueCatAppleKey
        : AppConstants.revenueCatGoogleKey;

    await Purchases.setLogLevel(LogLevel.debug);
    final config = PurchasesConfiguration(apiKey);
    await Purchases.configure(config);
    _initialized = true;

    // カスタマー情報更新リスナー（v8.x+ API）
    Purchases.addCustomerInfoUpdateListener((info) {
      if (!_customerInfoController.isClosed) {
        _customerInfoController.add(info);
      }
    });
  }

  /// 現在のカスタマー情報を取得
  Future<CustomerInfo> getCustomerInfo() async {
    return Purchases.getCustomerInfo();
  }

  /// プレミアム状態を確認
  Future<bool> isPremium() async {
    final info = await getCustomerInfo();
    return info.entitlements.active
        .containsKey(AppConstants.premiumEntitlementId);
  }

  /// 利用可能なオファリングを取得
  Future<Offerings?> getOfferings() async {
    try {
      return await Purchases.getOfferings();
    } catch (e) {
      return null;
    }
  }

  /// パッケージを購入
  Future<CustomerInfo?> purchase(Package package) async {
    try {
      final result = await Purchases.purchasePackage(package);
      return result;
    } on PurchasesErrorCode catch (e) {
      if (e == PurchasesErrorCode.purchaseCancelledError) return null;
      rethrow;
    }
  }

  /// 購入を復元
  Future<CustomerInfo> restorePurchases() async {
    return Purchases.restorePurchases();
  }

  /// カスタマー情報の変更を監視
  Stream<CustomerInfo> get customerInfoStream =>
      _customerInfoController.stream;
}
