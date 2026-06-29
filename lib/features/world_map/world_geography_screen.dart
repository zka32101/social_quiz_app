import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../repositories/progress_repository.dart';
import '../../utils/constants.dart';
import 'world_map_widget.dart';

// ─────────────────────────────────────────────────────────────
// Data models
// ─────────────────────────────────────────────────────────────

class _Continent {
  final String name;
  final String furigana;
  final String emoji;
  final Color color;
  final String description;
  final List<String> countries;

  const _Continent({
    required this.name,
    required this.furigana,
    required this.emoji,
    required this.color,
    required this.description,
    required this.countries,
  });
}

class _Country {
  final String flag;
  final String name;
  final String furigana;
  final String capital;
  final String capitalFurigana;
  final String region;
  final String feature;

  const _Country({
    required this.flag,
    required this.name,
    required this.furigana,
    required this.capital,
    required this.capitalFurigana,
    required this.region,
    required this.feature,
  });
}

class _Landform {
  final String emoji;
  final String name;
  final String furigana;
  final String type;
  final String detail;

  const _Landform({
    required this.emoji,
    required this.name,
    required this.furigana,
    required this.type,
    required this.detail,
  });
}

// ─────────────────────────────────────────────────────────────
// Continent data
// ─────────────────────────────────────────────────────────────

const List<_Continent> _continents = [
  _Continent(
    name: 'アジア',
    furigana: 'Asia',
    emoji: '🌏',
    color: Color(0xFFE65100),
    description:
        '世界最大の大陸で、面積・人口ともに世界一。'
        '日本・中国・インド・韓国・東南アジアなどが含まれます。'
        '世界人口の約60%（46億人以上）が住んでいます。',
    countries: ['🇯🇵 日本（にほん）', '🇨🇳 中国（ちゅうごく）', '🇮🇳 インド', '🇰🇷 韓国（かんこく）'],
  ),
  _Continent(
    name: 'ヨーロッパ',
    furigana: 'Europe',
    emoji: '🌍',
    color: Color(0xFF1565C0),
    description:
        'ユーラシア大陸の西部に位置する大陸。'
        '約50か国が集まり、EU（ヨーロッパ連合）でまとまって行動しています。'
        '歴史・芸術・科学の発展地で、産業革命もここから始まりました。',
    countries: ['🇫🇷 フランス', '🇩🇪 ドイツ（どいつ）', '🇬🇧 イギリス', '🇮🇹 イタリア'],
  ),
  _Continent(
    name: 'アフリカ',
    furigana: 'Africa',
    emoji: '🌍',
    color: Color(0xFF2E7D32),
    description:
        '世界第2位の面積と人口を持つ大陸。'
        '54か国が存在し、世界で最も国の数が多い大陸です。'
        'サハラ砂漠（さはらさばく）・ナイル川など有名な地形があります。',
    countries: ['🇿🇦 南アフリカ（みなみあふりか）', '🇳🇬 ナイジェリア', '🇪🇹 エチオピア', '🇰🇪 ケニア'],
  ),
  _Continent(
    name: '北アメリカ',
    furigana: 'North America',
    emoji: '🌎',
    color: Color(0xFF6A1B9A),
    description:
        'アメリカ合衆国・カナダ・メキシコなどが含まれる大陸。'
        '世界最大の経済大国（アメリカ）があり、経済・文化・技術で世界をリードしています。'
        'グランドキャニオン・ナイアガラの滝などの絶景があります。',
    countries: ['🇺🇸 アメリカ合衆国（がっしゅうこく）', '🇨🇦 カナダ', '🇲🇽 メキシコ', '🇨🇺 キューバ'],
  ),
  _Continent(
    name: '南アメリカ',
    furigana: 'South America',
    emoji: '🌎',
    color: Color(0xFFC62828),
    description:
        'ブラジル・アルゼンチンなどが含まれる大陸。'
        '世界最大の熱帯雨林（ねったいうりん）であるアマゾン川流域があります。'
        'サッカーが盛んで、多様な文化・民族が共存しています。',
    countries: ['🇧🇷 ブラジル', '🇦🇷 アルゼンチン', '🇵🇪 ペルー', '🇨🇱 チリ'],
  ),
  _Continent(
    name: 'オセアニア',
    furigana: 'Oceania',
    emoji: '🌏',
    color: Color(0xFF00695C),
    description:
        'オーストラリア・ニュージーランドや太平洋の島々が含まれる地域。'
        'オーストラリアは大陸であり国でもある特殊な地域です。'
        'カンガルー・コアラなど固有種（こゆうしゅ）が多く生息しています。',
    countries: ['🇦🇺 オーストラリア', '🇳🇿 ニュージーランド', '🇫🇯 フィジー', '🇵🇬 パプアニューギニア'],
  ),
];

