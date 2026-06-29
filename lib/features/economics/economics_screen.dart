import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../repositories/progress_repository.dart';
import '../../utils/constants.dart';
import '../../utils/furigana_map.dart';
import '../../widgets/ruby_text.dart';

// ─────────────────────────────────────────────────────────────
// Section model
// ─────────────────────────────────────────────────────────────

class _SectionInfo {
  final String id;
  final String title;
  final String furigana;
  final IconData icon;
  final Color color;
  final String description;
  final String pointsSummary;
  final String lifeConnection;
  final Widget Function() diagramBuilder;

  const _SectionInfo({
    required this.id,
    required this.title,
    required this.furigana,
    required this.icon,
    required this.color,
    required this.description,
    required this.pointsSummary,
    required this.lifeConnection,
    required this.diagramBuilder,
  });
}

// ─────────────────────────────────────────────────────────────
// Diagram widgets
// ─────────────────────────────────────────────────────────────

class _BranchBox extends StatelessWidget {
  final IconData icon;
  final String label;
  final String furigana;
  final Color color;

  const _BranchBox({
    required this.icon,
    required this.label,
    required this.furigana,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 90,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.13),
        border: Border.all(color: color, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 4),
          Text(
            furigana,
            style: TextStyle(fontSize: 8, color: color.withValues(alpha: 0.8)),
            textAlign: TextAlign.center,
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
              height: 1.2,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _ArrowRight extends StatelessWidget {
  const _ArrowRight();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 4),
      child: Icon(Icons.arrow_forward_ios, size: 18, color: Color(0xFF999999)),
    );
  }
}

class _ArrowDown extends StatelessWidget {
  const _ArrowDown();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Icon(Icons.arrow_downward, size: 20, color: Color(0xFF999999)),
    );
  }
}

class _FlowRow extends StatelessWidget {
  final String emoji;
  final String label;
  final Color color;

  const _FlowRow({
    required this.emoji,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        border: Border.all(color: color.withValues(alpha: 0.4)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 22)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF333333),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DiagramCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _DiagramCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE0E0E0)),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Color(0xFF666666),
            ),
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Per-section diagrams
// ─────────────────────────────────────────────────────────────

Widget _seijiDiagram() {
  return Column(
    children: [
      _DiagramCard(
        title: '図解：三権分立のしくみ',
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            _BranchBox(
              icon: Icons.account_balance,
              label: '国会\n（立法）',
              furigana: 'こっかい（りっぽう）',
              color: Color(0xFF3498DB),
            ),
            _ArrowRight(),
            _BranchBox(
              icon: Icons.admin_panel_settings,
              label: '内閣\n（行政）',
              furigana: 'ないかく（ぎょうせい）',
              color: Color(0xFF2ECC71),
            ),
            _ArrowRight(),
            _BranchBox(
              icon: Icons.balance,
              label: '裁判所\n（司法）',
              furigana: 'さいばんしょ（しほう）',
              color: Color(0xFFE74C3C),
            ),
          ],
        ),
      ),
      _DiagramCard(
        title: '国会の二院制：衆議院と参議院の違い',
        child: Table(
          border: TableBorder.all(color: const Color(0xFFE0E0E0), width: 1),
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          children: [
            TableRow(
              decoration: const BoxDecoration(color: Color(0xFFF0F0F0)),
              children: [
                _tableCell('', bold: true),
                _tableCell('衆議院\nしゅうぎいん', bold: true),
                _tableCell('参議院\nさんぎいん', bold: true),
              ],
            ),
            TableRow(children: [
              _tableCell('任期\nにんき'),
              _tableCell('4年'),
              _tableCell('6年'),
            ]),
            TableRow(children: [
              _tableCell('定数\nていすう'),
              _tableCell('465人'),
              _tableCell('248人'),
            ]),
            TableRow(children: [
              _tableCell('解散\nかいさん'),
              _tableCell('あり'),
              _tableCell('なし'),
            ]),
          ],
        ),
      ),
      _DiagramCard(
        title: '内閣総理大臣の選ばれ方',
        child: Column(
          children: const [
            _FlowRow(
              emoji: '🗳',
              label: '国民が衆議院・参議院議員を選挙で選ぶ',
              color: Color(0xFF3498DB),
            ),
            _ArrowDown(),
            _FlowRow(
              emoji: '🏛',
              label: '国会が内閣総理大臣を指名する',
              color: Color(0xFF2ECC71),
            ),
            _ArrowDown(),
            _FlowRow(
              emoji: '👑',
              label: '天皇が任命する（象徴的な行為）',
              color: Color(0xFFF39C12),
            ),
          ],
        ),
      ),
    ],
  );
}

