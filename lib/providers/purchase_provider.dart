import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../services/purchase_service.dart';

final purchaseServiceProvider = Provider((ref) => PurchaseService());

// ── プレミアム状態 ──────────────────────────────────────

final premiumStatusProvider =
    StreamProvider<bool>((ref) async* {
  final service = ref.watch(purchaseServiceProvider);

  // 初期状態
  yield await service.isPremium();

  // 変更を監視
  await for (final info in service.customerInfoStream) {
    yield info.entitlements.active
        .containsKey('premium');
  }
});

// ── オファリング ────────────────────────────────────────

final offeringsProvider = FutureProvider<Offerings?>((ref) async {
  final service = ref.watch(purchaseServiceProvider);
  return service.getOfferings();
});

// ── 購入状態管理 ────────────────────────────────────────

enum PurchaseStatus { idle, loading, success, error }

class PurchaseState {
  final PurchaseStatus status;
  final String? errorMessage;

  const PurchaseState({
    this.status = PurchaseStatus.idle,
    this.errorMessage,
  });
}

final purchaseNotifierProvider =
    StateNotifierProvider<PurchaseNotifier, PurchaseState>((ref) {
  return PurchaseNotifier(ref.watch(purchaseServiceProvider));
});

class PurchaseNotifier extends StateNotifier<PurchaseState> {
  final PurchaseService _service;

  PurchaseNotifier(this._service)
      : super(const PurchaseState());

  Future<bool> purchase(Package package) async {
    state = const PurchaseState(status: PurchaseStatus.loading);
    try {
      final info = await _service.purchase(package);
      if (info == null) {
        // キャンセル
        state = const PurchaseState(status: PurchaseStatus.idle);
        return false;
      }
      state = const PurchaseState(status: PurchaseStatus.success);
      return true;
    } catch (e) {
      state = PurchaseState(
        status: PurchaseStatus.error,
        errorMessage: '購入に失敗しました: $e',
      );
      return false;
    }
  }

  Future<bool> restore() async {
    state = const PurchaseState(status: PurchaseStatus.loading);
    try {
      final info = await _service.restorePurchases();
      final isPremium = info.entitlements.active
          .containsKey('premium');
      state = const PurchaseState(status: PurchaseStatus.success);
      return isPremium;
    } catch (e) {
      state = PurchaseState(
        status: PurchaseStatus.error,
        errorMessage: '復元に失敗しました: $e',
      );
      return false;
    }
  }

  void reset() {
    state = const PurchaseState();
  }
}
