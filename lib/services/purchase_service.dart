import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show PlatformException;
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
    try {
      await Purchases.configure(config);
      _initialized = true;
      debugPrint(
        '[RevenueCat] configure 成功 (platform=${Platform.isIOS ? 'iOS' : 'Android'})',
      );
    } catch (e, st) {
      debugPrint('[RevenueCat] configure 失敗: $e\n$st');
      rethrow;
    }

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

  /// ユーザーがサブスクリプション中かどうか確認
  Future<bool> isSubscribed(String userId) async {
    return await isPremium();
  }

  /// サブスクリプションの有効期限を取得
  Future<DateTime?> getSubscriptionExpirationDate(String userId) async {
    final info = await getCustomerInfo();
    final premiumEntitlement =
        info.entitlements.active[AppConstants.premiumEntitlementId];
    final expirationDate = premiumEntitlement?.expirationDate;
    return expirationDate != null ? DateTime.tryParse(expirationDate) : null;
  }

  /// 利用可能なオファリングを取得
  ///
  /// 失敗時は例外を握りつぶさず、原因をログ出力した上で再送出する。
  /// 呼び出し側（offeringsProvider）はエラー状態として扱い、
  /// UI 側で「読み込みできない」原因を追えるようにする。
  Future<Offerings?> getOfferings() async {
    try {
      final offerings = await Purchases.getOfferings();
      if (offerings.current == null) {
        debugPrint(
          '[RevenueCat] getOfferings 成功したが current Offering が null です。'
          'RevenueCat ダッシュボードで Offering が "current" に設定されているか、'
          'Package に Google Play 商品が正しく紐付いているか確認してください。'
          ' all=${offerings.all.keys}',
        );
      }
      return offerings;
    } on PlatformException catch (e, st) {
      final errorCode = PurchasesErrorHelper.getErrorCode(e);
      debugPrint(
        '[RevenueCat] getOfferings 失敗: code=$errorCode message=${e.message} '
        'details=${e.details}\n$st',
      );
      rethrow;
    } catch (e, st) {
      debugPrint('[RevenueCat] getOfferings 失敗（不明なエラー）: $e\n$st');
      rethrow;
    }
  }

  /// パッケージを購入
  Future<CustomerInfo?> purchase(Package package) async {
    try {
      final result = await Purchases.purchasePackage(package);
      return result.customerInfo;
    } on PurchasesErrorCode catch (e) {
      if (e == PurchasesErrorCode.purchaseCancelledError) return null;
      debugPrint('[RevenueCat] purchase 失敗: code=$e package=${package.identifier}');
      rethrow;
    } catch (e, st) {
      debugPrint('[RevenueCat] purchase 失敗（不明なエラー）: $e\n$st');
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