Widget _tableCell(String text, {bool bold = false}) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
    child: Text(
      text,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 11,
        fontWeight: bold ? FontWeight.bold : FontWeight.normal,
        color: const Color(0xFF333333),
        height: 1.3,
      ),
    ),
  );
}

Widget _senkyoDiagram() {
  return Column(
    children: [
      _DiagramCard(
        title: '図解：投票のてじゅん',
        child: Column(
          children: const [
            _FlowRow(
              emoji: '📩',
              label: '投票所入場券（はがき）が届く',
              color: Color(0xFF3498DB),
            ),
            _ArrowDown(),
            _FlowRow(
              emoji: '🏫',
              label: '投票所（学校・公民館など）へ行く',
              color: Color(0xFF3498DB),
            ),
            _ArrowDown(),
            _FlowRow(
              emoji: '✏️',
              label: '投票用紙に候補者の名前を書く',
              color: Color(0xFF3498DB),
            ),
            _ArrowDown(),
            _FlowRow(
              emoji: '🗳',
              label: '投票箱に入れる',
              color: Color(0xFF3498DB),
            ),
            _ArrowDown(),
            _FlowRow(
              emoji: '📊',
              label: '開票→当選者が決まる',
              color: Color(0xFF3498DB),
            ),
          ],
        ),
      ),
      _DiagramCard(
        title: '民主主義のしくみ図解',
        child: Column(
          children: const [
            _FlowRow(
              emoji: '👨‍👩‍👧',
              label: '国民がリーダー（議員）を選ぶ',
              color: Color(0xFF9B59B6),
            ),
            _ArrowDown(),
            _FlowRow(
              emoji: '🏛',
              label: '議員がみんなのために法律・予算を決める',
              color: Color(0xFF9B59B6),
            ),
            _ArrowDown(),
            _FlowRow(
              emoji: '🔄',
              label: '国民が政治をチェック・次の選挙で判断',
              color: Color(0xFF9B59B6),
            ),
          ],
        ),
      ),
      _DiagramCard(
        title: '選挙権が18歳になった理由',
        child: const Text(
          '2015年に公職選挙法が改正され、選挙権年齢が20歳から18歳に引き下げられました。'
          '若い人たちにも政治参加してもらい、未来の日本をみんなで考えるためです。'
          '世界では多くの国が18歳以上を選挙権年齢としており、日本も国際標準に合わせました。',
          style: TextStyle(
            fontSize: 13,
            color: Color(0xFF555555),
            height: 1.6,
          ),
        ),
      ),
    ],
  );
}

Widget _zeikinDiagram() {
  return Column(
    children: [
      _DiagramCard(
        title: '図解：税金の流れ',
        child: Column(
          children: const [
            _FlowRow(
              emoji: '👨‍👩‍👧',
              label: '国民が税金を払う',
              color: Color(0xFFF39C12),
            ),
            _ArrowDown(),
            _FlowRow(
              emoji: '🏛',
              label: '国・地方公共団体が集める',
              color: Color(0xFFF39C12),
            ),
            _ArrowDown(),
            _FlowRow(
              emoji: '🏫🏥🛣',
              label: '学校・病院・道路・公園などに使われる',
              color: Color(0xFFF39C12),
            ),
          ],
        ),
      ),
      _DiagramCard(
        title: '主な税の種類',
        child: Column(
          children: [
            _taxRow('消費税\nしょうひぜい', '買い物のたびに払う税（10%）', '🛒'),
            const SizedBox(height: 6),
            _taxRow('所得税\nしょとくぜい', '働いて得た収入にかかる税', '💼'),
            const SizedBox(height: 6),
            _taxRow('法人税\nほうじんぜい', '会社の利益にかかる税', '🏢'),
            const SizedBox(height: 6),
            _taxRow('固定資産税\nこていしさんぜい', '土地や建物を持つ人が払う税', '🏠'),
          ],
        ),
      ),
      _DiagramCard(
        title: '税金の主な使われ方（イメージ）',
        child: Column(
          children: [
            _barItem('社会保障\nしゃかいほしょう（医療・年金など）', 0.33, const Color(0xFFE74C3C)),
            const SizedBox(height: 6),
            _barItem('教育\nきょういく・科学・文化', 0.18, const Color(0xFF3498DB)),
            const SizedBox(height: 6),
            _barItem('公共事業\nこうきょうじぎょう（道路・橋など）', 0.12, const Color(0xFF2ECC71)),
            const SizedBox(height: 6),
            _barItem('国債費\nこくさいひ（借金の返済）', 0.24, const Color(0xFFF39C12)),
          ],
        ),
      ),
    ],
  );
}

