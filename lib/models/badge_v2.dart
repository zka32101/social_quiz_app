/// バッジカテゴリ（v1.1 拡張）
enum BadgeCategory {
  prefecture,    // 都道府県制覇（v1.0）
  streak,        // 連続学習（v1.0）
  region,        // 地方制覇（v1.0）
  stage,         // ステージ完了（v1.1 新規）
  timebased,     // 時間到達（v1.1 新規）
  complexity,    // 複雑度マスター（v1.1 新規）
  social,        // ソーシャル達成（v1.1 新規）
}

/// バッジレアリティ（v1.1 新規）
enum BadgeRarity {
  common,       // 誰でも取得可能
  uncommon,     // 少し努力が必要
  rare,         // かなりの努力が必要
  epic,         // 専門的な努力が必要
  legendary,    // 非常に稀な達成
}

/// バッジ定義（v1.1 拡張版）
class BadgeDefinition {
  final String id;
  final String name;
  final String description;
  final String emoji;
  final BadgeCategory category;
  final BadgeRarity rarity;            // v1.1 新規
  final int? requiredCount;            // v1.1 新規（例: 7日連続なら7）
  final String? unlockedCondition;     // v1.1 新規（条件説明）
  final DateTime? addedDate;           // v1.1 新規（実装日）
  final bool isHidden;                 // v1.1 新規（隠し要素か）

  const BadgeDefinition({
    required this.id,
    required this.name,
    required this.description,
    required this.emoji,
    required this.category,
    required this.rarity,
    this.requiredCount,
    this.unlockedCondition,
    this.addedDate,
    this.isHidden = false,
  });

