import 'package:flutter/material.dart';
import '../../models/stage.dart';
import '../../utils/constants.dart';

/// ステージクリア後のまとめカード画面
class StageClearScreen extends StatelessWidget {
  final Stage stage;

  const StageClearScreen({Key? key, required this.stage}) : super(key: key);

  static const Map<String, List<String>> _stageSummaries = {
    'stage_1': [
      '北海道は広い農地があり、じゃがいも・乳製品・米の産地です',
      '青森県はりんごの生産量が全国1位です',
      '宮城県の気仙沼はサメ（フカヒレ）の水揚げで有名です',
      '秋田県のきりたんぽは米どころならではの料理です',
    ],
    'stage_2': [
      '関東平野は日本最大の平野で、人口も最も多い地方です',
      '東京は日本の首都で、政治・経済・文化の中心です',
      '群馬・栃木は内陸にあり、山と温泉が豊かです',
      '神奈川県横浜には日本最大の中華街があります',
    ],
    'stage_3': [
      '富士山は日本最高峰（3776m）、静岡・山梨の県境にあります',
      '長野県は標高が高く、高原野菜（レタス・キャベツ等）の産地です',
      '新潟県は日本有数の米どころで、コシヒカリが有名です',
      '愛知県はトヨタ自動車の本拠地、中京工業地帯が広がります',
    ],
    'stage_4': [
      '大阪は「食い倒れの街」として、たこ焼き・お好み焼きが有名です',
      '京都は794年から約1100年間、日本の都でした',
      '奈良には東大寺と奈良の大仏（奈良時代）があります',
      '兵庫の神戸港は明治時代の重要な国際貿易港です',
    ],
    'stage_5': [
      '瀬戸内海は穏やかな気候で、塩・柑橘類・アナゴが名産です',
      '広島には原爆ドームがあり、平和記念都市として世界に知られます',
      '高知県は温暖な気候を活かしたビニールハウス（促成農業）が盛んです',
      '鳥取砂丘は日本最大級の砂丘で、中国地方の名所です',
    ],
    'stage_6': [
      '熊本県は「火の国」、阿蘇山（世界最大級のカルデラ）が有名です',
      '鹿児島県には桜島という現在も噴火する活火山があります',
      '沖縄県は亜熱帯気候で、サンゴ礁と独自の文化（琉球文化）が魅力です',
      '福岡県は九州最大の都市で、博多どんたく・博多ラーメンが有名です',
    ],
    'stage_7': [
      '日本最長の川は信濃川（約367km）、2番目は利根川（約322km）です',
      '日本最大の湖は琵琶湖（滋賀県）、日本の飲料水の重要な源です',
      '日本の山地は国土の約70%を占め、平野は少ない地形です',
      '3大工業地帯：京浜（東京・神奈川）・中京（愛知）・阪神（大阪・兵庫）',
    ],
    'stage_8': [
      '日本国憲法の3大原則：国民主権・平和主義・基本的人権の尊重',
      '三権分立：国会（立法）・内閣（行政）・裁判所（司法）に分かれます',
      '選挙権は18歳以上の国民に与えられています',
      '衆議院を解散する権限は内閣（内閣総理大臣）が持ちます',
    ],
    'stage_9': [
      '日本の主な輸出品：自動車・機械類・電子部品（アメリカ向けが最多）',
      '日本の主な輸入品：石油・食料品・機械類（中国からが最多）',
      '食料自給率（カロリーベース）は約38%と低く、食料の多くを輸入に頼ります',
      '農業の課題：高齢化・後継者不足・耕作放棄地の増加',
    ],
    'stage_10': [
      '日本は4つのプレートが交わる位置にあるため、地震・火山が多いです',
      '排他的経済水域（EEZ）の面積は世界6位の広さです',
      '梅雨・台風・冬の積雪が日本の気候の主な特徴です',
      '日本の総人口は約1.2億人で、少子高齢化が課題となっています',
    ],
    'stage_11': [
      '稲作は弥生時代に大陸（中国・朝鮮半島）から伝わりました',
      '源頼朝が1185〜1192年に鎌倉幕府を開き、武家政権が始まりました',
      '江戸幕府の鎖国政策：長崎・出島のオランダ・中国のみ貿易を許可',
      '明治維新（1868年）で近代国家への大変革が始まりました',
      '1945年終戦→1947年日本国憲法施行、現在に至ります',
    ],
    'stage_12': [
      'SDGsは2015年に193か国が採択した17の目標（2030年期限）',
      '地球温暖化の主因はCO₂などの温室効果ガス（化石燃料の燃焼）',
      '3R：Reduce（減らす）→Reuse（再利用）→Recycle（資源化）の順が大切',
      'マイクロプラスチック（5mm以下）が海洋生態系を深刻に汚染しています',
      '2050年カーボンニュートラル（温室ガス実質ゼロ）が日本の目標です',
    ],
    'stage_13': [
      '日本最長の川：信濃川（367km）、2位：利根川（322km）',
      '日本最大の湖：琵琶湖（滋賀県）、約670km²',
      '日本アルプス（飛騨・木曽・赤石山脈）が中部地方に連なります',
      '日本には110座以上の活火山があり、温泉の源になっています',
      '扇状地（川が山から平野に出る場所）と三角州（川の河口）が形成されます',
    ],
    'stage_14': [
      '稲作の流れ：田おこし→代かき（しろかき）→田植え（5〜6月）→稲刈り（9〜10月）',
      '耕作放棄地は農家の高齢化・後継者不足が原因で増え続けています',
      '有機農業は農薬・化学肥料を使わない、環境にやさしい農業です',
      '食品ロスは年間約500〜600万トン（日本）、世界の食料援助量の約2倍！',
      '日本の食料自給率（カロリーベース）は約38%と低い水準です',
    ],
    'stage_15': [
      '国連（UN）本部はアメリカ・ニューヨーク、193か国が加盟しています',
      'UNICEF：世界の子どもの命・健康・教育を守る国連機関',
      'UNESCO：教育・科学・文化の発展と世界遺産の保護を担う国連機関',
      'ODA（政府開発援助）：日本政府が発展途上国を支援する取り組み',
      '日本は石油の多くを中東（サウジアラビア等）から輸入しています',
    ],
    'stage_16': [
      '地図記号は国土地理院が定めた全国共通の記号で、地形図に使われます',
      '縮尺1:25000の地形図では地図の1cmが実際の250m（0.25km）を表します',
      '等高線（とうこうせん）は同じ高さの点を結んだ線で、山の形がわかります',
      '方位記号の矢印は「北（N）」を指し、8方位・16方位で方向を表します',
      '田・畑・果樹園・工場・学校など、土地の使われ方が地図記号でわかります',
    ],
    'stage_17': [
      '日本には47都道府県（1都・1道・2府・43県）があります',
      '都道府県庁所在地は県名と同じとは限りません（例：石川県→金沢市）',
      '面積最大：北海道（83,424km²）、最小：香川県（1,877km²）',
      '人口最多：東京都（約1,400万人）、最少：鳥取県（約54万人）',
      '政令指定都市は人口50万人以上の都市に特別な権限が与えられます',
    ],
    'stage_18': [
      'お正月（1月1日）：新年を迎える最大の年中行事、おせち・お雑煮・初詣',
      '節分（2月3日頃）：鬼を追い払う豆まきと恵方巻きが定番行事です',
      '七夕（7月7日）：織姫と彦星の伝説、短冊に願いを書く日本の行事です',
      'お盆（8月13〜16日）：ご先祖様の霊が戻ってくる時期とされる行事です',
      '端午の節句（5月5日）：こどもの日にこいのぼりを飾り、健やかな成長を願います',
    ],
    'stage_19': [
      '聖徳太子（604年）は十七条憲法を制定し、仏教・儒教を重んじました',
      '大化の改新（645年）：中大兄皇子が蘇我氏を倒し律令国家建設を開始',
      '元冦（1274・1281年）：モンゴル帝国の襲来、嵐（神風）が日本を救いました',
      '関ヶ原の戦い（1600年）：徳川家康が勝利し江戸幕府（265年間）を開きました',
      'ペリー来航（1853年）→明治維新（1868年）→近代日本国家の誕生',
    ],
    'stage_20': [
      '日本の税金：国税（所得税・法人税・消費税等）と地方税（住民税等）があります',
      '消費税は2019年から10%（軽減税率8%：食料品・新聞等）',
      '社会保障の4本柱：社会保険・社会福祉・公的扶助（生活保護）・保健医療',
      '国民の3つの義務：教育を受けさせる義務・勤労の義務・納税の義務',
      '裁判員制度（2009年〜）：無作為に選ばれた市民が刑事裁判に参加します',
    ],
  };

  List<String> get _summary =>
      _stageSummaries[stage.id] ??
      ['このステージの学習が完了しました！おつかれさまでした！'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Column(
          children: [
            // ヘッダー
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const Icon(Icons.emoji_events,
                      color: Colors.amber, size: 64),
                  const SizedBox(height: 12),
                  const Text(
                    'ステージクリア！',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    stage.title,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            // まとめカード
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.menu_book,
                              color: AppColors.primary, size: 24),
                          const SizedBox(width: 8),
                          const Text(
                            'このステージで学んだこと',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ..._summary
                          .asMap()
                          .entries
                          .map((e) => _SummaryPoint(
                                number: e.key + 1,
                                text: e.value,
                              )),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.check),
                          label: const Text(
                            'ステージ一覧に戻る',
                            style: TextStyle(fontSize: 16),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding:
                                const EdgeInsets.symmetric(vertical: 16),
                          ),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryPoint extends StatelessWidget {
  final int number;
  final String text;

  const _SummaryPoint({required this.number, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$number',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                text,
                style: const TextStyle(fontSize: 14, height: 1.5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
