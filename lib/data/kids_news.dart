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
  KidsNews(
    title: '🗻 富士山、世界文化遺産に登録されて10年以上',
    emoji: '🗻',
    description:
        '富士山（ふじさん、3776m）は日本一高い山で、世界文化遺産です。'
        '静岡県と山梨県にまたがっていて、多くの登山者や観光客が訪れます。',
    relevantCategory: '日本地理',
  ),
  KidsNews(
    title: '🐟 日本近海の漁業を守る取り組み',
    emoji: '🎣',
    description:
        '日本は周りを海に囲まれた島国で、漁業（ぎょぎょう）がさかんです。'
        '魚を取りすぎないように「持続可能な漁業」が世界で進められています。',
    relevantCategory: '産業・水産業',
  ),
  KidsNews(
    title: '🏫 小学校でプログラミング教育が必修に',
    emoji: '💻',
    description:
        '2020年から小学校でプログラミング教育が始まりました。'
        '未来の情報化社会（じょうほうかしゃかい）に対応する力を育てています。',
    relevantCategory: '公民・情報化社会',
  ),
  KidsNews(
    title: '🌋 火山と共に生きる日本の暮らし',
    emoji: '🌋',
    description:
        '日本には多くの活火山（かつかざん）があります。'
        '温泉や地熱発電など、火山の恵みを生活に生かす工夫もされています。',
    relevantCategory: '日本地理・防災',
  ),
  KidsNews(
    title: '🌏 世界の人口が増え続けている',
    emoji: '🌏',
    description:
        '世界の人口は約80億人をこえました。'
        '食料や水をどう分け合うかが、世界共通の課題になっています。',
    relevantCategory: '世界地理・国際',
  ),
  KidsNews(
    title: '⚖️ 三権分立ってなに？',
    emoji: '⚖️',
    description:
        '日本の政治は「国会・内閣・裁判所」の3つに分かれて仕事をしています。'
        'これを三権分立（さんけんぶんりつ）といい、権力の集中を防ぎます。',
    relevantCategory: '公民・政治',
  ),
  KidsNews(
    title: '🏗️ 地震に強いまちづくり',
    emoji: '🏗️',
    description:
        '日本は地震が多い国です。建物の耐震（たいしん）技術や防災訓練など'
        '地震に強いまちづくりが各地で進められています。',
    relevantCategory: '日本地理・防災',
  ),
  KidsNews(
    title: '🚢 貿易でつながる世界の国々',
    emoji: '🚢',
    description:
        '日本は資源の少ない国なので、多くの原料を輸入（ゆにゅう）し、'
        '製品を輸出（ゆしゅつ）しています。貿易は経済の大切な仕組みです。',
    relevantCategory: '経済・貿易',
  ),
  KidsNews(
    title: '🐘 動物園で希少動物の保護活動',
    emoji: '🐘',
    description:
        '世界には絶滅（ぜつめつ）の危機にある動物がたくさんいます。'
        '動物園や研究者が協力して、希少な動物を守る活動を続けています。',
    relevantCategory: '世界地理・環境',
  ),
  KidsNews(
    title: '🗳️ 選挙権年齢が18歳に引き下げ',
    emoji: '🗳️',
    description:
        '2016年から選挙（せんきょ）に参加できる年齢が18歳になりました。'
        '自分たちの意見を政治に届ける大切な権利です。',
    relevantCategory: '公民・選挙',
  ),
  KidsNews(
    title: '🏔️ 日本アルプスの豊かな自然',
    emoji: '🏔️',
    description:
        '長野県・岐阜県などにまたがる「日本アルプス」は3000m級の山々が連なります。'
        '豊かな自然が観光や水資源を支えています。',
    relevantCategory: '日本地理',
  ),
  KidsNews(
    title: '💰 税金はなんのためにあるの？',
    emoji: '💰',
    description:
        '税金（ぜいきん）は学校や道路、病院などみんなのために使われるお金です。'
        '国や都道府県、市区町村がいろいろな税金を集めています。',
    relevantCategory: '公民・経済',
  ),
  KidsNews(
    title: '🍊 果物の産地、それぞれの特色',
    emoji: '🍊',
    description:
        '愛媛県はみかん、山梨県はぶどう・もも、青森県はりんごが有名です。'
        '気候や土地の特徴に合わせて、各地で特産の果物が作られています。',
    relevantCategory: '日本地理・産業',
  ),
  KidsNews(
    title: '🏯 世界に誇る日本の城めぐり',
    emoji: '🏯',
    description:
        '姫路城や熊本城など、日本各地には歴史ある城がたくさんあります。'
        '城は昔の戦国大名の権力の象徴であり、今は人気の観光地です。',
    relevantCategory: '歴史・観光',
  ),
  KidsNews(
    title: '♻️ ごみを減らす3Rの合言葉',
    emoji: '♻️',
    description:
        'リデュース（減らす）・リユース（再利用）・リサイクル（再資源化）の'
        '「3R」を意識することで、ごみの量を減らすことができます。',
    relevantCategory: '環境・SDGs',
  ),
  KidsNews(
    title: '🌐 情報化社会とわたしたちの暮らし',
    emoji: '📱',
    description:
        'インターネットやスマートフォンの普及で、情報化社会が進んでいます。'
        '便利になった一方で、正しい情報を見分ける力も大切です。',
    relevantCategory: '公民・情報化社会',
  ),
];
