import 'package:shared_core/shared_core.dart';

// 2026-08 キャラクターリニューアル: 全16体を性別・種族混合の新ラインナップに
// 刷新（旧: 全員「〜コ」で終わる女の子 → 新: 男の子・動物・架空種族を混ぜた
// ラインナップ）。id を変更したキャラは、旧セーブデータの解放状況・Lvを
// 引き継ぐため services/character_id_migration.dart で新idに移行する。
// 教科テーマ(subject)・tier・unlockAtは旧ラインナップから変更していない。
const List<BaseCharacter> kShakaiCharacters = [
  // ─── Tier 1（小3-4年向け） ────────────────────────────────────────────────

  BaseCharacter(
    id: 'mapple',
    name: 'マップル',
    emoji: '🧭',
    tier: 1,
    unlockAt: 0,
    subject: '地図記号',
    imageAsset: 'assets/characters/mapple.png',
    levelImages: {
      2: 'assets/characters/mapple_lv2.png',
      3: 'assets/characters/mapple_lv3.png',
      4: 'assets/characters/mapple_lv4.png',
      5: 'assets/characters/mapple_lvmax.png',
    },
    backstory:
        'マップルは地図記号が大好きな狐耳の探検少年。\n'
        'コンパスと地図を片手に、日本中どこでも歩き回っているんだって。\n'
        '「記号を覚えると、地図が読めるようになるよ！」と\n'
        'マップルはいつも教えてくれるんだ。',
    stampPhrases: [
      '地図読めた！',
      'どこでも分かる',
      'マップルと一緒に',
      '記号覚えた！',
      '地図が好き！',
      'ありがとう！',
      'また地図ひろう',
      '場所を探せ',
    ],
  ),

  BaseCharacter(
    id: 'yukina',
    name: 'ユキナ',
    emoji: '🐇',
    tier: 1,
    unlockAt: 3,
    subject: '北海道・東北',
    imageAsset: 'assets/characters/yukina.png',
    levelImages: {
      2: 'assets/characters/yukina_lv2.png',
      3: 'assets/characters/yukina_lv3.png',
      4: 'assets/characters/yukina_lv4.png',
      5: 'assets/characters/yukina_lvmax.png',
    },
    backstory:
        'ユキナは雪と氷が大好きな雪うさぎ。\n'
        '北海道の広い大地や東北の祭りが大のお気に入り。\n'
        '「北の地方には素敵なものがたくさんあるよ！」と\n'
        'いつも元気いっぱい教えてくれる。',
    stampPhrases: [
      '北へ行こう！',
      '雪が好き！',
      'がんばったよ',
      '東北最高！',
      'また来てね',
      'すごいでしょ',
      '北国の風',
      'やったね！',
    ],
  ),

  BaseCharacter(
    id: 'haruka',
    name: 'はるか',
    emoji: '🌸',
    tier: 1,
    unlockAt: 6,
    subject: '関東・中部',
    imageAsset: 'assets/characters/haruka.png',
    levelImages: {
      2: 'assets/characters/haruka_lv2.png',
      3: 'assets/characters/haruka_lv3.png',
      4: 'assets/characters/haruka_lv4.png',
      5: 'assets/characters/haruka_lvmax.png',
    },
    backstory:
        'はるかは春の花と関東・中部地方が大好きな女の子。\n'
        '東京の賑やかさも、富士山の雄大さも大好きだよ。\n'
        '「関東と中部を覚えたら、日本がもっと好きになるよ！」と\n'
        'はるかはやさしく教えてくれる。',
    stampPhrases: [
      '春が来たよ！',
      '関東大好き！',
      '富士山見えた',
      'はるかと学ぼ',
      'やさしいね',
      '花みたいに',
      'もっと頑張る',
      '一緒に覚えよ',
    ],
  ),

  BaseCharacter(
    id: 'miyabi',
    name: 'みやび',
    emoji: '🏯',
    tier: 1,
    unlockAt: 9,
    subject: '近畿・中国・四国',
    imageAsset: 'assets/characters/miyabi.png',
    levelImages: {
      2: 'assets/characters/miyabi_lv2.png',
      3: 'assets/characters/miyabi_lv3.png',
      4: 'assets/characters/miyabi_lv4.png',
      5: 'assets/characters/miyabi_lvmax.png',
    },
    backstory:
        'みやびはお城と歴史ある町が大好きな狐の妖精。\n'
        '近畿・中国・四国には昔からの文化がたくさんあるんだって。\n'
        '「西の地方の魅力をぜひ知ってほしいな！」と\n'
        'みやびはいつも笑顔で話してくれる。',
    stampPhrases: [
      'お城が好き！',
      '西日本最高',
      'みやびここだよ',
      '歴史あるよ',
      'また会おうね',
      '四国も行こう',
      'すごく楽しい',
      '覚えてくれた',
    ],
  ),

  // ─── Tier 2（小4-5年向け） ────────────────────────────────────────────────

  BaseCharacter(
    id: 'minori',
    name: 'みのり',
    emoji: '🌾',
    tier: 2,
    unlockAt: 13,
    subject: '農業',
    imageAsset: 'assets/characters/minori.png',
    levelImages: {
      2: 'assets/characters/minori_lv2.png',
      3: 'assets/characters/minori_lv3.png',
      4: 'assets/characters/minori_lv4.png',
      5: 'assets/characters/minori_lvmax.png',
    },
    backstory:
        'みのりは田んぼや畑が大好きな元気な案山子の男の子。\n'
        '日本の農業がどこでどんな作物を育てているか、よく知っているよ。\n'
        '「食べ物はどこから来るか、一緒に調べようよ！」と\n'
        'みのりはいつも声をかけてくれる。',
    stampPhrases: [
      '農業大好き！',
      '育ててみよう',
      '収穫できたよ',
      'みのりにまかせ',
      '田んぼは楽し',
      'おいしいね',
      '野菜が好き！',
      '土の匂いだ',
    ],
  ),

  BaseCharacter(
    id: 'namika',
    name: 'なみか',
    emoji: '🐬',
    tier: 2,
    unlockAt: 16,
    subject: '水産業',
    imageAsset: 'assets/characters/namika.png',
    levelImages: {
      2: 'assets/characters/namika_lv2.png',
      3: 'assets/characters/namika_lv3.png',
      4: 'assets/characters/namika_lv4.png',
      5: 'assets/characters/namika_lvmax.png',
    },
    backstory:
        'なみかは海と魚が大好きな元気ないるか。\n'
        '日本の漁業や海の幸についてとても詳しいんだよ。\n'
        '「日本は海に囲まれた国だから、水産業がとても大切なんだ！」と\n'
        'なみかは誇らしそうに教えてくれる。',
    stampPhrases: [
      '海が大好き！',
      '魚とれたよ',
      '漁業ってすごい',
      'なみかと泳ごう',
      '海の幸だよ',
      '元気な魚だ',
      'また行こうね',
      '海は広いよ',
    ],
  ),

  BaseCharacter(
    id: 'geana',
    name: 'ギアナ',
    emoji: '🤖',
    tier: 2,
    unlockAt: 19,
    subject: '工業・工業地帯',
    imageAsset: 'assets/characters/geana.png',
    levelImages: {
      2: 'assets/characters/geana_lv2.png',
      3: 'assets/characters/geana_lv3.png',
      4: 'assets/characters/geana_lv4.png',
      5: 'assets/characters/geana_lvmax.png',
    },
    backstory:
        'ギアナは機械や工場が大好きな小型ロボット。\n'
        '日本の工業地帯がどこにあって、何を作っているか知っているよ。\n'
        '「ものづくりの大切さをみんなに知ってほしい！」と\n'
        'ギアナはいつも力強く語ってくれる。',
    stampPhrases: [
      '工業が好き！',
      'ものづくりだ',
      'すごい工場だ',
      'ギアナ参上',
      '作ってみよう',
      '機械は面白い',
      '力をあわせて',
      'できあがった！',
    ],
  ),

  BaseCharacter(
    id: 'michiru',
    name: 'みちる',
    emoji: '🚄',
    tier: 2,
    unlockAt: 22,
    subject: '交通・情報化',
    imageAsset: 'assets/characters/michiru.png',
    levelImages: {
      2: 'assets/characters/michiru_lv2.png',
      3: 'assets/characters/michiru_lv3.png',
      4: 'assets/characters/michiru_lv4.png',
      5: 'assets/characters/michiru_lvmax.png',
    },
    backstory:
        'みちるは道路や交通手段が大好きな新幹線の精霊。\n'
        '新幹線・高速道路・インターネットなど、つながる世界に夢中だよ。\n'
        '「情報と交通が発達すると、生活がもっと便利になるんだよ！」と\n'
        'みちるは速足で教えてくれる。',
    stampPhrases: [
      '交通大好き！',
      '新幹線速い！',
      'つながってるね',
      'みちると走ろ',
      '情報は大事',
      'どこへでも行く',
      '便利になった',
      '次の駅だよ！',
    ],
  ),

  // ─── Tier 3（小5-6年向け） ────────────────────────────────────────────────

  BaseCharacter(
    id: 'fumika',
    name: 'ふみか',
    emoji: '📜',
    tier: 3,
    unlockAt: 25,
    subject: '古代・中世の歴史',
    imageAsset: 'assets/characters/fumika.png',
    levelImages: {
      2: 'assets/characters/fumika_lv2.png',
      3: 'assets/characters/fumika_lv3.png',
      4: 'assets/characters/fumika_lv4.png',
      5: 'assets/characters/fumika_lvmax.png',
    },
    backstory:
        'ふみかは古い巻物と歴史が大好きな知恵深い女の子。\n'
        '縄文・弥生時代から鎌倉幕府まで、何でも知っているよ。\n'
        '「昔の人がどんな暮らしをしていたか、一緒に旅しよう！」と\n'
        'ふみかは静かに語りかけてくれる。',
    stampPhrases: [
      '歴史は楽しい',
      '古代の謎だ',
      'ふみかに聞いて',
      '時をこえてく',
      '知恵をかしてね',
      '昔はすごかった',
      '学んでくれてる',
      '巻物広げよう',
    ],
  ),

  BaseCharacter(
    id: 'tsubaki',
    name: 'つばき',
    emoji: '⚔️',
    tier: 3,
    unlockAt: 28,
    subject: '江戸・幕末',
    imageAsset: 'assets/characters/tsubaki.png',
    levelImages: {
      2: 'assets/characters/tsubaki_lv2.png',
      3: 'assets/characters/tsubaki_lv3.png',
      4: 'assets/characters/tsubaki_lv4.png',
      5: 'assets/characters/tsubaki_lvmax.png',
    },
    backstory:
        'つばきは刀と武士道が大好きな勇敢な少年侍。\n'
        '江戸時代の武士の暮らしや幕末の変化に詳しいんだよ。\n'
        '「幕末には日本が大きく変わったんだ、勇気をもって学ぼう！」と\n'
        'つばきは凛々しく語ってくれる。',
    stampPhrases: [
      '侍の心だ！',
      '江戸は面白い',
      '幕末を学ぼ',
      'つばきと戦え',
      '勇気を出して',
      '剣より知恵だ',
      'やりとげたよ',
      '武士道精神',
    ],
  ),

  BaseCharacter(
    id: 'haikara',
    name: 'はいから',
    emoji: '🎩',
    tier: 3,
    unlockAt: 31,
    subject: '明治・近代',
    imageAsset: 'assets/characters/haikara.png',
    levelImages: {
      2: 'assets/characters/haikara_lv2.png',
      3: 'assets/characters/haikara_lv3.png',
      4: 'assets/characters/haikara_lv4.png',
      5: 'assets/characters/haikara_lvmax.png',
    },
    backstory:
        'はいからはシルクハットと洋服が大好きなおしゃれな紳士。\n'
        '明治時代に日本がどう変わっていったか、よく知っているよ。\n'
        '「近代化って面白いんだよ！みんなもたくさん学んでね！」と\n'
        'はいからは元気に教えてくれる。',
    stampPhrases: [
      '明治は近代だ',
      '日本が変わった',
      'はいから参上',
      'おしゃれでしょ',
      '新しい時代だ',
      '学んで成長',
      '歴史は続くよ',
      '近代化すごい',
    ],
  ),

  BaseCharacter(
    id: 'tera',
    name: 'テラ',
    emoji: '🌍',
    tier: 3,
    unlockAt: 34,
    subject: '国際・世界地理',
    imageAsset: 'assets/characters/tera.png',
    levelImages: {
      2: 'assets/characters/tera_lv2.png',
      3: 'assets/characters/tera_lv3.png',
      4: 'assets/characters/tera_lv4.png',
      5: 'assets/characters/tera_lvmax.png',
    },
    backstory:
        'テラは地球儀と世界地図が大好きな地球の精霊。\n'
        '世界の国々の場所や文化についてとても詳しいんだよ。\n'
        '「日本だけじゃなく、世界を知るともっと広い視野が持てるよ！」と\n'
        'テラは夢をもって語ってくれる。',
    stampPhrases: [
      '世界は広い！',
      '国際大好き！',
      '地球を旅しよ',
      'テラだよ',
      '友達になろう',
      '世界はつながる',
      'もっと知りたい',
      '地図を広げて',
    ],
  ),

  // ─── Tier 4（小6年・全制覇向け） ──────────────────────────────────────────

  BaseCharacter(
    id: 'seigi',
    name: 'せいぎ',
    emoji: '🦉',
    tier: 4,
    unlockAt: 38,
    subject: '憲法・三権分立',
    imageAsset: 'assets/characters/seigi.png',
    levelImages: {
      2: 'assets/characters/seigi_lv2.png',
      3: 'assets/characters/seigi_lv3.png',
      4: 'assets/characters/seigi_lv4.png',
      5: 'assets/characters/seigi_lvmax.png',
    },
    backstory:
        'せいぎは法律と権利が大好きな正義感あふれるふくろう。\n'
        '日本国憲法や三権分立のしくみをしっかり学んでいるよ。\n'
        '「みんなの権利を守るために、憲法をちゃんと知ってほしいな！」と\n'
        'せいぎは真剣な顔で語りかけてくれる。',
    stampPhrases: [
      '権利を守るぞ',
      '憲法大事だよ',
      '三権わかった！',
      'せいぎ見てて',
      '正義のために',
      '法律を学ぼう',
      '公平が一番',
      'みんなで守ろう',
    ],
  ),

  BaseCharacter(
    id: 'takara',
    name: 'たから',
    emoji: '🦝',
    tier: 4,
    unlockAt: 41,
    subject: '税金・選挙',
    imageAsset: 'assets/characters/takara.png',
    levelImages: {
      2: 'assets/characters/takara_lv2.png',
      3: 'assets/characters/takara_lv3.png',
      4: 'assets/characters/takara_lv4.png',
      5: 'assets/characters/takara_lvmax.png',
    },
    backstory:
        'たからはお金と社会のしくみが大好きな賢いたぬき。\n'
        '税金がどう使われるか、選挙の大切さをよく知っているよ。\n'
        '「税金と選挙を知ると、社会の一員になれるんだよ！」と\n'
        'たからは丁寧に説明してくれる。',
    stampPhrases: [
      '税金わかった',
      '選挙に行こう',
      'たからに聞いて',
      'お金は大事だ',
      '社会のしくみ',
      '一票が大切',
      '賢く学ぼう',
      'みんなのお金',
    ],
  ),

  BaseCharacter(
    id: 'michinori',
    name: 'みちのり',
    emoji: '🕊️',
    tier: 4,
    unlockAt: 44,
    subject: '都道府県マスター',
    imageAsset: 'assets/characters/michinori.png',
    levelImages: {
      2: 'assets/characters/michinori_lv2.png',
      3: 'assets/characters/michinori_lv3.png',
      4: 'assets/characters/michinori_lv4.png',
      5: 'assets/characters/michinori_lvmax.png',
    },
    backstory:
        'みちのりは47都道府県すべてを愛している旅する鶴。\n'
        '形も場所も特産物も、ぜんぶ頭に入っているんだって。\n'
        '「47都道府県を全部覚えたあなたはもう地理の達人だよ！」と\n'
        'みちのりは誇らしそうに羽を広げてくれる。',
    stampPhrases: [
      '47制覇だ！',
      '都道府県完璧',
      'みちのりと旅しよ',
      'どこでも行ける',
      '地図が読める',
      '全国制覇！',
      'あなたは達人',
      '日本が好き！',
    ],
  ),

  BaseCharacter(
    id: 'shakai_star',
    name: 'シャカイスター',
    emoji: '🌟',
    tier: 4,
    unlockAt: 47,
    subject: '社会科完全マスター',
    imageAsset: 'assets/characters/shakai_star.png',
    levelImages: {
      2: 'assets/characters/shakai_star_lv2.png',
      3: 'assets/characters/shakai_star_lv3.png',
      4: 'assets/characters/shakai_star_lv4.png',
      5: 'assets/characters/shakai_star_lvmax.png',
    },
    backstory:
        'シャカイスターはすべての社会科をマスターした伝説の存在。\n'
        '地理・歴史・公民のすべてを極めた真の社会科の達人だよ。\n'
        '「47都道府県を完全制覇したあなたは、本当にすごい！」と\n'
        'シャカイスターは輝きながら称えてくれる。',
    stampPhrases: [
      '完全マスター！',
      '社会科最強だ',
      '星が輝くよ',
      '伝説になった',
      '全部覚えたね',
      'あなたが一番',
      'ありがとう！',
      '一緒に輝こう',
    ],
  ),
];