Widget _taxRow(String name, String desc, String emoji) {
  return Row(
    children: [
      Text(emoji, style: const TextStyle(fontSize: 20)),
      const SizedBox(width: 8),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Color(0xFF444444),
                height: 1.2,
              ),
            ),
            Text(
              desc,
              style: const TextStyle(fontSize: 12, color: Color(0xFF666666)),
            ),
          ],
        ),
      ),
    ],
  );
}

Widget _barItem(String label, double ratio, Color color) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: const TextStyle(
          fontSize: 11,
          color: Color(0xFF555555),
          height: 1.2,
        ),
      ),
      const SizedBox(height: 3),
      Row(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: ratio,
                minHeight: 14,
                backgroundColor: const Color(0xFFEEEEEE),
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${(ratio * 100).round()}%',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    ],
  );
}

Widget _sangyoDiagram() {
  return Column(
    children: [
      _DiagramCard(
        title: '産業の三分類',
        child: Column(
          children: [
            _industryRow('第一次産業\nだいいちじさんぎょう', '農業・漁業・林業', '🌾🐟🌲', const Color(0xFF27AE60)),
            const SizedBox(height: 8),
            _industryRow('第二次産業\nだいにじさんぎょう', '工業・建設業・鉱業', '🏭🔧⛏', const Color(0xFF2980B9)),
            const SizedBox(height: 8),
            _industryRow('第三次産業\nだいさんじさんぎょう', 'サービス業・商業・交通', '🏪🚗📡', const Color(0xFF8E44AD)),
          ],
        ),
      ),
      _DiagramCard(
        title: '日本の主要輸出品（割合イメージ）',
        child: Column(
          children: [
            _barItem('自動車\nじどうしゃ・輸送機器\nゆそうきき', 0.40, const Color(0xFF9B59B6)),
            const SizedBox(height: 6),
            _barItem('機械類\nきかいるい・電子部品\nでんしぶひん', 0.25, const Color(0xFF2ECC71)),
            const SizedBox(height: 6),
            _barItem('化学製品\nかがくせいひん', 0.11, const Color(0xFFF39C12)),
            const SizedBox(height: 6),
            _barItem('その他', 0.24, const Color(0xFF95A5A6)),
          ],
        ),
      ),
      _DiagramCard(
        title: '少子高齢化の課題',
        child: const Text(
          '日本では子どもの数（少子化）が減り、高齢者の割合が増えています（高齢化）。'
          '働く人の数が減ると、税収が下がり、社会保障（年金・医療）を支えることが難しくなります。'
          'この問題を解決するため、女性・外国人・高齢者が活躍できる社会づくりが進められています。',
          style: TextStyle(
            fontSize: 13,
            color: Color(0xFF555555),
            height: 1.6,
          ),
        ),
      ),
    ],
  );
}

