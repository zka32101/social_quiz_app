import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../repositories/progress_repository.dart';
import '../../utils/constants.dart';

// ─── Data models ─────────────────────────────────────────────────────────────

class KeyPerson {
  final String name;
  final String reading;
  final String description;
  const KeyPerson({
    required this.name,
    required this.reading,
    required this.description,
  });
}

class EraQuiz {
  final String question;
  final List<String> choices;
  final int correctIndex;
  final String explanation;
  const EraQuiz({
    required this.question,
    required this.choices,
    required this.correctIndex,
    required this.explanation,
  });
}

class EraDetail {
  final String id;
  final String name;
  final String reading;
  final String emoji;
  final String period;
  final String description;
  final List<KeyPerson> keyPersons;
  final List<String> keyEvents;
  final List<EraQuiz> quizzes;
  const EraDetail({
    required this.id,
    required this.name,
    required this.reading,
    required this.emoji,
    required this.period,
    required this.description,
    required this.keyPersons,
    required this.keyEvents,
    required this.quizzes,
  });
}

// ─── Era content database ─────────────────────────────────────────────────────

final Map<String, EraDetail> _eraData = {
  'jomon': const EraDetail(
    id: 'jomon',
    name: '縄文時代',
    reading: 'じょうもんじだい',
    emoji: '🪨',
    period: '約14000〜300年前（紀元前）',
    description:
        '縄文時代は今から約14000年前から始まった、日本でもっとも長い時代です。'
        'この時代の人々は狩りや魚とり、木の実や山菜を集めて生活していました。'
        '縄目のもようがついた「縄文土器」を作り、料理や食べ物の保存に使っていました。'
        'たて穴住居（地面を掘って作った家）に住み、集落を作って暮らしていました。',
    keyPersons: [],
    keyEvents: [
      '縄文土器の使用開始',
      'たて穴住居での集落生活',
      '狩猟・採集・漁による生活',
      '三内丸山遺跡（青森県）など大規模集落の形成',
    ],
    quizzes: [
      EraQuiz(
        question: '縄文時代の人々はどのような生活をしていましたか？',
        choices: ['農業で米を育てた', '狩りや魚とり・木の実を集めた', '工場で働いた', '船で外国と貿易した'],
        correctIndex: 1,
        explanation: '縄文時代の人々は農業ではなく、狩り・漁・採集（きのみや山菜を集めること）で生活していました。',
      ),
      EraQuiz(
        question: '縄文時代に作られた土器の名前は？',
        choices: ['弥生土器', '縄文土器', '埴輪（はにわ）', '青銅器'],
        correctIndex: 1,
        explanation: '縄目もようがついた「縄文土器」が作られました。料理や食べ物の保存に使われました。',
      ),
      EraQuiz(
        question: '縄文時代の家はどのような形でしたか？',
        choices: ['高いビル', '城（お城）', 'たて穴住居', 'テント'],
        correctIndex: 2,
        explanation: '地面を掘って柱を立てた「たて穴住居」に住んでいました。屋根は草などで作られていました。',
      ),
    ],
  ),

  'yayoi': const EraDetail(
    id: 'yayoi',
    name: '弥生時代',
    reading: 'やよいじだい',
    emoji: '🌾',
    period: '約紀元前300年〜紀元後300年',
    description:
        '弥生時代は中国や朝鮮半島から稲作の技術が伝わり、米づくりが広まった時代です。'
        '米を育てることで食べ物が安定して手に入るようになり、人々の生活が大きく変わりました。'
        '薄くてかたい「弥生土器」や、金属でできた銅剣・銅鐸（どうたく）なども作られるようになりました。'
        '稲作をめぐって村どうしの争いが起きるようになり、むらのリーダーも生まれました。',
    keyPersons: [
      KeyPerson(
        name: '卑弥呼',
        reading: 'ひみこ',
        description: '邪馬台国（やまたいこく）の女王。まじないで国をまとめた',
      ),
    ],
    keyEvents: [
      '大陸から稲作・金属器の技術が伝来',
      '弥生土器の使用',
      '銅鐸・銅剣などの青銅器の製作',
      '邪馬台国の成立と卑弥呼の統治',
    ],
    quizzes: [
      EraQuiz(
        question: '弥生時代に広まった農業といえば？',
        choices: ['麦（むぎ）づくり', '米づくり（稲作）', 'いもづくり', 'とうもろこしづくり'],
        correctIndex: 1,
        explanation: '弥生時代に大陸から稲作が伝わり、米づくりが広まりました。',
      ),
      EraQuiz(
        question: '邪馬台国の女王の名前は？',
        choices: ['推古天皇', '卑弥呼', '持統天皇', '北条政子'],
        correctIndex: 1,
        explanation: '邪馬台国の女王「卑弥呼（ひみこ）」が、まじないの力で多くの国をまとめていました。',
      ),
      EraQuiz(
        question: '弥生時代に大陸から伝わったものは？',
        choices: ['自動車', '稲作と金属器', '電気', '写真機'],
        correctIndex: 1,
        explanation: '稲作（米づくり）と鉄器・青銅器などの金属器の技術が大陸から伝わりました。',
      ),
    ],
  ),

  'kofun': const EraDetail(
    id: 'kofun',
    name: '古墳時代',
    reading: 'こふんじだい',
    emoji: '🏔️',
    period: '約300〜593年',
    description:
        '古墳時代は王や豪族（ごうぞく）を葬るために巨大な「古墳（こふん）」が作られた時代です。'
        '大阪府にある大仙古墳（仁徳天皇陵）は全長500メートルを超える世界最大級の古墳です。'
        '古墳の周りには「埴輪（はにわ）」という土でできた人や動物の形の飾りが並べられました。'
        'この時代に大和地方（今の奈良県）を中心とした大和朝廷が力をのばしていきました。',
    keyPersons: [
      KeyPerson(
        name: '仁徳天皇',
        reading: 'にんとくてんのう',
        description: '大仙古墳に葬られたとされる大王（おおきみ）',
      ),
    ],
    keyEvents: [
      '前方後円墳など大型古墳の建設',
      '大仙古墳（仁徳天皇陵）の建設',
      '埴輪・鏡・剣などの副葬品',
      '大和朝廷の成立と全国統一へ',
    ],
    quizzes: [
      EraQuiz(
        question: '古墳時代に作られた、王の墓の名前は？',
        choices: ['ピラミッド', '古墳（こふん）', 'お寺', '城（しろ）'],
        correctIndex: 1,
        explanation: '古墳は王や豪族の大きなお墓です。前方後円墳（ぜんぽうこうえんふん）が代表的な形です。',
      ),
      EraQuiz(
        question: '古墳の周りに並べられた土でできた飾りは？',
        choices: ['銅鐸（どうたく）', '埴輪（はにわ）', '土器（どき）', '鏡（かがみ）'],
        correctIndex: 1,
        explanation: '人や馬・家などの形をした「埴輪（はにわ）」が古墳の周りに並べられていました。',
      ),
      EraQuiz(
        question: '日本最大の古墳がある都道府県は？',
        choices: ['東京都', '奈良県', '大阪府', '京都府'],
        correctIndex: 2,
        explanation: '全長500メートルを超える大仙古墳（仁徳天皇陵）は大阪府堺市にあります。',
      ),
    ],
  ),

  'asuka': const EraDetail(
    id: 'asuka',
    name: '飛鳥時代',
    reading: 'あすかじだい',
    emoji: '🕊️',
    period: '593〜710年',
    description:
        '飛鳥時代は聖徳太子（しょうとくたいし）が活躍し、仏教が広まった時代です。'
        '聖徳太子は十七条の憲法を作って国のルールを整え、遣隋使（けんずいし）を送って中国から文化や政治を学びました。'
        '645年には中大兄皇子（なかのおおえのみこ）と中臣鎌足（なかとみのかまたり）が「大化の改新」をおこない、天皇中心の国づくりを進めました。'
        '法隆寺（ほうりゅうじ）は聖徳太子が建てた世界最古の木造建築として有名です。',
    keyPersons: [
      KeyPerson(
        name: '聖徳太子',
        reading: 'しょうとくたいし',
        description: '十七条の憲法を作り、仏教を広めた政治家',
      ),
      KeyPerson(
        name: '中大兄皇子',
        reading: 'なかのおおえのみこ',
        description: '大化の改新を行い、後の天智天皇',
      ),
      KeyPerson(
        name: '中臣鎌足',
        reading: 'なかとみのかまたり',
        description: '大化の改新で中大兄皇子を助けた。藤原氏の祖先',
      ),
    ],
    keyEvents: [
      '593年 聖徳太子が摂政になる',
      '十七条の憲法の制定',
      '遣隋使の派遣',
      '645年 大化の改新',
      '法隆寺の建立',
    ],
    quizzes: [
      EraQuiz(
        question: '十七条の憲法を作ったのは誰ですか？',
        choices: ['徳川家康', '聖徳太子', '織田信長', '源頼朝'],
        correctIndex: 1,
        explanation: '聖徳太子が「十七条の憲法」を作り、役人の心がけや国のルールを定めました。',
      ),
      EraQuiz(
        question: '645年におこった、天皇中心の国づくりを目指した改革は？',
        choices: ['明治維新', '大政奉還', '大化の改新', '享保の改革'],
        correctIndex: 2,
        explanation: '中大兄皇子と中臣鎌足が協力して「大化の改新」を行い、新しい政治の仕組みを作りました。',
      ),
      EraQuiz(
        question: '聖徳太子が建てた、世界最古の木造建築は？',
        choices: ['東大寺', '金閣寺', '法隆寺', '清水寺'],
        correctIndex: 2,
        explanation: '奈良県にある「法隆寺（ほうりゅうじ）」は聖徳太子が建てた世界最古の木造建築です。',
      ),
    ],
  ),

  'nara': const EraDetail(
    id: 'nara',
    name: '奈良時代',
    reading: 'ならじだい',
    emoji: '🦌',
    period: '710〜794年',
    description:
        '奈良時代は奈良に都（みやこ）が置かれ、仏教の力で国をまとめようとした時代です。'
        '聖武天皇（しょうむてんのう）は仏教を広め、全国に国分寺（こくぶんじ）を建て、奈良には大仏を作らせました。'
        '東大寺の大仏（だいぶつ）は高さ約15メートルで、完成するまでに多くの人々が協力しました。'
        '万葉集（まんようしゅう）という日本最古の和歌集もこの時代に編まれました。',
    keyPersons: [
      KeyPerson(
        name: '聖武天皇',
        reading: 'しょうむてんのう',
        description: '仏教で国を守ろうと東大寺の大仏を建てた天皇',
      ),
      KeyPerson(
        name: '行基',
        reading: 'ぎょうき',
        description: '大仏建設で民衆から寄付を集めたお坊さん',
      ),
    ],
    keyEvents: [
      '710年 平城京（奈良）への遷都',
      '聖武天皇が全国に国分寺を建立',
      '752年 東大寺の大仏開眼供養',
      '万葉集の編さん',
    ],
    quizzes: [
      EraQuiz(
        question: '奈良時代に奈良に作られた都の名前は？',
        choices: ['平安京', '平城京', '江戸', '難波宮'],
        correctIndex: 1,
        explanation: '710年に「平城京（へいじょうきょう）」が完成し、奈良が日本の都になりました。',
      ),
      EraQuiz(
        question: '奈良の東大寺に大仏を作るように命じた天皇は？',
        choices: ['推古天皇', '聖武天皇', '桓武天皇', '天智天皇'],
        correctIndex: 1,
        explanation: '聖武天皇が仏教の力で国を守るために東大寺の大仏を作るよう命じました。',
      ),
      EraQuiz(
        question: '日本最古の和歌集の名前は？',
        choices: ['源氏物語', '枕草子', '万葉集', '古事記'],
        correctIndex: 2,
        explanation: '「万葉集（まんようしゅう）」は奈良時代に編まれた日本最古の和歌集で、約4500首の歌が収められています。',
      ),
    ],
  ),

  'heian': const EraDetail(
    id: 'heian',
    name: '平安時代',
    reading: 'へいあんじだい',
    emoji: '🌸',
    period: '794〜1185年',
    description:
        '平安時代は京都（きょうと）に都が置かれ、約400年間続いた長い時代です。'
        '藤原氏（ふじわらし）が天皇に代わって政治の実権をにぎる「摂関政治（せっかんせいじ）」が行われました。'
        '貴族の文化が花開き、紫式部（むらさきしきぶ）が「源氏物語」を、清少納言（せいしょうなごん）が「枕草子」を書きました。'
        'かな文字（ひらがな・カタカナ）もこの時代に広まり、日本独自の文化が発展しました。',
    keyPersons: [
      KeyPerson(
        name: '藤原道長',
        reading: 'ふじわらのみちなが',
        description: '摂関政治の頂点に立った最高権力者',
      ),
      KeyPerson(
        name: '紫式部',
        reading: 'むらさきしきぶ',
        description: '源氏物語を書いた女性作家',
      ),
      KeyPerson(
        name: '清少納言',
        reading: 'せいしょうなごん',
        description: '枕草子を書いた女性作家',
      ),
    ],
    keyEvents: [
      '794年 平安京（京都）への遷都',
      '藤原氏による摂関政治の全盛',
      '源氏物語・枕草子などの文学作品の誕生',
      'かな文字の普及',
      '1185年 平氏の滅亡・鎌倉幕府の成立へ',
    ],
    quizzes: [
      EraQuiz(
        question: '平安時代に都が置かれたのはどこですか？',
        choices: ['奈良', '東京', '京都', '大阪'],
        correctIndex: 2,
        explanation: '794年に桓武天皇が「平安京（へいあんきょう）」を作り、京都が都になりました。',
      ),
      EraQuiz(
        question: '「源氏物語」を書いた人物は？',
        choices: ['清少納言', '紫式部', '藤原道長', '推古天皇'],
        correctIndex: 1,
        explanation: '紫式部（むらさきしきぶ）が「源氏物語」を書きました。世界最古の長編小説の一つとされています。',
      ),
      EraQuiz(
        question: '平安時代に権力をにぎった一族は？',
        choices: ['徳川氏', '藤原氏', '源氏', '平家'],
        correctIndex: 1,
        explanation: '藤原氏が天皇の親族となり、摂政や関白として政治の実権をにぎりました。',
      ),
    ],
  ),

  'kamakura': const EraDetail(
    id: 'kamakura',
    name: '鎌倉時代',
    reading: 'かまくらじだい',
    emoji: '⚔️',
    period: '1185〜1336年',
    description:
        '鎌倉時代は源頼朝（みなもとのよりとも）が神奈川県の鎌倉に武家政権（幕府）を開いた時代です。'
        '武士が初めて国の政治を動かすようになり、将軍と御家人（ごけにん）が主従関係で結ばれました。'
        '1274年と1281年の二度にわたってモンゴル帝国（元）が攻めてきた「元寇（げんこう）」がありましたが、日本は撃退しました。'
        '法然・親鸞・日蓮など多くの仏教の宗派も鎌倉時代に誕生しました。',
    keyPersons: [
      KeyPerson(
        name: '源頼朝',
        reading: 'みなもとのよりとも',
        description: '鎌倉幕府を開いた初代将軍',
      ),
      KeyPerson(
        name: '北条時宗',
        reading: 'ほうじょうときむね',
        description: '元寇のとき幕府を率いて日本を守った執権',
      ),
    ],
    keyEvents: [
      '1185年 鎌倉幕府の成立',
      '守護・地頭の設置',
      '1274年 文永の役（元寇一度目）',
      '1281年 弘安の役（元寇二度目）',
      '鎌倉大仏の建立',
    ],
    quizzes: [
      EraQuiz(
        question: '鎌倉幕府を開いたのは誰ですか？',
        choices: ['源義経', '平清盛', '源頼朝', '足利尊氏'],
        correctIndex: 2,
        explanation: '源頼朝（みなもとのよりとも）が1185年に鎌倉幕府を開き、日本初の武家政権を作りました。',
      ),
      EraQuiz(
        question: '鎌倉時代にモンゴル帝国が日本に攻めてきたことを何といいますか？',
        choices: ['関ヶ原の戦い', '元寇（げんこう）', '壬申の乱', '応仁の乱'],
        correctIndex: 1,
        explanation: '1274年と1281年の二回、モンゴル帝国（元）が日本に攻めてきました。これを「元寇（げんこう）」といいます。',
      ),
      EraQuiz(
        question: '鎌倉幕府で将軍を補佐した役職は？',
        choices: ['摂政', '関白', '執権（しっけん）', '大老'],
        correctIndex: 2,
        explanation: '北条氏が「執権（しっけん）」という役職につき、将軍を補佐して幕府の実権をにぎりました。',
      ),
    ],
  ),

  'muromachi': const EraDetail(
    id: 'muromachi',
    name: '室町時代',
    reading: 'むろまちじだい',
    emoji: '🎭',
    period: '1336〜1573年',
    description:
        '室町時代は足利尊氏（あしかがたかうじ）が京都の室町に幕府を開いた時代です。'
        '足利義満（あしかがよしみつ）の時代に金閣寺が建てられ、日明貿易（にちみんぼうえき）で栄えました。'
        '足利義政（あしかがよしまさ）は銀閣寺を建て、わびさびの文化（能・狂言・茶道・生け花）が発達しました。'
        '1467年から「応仁の乱（おうにんのらん）」が起こり、戦国時代へと続く100年以上の乱れた時代が始まりました。',
    keyPersons: [
      KeyPerson(
        name: '足利義満',
        reading: 'あしかがよしみつ',
        description: '金閣寺を建て、室町幕府の全盛期を作った将軍',
      ),
      KeyPerson(
        name: '足利義政',
        reading: 'あしかがよしまさ',
        description: '銀閣寺を建て、東山文化を発展させた将軍',
      ),
    ],
    keyEvents: [
      '1336年 室町幕府の成立',
      '1397年 金閣寺の建立',
      '日明貿易の開始',
      '1467年 応仁の乱（戦国時代の始まり）',
      '1489年 銀閣寺の建立',
    ],
    quizzes: [
      EraQuiz(
        question: '室町幕府を開いた人物は？',
        choices: ['源頼朝', '足利尊氏', '徳川家康', '豊臣秀吉'],
        correctIndex: 1,
        explanation: '足利尊氏（あしかがたかうじ）が1336年に京都の室町に幕府を開きました。',
      ),
      EraQuiz(
        question: '足利義満が京都に建てたのは？',
        choices: ['銀閣寺', '清水寺', '金閣寺', '東大寺'],
        correctIndex: 2,
        explanation: '足利義満が1397年に「金閣寺（きんかくじ）」を建てました。三層の建物が金箔で飾られています。',
      ),
      EraQuiz(
        question: '1467年から始まった、戦国時代のきっかけになった争いは？',
        choices: ['関ヶ原の戦い', '応仁の乱', '壬申の乱', '元寇'],
        correctIndex: 1,
        explanation: '「応仁の乱（おうにんのらん）」が1467年に始まり、11年間続いた大きな争いが戦国時代のきっかけになりました。',
      ),
    ],
  ),

  'azuchi': const EraDetail(
    id: 'azuchi',
    name: '安土桃山時代',
    reading: 'あづちももやまじだい',
    emoji: '🏯',
    period: '1573〜1603年',
    description:
        '安土桃山時代は織田信長（おだのぶなが）と豊臣秀吉（とよとみひでよし）が天下統一を目指した時代です。'
        '織田信長は鉄砲を使って強い軍隊を作り、室町幕府を滅ぼしました。'
        '豊臣秀吉は信長の後を継いで全国を統一し、検地（土地の調査）と刀狩（農民の武器を取り上げる）を行いました。'
        '南蛮貿易（ヨーロッパとの貿易）が盛んになり、キリスト教も伝わりました。',
    keyPersons: [
      KeyPerson(
        name: '織田信長',
        reading: 'おだのぶなが',
        description: '鉄砲を活用し、室町幕府を倒した戦国武将',
      ),
      KeyPerson(
        name: '豊臣秀吉',
        reading: 'とよとみひでよし',
        description: '農民から出世し、全国統一を成し遂げた武将',
      ),
      KeyPerson(
        name: 'フランシスコ・ザビエル',
        reading: 'ふらんしすこ ざびえる',
        description: '日本にキリスト教を伝えたスペインの宣教師',
      ),
    ],
    keyEvents: [
      '1573年 室町幕府の滅亡',
      '1575年 長篠の戦い（鉄砲の大量使用）',
      '豊臣秀吉の全国統一',
      '太閤検地・刀狩の実施',
      'キリスト教・南蛮文化の流入',
    ],
    quizzes: [
      EraQuiz(
        question: '織田信長が活躍した時代に流行した武器は？',
        choices: ['大砲', '鉄砲（てっぽう）', '弓矢', '大刀'],
        correctIndex: 1,
        explanation: '織田信長は鉄砲（てっぽう）を大量に使う戦い方で、長篠の戦いなどに勝利しました。',
      ),
      EraQuiz(
        question: '農民から武器を取り上げる政策を何といいますか？',
        choices: ['検地（けんち）', '参勤交代', '刀狩（かたながり）', '廃藩置県'],
        correctIndex: 2,
        explanation: '豊臣秀吉は「刀狩（かたながり）」で農民から武器を取り上げ、武士と農民の身分をはっきり分けました。',
      ),
      EraQuiz(
        question: '豊臣秀吉が行った、土地の広さや収穫量を調べた政策は？',
        choices: ['参勤交代', '太閤検地（たいこうけんち）', '廃藩置県', '版籍奉還'],
        correctIndex: 1,
        explanation: '豊臣秀吉は「太閤検地（たいこうけんち）」で全国の土地の面積や収穫量を調べ、税を決めました。',
      ),
    ],
  ),

  'edo': const EraDetail(
    id: 'edo',
    name: '江戸時代',
    reading: 'えどじだい',
    emoji: '🗾',
    period: '1603〜1868年',
    description:
        '江戸時代は徳川家康が江戸（今の東京）に幕府を開いた時代です。'
        '約265年間、平和な時代が続きました。'
        '参勤交代という制度で大名が江戸と国を行き来し、庶民の文化（浮世絵・歌舞伎）も栄えました。'
        '外国との交流を制限する鎖国（さこく）を行い、長崎の出島でのみオランダ・中国と貿易しました。',
    keyPersons: [
      KeyPerson(
        name: '徳川家康',
        reading: 'とくがわいえやす',
        description: '江戸幕府を開いた初代将軍',
      ),
      KeyPerson(
        name: '徳川吉宗',
        reading: 'とくがわよしむね',
        description: '享保の改革をおこなった8代将軍',
      ),
    ],
    keyEvents: [
      '1603年 江戸幕府成立',
      '参勤交代制度の確立',
      '鎖国政策の実施',
      '元禄文化・化政文化の発展',
      '1868年 江戸幕府の終焉（大政奉還）',
    ],
    quizzes: [
      EraQuiz(
        question: '江戸幕府を開いたのは？',
        choices: ['豊臣秀吉', '徳川家康', '織田信長', '源頼朝'],
        correctIndex: 1,
        explanation: '徳川家康が1603年に江戸（現在の東京）に幕府を開きました。',
      ),
      EraQuiz(
        question: '江戸時代に大名が江戸と自分の国を行き来した制度は？',
        choices: ['鎖国', '参勤交代（さんきんこうたい）', '太閤検地', '廃藩置県'],
        correctIndex: 1,
        explanation: '「参勤交代（さんきんこうたい）」という制度で、大名は1年おきに江戸と自分の領地を行き来しなければなりませんでした。',
      ),
      EraQuiz(
        question: '江戸時代に外国との交流を制限した政策は？',
        choices: ['鎖国（さこく）', '開国', '日明貿易', '南蛮貿易'],
        correctIndex: 0,
        explanation: '江戸幕府は「鎖国（さこく）」を行い、長崎の出島でのみオランダと中国との貿易を許可しました。',
      ),
    ],
  ),

  'meiji': const EraDetail(
    id: 'meiji',
    name: '明治時代',
    reading: 'めいじじだい',
    emoji: '🚂',
    period: '1868〜1912年',
    description:
        '明治時代は江戸幕府が終わり、天皇を中心とした新しい政府が作られた時代です。'
        '欧米（ヨーロッパ・アメリカ）の技術や文化を積極的に取り入れる「文明開化（ぶんめいかいか）」が進みました。'
        '鉄道・電信・洋服・パンなど西洋の文化が日本に広まり、近代的な国家の仕組みが整いました。'
        '1889年には大日本帝国憲法が制定され、国会も開かれるようになりました。',
    keyPersons: [
      KeyPerson(
        name: '明治天皇',
        reading: 'めいじてんのう',
        description: '近代化を進めた天皇。五箇条の御誓文を発布',
      ),
      KeyPerson(
        name: '伊藤博文',
        reading: 'いとうひろぶみ',
        description: '大日本帝国憲法を作り、初代内閣総理大臣になった政治家',
      ),
      KeyPerson(
        name: '福沢諭吉',
        reading: 'ふくざわゆきち',
        description: '「学問のすゝめ」を書き、近代的な考え方を広めた思想家',
      ),
    ],
    keyEvents: [
      '1868年 明治維新（めいじいしん）',
      '廃藩置県（はいはんちけん）の実施',
      '文明開化・富国強兵・殖産興業',
      '1889年 大日本帝国憲法の発布',
      '1890年 帝国議会の開設',
    ],
    quizzes: [
      EraQuiz(
        question: '明治時代に欧米の文化を取り入れることを何といいますか？',
        choices: ['大化の改新', '文明開化（ぶんめいかいか）', '参勤交代', '鎖国'],
        correctIndex: 1,
        explanation: '西洋の技術・文化を積極的に取り入れることを「文明開化（ぶんめいかいか）」といいます。',
      ),
      EraQuiz(
        question: '大日本帝国憲法を作るために尽力した初代内閣総理大臣は？',
        choices: ['坂本龍馬', '西郷隆盛', '伊藤博文', '大久保利通'],
        correctIndex: 2,
        explanation: '伊藤博文（いとうひろぶみ）がヨーロッパで憲法を学び、1889年に大日本帝国憲法を作りました。',
      ),
      EraQuiz(
        question: '「学問のすゝめ」を書いた人物は？',
        choices: ['夏目漱石', '福沢諭吉', '坂本龍馬', '松尾芭蕉'],
        correctIndex: 1,
        explanation: '福沢諭吉（ふくざわゆきち）が「学問のすゝめ」を書き、「天は人の上に人を造らず」という考えを広めました。',
      ),
    ],
  ),

  'taisho': const EraDetail(
    id: 'taisho',
    name: '大正時代',
    reading: 'たいしょうじだい',
    emoji: '📻',
    period: '1912〜1926年',
    description:
        '大正時代は民主主義（みんしゅしゅぎ）の考えが広まった時代です。'
        '普通選挙（男性が全員投票できる選挙）を求める運動（大正デモクラシー）が盛んになりました。'
        'ラジオ放送が始まり、映画や野球なども人々に親しまれるようになりました。'
        '1923年の関東大震災（かんとうだいしんさい）では東京・横浜に大きな被害がありました。',
    keyPersons: [
      KeyPerson(
        name: '原敬',
        reading: 'はらたかし',
        description: '日本初の本格的な政党内閣（平民宰相）の総理大臣',
      ),
      KeyPerson(
        name: '吉野作造',
        reading: 'よしのさくぞう',
        description: '民本主義を唱えた思想家・大正デモクラシーの代表者',
      ),
    ],
    keyEvents: [
      '大正デモクラシー運動の広がり',
      '1918年 原敬内閣（初の政党内閣）',
      '1923年 関東大震災',
      '1925年 普通選挙法（男性全員に選挙権）の制定',
      'ラジオ放送の開始',
    ],
    quizzes: [
      EraQuiz(
        question: '大正時代に広まった、民主主義を求める運動を何といいますか？',
        choices: ['文明開化', '大政奉還', '大正デモクラシー', '廃藩置県'],
        correctIndex: 2,
        explanation: '「大正デモクラシー」という、国民が政治に参加することを求める民主主義運動が盛んになりました。',
      ),
      EraQuiz(
        question: '1923年に東京・横浜を中心に起きた大きな災害は？',
        choices: ['阪神大震災', '関東大震災（かんとうだいしんさい）', '濃尾地震', '東日本大震災'],
        correctIndex: 1,
        explanation: '1923年9月1日に「関東大震災（かんとうだいしんさい）」が起こり、10万人以上が亡くなりました。',
      ),
      EraQuiz(
        question: '大正時代に制定された、男性全員が選挙に参加できる法律は？',
        choices: ['教育基本法', '憲法改正', '普通選挙法（ふつうせんきょほう）', '廃藩置県'],
        correctIndex: 2,
        explanation: '1925年に「普通選挙法（ふつうせんきょほう）」が制定され、満25歳以上の男性全員に選挙権が与えられました。',
      ),
    ],
  ),

  'showa': const EraDetail(
    id: 'showa',
    name: '昭和時代',
    reading: 'しょうわじだい',
    emoji: '🕊️',
    period: '1926〜1989年',
    description:
        '昭和時代は平和な時代と戦争の時代の両方を持つ、激動の時代です。'
        '1941年から1945年の太平洋戦争（第二次世界大戦）では多くの人が亡くなり、広島と長崎に原子爆弾が落とされました。'
        '戦後は日本国憲法が作られ、民主主義の国として復興を遂げました。'
        '1960〜70年代の高度経済成長期には電化製品や自動車が普及し、1964年の東京オリンピックが開かれました。',
    keyPersons: [
      KeyPerson(
        name: '昭和天皇',
        reading: 'しょうわてんのう',
        description: '63年間在位し、戦争と復興・高度成長を見届けた天皇',
      ),
      KeyPerson(
        name: '吉田茂',
        reading: 'よしだしげる',
        description: '戦後の日本の復興を指導した首相',
      ),
    ],
    keyEvents: [
      '1941〜1945年 太平洋戦争（第二次世界大戦）',
      '1945年 広島・長崎への原爆投下、終戦',
      '1946年 日本国憲法の制定',
      '1964年 東京オリンピック',
      '高度経済成長期（1955〜1973年）',
    ],
    quizzes: [
      EraQuiz(
        question: '1945年に原子爆弾が落とされた都市はどこですか？（2つのうちの1つ）',
        choices: ['東京', '広島', '大阪', '名古屋'],
        correctIndex: 1,
        explanation: '1945年8月6日に広島、8月9日に長崎に原子爆弾が落とされました。多くの命が失われました。',
      ),
      EraQuiz(
        question: '戦後の日本で1946年に制定された憲法は？',
        choices: ['大日本帝国憲法', '日本国憲法', '明治憲法', '平和憲法'],
        correctIndex: 1,
        explanation: '1946年に「日本国憲法（にほんこくけんぽう）」が制定され、国民主権・平和主義・基本的人権の尊重が定められました。',
      ),
      EraQuiz(
        question: '1964年に日本で開かれたオリンピックの開催都市は？',
        choices: ['大阪', '名古屋', '東京', '京都'],
        correctIndex: 2,
        explanation: '1964年に「東京オリンピック」が開かれました。日本の戦後復興を世界に示す大会になりました。',
      ),
    ],
  ),

  'heisei_reiwa': const EraDetail(
    id: 'heisei_reiwa',
    name: '平成・令和時代',
    reading: 'へいせい・れいわじだい',
    emoji: '💻',
    period: '1989年〜現在',
    description:
        '平成時代はインターネットや携帯電話（スマートフォン）が普及し、情報化社会になった時代です。'
        '1995年の阪神大震災、2011年の東日本大震災など大きな自然災害もありました。'
        '2019年に令和時代が始まり、現代の日本では環境問題やデジタル化・国際化が重要な課題となっています。'
        '2021年には東京オリンピック・パラリンピックが開かれ、日本が多くのメダルを獲得しました。',
    keyPersons: [
      KeyPerson(
        name: '平成天皇（上皇）',
        reading: 'へいせいてんのう（じょうこう）',
        description: '平成の時代を生きた天皇。2019年に上皇になった',
      ),
      KeyPerson(
        name: '今上天皇',
        reading: 'きんじょうてんのう',
        description: '2019年に即位した令和時代の天皇',
      ),
    ],
    keyEvents: [
      '1995年 阪神大震災',
      'インターネット・スマートフォンの普及',
      '2011年 東日本大震災・東京電力福島第一原発事故',
      '2019年 令和への改元',
      '2021年 東京オリンピック・パラリンピック',
    ],
    quizzes: [
      EraQuiz(
        question: '平成・令和時代に広まった情報のやりとりの手段は？',
        choices: ['電報（でんぽう）', 'インターネット・スマートフォン', '手紙', '電話のみ'],
        correctIndex: 1,
        explanation: 'インターネットやスマートフォンが広まり、世界中の人とすぐに情報をやりとりできるようになりました。',
      ),
      EraQuiz(
        question: '2011年3月11日に起きた大きな災害は？',
        choices: ['関東大震災', '阪神大震災', '東日本大震災', '濃尾地震'],
        correctIndex: 2,
        explanation: '2011年3月11日に「東日本大震災（ひがしにほんだいしんさい）」が起き、津波や原発事故が起こりました。',
      ),
      EraQuiz(
        question: '令和時代が始まったのは何年ですか？',
        choices: ['2016年', '2018年', '2019年', '2020年'],
        correctIndex: 2,
        explanation: '2019年5月1日に新天皇が即位し、元号が「平成」から「令和（れいわ）」に変わりました。',
      ),
    ],
  ),
};

