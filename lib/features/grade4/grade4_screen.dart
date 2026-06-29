import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// 地方マップ学習バナー
class _MapStudyBanner extends StatelessWidget {
  const _MapStudyBanner();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: InkWell(
        onTap: () => context.push('/region-map'),
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1565C0), Color(0xFF1976D2)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF1565C0).withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              const Text('🗾', style: TextStyle(fontSize: 30)),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '地方マップで覚えよう！',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      '8つの地方と47都道府県を視覚的に確認',
                      style: TextStyle(color: Colors.white70, fontSize: 11),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  children: [
                    Text('学習する',
                        style: TextStyle(color: Colors.white, fontSize: 12)),
                    SizedBox(width: 3),
                    Icon(Icons.arrow_forward_ios,
                        size: 11, color: Colors.white),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Section {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  const _Section({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}

const _sections = <_Section>[
  _Section(
    id: 'prefectures',
    title: '都道府県',
    description: '47都道府県の場所・特色・県庁所在地を覚えよう',
    icon: Icons.map_outlined,
    color: Color(0xFF00897B),
  ),
  _Section(
    id: 'regions',
    title: '地方区分',
    description: '8つの地方と各地方の都道府県を学ぼう',
    icon: Icons.grid_view,
    color: Color(0xFF1976D2),
  ),
  _Section(
    id: 'geography',
    title: '山・川・湖',
    description: '日本の主な山・川・湖の特徴を学ぼう',
    icon: Icons.landscape,
    color: Color(0xFF558B2F),
  ),
  _Section(
    id: 'seasons',
    title: '気候・季節',
    description: '梅雨・台風など日本の気候の特徴を学ぼう',
    icon: Icons.cloud,
    color: Color(0xFF0288D1),
  ),
  _Section(
    id: 'water',
    title: '水道・下水',
    description: '水道水がどこから来るかを学ぼう',
    icon: Icons.water_drop,
    color: Color(0xFF00ACC1),
  ),
  _Section(
    id: 'disaster',
    title: '災害・防災',
    description: '地震・津波・洪水などの災害と防災を学ぼう',
    icon: Icons.warning_amber,
    color: Color(0xFFE53935),
  ),
];

class Grade4Screen extends StatelessWidget {
  const Grade4Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('小4 社会科'),
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildHeader(),
          const _MapStudyBanner(),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.9,
              ),
              itemCount: _sections.length,
              itemBuilder: (context, i) => _SectionCard(
                section: _sections[i],
                onTap: () => context.push('/grade4-quiz/${_sections[i].id}'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF00897B), Color(0xFF00695C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Row(
        children: [
          Text('🗾', style: TextStyle(fontSize: 36)),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '小学4年生 社会科',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  '都道府県・地方区分・防災を学ぼう',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final _Section section;
  final VoidCallback onTap;

  const _SectionCard({required this.section, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: section.color.withOpacity(0.07),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(section.icon, size: 44, color: section.color),
              const SizedBox(height: 8),
              Text(
                section.title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                section.description,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style:
                    TextStyle(fontSize: 11, color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