// ─────────────────────────────────────────────────────────────
// Country data
// ─────────────────────────────────────────────────────────────

const List<_Country> _countries = [
  // アジア
  _Country(
    flag: '🇯🇵',
    name: '日本',
    furigana: 'にほん',
    capital: '東京',
    capitalFurigana: 'とうきょう',
    region: 'アジア',
    feature: '島国・自動車・電子技術が発展',
  ),
  _Country(
    flag: '🇨🇳',
    name: '中国',
    furigana: 'ちゅうごく',
    capital: '北京',
    capitalFurigana: 'ぺきん',
    region: 'アジア',
    feature: '世界最多の人口・万里の長城',
  ),
  _Country(
    flag: '🇮🇳',
    name: 'インド',
    furigana: 'いんど',
    capital: 'ニューデリー',
    capitalFurigana: 'にゅーでりー',
    region: 'アジア',
    feature: 'IT産業・カレー・人口世界一',
  ),
  _Country(
    flag: '🇰🇷',
    name: '韓国',
    furigana: 'かんこく',
    capital: 'ソウル',
    capitalFurigana: 'そうる',
    region: 'アジア',
    feature: 'K-POP・半導体産業・韓国料理',
  ),
  // 東南アジア
  _Country(
    flag: '🇹🇭',
    name: 'タイ',
    furigana: 'たい',
    capital: 'バンコク',
    capitalFurigana: 'ばんこく',
    region: 'アジア',
    feature: '仏教の国・観光・米の輸出大国',
  ),
  _Country(
    flag: '🇻🇳',
    name: 'ベトナム',
    furigana: 'べとなむ',
    capital: 'ハノイ',
    capitalFurigana: 'はのい',
    region: 'アジア',
    feature: 'フォー・コーヒー・バイク文化',
  ),
  _Country(
    flag: '🇮🇩',
    name: 'インドネシア',
    furigana: 'いんどねしあ',
    capital: 'ジャカルタ',
    capitalFurigana: 'じゃかるた',
    region: 'アジア',
    feature: '世界最多の島国（約17,000島）・イスラム教',
  ),
  _Country(
    flag: '🇵🇭',
    name: 'フィリピン',
    furigana: 'ふぃりぴん',
    capital: 'マニラ',
    capitalFurigana: 'まにら',
    region: 'アジア',
    feature: '島国・熱帯・バナナの産地',
  ),
  _Country(
    flag: '🇸🇬',
    name: 'シンガポール',
    furigana: 'しんがぽーる',
    capital: 'シンガポール',
    capitalFurigana: 'しんがぽーる',
    region: 'アジア',
    feature: '都市国家・金融・多民族国家',
  ),
  _Country(
    flag: '🇲🇾',
    name: 'マレーシア',
    furigana: 'まれーしあ',
    capital: 'クアラルンプール',
    capitalFurigana: 'くあらるんぷーる',
    region: 'アジア',
    feature: 'ペトロナスタワー・ゴム・パーム油',
  ),
  // 北アメリカ
  _Country(
    flag: '🇺🇸',
    name: 'アメリカ',
    furigana: 'あめりか',
    capital: 'ワシントンD.C.',
    capitalFurigana: 'わしんとんでぃーしー',
    region: '北アメリカ',
    feature: 'GDP世界一・シリコンバレー・映画',
  ),
  _Country(
    flag: '🇨🇦',
    name: 'カナダ',
    furigana: 'かなだ',
    capital: 'オタワ',
    capitalFurigana: 'おたわ',
    region: '北アメリカ',
    feature: '世界第2位の面積・メープルシロップ・多文化社会',
  ),
  _Country(
    flag: '🇲🇽',
    name: 'メキシコ',
    furigana: 'めきしこ',
    capital: 'メキシコシティ',
    capitalFurigana: 'めきしこしてぃ',
    region: '北アメリカ',
    feature: 'マヤ文明・タコス・テキーラ',
  ),
  // ヨーロッパ
  _Country(
    flag: '🇬🇧',
    name: 'イギリス',
    furigana: 'いぎりす',
    capital: 'ロンドン',
    capitalFurigana: 'ろんどん',
    region: 'ヨーロッパ',
    feature: '産業革命発祥地・サッカー・王室',
  ),
  _Country(
    flag: '🇫🇷',
    name: 'フランス',
    furigana: 'ふらんす',
    capital: 'パリ',
    capitalFurigana: 'ぱり',
    region: 'ヨーロッパ',
    feature: 'ファッション・エッフェル塔・ワイン',
  ),
  _Country(
    flag: '🇩🇪',
    name: 'ドイツ',
    furigana: 'どいつ',
    capital: 'ベルリン',
    capitalFurigana: 'べるりん',
    region: 'ヨーロッパ',
    feature: '自動車（BMW・ベンツ）・工業大国',
  ),
  _Country(
    flag: '🇮🇹',
    name: 'イタリア',
    furigana: 'いたりあ',
    capital: 'ローマ',
    capitalFurigana: 'ろーま',
    region: 'ヨーロッパ',
    feature: 'ピザ・パスタ・コロッセオ・ルネサンス',
  ),
  _Country(
    flag: '🇷🇺',
    name: 'ロシア',
    furigana: 'ろしあ',
    capital: 'モスクワ',
    capitalFurigana: 'もすくわ',
    region: 'ヨーロッパ/アジア',
    feature: '世界最大の国土面積・シベリア',
  ),
  _Country(
    flag: '🇪🇸',
    name: 'スペイン',
    furigana: 'すぺいん',
    capital: 'マドリード',
    capitalFurigana: 'まどりーど',
    region: 'ヨーロッパ',
    feature: 'サッカー・フラメンコ・バルセロナ',
  ),
  _Country(
    flag: '🇳🇱',
    name: 'オランダ',
    furigana: 'おらんだ',
    capital: 'アムステルダム',
    capitalFurigana: 'あむすてるだむ',
    region: 'ヨーロッパ',
    feature: 'チューリップ・風車・埋め立て地の国',
  ),
  _Country(
    flag: '🇨🇭',
    name: 'スイス',
    furigana: 'すいす',
    capital: 'ベルン',
    capitalFurigana: 'べるん',
    region: 'ヨーロッパ',
    feature: '時計・チョコレート・永世中立国',
  ),
  _Country(
    flag: '🇸🇪',
    name: 'スウェーデン',
    furigana: 'すうぇーでん',
    capital: 'ストックホルム',
    capitalFurigana: 'すとっくほるむ',
    region: 'ヨーロッパ',
    feature: 'ノーベル賞・IKEA・北欧福祉国家',
  ),
  // アフリカ
  _Country(
    flag: '🇿🇦',
    name: '南アフリカ',
    furigana: 'みなみあふりか',
    capital: 'プレトリア',
    capitalFurigana: 'ぷれとりあ',
    region: 'アフリカ',
    feature: 'ダイヤモンド・金の産地',
  ),
  _Country(
    flag: '🇪🇬',
    name: 'エジプト',
    furigana: 'えじぷと',
    capital: 'カイロ',
    capitalFurigana: 'かいろ',
    region: 'アフリカ',
    feature: 'ピラミッド・ナイル川・古代文明',
  ),
  _Country(
    flag: '🇳🇬',
    name: 'ナイジェリア',
    furigana: 'ないじぇりあ',
    capital: 'アブジャ',
    capitalFurigana: 'あぶじゃ',
    region: 'アフリカ',
    feature: 'アフリカ最多人口・石油・映画産業',
  ),
  _Country(
    flag: '🇪🇹',
    name: 'エチオピア',
    furigana: 'えちおぴあ',
    capital: 'アディスアベバ',
    capitalFurigana: 'あでぃすあべば',
    region: 'アフリカ',
    feature: 'コーヒー発祥地・マラソン大国・高地',
  ),
  _Country(
    flag: '🇰🇪',
    name: 'ケニア',
    furigana: 'けにあ',
    capital: 'ナイロビ',
    capitalFurigana: 'ないろび',
    region: 'アフリカ',
    feature: 'サバンナ・マラソン・サファリ観光',
  ),
  _Country(
    flag: '🇲🇦',
    name: 'モロッコ',
    furigana: 'もろっこ',
    capital: 'ラバト',
    capitalFurigana: 'らばと',
    region: 'アフリカ',
    feature: 'サハラ砂漠の入口・アルガンオイル・地中海',
  ),
  // 南アメリカ
  _Country(
    flag: '🇧🇷',
    name: 'ブラジル',
    furigana: 'ぶらじる',
    capital: 'ブラジリア',
    capitalFurigana: 'ぶらじりあ',
    region: '南アメリカ',
    feature: 'アマゾン川・サッカー・カーニバル',
  ),
  _Country(
    flag: '🇦🇷',
    name: 'アルゼンチン',
    furigana: 'あるぜんちん',
    capital: 'ブエノスアイレス',
    capitalFurigana: 'ぶえのすあいれす',
    region: '南アメリカ',
    feature: 'タンゴ・牛肉・メッシの故郷',
  ),
  _Country(
    flag: '🇵🇪',
    name: 'ペルー',
    furigana: 'ぺるー',
    capital: 'リマ',
    capitalFurigana: 'りま',
    region: '南アメリカ',
    feature: 'マチュピチュ・インカ文明・アンデス',
  ),
  _Country(
    flag: '🇨🇱',
    name: 'チリ',
    furigana: 'ちり',
    capital: 'サンティアゴ',
    capitalFurigana: 'さんてぃあご',
    region: '南アメリカ',
    feature: '南北に細長い国・銅の産地・アタカマ砂漠',
  ),
  // オセアニア
  _Country(
    flag: '🇦🇺',
    name: 'オーストラリア',
    furigana: 'おーすとらりあ',
    capital: 'キャンベラ',
    capitalFurigana: 'きゃんべら',
    region: 'オセアニア',
    feature: 'カンガルー・コアラ・ウルル（エアーズロック）',
  ),
  _Country(
    flag: '🇳🇿',
    name: 'ニュージーランド',
    furigana: 'にゅーじーらんど',
    capital: 'ウェリントン',
    capitalFurigana: 'うぇりんとん',
    region: 'オセアニア',
    feature: '羊の国・ラグビー・キウイフルーツ',
  ),
  // 中東
  _Country(
    flag: '🇸🇦',
    name: 'サウジアラビア',
    furigana: 'さうじあらびあ',
    capital: 'リヤド',
    capitalFurigana: 'りやど',
    region: '中東（アジア）',
    feature: '石油・砂漠・イスラム教の聖地',
  ),
  _Country(
    flag: '🇦🇪',
    name: 'アラブ首長国連邦',
    furigana: 'あらぶしゅちょうこくれんぽう',
    capital: 'アブダビ',
    capitalFurigana: 'あぶだび',
    region: '中東（アジア）',
    feature: 'ドバイ・石油・世界一高いビル（ブルジュハリファ）',
  ),
  _Country(
    flag: '🇹🇷',
    name: 'トルコ',
    furigana: 'とるこ',
    capital: 'アンカラ',
    capitalFurigana: 'あんから',
    region: '中東（アジア）',
    feature: 'アジアとヨーロッパをつなぐ国・イスタンブール',
  ),
];

