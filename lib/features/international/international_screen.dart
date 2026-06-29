import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../repositories/progress_repository.dart';
import '../../utils/constants.dart';

// ─────────────────────────────────────────────────────────────
// Section model
// ─────────────────────────────────────────────────────────────

class _IntlSection {
  final String id;
  final String title;
  final String furigana;
  final String emoji;
  final Color color;
  final String description;
  final List<_InfoPoint> points;

  const _IntlSection({
    required this.id,
    required this.title,
    required this.furigana,
    required this.emoji,
    required this.color,
    required this.description,
    required this.points,
  });
}

class _InfoPoint {
  final String label;
  final String detail;

  const _InfoPoint(this.label, this.detail);
}

// ─────────────────────────────────────────────────────────────
// Section data
// ─────────────────────────────────────────────────────────────

const List<_IntlSection> _sections = [
  _IntlSection(
    id: 'un',
    title: '国際連合（UN）',
    furigana: 'こくさいれんごう',
    emoji: '🌐',
    color: Color(0xFF1565C0),
    description:
        '国際連合（こくさいれんごう）は1945年10月24日に設立された世界最大の国際機関です。'
        '第二次世界大戦（だいにじせかいたいせん）が終わった後、二度と世界大戦を起こさないために作られました。'
        '現在（2024年）193か国が加盟しており、世界人口のほぼすべてを代表しています。'
        '日本は1956年（昭和31年）に加盟し、常任理事国ではありませんが非常任理事国として活動しています。',
    points: [
      _InfoPoint('設立', '1945年10月24日（国連の日）'),
      _InfoPoint('本部', 'アメリカ・ニューヨーク市'),
      _InfoPoint('加盟国', '193か国（2024年）'),
      _InfoPoint('公用語', '英語・フランス語・スペイン語・ロシア語・中国語・アラビア語'),
      _InfoPoint('安全保障理事会（あんぽりじかい）', '常任理事国5か国：米・英・仏・露・中が拒否権（きょひけん）を持つ'),
      _InfoPoint('主な機関', '総会（そうかい）・安全保障理事会・国際司法裁判所・事務局'),
      _InfoPoint('日本の加盟', '1956年（昭和31年）加盟'),
    ],
  ),
  _IntlSection(
    id: 'sdgs',
    title: 'SDGs（持続可能な開発目標）',
    furigana: 'えすでぃーじーず',
    emoji: '🌱',
    color: Color(0xFF2E7D32),
    description:
        'SDGs（エスディージーズ）は "Sustainable Development Goals"（持続可能な開発目標：じぞくかのうなかいはつもくひょう）の略で、'
        '2015年に国連で採択（さいたく）されました。'
        '2030年までに世界の貧困（ひんこん）・不平等・気候変動（きこうへんどう）などの問題を解決するための17の目標があります。'
        '世界中の国・企業・学校・個人がSDGsの達成に向けて取り組んでいます。',
    points: [
      _InfoPoint('目標1', '貧困をなくそう 🏚'),
      _InfoPoint('目標2', '飢餓（きが）をゼロに 🌾'),
      _InfoPoint('目標3', 'すべての人に健康と福祉（ふくし）を 🏥'),
      _InfoPoint('目標4', '質の高い教育をみんなに 📚'),
      _InfoPoint('目標5', 'ジェンダー平等を実現しよう ♀'),
      _InfoPoint('目標6', '安全な水とトイレを世界中に 💧'),
      _InfoPoint('目標7', 'エネルギーをみんなに・クリーンに ⚡'),
      _InfoPoint('目標13', '気候変動（きこうへんどう）に具体的な対策を 🌡'),
      _InfoPoint('目標17', 'パートナーシップで目標を達成しよう 🤝'),
    ],
  ),
  _IntlSection(
    id: 'contribution',
    title: '日本の国際貢献',
    furigana: 'にほんのこくさいこうけん',
    emoji: '🤝',
    color: Color(0xFFE65100),
    description:
        '日本は世界の平和や発展（はってん）のためにさまざまな国際貢献（こくさいこうけん）を行っています。'
        'ODA（政府開発援助：せいふかいはつえんじょ）として、発展途上国（はってんとじょうこく）の道路・学校・病院の建設を支援しています。'
        'PKO（国連平和維持活動：こくれんへいわいじかつどう）として、自衛隊（じえいたい）が紛争地域（ふんそうちいき）の安定に協力しています。'
        'ユニセフ（UNICEF）募金などで、世界の子どもたちを支援する活動も盛んです。',
    points: [
      _InfoPoint('ODA（政府開発援助）', '道路・学校・病院の建設支援・技術指導など'),
      _InfoPoint('PKO（国連平和維持活動）', '紛争後の地域の安定・復興支援（南スーダンなど）'),
      _InfoPoint('UNICEF（ユニセフ）', '世界の子どもの教育・健康・栄養支援'),
      _InfoPoint('日本のNGO活動', '民間団体が海外で医療・食料支援を実施'),
      _InfoPoint('文化交流', '日本語・文化を海外に伝えるJICA・国際交流基金'),
    ],
  ),
  _IntlSection(
    id: 'world_issues',
    title: '世界の問題',
    furigana: 'せかいのもんだい',
    emoji: '🌍',
    color: Color(0xFFC62828),
    description:
        '現在の世界では多くの深刻（しんこく）な問題が起きています。'
        '世界人口の約10%（8億人以上）が極度の貧困（ひんこん）の中で生活しています。'
        '紛争（ふんそう）や戦争による難民（なんみん）は世界全体で1億人以上に達しており、住む場所や食料・教育の機会を失っています。'
        '経済格差（けいざいかくさ）は拡大し、豊かな国と貧しい国の差が広がっています。',
    points: [
      _InfoPoint('貧困（ひんこん）', '世界人口の約10%が1日1.90ドル以下で生活'),
      _InfoPoint('飢餓（きが）', '約7億人が食料不足に苦しんでいる'),
      _InfoPoint('紛争・戦争', '世界各地で内戦・紛争が続いており難民が急増'),
      _InfoPoint('難民（なんみん）', '故郷を追われた人が世界で1億人以上'),
      _InfoPoint('経済格差（けいざいかくさ）', '豊かな国と貧しい国の差が拡大している'),
      _InfoPoint('気候変動（きこうへんどう）', '異常気象・海面上昇で生活を失う地域も'),
    ],
  ),
  _IntlSection(
    id: 'culture',
    title: '異文化理解',
    furigana: 'いぶんかりかい',
    emoji: '🌏',
    color: Color(0xFF6A1B9A),
    description:
        '世界には200近くの国・地域があり、言語・文化・宗教（しゅうきょう）・食文化など多様な違いがあります。'
        '異文化理解（いぶんかりかい）とは、自分と違う文化を否定（ひてい）せず、理解・尊重（そんちょう）することです。'
        '世界では約7,000の言語が使われており、英語は国際共通語として広く使われています。'
        '宗教には仏教（ぶっきょう）・キリスト教・イスラム教・ヒンドゥー教など多くの種類があります。',
    points: [
      _InfoPoint('言語の多様性（たようせい）', '世界には約7,000の言語がある。英語が国際共通語'),
      _InfoPoint('主な宗教（しゅうきょう）', 'キリスト教・イスラム教・仏教・ヒンドゥー教など'),
      _InfoPoint('食文化の違い', '宗教や文化により食べてよいもの・避けるものが異なる'),
      _InfoPoint('あいさつの違い', 'おじぎ（日本）・握手（欧米）・頬（ほほ）へのキス（仏など）'),
      _InfoPoint('多文化共生（たぶんかきょうせい）', '異なる文化を持つ人が共に暮らす社会をめざす'),
    ],
  ),
  _IntlSection(
    id: 'global_citizen',
    title: '地球市民として',
    furigana: 'ちきゅうしみんとして',
    emoji: '🌟',
    color: Color(0xFF00695C),
    description:
        '「地球市民（ちきゅうしみん）」とは、国や民族を超えて地球全体のことを考え、行動できる人のことです。'
        '世界の問題は一国だけでは解決できないため、みんなが地球市民として考える必要があります。'
        '私たちも日常生活の中で地球市民として行動できることがたくさんあります。'
        '外国の文化を学ぶ、環境に配慮した行動をする、フェアトレード商品を選ぶなどが身近な例です。',
    points: [
      _InfoPoint('環境への配慮（はいりょ）', 'ゴミの分別・節電・マイバッグでCO₂を減らす'),
      _InfoPoint('フェアトレード', '発展途上国の生産者が正当な報酬を受けられる貿易'),
      _InfoPoint('異文化を学ぶ', '外国語・文化・歴史を積極的に学ぶ'),
      _InfoPoint('ボランティア活動', '地域・国際支援の活動に参加する'),
      _InfoPoint('SNSの正しい使い方', '差別・偏見（へんけん）を広めないよう情報を確認する'),
      _InfoPoint('選挙への参加', '18歳になったら投票で社会に参加する'),
    ],
  ),
];

