import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/progress_repository.dart';
import '../repositories/avatar_shop_repository.dart';
import '../models/avatar.dart';

/// アバター購入サービス
/// コイン残高確認、購入処理、リワード管理を行います
class AvatarPurchaseService {
  final ProgressRepository progressRepo;
  final AvatarShopRepository shopRepo;

  AvatarPurchaseService({
    required this.progressRepo,
    required this.shopRepo,
  });

  /// アバターを購入（コイン消費）
  /// 成功時は true、失敗時は false を返す
  Future<bool> purchaseAvatar(int avatarId, int coinCost) async {
    final current = progressRepo.loadLocal();

    // コイン残高確認
    if (current.coins < coinCost) {
      return false; // コイン不足
    }

    // コイン消費
    final updated = current.copyWith(
      coins: current.coins - coinCost,
    );
    progressRepo.saveLocal(updated);

    // アバター購入記録
    await shopRepo.purchaseAvatar(avatarId);

    return true;
  }

  /// 購入可能かどうかを確認
  bool canAfford(int coinCost, int currentCoins) {
    return currentCoins >= coinCost;
  }

  /// アバターの詳細情報を取得
  Avatar? getAvatarInfo(int avatarId) {
    try {
      return kDefaultAvatars.firstWhere((a) => a.id == avatarId);
    } catch (_) {
      return null;
    }
  }

  /// 全ショップアバターを取得（購入可能なもの）
  List<Avatar> getShopAvatars() {
    return kDefaultAvatars.where((a) => !a.isFree).toList();
  }

  /// ユーザーが所有しているアバター（デフォルト + 購入済み）
  List<Avatar> getAvailableAvatars() {
    final ownedIds = <int>{};
    // デフォルトアバター
    for (final avatar in kDefaultAvatars.where((a) => a.isFree)) {
      ownedIds.add(avatar.id);
    }
    // 購入済みアバター
    ownedIds.addAll(shopRepo.getPurchasedAvatarIds());

    return kDefaultAvatars.where((a) => ownedIds.contains(a.id)).toList();
  }
}

/// AvatarPurchaseService プロバイダー
final avatarPurchaseServiceProvider =
    Provider<AvatarPurchaseService>((ref) {
  final progressRepo = ref.watch(progressRepositoryProvider);
  final shopRepo = ref.watch(avatarShopRepositoryProvider);
  return AvatarPurchaseService(
    progressRepo: progressRepo,
    shopRepo: shopRepo,
  );
});