// ─────────────────────────────────────────────────────────────
// Landform data
// ─────────────────────────────────────────────────────────────

const List<_Landform> _landforms = [
  // 山
  _Landform(
    emoji: '⛰',
    name: 'エベレスト山',
    furigana: 'えべれすとさん',
    type: '山（やま）',
    detail: '世界最高峰（8,848m）。ヒマラヤ山脈（インド・ネパール・中国の国境）',
  ),
  _Landform(
    emoji: '🗻',
    name: '富士山',
    furigana: 'ふじさん',
    type: '山（やま）',
    detail: '日本の最高峰（3,776m）・ユネスコ世界文化遺産',
  ),
  _Landform(
    emoji: '⛰',
    name: 'アンデス山脈',
    furigana: 'あんでさんみゃく',
    type: '山脈（さんみゃく）',
    detail: '南アメリカ大陸を縦断する世界最長の山脈（約7,000km）',
  ),
  _Landform(
    emoji: '⛰',
    name: 'アルプス山脈',
    furigana: 'あるぷすさんみゃく',
    type: '山脈（さんみゃく）',
    detail: 'ヨーロッパ中部の山脈。スイス・フランス・イタリア・オーストリアにまたがる',
  ),
  // 川
  _Landform(
    emoji: '🏞',
    name: 'ナイル川',
    furigana: 'ないるがわ',
    type: '川（かわ）',
    detail: '世界最長の川（約6,650km）。エジプト・スーダンを流れアフリカ北部へ',
  ),
  _Landform(
    emoji: '🏞',
    name: 'アマゾン川',
    furigana: 'あまぞんがわ',
    type: '川（かわ）',
    detail: '世界最大の流域面積。南アメリカ・ブラジルを流れる熱帯雨林の大河',
  ),
  _Landform(
    emoji: '🏞',
    name: '長江（ちょうこう）',
    furigana: 'ちょうこう',
    type: '川（かわ）',
    detail: 'アジア最長の川（約6,300km）。中国を西から東へ流れる',
  ),
  // 砂漠
  _Landform(
    emoji: '🏜',
    name: 'サハラ砂漠',
    furigana: 'さはらさばく',
    type: '砂漠（さばく）',
    detail: '世界最大の砂漠（約920万km²）。アフリカ大陸北部に広がる',
  ),
  _Landform(
    emoji: '🏜',
    name: 'ゴビ砂漠',
    furigana: 'ごびさばく',
    type: '砂漠（さばく）',
    detail: 'アジア最大の砂漠。中国・モンゴルにまたがる',
  ),
  // 海・湖
  _Landform(
    emoji: '🌊',
    name: '太平洋',
    furigana: 'たいへいよう',
    type: '海洋（かいよう）',
    detail: '世界最大の海洋。日本の東側・アメリカの西側に広がる',
  ),
  _Landform(
    emoji: '🌊',
    name: '大西洋',
    furigana: 'たいせいよう',
    type: '海洋（かいよう）',
    detail: '世界第2位の海洋。ヨーロッパ・アフリカとアメリカの間に位置する',
  ),
  _Landform(
    emoji: '💧',
    name: 'カスピ海',
    furigana: 'かすぴかい',
    type: '湖（みずうみ）',
    detail: '世界最大の湖（塩湖）。ロシア・カザフスタン・イランなどに囲まれている',
  ),
];

