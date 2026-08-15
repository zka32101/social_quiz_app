import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../utils/constants.dart';

// ─── Section data model ───────────────────────────────────────────────────────

class _Grade3Section {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final String route;

  const _Grade3Section({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.route,
  });
}

const _sections = <_Grade3Section>[
  _Grade3Section(
    id: 'map_symbols',
    title: '地図記号',
    description: '学校・病院・田んぼなど、地図に使われる記号を学ぼう！',
    icon: Icons.map,
    color: Colors.green,
    route: '/grade3-quiz/map_symbols',
  ),
  _Grade3Section(
    id: 'directions',
    title: '方位',
    description: '東西南北の方位と、方位磁針の使い方を学ぼう！',
    icon: Icons.explore,
    color: Colors.blue,
    route: '/grade3-quiz/directions',
  ),
  _Grade3Section(
    id: 'old_life',
    title: '昔のくらし',
    description: '昔の道具や人々の生活の様子を学ぼう！',
    icon: Icons.history,
    color: Colors.brown,
    route: '/grade3-quiz/old_life',
  ),
  _Grade3Section(
    id: 'public_services',
    title: '消防・警察',
    description: '消防署や警察署の仕事と、地域を守るしくみを学ぼう！',
    icon: Icons.local_fire_department,
    color: Colors.red,
    route: '/grade3-quiz/public_services',
  ),
  _Grade3Section(
    id: 'supermarket',
    title: 'スーパーの工夫',
    description: 'スーパーマーケットの売り場のひみつや工夫を学ぼう！',
    icon: Icons.store,
    color: Colors.orange,
    route: '/grade3-quiz/supermarket',
  ),
];

// ─── Screen ──────────────────────────────────────────────────────────────────

class Grade3Screen extends ConsumerWidget {
  const Grade3Screen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('小学3年生の社会'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        children: [
          // ─── Header banner ─────────────────────────────────────
          _HeaderBanner(),
          const SizedBox(height: 16),

          // ─── Section cards ─────────────────────────────────────
          for (final section in _sections) ...[
            _SectionCard(section: section),
            const SizedBox(height: 12),
          ],

          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

// ─── Header banner ───────────────────────────────────────────────────────────

class _HeaderBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(AppColors.primaryValue).withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: const Color(AppColors.primaryValue).withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Center(
              child: Text('🏫', style: TextStyle(fontSize: 28)),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '小3社会科',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333333),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'カテゴリーを選んでクイズに挑戦しよう！',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Section card ────────────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  final _Grade3Section section;

  const _SectionCard({required this.section});

  @override
  Widget build(BuildContext context) {
    final color = section.color;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.25), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // ─── Icon ──────────────────────────────────────────────
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(section.icon, color: color, size: 28),
            ),
            const SizedBox(width: 14),

            // ─── Text ─────────────────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    section.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    section.description,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF666666),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      // go() だとルートスタックが置き換わり、クイズ中に
                      // 戻るボタン・閉じるボタンが無くなってしまうため push() を使う
                      // （他の教科一覧画面と統一）
                      onPressed: () => context.push(section.route),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: color,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      child: const Text('クイズに挑戦 →'),
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
