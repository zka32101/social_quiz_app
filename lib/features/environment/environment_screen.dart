import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
    id: 'pollution',
    title: '公害・汚染',
    description: '四大公害病・大気汚染・水質汚染を学ぼう',
    icon: Icons.factory,
    color: Color(0xFF795548),
  ),
  _Section(
    id: 'climate',
    title: '地球温暖化',
    description: '温室効果ガス・気候変動・海面上昇',
    icon: Icons.thermostat,
    color: Color(0xFFE53935),
  ),
  _Section(
    id: 'sdgs',
    title: 'SDGs',
    description: '持続可能な開発目標・17の目標',
    icon: Icons.public,
    color: Color(0xFF00897B),
  ),
  _Section(
    id: 'energy',
    title: 'エネルギー',
    description: '化石燃料・再生可能エネルギー・節電',
    icon: Icons.bolt,
    color: Color(0xFFF9A825),
  ),
  _Section(
    id: 'recycle',
    title: 'リサイクル',
    description: '3R・プラスチック問題・ゴミの分別',
    icon: Icons.recycling,
    color: Color(0xFF43A047),
  ),
  _Section(
    id: 'forest',
    title: '森林・自然',
    description: '森林破壊・生態系・自然環境の保護',
    icon: Icons.forest,
    color: Color(0xFF2E7D32),
  ),
];

class EnvironmentScreen extends StatelessWidget {
  const EnvironmentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('環境・SDGs'),
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.9,
              ),
              itemCount: _sections.length,
              itemBuilder: (context, i) => _SectionCard(
                section: _sections[i],
                onTap: () => context.push('/environment-quiz/${_sections[i].id}'),
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
          colors: [Color(0xFF00897B), Color(0xFF1B5E20)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Row(
        children: [
          Text('🌍', style: TextStyle(fontSize: 36)),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '環境・SDGs',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  '地球の未来を守るために学ぼう',
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
          decoration: BoxDecoration(color: section.color.withOpacity(0.07)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(section.icon, size: 44, color: section.color),
              const SizedBox(height: 8),
              Text(
                section.title,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                section.description,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
