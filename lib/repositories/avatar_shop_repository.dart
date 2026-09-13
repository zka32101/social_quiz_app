import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// ユーザーが購入したアバターを管理するリポジトリ
class AvatarShopRepository {
  static const _boxName = 'avatar_shop';
  static const _purchasedKey = 'purchased_avatars';

  Box get _box => Hive.box(_boxName);

  /// 購入済みアバターIDのリストを取得
  List<int> getPurchasedAvatarIds() {
    final raw = _box.get(_purchasedKey) as List?;
    if (raw == null) return [];
    return List<int>.from(raw);
  }

  /// アバターが購入済みかどうかを確認
  bool isAvatarPurchased(int avatarId) {
    return getPurchasedAvatarIds().contains(avatarId);
  }

  /// アバターを購入（追加）
  Future<void> purchaseAvatar(int avatarId) async {
    final purchased = getPurchasedAvatarIds();
    if (!purchased.contains(avatarId)) {
      purchased.add(avatarId);
      await _box.put(_purchasedKey, purchased);
    }
  }

  /// 購入履歴をクリア（テスト用）
  Future<void> clearPurchases() async {
    await _box.delete(_purchasedKey);
  }
}

/// AvatarShopRepository プロバイダー
final avatarShopRepositoryProvider = Provider<AvatarShopRepository>((ref) {
  return AvatarShopRepository();
});

/// 購入済みアバターIDsプロバイダー
final purchasedAvatarIdsProvider = StateProvider<List<int>>((ref) {
  final repo = ref.watch(avatarShopRepositoryProvider);
  return repo.getPurchasedAvatarIds();
});

/// アバター購入状況をチェック（特定アバター）
final isAvatarPurchasedProvider =
    StateProvider.family<bool, int>((ref, avatarId) {
  final repo = ref.watch(avatarShopRepositoryProvider);
  return repo.isAvatarPurchased(avatarId);
});