Widget _industryRow(String name, String examples, String emoji, Color color) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.08),
      border: Border.all(color: color.withValues(alpha: 0.4)),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 20)),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: color,
                  height: 1.2,
                ),
              ),
              Text(
                examples,
                style: const TextStyle(fontSize: 12, color: Color(0xFF555555)),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

Widget _boeikiDiagram() {
  return Column(
    children: [
      _DiagramCard(
        title: '日本の主要貿易相手国（輸出）',
        child: Column(
          children: [
            _tradeRow('🇺🇸', 'アメリカ', '自動車・機械', 0.20, const Color(0xFF3498DB)),
            const SizedBox(height: 6),
            _tradeRow('🇨🇳', '中国\nちゅうごく', '機械・電子部品', 0.19, const Color(0xFFE74C3C)),
            const SizedBox(height: 6),
            _tradeRow('🇰🇷', '韓国\nかんこく', '機械・化学品', 0.07, const Color(0xFF2ECC71)),
            const SizedBox(height: 6),
            _tradeRow('🇹🇼', '台湾\nたいわん', '半導体・機械', 0.07, const Color(0xFFF39C12)),
          ],
        ),
      ),
      _DiagramCard(
        title: '主な輸出品・輸入品',
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '輸出（ゆしゅつ）',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2ECC71),
                    ),
                  ),
                  const SizedBox(height: 6),
                  ...[
                    '🚗 自動車',
                    '🔧 機械',
                    '💡 電子部品',
                    '⚗️ 化学品',
                  ].map(
                    (e) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        e,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF444444),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(width: 1, height: 100, color: const Color(0xFFEEEEEE)),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '輸入（ゆにゅう）',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFE74C3C),
                    ),
                  ),
                  const SizedBox(height: 6),
                  ...[
                    '🛢 石油',
                    '⚡ 天然ガス',
                    '🌾 食料',
                    '🪵 木材',
                  ].map(
                    (e) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        e,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF444444),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      _DiagramCard(
        title: '国際連合（国連）のしくみ',
        child: const Text(
          '国際連合（UN）は1945年に設立された世界最大の国際機関です。'
          '現在193か国が加盟しており（日本は1956年加盟）、世界平和・人権・環境・開発などの問題に取り組みます。'
          '重要な決定は安全保障理事会（アメリカ・ロシア・中国・イギリス・フランスの5か国が常任理事国）で行われます。',
          style: TextStyle(
            fontSize: 13,
            color: Color(0xFF555555),
            height: 1.6,
          ),
        ),
      ),
    ],
  );
}

Widget _tradeRow(
  String flag,
  String country,
  String items,
  double ratio,
  Color color,
) {
  return Row(
    children: [
      Text(flag, style: const TextStyle(fontSize: 20)),
      const SizedBox(width: 8),
      SizedBox(
        width: 60,
        child: Text(
          country,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: Color(0xFF333333),
            height: 1.2,
          ),
        ),
      ),
      Expanded(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: ratio,
            minHeight: 12,
            backgroundColor: const Color(0xFFEEEEEE),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ),
      const SizedBox(width: 6),
      Text(
        '${(ratio * 100).round()}%',
        style: TextStyle(
          fontSize: 11,
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    ],
  );
}

Widget _kankyoDiagram() {
  return Column(
    children: [
      _DiagramCard(
        title: '地球温暖化のしくみ',
        child: Column(
          children: const [
            _FlowRow(
              emoji: '🏭🚗',
              label: '工場・車などから二酸化炭素（CO₂）が出る',
              color: Color(0xFFE74C3C),
            ),
            _ArrowDown(),
            _FlowRow(
              emoji: '🌍',
              label: '大気中に温室効果ガスが増える',
              color: Color(0xFFE74C3C),
            ),
            _ArrowDown(),
            _FlowRow(
              emoji: '🌡',
              label: '地球の気温が上がる（温暖化）',
              color: Color(0xFFE74C3C),
            ),
            _ArrowDown(),
            _FlowRow(
              emoji: '🌊🔥',
              label: '海面上昇・異常気象・生態系への影響',
              color: Color(0xFFE74C3C),
            ),
          ],
        ),
      ),
      _DiagramCard(
        title: 'SDGs 17の目標（かんたん版）',
        child: Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            _sdgChip('1', '貧困をなくす', const Color(0xFFE5243B)),
            _sdgChip('2', '飢餓をゼロ', const Color(0xFFDDA63A)),
            _sdgChip('3', '健康と福祉', const Color(0xFF4C9F38)),
            _sdgChip('4', '質の高い教育', const Color(0xFFC5192D)),
            _sdgChip('5', 'ジェンダー平等', const Color(0xFFFF3A21)),
            _sdgChip('6', '安全な水', const Color(0xFF26BDE2)),
            _sdgChip('7', 'エネルギー', const Color(0xFFFCC30B)),
            _sdgChip('8', '経済成長・雇用', const Color(0xFFA21942)),
            _sdgChip('9', '産業・革新', const Color(0xFFFF6A11)),
            _sdgChip('10', '不平等をなくす', const Color(0xFFDD1367)),
            _sdgChip('11', '住み続けられる街', const Color(0xFFFD9D24)),
            _sdgChip('12', 'つくる・使う', const Color(0xFFBF8B2E)),
            _sdgChip('13', '気候変動', const Color(0xFF3F7E44)),
            _sdgChip('14', '海の豊かさ', const Color(0xFF0A97D9)),
            _sdgChip('15', '陸の豊かさ', const Color(0xFF56C02B)),
            _sdgChip('16', '平和と公正', const Color(0xFF00689D)),
            _sdgChip('17', 'パートナーシップ', const Color(0xFF19486A)),
          ],
        ),
      ),
      _DiagramCard(
        title: '3R（スリーアール）の具体例',
        child: Column(
          children: [
            _threeRRow('Reduce\nリデュース', '減らす', '買い過ぎをやめる・食品ロスをなくす', '♻️', const Color(0xFF27AE60)),
            const SizedBox(height: 6),
            _threeRRow('Reuse\nリユース', '繰り返し使う', 'マイボトル・フリマアプリ・お下がり', '🔄', const Color(0xFF2980B9)),
            const SizedBox(height: 6),
            _threeRRow('Recycle\nリサイクル', '再資源化', 'ゴミの分別・ペットボトル回収', '🗑', const Color(0xFFF39C12)),
          ],
        ),
      ),
    ],
  );
}

