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
    // ステージ完了バッジ
    BadgeDef(id:'stage_1_complete', name:'ステージ1 クリア', description:'北海道・東北地方を学ぼう - をクリアした', emoji:'🎯', category:BadgeCategory.quiz, rarity:BadgeRarity.common, coinReward:15),
    BadgeDef(id:'stage_2_complete', name:'ステージ2 クリア', description:'関東地方を学ぼう - をクリアした', emoji:'🎯', category:BadgeCategory.quiz, rarity:BadgeRarity.common, coinReward:15),
    BadgeDef(id:'stage_3_complete', name:'ステージ3 クリア', description:'近畿地方を学ぼう - をクリアした', emoji:'🎯', category:BadgeCategory.quiz, rarity:BadgeRarity.uncommon, coinReward:20),
    BadgeDef(id:'stage_4_complete', name:'ステージ4 クリア', description:'九州地方を学ぼう - をクリアした', emoji:'🎯', category:BadgeCategory.quiz, rarity:BadgeRarity.uncommon, coinReward:20),
    BadgeDef(id:'stage_5_complete', name:'ステージ5 クリア', description:'日本の産業を学ぼう - をクリアした', emoji:'🎯', category:BadgeCategory.quiz, rarity:BadgeRarity.uncommon, coinReward:20),
    BadgeDef(id:'stage_6_complete', name:'ステージ6 クリア', description:'農業と食べ物 - をクリアした', emoji:'🎯', category:BadgeCategory.quiz, rarity:BadgeRarity.rare, coinReward:30),
    BadgeDef(id:'stage_7_complete', name:'ステージ7 クリア', description:'工業と製造業 - をクリアした', emoji:'🎯', category:BadgeCategory.quiz, rarity:BadgeRarity.rare, coinReward:30),
    BadgeDef(id:'stage_8_complete', name:'ステージ8 クリア', description:'文化と観光地 - をクリアした', emoji:'🎯', category:BadgeCategory.quiz, rarity:BadgeRarity.rare, coinReward:30),
    BadgeDef(id:'stage_9_complete', name:'ステージ9 クリア', description:'交通と流通 - をクリアした', emoji:'🎯', category:BadgeCategory.quiz, rarity:BadgeRarity.rare, coinReward:30),
    BadgeDef(id:'stage_10_complete', name:'ステージ10 クリア', description:'社会博士への道 - をクリアした', emoji:'🎯', category:BadgeCategory.quiz, rarity:BadgeRarity.epic, coinReward:50),
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
    // 都道府県制覇バッジ（47都道府県） — クイズで7問以上正解すると獲得
    BadgeDef(id:'hokkaido_master', name:'北海道マスター', description:'北海道を完全制覇！', emoji:'🦌', category:BadgeCategory.geography, rarity:BadgeRarity.common, coinReward:20),
    BadgeDef(id:'aomori_master', name:'青森県マスター', description:'青森県を完全制覇！', emoji:'🍎', category:BadgeCategory.geography, rarity:BadgeRarity.common, coinReward:20),
    BadgeDef(id:'iwate_master', name:'岩手県マスター', description:'岩手県を完全制覇！', emoji:'🍜', category:BadgeCategory.geography, rarity:BadgeRarity.common, coinReward:20),
    BadgeDef(id:'miyagi_master', name:'宮城県マスター', description:'宮城県を完全制覇！', emoji:'🐄', category:BadgeCategory.geography, rarity:BadgeRarity.common, coinReward:20),
    BadgeDef(id:'akita_master', name:'秋田県マスター', description:'秋田県を完全制覇！', emoji:'🌾', category:BadgeCategory.geography, rarity:BadgeRarity.common, coinReward:20),
    BadgeDef(id:'yamagata_master', name:'山形県マスター', description:'山形県を完全制覇！', emoji:'🍒', category:BadgeCategory.geography, rarity:BadgeRarity.common, coinReward:20),
    BadgeDef(id:'fukushima_master', name:'福島県マスター', description:'福島県を完全制覇！', emoji:'🍑', category:BadgeCategory.geography, rarity:BadgeRarity.common, coinReward:20),
    BadgeDef(id:'ibaraki_master', name:'茨城県マスター', description:'茨城県を完全制覇！', emoji:'🫘', category:BadgeCategory.geography, rarity:BadgeRarity.common, coinReward:20),
    BadgeDef(id:'tochigi_master', name:'栃木県マスター', description:'栃木県を完全制覇！', emoji:'🍓', category:BadgeCategory.geography, rarity:BadgeRarity.common, coinReward:20),
    BadgeDef(id:'gunma_master', name:'群馬県マスター', description:'群馬県を完全制覇！', emoji:'♨️', category:BadgeCategory.geography, rarity:BadgeRarity.common, coinReward:20),
    BadgeDef(id:'saitama_master', name:'埼玉県マスター', description:'埼玉県を完全制覇！', emoji:'🌿', category:BadgeCategory.geography, rarity:BadgeRarity.common, coinReward:20),
    BadgeDef(id:'chiba_master', name:'千葉県マスター', description:'千葉県を完全制覇！', emoji:'🥜', category:BadgeCategory.geography, rarity:BadgeRarity.common, coinReward:20),
    BadgeDef(id:'tokyo_master', name:'東京都マスター', description:'東京都を完全制覇！', emoji:'🗼', category:BadgeCategory.geography, rarity:BadgeRarity.common, coinReward:20),
    BadgeDef(id:'kanagawa_master', name:'神奈川県マスター', description:'神奈川県を完全制覇！', emoji:'⚓', category:BadgeCategory.geography, rarity:BadgeRarity.common, coinReward:20),
    BadgeDef(id:'niigata_master', name:'新潟県マスター', description:'新潟県を完全制覇！', emoji:'🍚', category:BadgeCategory.geography, rarity:BadgeRarity.common, coinReward:20),
    BadgeDef(id:'toyama_master', name:'富山県マスター', description:'富山県を完全制覇！', emoji:'✨', category:BadgeCategory.geography, rarity:BadgeRarity.common, coinReward:20),
    BadgeDef(id:'ishikawa_master', name:'石川県マスター', description:'石川県を完全制覇！', emoji:'🌸', category:BadgeCategory.geography, rarity:BadgeRarity.common, coinReward:20),
    BadgeDef(id:'fukui_master', name:'福井県マスター', description:'福井県を完全制覇！', emoji:'🦕', category:BadgeCategory.geography, rarity:BadgeRarity.common, coinReward:20),
    BadgeDef(id:'yamanashi_master', name:'山梨県マスター', description:'山梨県を完全制覇！', emoji:'🍇', category:BadgeCategory.geography, rarity:BadgeRarity.common, coinReward:20),
    BadgeDef(id:'nagano_master', name:'長野県マスター', description:'長野県を完全制覇！', emoji:'⛷️', category:BadgeCategory.geography, rarity:BadgeRarity.common, coinReward:20),
    BadgeDef(id:'gifu_master', name:'岐阜県マスター', description:'岐阜県を完全制覇！', emoji:'🏘️', category:BadgeCategory.geography, rarity:BadgeRarity.common, coinReward:20),
    BadgeDef(id:'shizuoka_master', name:'静岡県マスター', description:'静岡県を完全制覇！', emoji:'🍵', category:BadgeCategory.geography, rarity:BadgeRarity.common, coinReward:20),
    BadgeDef(id:'aichi_master', name:'愛知県マスター', description:'愛知県を完全制覇！', emoji:'🚗', category:BadgeCategory.geography, rarity:BadgeRarity.common, coinReward:20),
    BadgeDef(id:'mie_master', name:'三重県マスター', description:'三重県を完全制覇！', emoji:'🦐', category:BadgeCategory.geography, rarity:BadgeRarity.common, coinReward:20),
    BadgeDef(id:'shiga_master', name:'滋賀県マスター', description:'滋賀県を完全制覇！', emoji:'🐟', category:BadgeCategory.geography, rarity:BadgeRarity.common, coinReward:20),
    BadgeDef(id:'kyoto_master', name:'京都府マスター', description:'京都府を完全制覇！', emoji:'⛩️', category:BadgeCategory.geography, rarity:BadgeRarity.common, coinReward:20),
    BadgeDef(id:'osaka_master', name:'大阪府マスター', description:'大阪府を完全制覇！', emoji:'🐙', category:BadgeCategory.geography, rarity:BadgeRarity.common, coinReward:20),
    BadgeDef(id:'hyogo_master', name:'兵庫県マスター', description:'兵庫県を完全制覇！', emoji:'🏯', category:BadgeCategory.geography, rarity:BadgeRarity.common, coinReward:20),
    BadgeDef(id:'nara_master', name:'奈良県マスター', description:'奈良県を完全制覇！', emoji:'🦌', category:BadgeCategory.geography, rarity:BadgeRarity.common, coinReward:20),
    BadgeDef(id:'wakayama_master', name:'和歌山県マスター', description:'和歌山県を完全制覇！', emoji:'🍋', category:BadgeCategory.geography, rarity:BadgeRarity.common, coinReward:20),
    BadgeDef(id:'tottori_master', name:'鳥取県マスター', description:'鳥取県を完全制覇！', emoji:'🏜️', category:BadgeCategory.geography, rarity:BadgeRarity.common, coinReward:20),
    BadgeDef(id:'shimane_master', name:'島根県マスター', description:'島根県を完全制覇！', emoji:'⛩️', category:BadgeCategory.geography, rarity:BadgeRarity.common, coinReward:20),
    BadgeDef(id:'okayama_master', name:'岡山県マスター', description:'岡山県を完全制覇！', emoji:'🍑', category:BadgeCategory.geography, rarity:BadgeRarity.common, coinReward:20),
    BadgeDef(id:'hiroshima_master', name:'広島県マスター', description:'広島県を完全制覇！', emoji:'🕊️', category:BadgeCategory.geography, rarity:BadgeRarity.common, coinReward:20),
    BadgeDef(id:'yamaguchi_master', name:'山口県マスター', description:'山口県を完全制覇！', emoji:'🐡', category:BadgeCategory.geography, rarity:BadgeRarity.common, coinReward:20),
    BadgeDef(id:'tokushima_master', name:'徳島県マスター', description:'徳島県を完全制覇！', emoji:'💃', category:BadgeCategory.geography, rarity:BadgeRarity.common, coinReward:20),
    BadgeDef(id:'kagawa_master', name:'香川県マスター', description:'香川県を完全制覇！', emoji:'🍜', category:BadgeCategory.geography, rarity:BadgeRarity.common, coinReward:20),
    BadgeDef(id:'ehime_master', name:'愛媛県マスター', description:'愛媛県を完全制覇！', emoji:'🍊', category:BadgeCategory.geography, rarity:BadgeRarity.common, coinReward:20),
    BadgeDef(id:'kochi_master', name:'高知県マスター', description:'高知県を完全制覇！', emoji:'🐟', category:BadgeCategory.geography, rarity:BadgeRarity.common, coinReward:20),
    BadgeDef(id:'fukuoka_master', name:'福岡県マスター', description:'福岡県を完全制覇！', emoji:'🍜', category:BadgeCategory.geography, rarity:BadgeRarity.common, coinReward:20),
    BadgeDef(id:'saga_master', name:'佐賀県マスター', description:'佐賀県を完全制覇！', emoji:'🏺', category:BadgeCategory.geography, rarity:BadgeRarity.common, coinReward:20),
    BadgeDef(id:'nagasaki_master', name:'長崎県マスター', description:'長崎県を完全制覇！', emoji:'🚢', category:BadgeCategory.geography, rarity:BadgeRarity.common, coinReward:20),
    BadgeDef(id:'kumamoto_master', name:'熊本県マスター', description:'熊本県を完全制覇！', emoji:'🌋', category:BadgeCategory.geography, rarity:BadgeRarity.common, coinReward:20),
    BadgeDef(id:'oita_master', name:'大分県マスター', description:'大分県を完全制覇！', emoji:'♨️', category:BadgeCategory.geography, rarity:BadgeRarity.common, coinReward:20),
    BadgeDef(id:'miyazaki_master', name:'宮崎県マスター', description:'宮崎県を完全制覇！', emoji:'🥭', category:BadgeCategory.geography, rarity:BadgeRarity.common, coinReward:20),
    BadgeDef(id:'kagoshima_master', name:'鹿児島県マスター', description:'鹿児島県を完全制覇！', emoji:'🌋', category:BadgeCategory.geography, rarity:BadgeRarity.common, coinReward:20),
    BadgeDef(id:'okinawa_master', name:'沖縄県マスター', description:'沖縄県を完全制覇！', emoji:'🌺', category:BadgeCategory.geography, rarity:BadgeRarity.common, coinReward:20),
    // コレクション・マスター
    BadgeDef(id:'all_prefectures', name:'47都道府県制覇', description:'全47都道府県を学習した', emoji:'🗾', category:BadgeCategory.collection, rarity:BadgeRarity.legendary, coinReward:1000),
    BadgeDef(id:'social_master', name:'社会博士', description:'全てのバッジを獲得した', emoji:'👑', category:BadgeCategory.master, rarity:BadgeRarity.legendary, coinReward:2000),
  ];

  static BadgeDef? findById(String id) {
    try { return all.firstWhere((b) => b.id == id); } catch(_) { return null; }
  }
}