// ─── Badge helpers ────────────────────────────────────────────────────────────

String _eraBadgeId(String eraId) => 'history_era_$eraId';

// ─── Screen ──────────────────────────────────────────────────────────────────

class HistoryEraScreen extends ConsumerStatefulWidget {
  final String eraId;

  const HistoryEraScreen({super.key, required this.eraId});

  @override
  ConsumerState<HistoryEraScreen> createState() => _HistoryEraScreenState();
}

class _HistoryEraScreenState extends ConsumerState<HistoryEraScreen> {
  // Quiz state
  bool _quizStarted = false;
  int _currentQuizIndex = 0;
  int? _selectedAnswer;
  bool _answered = false;
  int _correctCount = 0;
  bool _quizFinished = false;

  EraDetail? get _era => _eraData[widget.eraId];

  Color get _primaryColor => const Color(AppColors.primaryValue);

  @override
  Widget build(BuildContext context) {
    final era = _era;
    if (era == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('不明な時代')),
        body: const Center(child: Text('データが見つかりません')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(era.name),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildHeroSection(era),
          const SizedBox(height: 16),
          _buildDescriptionCard(era),
          const SizedBox(height: 12),
          if (era.keyPersons.isNotEmpty) ...[
            _buildKeyPersonsCard(era),
            const SizedBox(height: 12),
          ],
          _buildKeyEventsCard(era),
          const SizedBox(height: 16),
          if (!_quizStarted) _buildStartQuizButton(era),
          if (_quizStarted && !_quizFinished) _buildQuizSection(era),
          if (_quizFinished) _buildQuizResult(era),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // ─── Hero section ─────────────────────────────────────────────────────────

  Widget _buildHeroSection(EraDetail era) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _primaryColor.withOpacity(0.85),
            _primaryColor,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Text(era.emoji, style: const TextStyle(fontSize: 56)),
          const SizedBox(height: 8),
          Text(
            era.name,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            era.reading,
            style: const TextStyle(fontSize: 13, color: Colors.white70),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              era.period,
              style: const TextStyle(fontSize: 13, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Description card ─────────────────────────────────────────────────────

  Widget _buildDescriptionCard(EraDetail era) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.menu_book, color: _primaryColor, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'この時代について',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Divider(height: 16),
            Text(
              era.description,
              style: const TextStyle(fontSize: 14, height: 1.8),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Key persons card ─────────────────────────────────────────────────────

  Widget _buildKeyPersonsCard(EraDetail era) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.person, color: Colors.orange.shade700, size: 20),
                const SizedBox(width: 8),
                const Text(
                  '重要人物',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Divider(height: 16),
            for (final person in era.keyPersons) ...[
              _PersonTile(person: person),
              if (person != era.keyPersons.last) const SizedBox(height: 8),
            ],
          ],
        ),
      ),
    );
  }

