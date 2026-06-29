import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/prefecture_data.dart';
import '../../utils/constants.dart';

const Map<String, Color> _regionColors = {
  'hokkaido': Colors.teal,
  'tohoku':   Color(0xFF1565C0),
  'kanto':    Color(0xFF283593),
  'chubu':    Color(0xFF2E7D32),
  'kinki':    Color(0xFFE65100),
  'chugoku':  Color(0xFF6A1B9A),
  'shikoku':  Color(0xFF00838F),
  'kyushu':   Color(0xFFC62828),
};

const Map<String, String> _regionNames = {
  'hokkaido': '北海道地方',
  'tohoku':   '東北地方',
  'kanto':    '関東地方',
  'chubu':    '中部地方',
  'kinki':    '近畿地方',
  'chugoku':  '中国地方',
  'shikoku':  '四国地方',
  'kyushu':   '九州・沖縄地方',
};

class PrefectureDetailScreen extends ConsumerWidget {
  final String prefectureId;
  const PrefectureDetailScreen({required this.prefectureId, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pref = PrefectureDataList.findById(prefectureId);

    if (pref == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('エラー')),
        body: const Center(child: Text('都道府県データが見つかりませんでした')),
      );
    }

    final regionColor = _regionColors[pref.region] ?? AppColors.primary;
    final regionName = _regionNames[pref.region] ?? pref.region;

    return Scaffold(
      appBar: AppBar(
        title: Text('${pref.emoji} ${pref.name}'),
        backgroundColor: regionColor,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ヒーローカード
            Container(
              color: regionColor,
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
              child: Column(
                children: [
                  Text(pref.emoji, style: const TextStyle(fontSize: 72)),
                  const SizedBox(height: 8),
                  Text(
                    pref.name,
                    style: const TextStyle(
                      fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      regionName,
                      style: const TextStyle(fontSize: 14, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),

            // 情報カード
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _InfoCard(
                    children: [
                      _InfoRow(icon: '🏛', label: '県庁所在地', value: pref.capital),
                      const Divider(height: 16),
                      const Padding(
                        padding: EdgeInsets.only(bottom: 8),
                        child: Row(children: [
                          Text('🍱 ', style: TextStyle(fontSize: 18)),
                          Text('名産・特産物', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF666666))),
                        ]),
                      ),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: pref.specialties.map((s) => Chip(
                          label: Text(s, style: const TextStyle(fontSize: 12)),
                          backgroundColor: regionColor.withValues(alpha: 0.12),
                          side: BorderSide(color: regionColor.withValues(alpha: 0.3)),
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                        )).toList(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _InfoCard(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('📝 ', style: TextStyle(fontSize: 18)),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('説明', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF666666))),
                                const SizedBox(height: 6),
                                Text(pref.description, style: const TextStyle(fontSize: 15, height: 1.6)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // 豆知識カード
                  _InfoCard(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('💡 ', style: TextStyle(fontSize: 18)),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('豆知識', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF666666))),
                                const SizedBox(height: 6),
                                Text(pref.funFact, style: const TextStyle(fontSize: 14, height: 1.6)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // アクションボタン
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => context.push('/quiz/$prefectureId'),
                      icon: const Icon(Icons.quiz),
                      label: const Text('クイズに挑戦！'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: regionColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => context.go('/japan-map'),
                      icon: const Icon(Icons.map),
                      label: const Text('地図に戻る'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(color: regionColor),
                        foregroundColor: regionColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final List<Widget> children;
  const _InfoCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String icon;
  final String label;
  final String value;
  const _InfoRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(icon, style: const TextStyle(fontSize: 18)),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(fontSize: 14, color: Color(0xFF666666), fontWeight: FontWeight.bold)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
        ),
      ],
    );
  }
}
