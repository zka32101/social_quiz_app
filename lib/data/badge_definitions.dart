enum BadgeCategory { geography, quiz, streak, collection, master }
enum BadgeRarity { common, uncommon, rare, epic, legendary }

class BadgeDef {
  final String id;
  final String name;
  final String description;
  final String emoji;
  final BadgeCategory category;
  final BadgeRarity rarity;
  final int coinReward;
  const BadgeDef({required this.id, required this.name, required this.description, required this.emoji, required this.category, required this.rarity, required this.coinReward});
}

class BadgeDefinitions {
  static const List<BadgeDef> all = [
    // クイズバッジ
    BadgeDef(id:'first_correct', name:'はじめての正解', description:'最初のクイズに正解した', emoji:'⭐', category:BadgeCategory.quiz, rarity:BadgeRarity.common, coinReward:10),
    BadgeDef(id:'combo_10', name:'10問連続正解', description:'10問連続で正解した', emoji:'🔥', category:BadgeCategory.quiz, rarity:BadgeRarity.uncommon, coinReward:50),
    BadgeDef(id:'quiz_50', name:'50問クリア', description:'合計50問正解した', emoji:'💪', category:BadgeCategory.quiz, rarity:BadgeRarity.rare, coinReward:100),
    BadgeDef(id:'all_stages', name:'全ステージクリア', description:'全10ステージをクリアした', emoji:'🏆', category:BadgeCategory.quiz, rarity:BadgeRarity.epic, coinReward:500),
    // ストリークバッジ
    BadgeDef(id:'streak_3', name:'3日連続', description:'3日連続で学習した', emoji:'🌟', category:BadgeCategory.streak, rarity:BadgeRarity.common, coinReward:30),
    BadgeDef(id:'streak_7', name:'1週間連続', description:'7日連続で学習した', emoji:'🌙', category:BadgeCategory.streak, rarity:BadgeRarity.uncommon, coinReward:70),
    BadgeDef(id:'streak_30', name:'30日連続', description:'30日連続で学習した', emoji:'🌈', category:BadgeCategory.streak, rarity:BadgeRarity.rare, coinReward:300),
    // 地理バッジ（8地方）
    BadgeDef(id:'region_hokkaido', name:'北海道マスター', description:'北海道の学習をコンプリート', emoji:'🦌', category:BadgeCategory.geography, rarity:BadgeRarity.uncommon, coinReward:50),
    BadgeDef(id:'region_tohoku', name:'東北マスター', description:'東北6県の学習をコンプリート', emoji:'🍎', category:BadgeCategory.geography, rarity:BadgeRarity.uncommon, coinReward:60),
    BadgeDef(id:'region_kanto', name:'関東マスター', description:'関東7都県の学習をコンプリート', emoji:'🗼', category:BadgeCategory.geography, rarity:BadgeRarity.uncommon, coinReward:70),
    BadgeDef(id:'region_chubu', name:'中部マスター', description:'中部9県の学習をコンプリート', emoji:'🗻', category:BadgeCategory.geography, rarity:BadgeRarity.uncommon, coinReward:90),
    BadgeDef(id:'region_kinki', name:'近畿マスター', description:'近畿7府県の学習をコンプリート', emoji:'⛩️', category:BadgeCategory.geography, rarity:BadgeRarity.uncommon, coinReward:70),
    BadgeDef(id:'region_chugoku', name:'中国マスター', description:'中国5県の学習をコンプリート', emoji:'🦢', category:BadgeCategory.geography, rarity:BadgeRarity.uncommon, coinReward:50),
    BadgeDef(id:'region_shikoku', name:'四国マスター', description:'四国4県の学習をコンプリート', emoji:'🍊', category:BadgeCategory.geography, rarity:BadgeRarity.uncommon, coinReward:40),
    BadgeDef(id:'region_kyushu', name:'九州マスター', description:'九州8県の学習をコンプリート', emoji:'🌋', category:BadgeCategory.geography, rarity:BadgeRarity.uncommon, coinReward:80),
    // コレクション・マスター
    BadgeDef(id:'all_prefectures', name:'47都道府県制覇', description:'全47都道府県を学習した', emoji:'🗾', category:BadgeCategory.collection, rarity:BadgeRarity.legendary, coinReward:1000),
    BadgeDef(id:'social_master', name:'社会博士', description:'全てのバッジを獲得した', emoji:'👑', category:BadgeCategory.master, rarity:BadgeRarity.legendary, coinReward:2000),
  ];

  static BadgeDef? findById(String id) {
    try { return all.firstWhere((b) => b.id == id); } catch(_) { return null; }
  }
}