  // ─── Key events card ──────────────────────────────────────────────────────

  Widget _buildKeyEventsCard(EraDetail era) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.event_note, color: Colors.blue.shade700, size: 20),
                const SizedBox(width: 8),
                const Text(
                  '重要な出来事',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Divider(height: 16),
            for (final event in era.keyEvents) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 6),
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _primaryColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(event, style: const TextStyle(fontSize: 14, height: 1.6)),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ─── Start quiz button ────────────────────────────────────────────────────

  Widget _buildStartQuizButton(EraDetail era) {
    return ElevatedButton.icon(
      onPressed: () => setState(() => _quizStarted = true),
      icon: const Icon(Icons.quiz),
      label: const Text('クイズに挑戦！'),
      style: ElevatedButton.styleFrom(
        minimumSize: const Size.fromHeight(54),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
      ),
    );
  }

  // ─── Quiz section ─────────────────────────────────────────────────────────

  Widget _buildQuizSection(EraDetail era) {
    final quiz = era.quizzes[_currentQuizIndex];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Quiz header
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.orange.shade50,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.orange.shade200),
          ),
          child: Row(
            children: [
              Icon(Icons.quiz, color: Colors.orange.shade700),
              const SizedBox(width: 8),
              Text(
                '問題 ${_currentQuizIndex + 1} / ${era.quizzes.length}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.orange.shade800,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Question
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              quiz.question,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, height: 1.5),
            ),
          ),
        ),
        const SizedBox(height: 10),

        // Choices
        for (int i = 0; i < quiz.choices.length; i++)
          _ChoiceTile(
            label: String.fromCharCode(65 + i), // A B C D
            text: quiz.choices[i],
            state: _answered
                ? (i == quiz.correctIndex
                    ? _ChoiceState.correct
                    : (i == _selectedAnswer ? _ChoiceState.wrong : _ChoiceState.normal))
                : (_selectedAnswer == i ? _ChoiceState.selected : _ChoiceState.normal),
            onTap: _answered ? null : () => _onSelectAnswer(i, quiz),
          ),

        // Explanation after answer
        if (_answered) ...[
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(AppColors.correctBgValue),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(AppColors.correctValue).withOpacity(0.4)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('💡 ', style: TextStyle(fontSize: 16)),
                Expanded(
                  child: Text(
                    quiz.explanation,
                    style: const TextStyle(fontSize: 13, height: 1.6),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          ElevatedButton(
            onPressed: _onNextQuiz,
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(50),
              backgroundColor: _primaryColor,
            ),
            child: Text(
              _currentQuizIndex < era.quizzes.length - 1 ? '次の問題へ' : '結果を見る',
            ),
          ),
        ],
      ],
    );
  }

  // ─── Quiz result ──────────────────────────────────────────────────────────

  Widget _buildQuizResult(EraDetail era) {
    final total = era.quizzes.length;
    final allCorrect = _correctCount == total;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: allCorrect ? const Color(AppColors.correctBgValue) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: allCorrect
                  ? const Color(AppColors.correctValue).withOpacity(0.4)
                  : Colors.grey.shade200,
            ),
          ),
          child: Column(
            children: [
              Text(
                allCorrect ? '🎉 全問正解！' : '📝 クイズ結果',
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text(
                '$_correctCount / $total 正解',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: allCorrect ? const Color(AppColors.correctValue) : Colors.orange,
                ),
              ),
              const SizedBox(height: 8),
              if (allCorrect)
                const Text(
                  'すばらしい！全問正解です！',
                  style: TextStyle(fontSize: 14, color: Color(AppColors.correctValue)),
                )
              else
                Text(
                  'もう一度チャレンジしてみよう！',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('🪙 ', style: TextStyle(fontSize: 18)),
                  Text(
                    '+${_correctCount * 5} コイン',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(AppColors.accentValue),
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Text('⭐ ', style: TextStyle(fontSize: 18)),
                  Text(
                    '+${_correctCount * 10} ポイント',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(AppColors.primaryValue),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        OutlinedButton.icon(
          onPressed: _resetQuiz,
          icon: const Icon(Icons.replay),
          label: const Text('もう一度挑戦する'),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(48),
          ),
        ),
      ],
    );
  }

  // ─── Event handlers ───────────────────────────────────────────────────────

  void _onSelectAnswer(int index, EraQuiz quiz) {
    setState(() {
      _selectedAnswer = index;
      _answered = true;
      if (index == quiz.correctIndex) {
        _correctCount++;
      }
    });
  }

  Future<void> _onNextQuiz() async {
    final era = _era!;
    if (_currentQuizIndex < era.quizzes.length - 1) {
      setState(() {
        _currentQuizIndex++;
        _selectedAnswer = null;
        _answered = false;
      });
    } else {
      // Quiz finished — award coins, points, and badge
      final progressNotifier = ref.read(userProgressProvider.notifier);
      await progressNotifier.addCoins(_correctCount * 5);
      await progressNotifier.addPoints(_correctCount * 10);
      await progressNotifier.addBadge(_eraBadgeId(era.id));
      setState(() => _quizFinished = true);
    }
  }

  void _resetQuiz() {
    setState(() {
      _quizStarted = false;
      _quizFinished = false;
      _currentQuizIndex = 0;
      _selectedAnswer = null;
      _answered = false;
      _correctCount = 0;
    });
  }
}

