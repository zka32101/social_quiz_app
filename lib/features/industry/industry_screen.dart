import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../repositories/progress_repository.dart';
import '../../utils/constants.dart';

// ─────────────────────────────────────────────────────────────
// Section model
// ─────────────────────────────────────────────────────────────

class _SectionInfo {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final String route;

  const _SectionInfo({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.route,
  });
}

// ─────────────────────────────────────────────────────────────
// Section data
// ─────────────────────────────────────────────────────────────

const List<_SectionInfo> _sections = [
  _SectionInfo(
    id: 'agriculture',
    title: '農業',
    description: '日本の農業の特色や主な農産物、農家が抱える課題について学ぼう。',
    icon: Icons.grass,
    color: Colors.green,
    route: '/industry-quiz/agriculture',
  ),
  _SectionInfo(
    id: 'fishery',
    title: '水産業',
    description: '漁業の種類・漁港・水産物の流通など、日本の水産業を学ぼう。',
    icon: Icons.water,
    color: Colors.blue,
    route: '/industry-quiz/fishery',
  ),
  _SectionInfo(
    id: 'manufacturing',
    title: '工業・工業地帯',
    description: '太平洋ベルトや主要な工業地帯の特色と、日本の工業製品を学ぼう。',
    icon: Icons.factory,
    color: Colors.grey,
    route: '/industry-quiz/manufacturing',
  ),
  _SectionInfo(
    id: 'food_self_sufficiency',
    title: '食料自給率',
    description: '日本の食料自給率の現状・問題点・改善のための取り組みを学ぼう。',
    icon: Icons.restaurant,
    color: Colors.orange,
    route: '/industry-quiz/food_self_sufficiency',
  ),
  _SectionInfo(
    id: 'pollution',
    title: '公害・環境問題',
    description: '四大公害病や地球温暖化など、環境問題とその対策を学ぼう。',
    icon: Icons.eco,
    color: Colors.teal,
    route: '/industry-quiz/pollution',
  ),
  _SectionInfo(
    id: 'information_society',
    title: '情報化社会',
    description: 'インターネット・ICT・メディアリテラシーなど情報社会の特徴を学ぼう。',
    icon: Icons.computer,
    color: Colors.indigo,
    route: '/industry-quiz/information_society',
  ),
];

// ─────────────────────────────────────────────────────────────
// Screen
// ─────────────────────────────────────────────────────────────

class IndustryScreen extends ConsumerWidget {
  const IndustryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coins = ref.watch(coinsProvider);

    return Scaffold(
      backgroundColor: const Color(AppColors.bgLight),
      appBar: AppBar(
        title: const Text('小学5年生・産業と環境'),
        centerTitle: true,
        backgroundColor: Colors.teal,
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

class _SectionCard extends StatelessWidget {
  final _SectionInfo section;

  const _SectionCard({required this.section});

  @override
  Widget build(BuildContext context) {
    final s = section;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ─── Header row ──────────────────────────────────────
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: s.color,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(s.icon, color: Colors.white, size: 26),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      s.title,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF333333),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // ─── Description ─────────────────────────────────────
              Text(
                s.description,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF666666),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 14),

              // ─── Quiz button ──────────────────────────────────────
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => context.push(s.route),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: s.color,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  child: const Text('クイズに挑戦 →'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
