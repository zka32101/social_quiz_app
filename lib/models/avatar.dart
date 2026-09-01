/// Avatar モデル
///
/// ユーザーが選択可能なアバター（プロフィール画像）を表します。
/// - isFree = true: デフォルト利用可能（4つ）
/// - isFree = false: ショップで購入可能（5-16）
class Avatar {
  final int id;                    // 1-16
  final String nameJa;             // 日本語名（例: "茶色クマ"）
  final String nameEn;             // 英語名（例: "Brown Bear"）
  final String imageAsset;         // アセットパス（例: "assets/avatars/avatar_1.png"）
  final bool isFree;               // デフォルト利用可能か
  final int? priceCoins;           // ショップ価格（isFree=falseの場合）

  const Avatar({
    required this.id,
    required this.nameJa,
    required this.nameEn,
    required this.imageAsset,
    required this.isFree,
    this.priceCoins,
  });

  @override
  String toString() => 'Avatar($id: $nameJa / $nameEn)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Avatar && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// デフォルトアバター定義（4つ、国語アプリと同じ）
///
/// id 1-4: デフォルト利用可能
/// id 5-16: ショップで購入可能（将来実装）
const kDefaultAvatars = [
  Avatar(
    id: 1,
    nameJa: '茶色クマ',
    nameEn: 'Brown Bear',
    imageAsset: 'assets/avatars/avatar_1.png',
    isFree: true,
  ),
  Avatar(
    id: 2,
    nameJa: '黒猫',
    nameEn: 'Black Cat',
    imageAsset: 'assets/avatars/avatar_2.png',
    isFree: true,
  ),
  Avatar(
    id: 3,
    nameJa: 'パンダ',
    nameEn: 'Giant Panda',
    imageAsset: 'assets/avatars/avatar_3.png',
    isFree: true,
  ),
  Avatar(
    id: 4,
    nameJa: 'キツネ',
    nameEn: 'Fox',
    imageAsset: 'assets/avatars/avatar_4.png',
    isFree: true,
  ),
  // 以下、ショップで購入可能（id 5-16）
  // 将来実装時に追加予定
];

/// アバターIDからアバターオブジェクトを取得
Avatar? getAvatarById(int id) {
  try {
    return kDefaultAvatars.firstWhere((avatar) => avatar.id == id);
  } catch (e) {
    return null;
  }
}

/// デフォルトアバターのみを取得
List<Avatar> getDefaultAvatars() {
  return kDefaultAvatars.where((avatar) => avatar.isFree).toList();
}