// ─── Person tile ─────────────────────────────────────────────────────────────

class _PersonTile extends StatelessWidget {
  final KeyPerson person;

  const _PersonTile({required this.person});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.orange.shade100,
            shape: BoxShape.circle,
          ),
          child: const Center(
            child: Text('👤', style: TextStyle(fontSize: 18)),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                person.name,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              Text(
                person.reading,
                style: TextStyle(fontSize: 11, color: Colors.grey[500]),
              ),
              Text(
                person.description,
                style: const TextStyle(fontSize: 13, height: 1.4),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Choice tile ─────────────────────────────────────────────────────────────

enum _ChoiceState { normal, selected, correct, wrong }

class _ChoiceTile extends StatelessWidget {
  final String label;
  final String text;
  final _ChoiceState state;
  final VoidCallback? onTap;

  const _ChoiceTile({
    required this.label,
    required this.text,
    required this.state,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color borderColor;
    Color labelColor;

    switch (state) {
      case _ChoiceState.correct:
        bgColor = const Color(AppColors.correctBgValue);
        borderColor = const Color(AppColors.correctValue);
        labelColor = const Color(AppColors.correctValue);
      case _ChoiceState.wrong:
        bgColor = const Color(AppColors.incorrectBgValue);
        borderColor = const Color(AppColors.incorrectValue);
        labelColor = const Color(AppColors.incorrectValue);
      case _ChoiceState.selected:
        bgColor = const Color(0xFFE3F2FD);
        borderColor = Colors.blue;
        labelColor = Colors.blue;
      case _ChoiceState.normal:
        bgColor = Colors.white;
        borderColor = Colors.grey.shade300;
        labelColor = Colors.grey.shade600;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor, width: 1.5),
        ),
        child: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: borderColor.withOpacity(0.15),
                shape: BoxShape.circle,
                border: Border.all(color: borderColor),
              ),
              child: Center(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: labelColor,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(fontSize: 14, height: 1.4),
              ),
            ),
            if (state == _ChoiceState.correct)
              const Icon(Icons.check_circle, color: Color(AppColors.correctValue), size: 20),
            if (state == _ChoiceState.wrong)
              const Icon(Icons.cancel, color: Color(AppColors.incorrectValue), size: 20),
          ],
        ),
      ),
    );
  }
}
