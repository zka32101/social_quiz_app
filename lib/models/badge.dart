/// バッジ種別
enum BadgeCategory { prefecture, streak, region }

/// バッジ定義
class BadgeDefinition {
  final String id;
  final String name;
  final String description;
  final String emoji;
  final BadgeCategory category;

  const BadgeDefinition({
    required this.id,
    required this.name,
    required this.description,
    required this.emoji,
    required this.category,
  });
}

/// MVP 21種バッジ マスターデータ
class BadgeData {
  static const List<BadgeDefinition> all = [
    // 都道府県バッジ（14種）
    BadgeDefinition(id: 'hokkaido_master',  name: '北海道マスター',  description: '北海道を完全制覇！',  emoji: '🌾', category: BadgeCategory.prefecture),
    BadgeDefinition(id: 'aomori_master',    name: '青森マスター',   description: '青森県を完全制覇！',  emoji: '🍎', category: BadgeCategory.prefecture),
    BadgeDefinition(id: 'miyagi_master',    name: '宮城マスター',   description: '宮城県を完全制覇！',  emoji: '🐄', category: BadgeCategory.prefecture),
    BadgeDefinition(id: 'tokyo_master',     name: '東京マスター',   description: '東京都を完全制覇！',  emoji: '🗼', category: BadgeCategory.prefecture),
    BadgeDefinition(id: 'kanagawa_master',  name: '神奈川マスター', description: '神奈川県を完全制覇！', emoji: '⚓', category: BadgeCategory.prefecture),
    BadgeDefinition(id: 'saitama_master',   name: '埼玉マスター',   description: '埼玉県を完全制覇！',  emoji: '🌿', category: BadgeCategory.prefecture),
    BadgeDefinition(id: 'osaka_master',     name: '大阪マスター',   description: '大阪府を完全制覇！',  emoji: '🏯', category: BadgeCategory.prefecture),
    BadgeDefinition(id: 'kyoto_master',     name: '京都マスター',   description: '京都府を完全制覇！',  emoji: '⛩️', category: BadgeCategory.prefecture),
    BadgeDefinition(id: 'hyogo_master',     name: '兵庫マスター',   description: '兵庫県を完全制覇！',  emoji: '🚢', category: BadgeCategory.prefecture),
    BadgeDefinition(id: 'nara_master',      name: '奈良マスター',   description: '奈良県を完全制覇！',  emoji: '🦌', category: BadgeCategory.prefecture),
    BadgeDefinition(id: 'fukuoka_master',   name: '福岡マスター',   description: '福岡県を完全制覇！',  emoji: '🍜', category: BadgeCategory.prefecture),
    BadgeDefinition(id: 'kumamoto_master',  name: '熊本マスター',   description: '熊本県を完全制覇！',  emoji: '🐻', category: BadgeCategory.prefecture),
    BadgeDefinition(id: 'kagoshima_master', name: '鹿児島マスター', description: '鹿児島県を完全制覇！', emoji: '🌋', category: BadgeCategory.prefecture),
    BadgeDefinition(id: 'okinawa_master',   name: '沖縄マスター',   description: '沖縄県を完全制覇！',  emoji: '🌺', category: BadgeCategory.prefecture),

    // ストリークバッジ（3種）
    BadgeDefinition(id: 'streak_3',  name: 'ファーストステップ', description: '3日連続学習！',  emoji: '🔥',    category: BadgeCategory.streak),
    BadgeDefinition(id: 'streak_7',  name: 'ウィークバトラー',  description: '7日連続学習！',  emoji: '🔥🔥',  category: BadgeCategory.streak),
    BadgeDefinition(id: 'streak_30', name: 'マンスリーヒーロー', description: '30日連続学習！', emoji: '🔥🔥🔥', category: BadgeCategory.streak),

    // 地方制覇バッジ（4種）
    BadgeDefinition(id: 'region_hokkaido_tohoku', name: '北海道・東北制覇', description: '北海道・東北3県を制覇！', emoji: '🗾', category: BadgeCategory.region),
    BadgeDefinition(id: 'region_kanto',           name: '関東制覇',        description: '関東3都県を制覇！',     emoji: '🗾', category: BadgeCategory.region),
    BadgeDefinition(id: 'region_kinki',           name: '近畿制覇',        description: '近畿4府県を制覇！',     emoji: '🗾', category: BadgeCategory.region),
    BadgeDefinition(id: 'region_kyushu',          name: '九州制覇',        description: '九州4県を制覇！',       emoji: '🗾', category: BadgeCategory.region),
  ];

  static BadgeDefinition? findById(String id) {
    try {
      return all.firstWhere((b) => b.id == id);
    } catch (_) {
      return null;
    }
  }
}
