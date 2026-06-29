import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class _RegionInfo {
  final String name;
  final String emoji;
  final Color color;
  final List<String> prefectures;
  final String tip;

  const _RegionInfo({
    required this.name,
    required this.emoji,
    required this.color,
    required this.prefectures,
    required this.tip,
  });
}

const _regions = <_RegionInfo>[
  _RegionInfo(
    name: '北海道地方',
    emoji: '🐻',
    color: Color(0xFF1565C0),
    prefectures: ['北海道'],
    tip: '日本でいちばん広い・1道だけの地方',
  ),
  _RegionInfo(
    name: '東北地方',
    emoji: '⛄',
    color: Color(0xFF0277BD),
    prefectures: ['青森県', '岩手県', '宮城県', '秋田県', '山形県', '福島県'],
    tip: '6県。雪が多く、稲作がさかん',
  ),
  _RegionInfo(
    name: '関東地方',
    emoji: '🗼',
    color: Color(0xFF2E7D32),
    prefectures: ['茨城県', '栃木県', '群馬県', '埼玉県', '千葉県', '東京都', '神奈川県'],
    tip: '1都6県。首都・東京がある地方',
  ),
  _RegionInfo(
    name: '中部地方',
    emoji: '🏔️',
    color: Color(0xFF6A1B9A),
    prefectures: ['新潟県', '富山県', '石川県', '福井県', '山梨県', '長野県', '岐阜県', '静岡県', '愛知県'],
    tip: '9県。日本アルプス（3000m級）がそびえる',
  ),
  _RegionInfo(
    name: '近畿地方',
    emoji: '⛩️',
    color: Color(0xFFC62828),
    prefectures: ['三重県', '滋賀県', '京都府', '大阪府', '兵庫県', '奈良県', '和歌山県'],
    tip: '2府5県。京都・奈良に古都が多い',
  ),
  _RegionInfo(
    name: '中国地方',
    emoji: '🏯',
    color: Color(0xFF4E342E),
    prefectures: ['鳥取県', '島根県', '岡山県', '広島県', '山口県'],
    tip: '5県。中国山地が東西に走る',
  ),
  _RegionInfo(
    name: '四国地方',
    emoji: '🍊',
    color: Color(0xFFE65100),
    prefectures: ['徳島県', '香川県', '愛媛県', '高知県'],
    tip: '4県だけ。うどん・みかんが有名',
  ),
  _RegionInfo(
    name: '九州・沖縄地方',
    emoji: '🌋',
    color: Color(0xFF00695C),
    prefectures: ['福岡県', '佐賀県', '長崎県', '熊本県', '大分県', '宮崎県', '鹿児島県', '沖縄県'],
    tip: '8県。火山・温泉が多く、沖縄は亜熱帯',
  ),
];

class RegionMapScreen extends StatelessWidget {
  const RegionMapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('地方マップで学ぼう'),
        elevation: 0,
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 20),
              itemCount: _regions.length,
              itemBuilder: (context, i) => _RegionCard(
                region: _regions[i],
                number: i + 1,
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/grade4-quiz/regions'),
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.quiz_outlined),
        label: const Text('地方区分クイズへ'),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1565C0), Color(0xFF0D47A1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Row(
        children: [
          Text('🗾', style: TextStyle(fontSize: 30)),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '日本の8つの地方',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'タップして都道府県を確認しよう！',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RegionCard extends StatefulWidget {
  final _RegionInfo region;
  final int number;

  const _RegionCard({required this.region, required this.number});

  @override
  State<_RegionCard> createState() => _RegionCardState();
}

class _RegionCardState extends State<_RegionCard>
    with SingleTickerProviderStateMixin {
  bool _expanded = false;
  late final AnimationController _ctrl;
  late final Animation<double> _heightFactor;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
    );
    _heightFactor = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() => _expanded = !_expanded);
    if (_expanded) {
      _ctrl.forward();
    } else {
      _ctrl.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.region;
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          InkWell(
            onTap: _toggle,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: r.color.withOpacity(0.10),
                border: Border(
                  left: BorderSide(color: r.color, width: 5),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: r.color,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '${widget.number}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(r.emoji, style: const TextStyle(fontSize: 24)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          r.name,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: r.color,
                          ),
                        ),
                        Text(
                          r.tip,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Chip(
                    label: Text(
                      '${r.prefectures.length}',
                      style: TextStyle(
                        fontSize: 11,
                        color: r.color,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    backgroundColor: r.color.withOpacity(0.13),
                    side: BorderSide.none,
                    padding: EdgeInsets.zero,
                    visualDensity: VisualDensity.compact,
                  ),
                  const SizedBox(width: 4),
                  AnimatedRotation(
                    turns: _expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 260),
                    child: Icon(Icons.expand_more, color: r.color),
                  ),
                ],
              ),
            ),
          ),
          ClipRect(
            child: AnimatedBuilder(
              animation: _heightFactor,
              builder: (context, child) => Align(
                heightFactor: _heightFactor.value,
                child: child,
              ),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(14, 6, 14, 12),
                color: r.color.withOpacity(0.05),
                child: Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: r.prefectures.map((pref) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: r.color.withOpacity(0.4)),
                        boxShadow: [
                          BoxShadow(
                            color: r.color.withOpacity(0.08),
                            blurRadius: 3,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Text(
                        pref,
                        style: TextStyle(
                          fontSize: 12,
                          color: r.color,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