Widget _sdgChip(String num, String label, Color color) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(6),
    ),
    child: Text(
      '$num. $label',
      style: const TextStyle(
        fontSize: 9,
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
    ),
  );
}

Widget _threeRRow(
  String name,
  String meaning,
  String examples,
  String emoji,
  Color color,
) {
  return Container(
    padding: const EdgeInsets.all(8),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.08),
      border: Border.all(color: color.withValues(alpha: 0.3)),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(emoji, style: const TextStyle(fontSize: 22)),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: color,
                  height: 1.2,
                ),
              ),
              Text(
                meaning,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333),
                ),
              ),
              Text(
                examples,
                style: const TextStyle(fontSize: 12, color: Color(0xFF666666)),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

// ─────────────────────────────────────────────────────────────
// Section data
// ─────────────────────────────────────────────────────────────

final List<_SectionInfo> _sections = [
  _SectionInfo(
    id: 'seiji',
    title: '日本の政治のしくみ',
    furigana: 'にほんのせいじのしくみ',
    icon: Icons.account_balance,
    color: const Color(0xFF2ECC71),
    description:
        '日本は「国会」「内閣」「裁判所」の三つの機関が国を動かしています。'
        'これを「三権分立」といい、一つの機関に権力が集まりすぎないようにしています。'
        '国会は「衆議院」と「参議院」の二院制（にいんせい）で成り立ち、国の法律や予算を決めます。'
        '内閣は国会が決めた法律にもとづいて政治を行い、内閣総理大臣が中心になります。'
        '裁判所は法律にもとづいて争いごとを判断します。',
    pointsSummary:
        '・三権分立 = 国会（立法）・内閣（行政）・裁判所（司法）\n'
        '・国会には衆議院（4年）と参議院（6年）がある\n'
        '・内閣総理大臣は国会議員の中から国会が指名する\n'
        '・日本国憲法は三権それぞれの役割を定めている',
    lifeConnection:
        '学校のルール（校則）は「法律」、先生や校長先生の指示が「行政」に例えられます。'
        '「選挙で選ばれた人が国のルールを作る」という仕組みは、みんなの声を政治に届ける大切なしかけです。',
    diagramBuilder: _seijiDiagram,
  ),
  _SectionInfo(
    id: 'senkyo',
    title: '選挙と民主主義',
    furigana: 'せんきょとみんしゅしゅぎ',
    icon: Icons.how_to_vote,
    color: const Color(0xFF3498DB),
    description:
        '民主主義とは、国民が政治に参加してみんなで国を動かすしくみです。'
        '日本では18歳以上のすべての国民が選挙で投票できます。'
        '衆議院議員は4年ごと、参議院議員は6年ごとに選挙が行われます。'
        '投票は「ひみつ投票」なので、自分の意見を自由に表現できます。'
        '棄権（きけん：投票しないこと）が増えると、国民の意見が政治に反映されにくくなります。',
    pointsSummary:
        '・民主主義 = 国民が政治に参加するしくみ\n'
        '・選挙権は18歳以上（2015年の法改正で20歳から引き下げ）\n'
        '・衆議院：4年任期、参議院：6年任期\n'
        '・投票はひみつ（秘密選挙）',
    lifeConnection:
        '学校のクラス委員を選挙で選ぶのも民主主義の練習です。'
        '「多数決」はみんなの意見をまとめる方法ですが、少数意見も大切にすることが本当の民主主義です。',
    diagramBuilder: _senkyoDiagram,
  ),
  _SectionInfo(
    id: 'zeikin',
    title: '税金とくらし',
    furigana: 'ぜいきんとくらし',
    icon: Icons.payments,
    color: const Color(0xFFF39C12),
    description:
        '税金はみんなが出し合うお金で、道路・学校・病院などの公共サービスに使われます。'
        '買い物のときにかかる消費税は現在10%です（食料品などは8%の軽減税率）。'
        '所得税（しょとくぜい）は働いて得た収入にかかる税金で、収入が多いほど税率が高くなります（累進課税：るいしんかぜい）。'
        '法人税（ほうじんぜい）は会社の利益にかかる税金です。'
        '税金は国（直接税・間接税）と地方（都道府県・市区町村）の両方が集めます。',
    pointsSummary:
        '・消費税：買い物のたびに払う（10%、食料品8%）\n'
        '・所得税：働いた収入にかかる税\n'
        '・法人税：会社の利益にかかる税\n'
        '・税金の使い道：社会保障・教育・公共事業など',
    lifeConnection:
        '110円の物を買うと、そのうち10円が消費税です。学校も無料で通えるのは、みんなの税金のおかげです。'
        '自分が大人になったら税金を払う義務（義務：ぎむ）があります。',
    diagramBuilder: _zeikinDiagram,
  ),
  _SectionInfo(
    id: 'sangyo',
    title: '日本の産業と経済',
    furigana: 'にほんのさんぎょうとけいざい',
    icon: Icons.factory,
    color: const Color(0xFF9B59B6),
    description:
        '日本は自動車・機械・電子部品などの製造業が盛んです。'
        '農業・漁業・林業は第一次産業、工業・建設業は第二次産業、サービス業・小売業は第三次産業とよばれます。'
        '日本のGDP（国内総生産：こくないそうせいさん）は世界第4位（2024年時点）で、経済大国のひとつです。'
        '近年は少子高齢化により働く人口が減り、AI・ロボットの活用や女性・外国人の活躍が求められています。',
    pointsSummary:
        '・第一次産業：農業・漁業・林業\n'
        '・第二次産業：工業・建設業・鉱業\n'
        '・第三次産業：サービス業・商業・情報通信\n'
        '・日本の主要輸出品：自動車・機械・電子部品\n'
        '・課題：少子高齢化・労働力不足',
    lifeConnection:
        '私たちが毎日使うスマホ・テレビ・車は製造業が作っています。'
        'スーパーでの買い物や学習塾はサービス業です。身の回りすべてが経済活動とつながっています。',
    diagramBuilder: _sangyoDiagram,
  ),
  _SectionInfo(
    id: 'boeki',
    title: '貿易と国際関係',
    furigana: 'ぼうえきとこくさいかんけい',
    icon: Icons.public,
    color: const Color(0xFF1ABC9C),
    description:
        '貿易（ぼうえき）とは外国と品物を売り買いすることです。'
        '日本は石油・天然ガス・食料などの資源が少ないため多くを輸入し、自動車・機械・電子部品などを輸出しています。'
        '主要貿易相手国はアメリカ・中国・韓国・台湾などです。'
        '国際連合（国連・UN）は世界平和・人権・環境問題に取り組む世界最大の国際機関で、193か国が加盟しています（日本は1956年加盟）。'
        '安全保障理事会（あんぽりじかい）の常任理事国5か国（米・英・仏・露・中）は重要な決定に参加します。',
    pointsSummary:
        '・貿易 = 外国と品物を売り買いすること\n'
        '・日本の主要輸出品：自動車・機械・電子部品\n'
        '・日本の主要輸入品：石油・天然ガス・食料\n'
        '・国際連合（UN）：世界平和のための国際機関（193か国加盟）\n'
        '・安全保障理事会：5常任理事国（米・英・仏・露・中）',
    lifeConnection:
        '私たちが食べる食料の約6割（カロリーベース）は外国から輸入しています。'
        '身の回りの「made in ○○」を見ると、世界とのつながりが実感できます。',
    diagramBuilder: _boeikiDiagram,
  ),
  _SectionInfo(
    id: 'kankyo',
    title: '環境問題',
    furigana: 'かんきょうもんだい',
    icon: Icons.eco,
    color: const Color(0xFF27AE60),
    description:
        '地球温暖化・大気汚染・水質汚染など、地球規模の環境問題が起きています。'
        '温暖化の主な原因は二酸化炭素（CO₂）などの温室効果ガスで、工場・自動車・発電所などから排出されます。'
        'SDGs（エスディージーズ：持続可能な開発目標）は2015年に国連が採択した17の目標で、'
        '2030年までに貧困・不平等・気候変動などの問題を解決しようとしています。'
        '3R（リデュース・リユース・リサイクル）は日常生活でできるごみ削減の取り組みです。',
    pointsSummary:
        '・地球温暖化：CO₂増加→気温上昇→海面上昇・異常気象\n'
        '・SDGs：国連の17目標（2030年目標）\n'
        '・3R：リデュース（減らす）・リユース（再利用）・リサイクル\n'
        '・日本の公害：水俣病・イタイイタイ病・四日市ぜんそくなど',
    lifeConnection:
        'ゴミの分別・マイバッグ・マイボトル・節電はすべて環境を守る行動です。'
        '私たちが毎日少しずつ実践することで、地球の未来を変えることができます。',
    diagramBuilder: _kankyoDiagram,
  ),
];

// ─────────────────────────────────────────────────────────────
// Screen
// ─────────────────────────────────────────────────────────────

class EconomicsScreen extends ConsumerWidget {
  const EconomicsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coins = ref.watch(coinsProvider);

    return Scaffold(
      backgroundColor: const Color(AppColors.bgLight),
      appBar: AppBar(
        title: const Text('経済・政治'),
        centerTitle: true,
        backgroundColor: AppColors.primary,
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
  final _SectionInfo section;

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
                      child: Icon(s.icon, color: Colors.white, size: 24),
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
                child: RubyText.fromAnnotated(
                  s.description.withRuby,
                  textFontSize: 14,
                  rubyFontSize: 9,
                  textColor: const Color(0xFF555555),
                ),
              ),

              // ─── Diagram ─────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
                child: s.diagramBuilder(),
              ),

              // ─── Points summary ───────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 6, 16, 4),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: s.color.withValues(alpha: 0.07),
                    border: Border.all(
                      color: s.color.withValues(alpha: 0.3),
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.star_rounded,
                            color: s.color,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'ポイントまとめ',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: s.color,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        s.pointsSummary,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF444444),
                          height: 1.6,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ─── Life connection ──────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 6, 16, 4),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF9E6),
                    border: Border.all(
                      color: const Color(0xFFF39C12).withValues(alpha: 0.4),
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Text('🏠', style: TextStyle(fontSize: 14)),
                          SizedBox(width: 4),
                          Text(
                            'みんなのくらしとのつながり',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFB7770D),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        s.lifeConnection,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF555555),
                          height: 1.6,
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
                        context.push('/economics-quiz/${s.id}'),
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