// ─────────────────────────────────────────────────────────────
// Screen
// ─────────────────────────────────────────────────────────────

class WorldGeographyScreen extends ConsumerStatefulWidget {
  const WorldGeographyScreen({super.key});

  @override
  ConsumerState<WorldGeographyScreen> createState() =>
      _WorldGeographyScreenState();
}

class _WorldGeographyScreenState
    extends ConsumerState<WorldGeographyScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final coins = ref.watch(coinsProvider);

    return Scaffold(
      backgroundColor: const Color(AppColors.bgLight),
      appBar: AppBar(
        title: const Text('世界の地理'),
        centerTitle: true,
        backgroundColor: const Color(0xFF0277BD),
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          isScrollable: true,
          tabs: const [
            Tab(text: '🗺️ 世界地図'),
            Tab(text: '六大陸・三大洋'),
            Tab(text: '主要国・首都'),
            Tab(text: '世界の地形'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/world-quiz'),
        backgroundColor: const Color(0xFF0277BD),
        foregroundColor: Colors.white,
        icon: const Text('🌏', style: TextStyle(fontSize: 20)),
        label: const Text(
          'クイズに挑戦！',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          _CoinBanner(coins: coins),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [
                WorldMapWidget(),
                _ContinentsTab(),
                _CountriesTab(),
                _LandformsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Coin banner
// ─────────────────────────────────────────────────────────────

class _CoinBanner extends StatelessWidget {
  final int coins;

  const _CoinBanner({required this.coins});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          const Text('🪙', style: TextStyle(fontSize: 18)),
          const SizedBox(width: 4),
          Text(
            '$coins',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Tab 1: Continents & Oceans
// ─────────────────────────────────────────────────────────────

class _ContinentsTab extends StatelessWidget {
  const _ContinentsTab();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      children: [
        // Three oceans header
        Container(
          padding: const EdgeInsets.all(14),
          margin: const EdgeInsets.only(bottom: 14),
          decoration: BoxDecoration(
            color: const Color(0xFF0277BD).withValues(alpha: 0.08),
            border: Border.all(
              color: const Color(0xFF0277BD).withValues(alpha: 0.3),
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '🌊 三大洋（さんたいよう）',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0277BD),
                ),
              ),
              const SizedBox(height: 8),
              _oceanRow('太平洋（たいへいよう）', '世界最大。日本の東側', '🌏'),
              _oceanRow('大西洋（たいせいよう）', '世界第2位。ヨーロッパと米大陸の間', '🌍'),
              _oceanRow('インド洋（いんどよう）', '世界第3位。インド・アフリカの南', '🌊'),
            ],
          ),
        ),
        // Continents
        ...(_continents.map((c) => _ContinentCard(continent: c))),
      ],
    );
  }

  Widget _oceanRow(String name, String desc, String emoji) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: '$name：',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF333333),
                    ),
                  ),
                  TextSpan(
                    text: desc,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF666666),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ContinentCard extends StatefulWidget {
  final _Continent continent;

  const _ContinentCard({required this.continent});

  @override
  State<_ContinentCard> createState() => _ContinentCardState();
}

class _ContinentCardState extends State<_ContinentCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final c = widget.continent;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => setState(() => _expanded = !_expanded),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: c.color.withValues(alpha: 0.08),
                ),
                child: Row(
                  children: [
                    Text(c.emoji, style: const TextStyle(fontSize: 28)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            c.furigana,
                            style: TextStyle(
                              fontSize: 10,
                              color: c.color.withValues(alpha: 0.8),
                            ),
                          ),
                          Text(
                            c.name,
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: c.color,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      _expanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: Colors.grey.shade500,
                    ),
                  ],
                ),
              ),
              if (_expanded) ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 10, 14, 4),
                  child: Text(
                    c.description,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF555555),
                      height: 1.6,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 6, 14, 12),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: c.color.withValues(alpha: 0.05),
                      border: Border.all(
                        color: c.color.withValues(alpha: 0.2),
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '代表的な国',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: c.color,
                          ),
                        ),
                        const SizedBox(height: 6),
                        ...c.countries.map(
                          (country) => Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Text(
                              '• $country',
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF444444),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Tab 2: Countries & Capitals
// ─────────────────────────────────────────────────────────────

class _CountriesTab extends StatelessWidget {
  const _CountriesTab();

  @override
  Widget build(BuildContext context) {
    // Group by region
    final regions = <String, List<_Country>>{};
    for (final c in _countries) {
      regions.putIfAbsent(c.region, () => []).add(c);
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      children: regions.entries.map((entry) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 8, top: 4),
              child: Text(
                entry.key,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0277BD),
                ),
              ),
            ),
            ...entry.value.map((c) => _CountryTile(country: c)),
            const SizedBox(height: 10),
          ],
        );
      }).toList(),
    );
  }
}