  factory BadgeDefinition.fromJson(Map<String, dynamic> json) {
    return BadgeDefinition(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      emoji: json['emoji'] as String? ?? '🏆',
      category: _parseBadgeCategory(json['category'] as String? ?? 'prefecture'),
      rarity: _parseBadgeRarity(json['rarity'] as String? ?? 'common'),
      requiredCount: json['requiredCount'] as int?,
      unlockedCondition: json['unlockedCondition'] as String?,
      addedDate: json['addedDate'] != null
          ? DateTime.tryParse(json['addedDate'] as String)
          : null,
      isHidden: json['isHidden'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'emoji': emoji,
        'category': category.toString().split('.').last,
        'rarity': rarity.toString().split('.').last,
        'requiredCount': requiredCount,
        'unlockedCondition': unlockedCondition,
        'addedDate': addedDate?.toIso8601String(),
        'isHidden': isHidden,
      };
}

/// ユーザーが獲得したバッジと獲得日時（v1.1 新規）
class UserBadgeAchievement {
  final String badgeId;
  final DateTime unlockedAt;
  final int? progress;  // 0-100%（例: 70%達成など）
  final String? progressDescription;

  const UserBadgeAchievement({
    required this.badgeId,
    required this.unlockedAt,
    this.progress,
    this.progressDescription,
  });

  factory UserBadgeAchievement.fromJson(Map<String, dynamic> json) {
    return UserBadgeAchievement(
      badgeId: json['badgeId'] as String? ?? '',
      unlockedAt: DateTime.tryParse(json['unlockedAt'] as String? ?? '') ??
          DateTime.now(),
      progress: json['progress'] as int?,
      progressDescription: json['progressDescription'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'badgeId': badgeId,
        'unlockedAt': unlockedAt.toIso8601String(),
        'progress': progress,
        'progressDescription': progressDescription,
      };
}

/// v1.2 最適化バッジマスターデータ
/// MVP 21個 + v1.1/v1.2 追加 21個 = 42個
class BadgeDataV2 {
  static const List<BadgeDefinition> mvpBadges = [
    // ──────────────────────────────────────
    // v1.0 既存: 都道府県バッジ（14種）
    // ──────────────────────────────────────
    BadgeDefinition(
      id: 'hokkaido_master',
      name: '北海道マスター',
      description: '北海道を完全制覇！',
      emoji: '🌾',
      category: BadgeCategory.prefecture,
      rarity: BadgeRarity.uncommon,
      addedDate: null, // v1.0
    ),
    BadgeDefinition(
      id: 'aomori_master',
      name: '青森マスター',
      description: '青森県を完全制覇！',
      emoji: '🍎',
      category: BadgeCategory.prefecture,
      rarity: BadgeRarity.uncommon,
      addedDate: null,
    ),
    BadgeDefinition(
      id: 'miyagi_master',
      name: '宮城マスター',
      description: '宮城県を完全制覇！',
      emoji: '🐄',
      category: BadgeCategory.prefecture,
      rarity: BadgeRarity.uncommon,
      addedDate: null,
    ),
    BadgeDefinition(
      id: 'tokyo_master',
      name: '東京マスター',
      description: '東京都を完全制覇！',
      emoji: '🗼',
      category: BadgeCategory.prefecture,
      rarity: BadgeRarity.uncommon,
      addedDate: null,
    ),
    BadgeDefinition(
      id: 'kanagawa_master',
      name: '神奈川マスター',
      description: '神奈川県を完全制覇！',
      emoji: '⚓',
      category: BadgeCategory.prefecture,
      rarity: BadgeRarity.uncommon,
      addedDate: null,
    ),
    BadgeDefinition(
      id: 'saitama_master',
      name: '埼玉マスター',
      description: '埼玉県を完全制覇！',
      emoji: '🌿',
      category: BadgeCategory.prefecture,
      rarity: BadgeRarity.uncommon,
      addedDate: null,
    ),
    BadgeDefinition(
      id: 'osaka_master',
      name: '大阪マスター',
      description: '大阪府を完全制覇！',
      emoji: '🏯',
      category: BadgeCategory.prefecture,
      rarity: BadgeRarity.uncommon,
      addedDate: null,
    ),
    BadgeDefinition(
      id: 'kyoto_master',
      name: '京都マスター',
      description: '京都府を完全制覇！',
      emoji: '⛩️',
      category: BadgeCategory.prefecture,
      rarity: BadgeRarity.uncommon,
      addedDate: null,
    ),
    BadgeDefinition(
      id: 'hyogo_master',
      name: '兵庫マスター',
      description: '兵庫県を完全制覇！',
      emoji: '🚢',
      category: BadgeCategory.prefecture,
      rarity: BadgeRarity.uncommon,
      addedDate: null,
    ),
    BadgeDefinition(
      id: 'nara_master',
      name: '奈良マスター',
      description: '奈良県を完全制覇！',
      emoji: '🦌',
      category: BadgeCategory.prefecture,
      rarity: BadgeRarity.uncommon,
      addedDate: null,
    ),
    BadgeDefinition(
      id: 'fukuoka_master',
      name: '福岡マスター',
      description: '福岡県を完全制覇！',
      emoji: '🍜',
      category: BadgeCategory.prefecture,
      rarity: BadgeRarity.uncommon,
      addedDate: null,
    ),
    BadgeDefinition(
      id: 'kumamoto_master',
      name: '熊本マスター',
      description: '熊本県を完全制覇！',
      emoji: '🐻',
      category: BadgeCategory.prefecture,
      rarity: BadgeRarity.uncommon,
      addedDate: null,
    ),
    BadgeDefinition(
      id: 'kagoshima_master',
      name: '鹿児島マスター',
      description: '鹿児島県を完全制覇！',
      emoji: '🌋',
      category: BadgeCategory.prefecture,
      rarity: BadgeRarity.uncommon,
      addedDate: null,
    ),
    BadgeDefinition(
      id: 'okinawa_master',
      name: '沖縄マスター',
      description: '沖縄県を完全制覇！',
      emoji: '🌺',
      category: BadgeCategory.prefecture,
      rarity: BadgeRarity.uncommon,
      addedDate: null,
    ),

    // ──────────────────────────────────────
    // v1.0 既存: ストリークバッジ（3種）
    // ──────────────────────────────────────
    BadgeDefinition(
      id: 'streak_3',
      name: 'ファーストステップ',
      description: '3日連続学習！',
      emoji: '🔥',
      category: BadgeCategory.streak,
      rarity: BadgeRarity.common,
      requiredCount: 3,
      unlockedCondition: '3日連続で学習',
      addedDate: null,
    ),
    BadgeDefinition(
      id: 'streak_7',
      name: 'ウィークバトラー',
      description: '7日連続学習！',
      emoji: '🔥🔥',
      category: BadgeCategory.streak,
      rarity: BadgeRarity.uncommon,
      requiredCount: 7,
      unlockedCondition: '7日連続で学習',
      addedDate: null,
    ),
    BadgeDefinition(
      id: 'streak_30',
      name: 'マンスリーヒーロー',
      description: '30日連続学習！',
      emoji: '🔥🔥🔥',
      category: BadgeCategory.streak,
      rarity: BadgeRarity.epic,
      requiredCount: 30,
      unlockedCondition: '30日連続で学習',
      addedDate: null,
    ),

    // ──────────────────────────────────────
    // v1.0 既存: 地方制覇バッジ（4種）
    // ──────────────────────────────────────
    BadgeDefinition(
      id: 'region_hokkaido_tohoku',
      name: '北海道・東北制覇',
      description: '北海道・東北3県を制覇！',
      emoji: '🗾',
      category: BadgeCategory.region,
      rarity: BadgeRarity.rare,
      requiredCount: 3,
      unlockedCondition: '北海道、青森、宮城をすべて完全制覇',
      addedDate: null,
    ),
    BadgeDefinition(
      id: 'region_kanto',
      name: '関東制覇',
      description: '関東3都県を制覇！',
      emoji: '🗾',
      category: BadgeCategory.region,
      rarity: BadgeRarity.rare,
      requiredCount: 3,
      unlockedCondition: '東京、神奈川、埼玉をすべて完全制覇',
      addedDate: null,
    ),
    BadgeDefinition(
      id: 'region_kinki',
      name: '近畿制覇',
      description: '近畿4府県を制覇！',
      emoji: '🗾',
      category: BadgeCategory.region,
      rarity: BadgeRarity.rare,
      requiredCount: 4,
      unlockedCondition: '大阪、京都、兵庫、奈良をすべて完全制覇',
      addedDate: null,
    ),
    BadgeDefinition(
      id: 'region_kyushu',
      name: '九州制覇',
      description: '九州4県を制覇！',
      emoji: '🗾',
      category: BadgeCategory.region,
      rarity: BadgeRarity.rare,
      requiredCount: 4,
      unlockedCondition: '福岡、熊本、鹿児島、沖縄をすべて完全制覇',
      addedDate: null,
    ),
  ];

  // v1.1 新規バッジ（最適化版）
  static final List<BadgeDefinition> v11NewBadges = [
    // ──────────────────────────────────────
    // ステージ完了バッジ（6種）: 5ステージごと + 全制覇 + スピード
    // ──────────────────────────────────────
    BadgeDefinition(
      id: 'stage_master_1_5',
      name: '地理入門マスター',
      description: 'ステージ1〜5をすべて完了！',
      emoji: '🗾',
      category: BadgeCategory.stage,
      rarity: BadgeRarity.uncommon,
      requiredCount: 5,
      unlockedCondition: 'ステージ1〜5をすべて完了',
      addedDate: DateTime(2026, 5, 28),
    ),
    BadgeDefinition(
      id: 'stage_master_6_10',
      name: '地理中級マスター',
      description: 'ステージ6〜10をすべて完了！',
      emoji: '🏔️',
      category: BadgeCategory.stage,
      rarity: BadgeRarity.rare,
      requiredCount: 5,
      unlockedCondition: 'ステージ6〜10をすべて完了',
      addedDate: DateTime(2026, 5, 28),
    ),
    BadgeDefinition(
      id: 'stage_master_11_15',
      name: '社会科エキスパート',
      description: 'ステージ11〜15をすべて完了！',
      emoji: '📚',
      category: BadgeCategory.stage,
      rarity: BadgeRarity.epic,
      requiredCount: 5,
      unlockedCondition: 'ステージ11〜15をすべて完了',
      addedDate: DateTime(2026, 5, 28),
    ),
    BadgeDefinition(
      id: 'stage_master_16_20',
      name: '社会科グランドマスター',
      description: 'ステージ16〜20をすべて完了！',
      emoji: '🎓',
      category: BadgeCategory.stage,
      rarity: BadgeRarity.epic,
      requiredCount: 5,
      unlockedCondition: 'ステージ16〜20をすべて完了',
      addedDate: DateTime(2026, 6, 20),
    ),
    BadgeDefinition(
      id: 'stage_100_completion',
      name: '全ステージ制覇',
      description: '全20ステージを完全制覇！',
      emoji: '👑',
      category: BadgeCategory.stage,
      rarity: BadgeRarity.legendary,
      requiredCount: 20,
      unlockedCondition: 'ステージ1〜20をすべて完全制覇',
      addedDate: DateTime(2026, 5, 28),
    ),
    BadgeDefinition(
      id: 'stage_speed_runner',
      name: 'スピードランナー',
      description: '7日以内にステージ5まで完了！',
      emoji: '⚡',
      category: BadgeCategory.stage,
      rarity: BadgeRarity.rare,
      requiredCount: 5,
      unlockedCondition: '初回プレイから7日以内にステージ5完了',
      addedDate: DateTime(2026, 5, 28),
      isHidden: true,
    ),

    // ──────────────────────────────────────
    // 正解数バッジ（3種）: 初心者〜上級の入口
    // ──────────────────────────────────────
    BadgeDefinition(
      id: 'quiz_correct_100',
      name: '100問突破',
      description: '累計100問正解達成！',
      emoji: '💯',
      category: BadgeCategory.complexity,
      rarity: BadgeRarity.common,
      requiredCount: 100,
      unlockedCondition: '累計正解数 100問以上',
      addedDate: DateTime(2026, 6, 20),
    ),
    BadgeDefinition(
      id: 'quiz_correct_500',
      name: '500問突破',
      description: '累計500問正解達成！',
      emoji: '🎯',
      category: BadgeCategory.complexity,
      rarity: BadgeRarity.uncommon,
      requiredCount: 500,
      unlockedCondition: '累計正解数 500問以上',
      addedDate: DateTime(2026, 6, 20),
    ),
    BadgeDefinition(
      id: 'quiz_correct_2000',
      name: '2000問突破',
      description: '累計2000問正解達成！',
      emoji: '🏆',
      category: BadgeCategory.complexity,
      rarity: BadgeRarity.epic,
      requiredCount: 2000,
      unlockedCondition: '累計正解数 2000問以上',
      addedDate: DateTime(2026, 6, 20),
    ),

    // ──────────────────────────────────────
    // クイズタイプ別バッジ（2種）
    // ──────────────────────────────────────
    BadgeDefinition(
      id: 'complexity_map_master',
      name: 'マップマスター',
      description: '地図タップクイズで50回正解！',
      emoji: '🗺️',
      category: BadgeCategory.complexity,
      rarity: BadgeRarity.rare,
      requiredCount: 50,
      unlockedCondition: '地図タップクイズで50回正解',
      addedDate: DateTime(2026, 5, 28),
    ),
    BadgeDefinition(
      id: 'complexity_fill_master',
      name: '穴埋めマスター',
      description: '穴埋めクイズで50回正解！',
      emoji: '✏️',
      category: BadgeCategory.complexity,
      rarity: BadgeRarity.rare,
      requiredCount: 50,
      unlockedCondition: '穴埋めクイズで50回正解',
      addedDate: DateTime(2026, 6, 20),
    ),

    // ──────────────────────────────────────
    // ストリーク追加: 14日（2週間）
    // ──────────────────────────────────────
    BadgeDefinition(
      id: 'streak_14',
      name: 'フォートナイト',
      description: '14日連続学習！',
      emoji: '🔥🔥',
      category: BadgeCategory.streak,
      rarity: BadgeRarity.rare,
      requiredCount: 14,
      unlockedCondition: '14日連続で学習',
      addedDate: DateTime(2026, 6, 20),
    ),

    // ──────────────────────────────────────
    // 時間到達バッジ（5種）
    // ──────────────────────────────────────
    BadgeDefinition(
      id: 'time_1hour',
      name: '1時間学習者',
      description: '累計1時間の学習達成！',
      emoji: '🕐',
      category: BadgeCategory.timebased,
      rarity: BadgeRarity.common,
      requiredCount: 60,
      unlockedCondition: '累計学習時間 60分以上',
      addedDate: DateTime(2026, 5, 28),
    ),
    BadgeDefinition(
      id: 'time_10hour',
      name: '10時間学習者',
      description: '累計10時間の学習達成！',
      emoji: '🕙',
      category: BadgeCategory.timebased,
      rarity: BadgeRarity.uncommon,
      requiredCount: 600,
      unlockedCondition: '累計学習時間 600分（10時間）以上',
      addedDate: DateTime(2026, 5, 28),
    ),
    BadgeDefinition(
      id: 'time_100hour',
      name: '100時間学習者',
      description: '累計100時間の学習達成！',
      emoji: '🏅',
      category: BadgeCategory.timebased,
      rarity: BadgeRarity.epic,
      requiredCount: 6000,
      unlockedCondition: '累計学習時間 6000分（100時間）以上',
      addedDate: DateTime(2026, 5, 28),
    ),
    BadgeDefinition(
      id: 'time_night_owl',
      name: 'ナイトアウル',
      description: '夜間（21時〜6時）に30回学習！',
      emoji: '🦉',
      category: BadgeCategory.timebased,
      rarity: BadgeRarity.uncommon,
      requiredCount: 30,
      unlockedCondition: '夜間（21時〜6時）での学習セッションが30回以上',
      addedDate: DateTime(2026, 5, 28),
    ),
    BadgeDefinition(
      id: 'time_morning_bird',
      name: 'モーニングバード',
      description: '朝（5時〜9時）に30回学習！',
      emoji: '🌅',
      category: BadgeCategory.timebased,
      rarity: BadgeRarity.uncommon,
      requiredCount: 30,
      unlockedCondition: '朝（5時〜9時）での学習セッションが30回以上',
      addedDate: DateTime(2026, 5, 28),
    ),

    // ──────────────────────────────────────
    // パーフェクト・継続バッジ（2種）
    // ──────────────────────────────────────
    BadgeDefinition(
      id: 'social_perfect_score',
      name: 'パーフェクト達成',
      description: '3回連続で全問正解！',
      emoji: '⭐',
      category: BadgeCategory.social,
      rarity: BadgeRarity.rare,
      requiredCount: 3,
      unlockedCondition: '3回連続でステージ全問正解',
      addedDate: DateTime(2026, 5, 28),
    ),
    BadgeDefinition(
      id: 'social_consistency',
      name: '継続の王',
      description: '90日連続学習達成！',
      emoji: '👑',
      category: BadgeCategory.social,
      rarity: BadgeRarity.legendary,
      requiredCount: 90,
      unlockedCondition: '90日連続で学習',
      addedDate: DateTime(2026, 5, 28),
    ),
  ];

  /// すべてのバッジを取得（v1.0 + v1.1）
  static List<BadgeDefinition> getAllBadges() {
    return [...mvpBadges, ...v11NewBadges];
  }

  /// ID でバッジを検索
  static BadgeDefinition? findById(String id) {
    try {
      return getAllBadges().firstWhere((b) => b.id == id);
    } catch (_) {
      return null;
    }
  }

  /// カテゴリでバッジをフィルタリング
  static List<BadgeDefinition> filterByCategory(BadgeCategory category) {
    return getAllBadges().where((b) => b.category == category).toList();
  }

  /// レアリティでバッジをフィルタリング
  static List<BadgeDefinition> filterByRarity(BadgeRarity rarity) {
    return getAllBadges().where((b) => b.rarity == rarity).toList();
  }
}

// ─── ヘルパー関数 ───────────────────────────────────

BadgeCategory _parseBadgeCategory(String categoryStr) {
  switch (categoryStr) {
    case 'prefecture':
      return BadgeCategory.prefecture;
    case 'streak':
      return BadgeCategory.streak;
    case 'region':
      return BadgeCategory.region;
    case 'stage':
      return BadgeCategory.stage;
    case 'timebased':
      return BadgeCategory.timebased;
    case 'complexity':
      return BadgeCategory.complexity;
    case 'social':
      return BadgeCategory.social;
    default:
      return BadgeCategory.prefecture;
  }
}

BadgeRarity _parseBadgeRarity(String rarityStr) {
  switch (rarityStr) {
    case 'common':
      return BadgeRarity.common;
    case 'uncommon':
      return BadgeRarity.uncommon;
    case 'rare':
      return BadgeRarity.rare;
    case 'epic':
      return BadgeRarity.epic;
    case 'legendary':
      return BadgeRarity.legendary;
    default:
      return BadgeRarity.common;
  }
}
