class KidsNews {
  final String title;
  final String emoji;
  final String description;
  final String relevantCategory;

  const KidsNews({
    required this.title,
    required this.emoji,
    required this.description,
    required this.relevantCategory,
  });
}

const List<KidsNews> kidsNewsList = [
  KidsNews(
    title: '🏔️ エベレスト、新年の登頂ラッシュ',
    emoji: '⛰️',
    description:
        '世界最高峰のエベレスト山（8849m）に毎年何千人もの登山家が挑戦します。'
        'エベレストはネパールとチベットの国境にあります。',
    relevantCategory: '世界地理',
  ),
  KidsNews(
    title: '🐼 パンダの赤ちゃんが誕生！',
    emoji: '🐼',
    description:
        'ジャイアントパンダは中国に住む貴重な動物です。'
        'パンダは絶滅の危機（ぜつめつのきき）から守られています。',
    relevantCategory: '世界地理・環境',
  ),
  KidsNews(
    title: '🚄 日本の新幹線、世界で活躍中',
    emoji: '🚄',
    description:
        '日本の新幹線（しんかんせん）技術は世界で最も進んでいます。'
        '台湾やインドでも日本の新幹線が走っています。',
    relevantCategory: '産業・技術',
  ),
  KidsNews(
    title: '🌾 稲刈りの季節がやってきた',
    emoji: '🌾',
    description:
        '秋は日本の農業で最も大切な季節です。'
        '米・蕎麦（そば）・野菜など、たくさんの食べ物が収穫されます。',
    relevantCategory: '産業・農業',
  ),
  KidsNews(
    title: '🌲 森の日、環境を守ろう！',
    emoji: '🌳',
    description:
        '日本には約67%が森林（しんりん）です。'
        'スギ・ヒノキなどの木は建材やパルプになり、生活に欠かせません。',
    relevantCategory: '環境・SDGs',
  ),
  KidsNews(
    title: '⚡ 再生可能エネルギーが増えている',
    emoji: '☀️',
    description:
        '太陽光・風力などの再生可能エネルギーが世界中で注目されています。'
        'これで地球温暖化（ちきゅうおんだんか）を防ぐことができます。',
    relevantCategory: '環境・SDGs',
  ),
  KidsNews(
    title: '🗾 地元の伝統文化を守ろう',
    emoji: '🎌',
    description:
        '日本全国には祭りや伝統工芸（でんとうこうげい）がたくさんあります。'
        'これらは代々受け継がれている大切な文化（ぶんか）です。',
    relevantCategory: '歴史・文化',
  ),
  KidsNews(
    title: '🏛️ 憲法記念日 — 日本の大切なルール',
    emoji: '📜',
    description:
        '日本国憲法（けんぽう）は1947年に始まった日本の大切なルールです。'
        '憲法で、国民の権利（けんり）や自由が守られています。',
    relevantCategory: '公民・政治',
  ),
  KidsNews(
    title: '🌍 SDGs — 世界中が協力する目標',
    emoji: '🎯',
    description:
        'SDGs（エス・ディー・ジーズ）は国連が決めた17の大切な目標です。'
        '貧困をなくす・環境を守る・質の良い教育など、世界中で取り組まれています。',
    relevantCategory: '環境・SDGs',
  ),
  KidsNews(
    title: '🏭 工業地帯の役割を学ぼう',
    emoji: '🏗️',
    description:
        '日本の工業は世界的に有名です。自動車・電化製品・医療機器など'
        'たくさんの製品が日本から世界中に輸出（ゆしゅつ）されています。',
    relevantCategory: '産業・工業',
  ),
  KidsNews(
    title: '🍱 日本の食文化が世界で人気',
    emoji: '🍜',
    description:
        '寿司・天ぷら・味噌汁（みそしる）など日本の食べ物が世界で人気です。'
        '日本の食文化はユネスコ無形文化遺産（ぶんかいさん）に登録されています。',
    relevantCategory: '文化・産業',
  ),
  KidsNews(
    title: '🚗 EV自動車の時代へ',
    emoji: '⚡',
    description:
        '電気自動車（でんきじどうしゃ）EV が世界で増えています。'
        'ガソリン車から環境にやさしい電気車へ、産業が変わっています。',
    relevantCategory: '産業・環境',
  ),
  KidsNews(
    title: '🌊 海のゴミ問題を解決しよう',
    emoji: '🐠',
    description:
        'プラスチックゴミが海に流れ込み、魚や海の生き物が苦しんでいます。'
        'わたしたちも毎日の生活で「3R」を意識して行動できます。',
    relevantCategory: '環境・SDGs',
  ),
];