class _CountryTile extends StatelessWidget {
  final _Country country;

  const _CountryTile({required this.country});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          children: [
            Text(
              country.flag,
              style: const TextStyle(fontSize: 28),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        country.furigana,
                        style: const TextStyle(
                          fontSize: 9,
                          color: Color(0xFF888888),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    country.name,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF333333),
                    ),
                  ),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_city,
                        size: 12,
                        color: Color(0xFF0277BD),
                      ),
                      const SizedBox(width: 3),
                      const Text(
                        '首都（しゅと）: ',
                        style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFF0277BD),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            country.capitalFurigana,
                            style: const TextStyle(
                              fontSize: 9,
                              color: Color(0xFF888888),
                            ),
                          ),
                          Text(
                            country.capital,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF444444),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Text(
                    country.feature,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF777777),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Tab 3: Landforms
// ─────────────────────────────────────────────────────────────

class _LandformsTab extends StatelessWidget {
  const _LandformsTab();

  @override
  Widget build(BuildContext context) {
    // Group by type
    final grouped = <String, List<_Landform>>{};
    for (final lf in _landforms) {
      grouped.putIfAbsent(lf.type, () => []).add(lf);
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      children: grouped.entries.map((entry) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 8, top: 4),
              child: Text(
                entry.key,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0277BD),
                ),
              ),
            ),
            ...entry.value.map((lf) => _LandformTile(landform: lf)),
            const SizedBox(height: 10),
          ],
        );
      }).toList(),
    );
  }
}

class _LandformTile extends StatelessWidget {
  final _Landform landform;

  const _LandformTile({required this.landform});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              landform.emoji,
              style: const TextStyle(fontSize: 26),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    landform.furigana,
                    style: const TextStyle(
                      fontSize: 9,
                      color: Color(0xFF888888),
                    ),
                  ),
                  Text(
                    landform.name,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF333333),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    landform.detail,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF666666),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