// ─────────────────────────────────────────────────────────────
// Screen
// ─────────────────────────────────────────────────────────────

class InternationalScreen extends ConsumerWidget {
  const InternationalScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coins = ref.watch(coinsProvider);

    return Scaffold(
      backgroundColor: const Color(AppColors.bgLight),
      appBar: AppBar(
        title: const Text('国際'),
        centerTitle: true,
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          _CoinBanner(coins: coins),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              itemCount: _sections.length,
              itemBuilder: (context, index) {
                return _SectionCard(section: _sections[index]);
              },
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
// Section card
// ─────────────────────────────────────────────────────────────

class _SectionCard extends StatefulWidget {
  final _IntlSection section;

  const _SectionCard({required this.section});

  @override
  State<_SectionCard> createState() => _SectionCardState();
}

class _SectionCardState extends State<_SectionCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final s = widget.section;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            // ─── Header ─────────────────────────────────────────
            InkWell(
              onTap: () => setState(() => _expanded = !_expanded),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: s.color.withValues(alpha: 0.10),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: s.color,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          s.emoji,
                          style: const TextStyle(fontSize: 22),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            s.furigana,
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey.shade600,
                              height: 1.2,
                            ),
                          ),
                          Text(
                            s.title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF333333),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      _expanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: Colors.grey.shade600,
                    ),
                  ],
                ),
              ),
            ),

            // ─── Expanded body ───────────────────────────────────
            if (_expanded) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
                child: Text(
                  s.description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF555555),
                    height: 1.6,
                  ),
                ),
              ),

              // ─── Info points ──────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: s.color.withValues(alpha: 0.06),
                    border: Border.all(
                      color: s.color.withValues(alpha: 0.25),
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: s.color,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'くわしく知ろう',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: s.color,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ...s.points.map(
                        (p) => Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '▸ ',
                                style: TextStyle(
                                  color: s.color,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Expanded(
                                child: RichText(
                                  text: TextSpan(
                                    children: [
                                      TextSpan(
                                        text: '${p.label}：',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF333333),
                                        ),
                                      ),
                                      TextSpan(
                                        text: p.detail,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFF555555),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ─── Quiz button ──────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () =>
                        context.push('/international-quiz/${s.id}'),
                    icon: const Icon(Icons.quiz, size: 18),
                    label: const Text('クイズに挑戦！'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: s.color,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
