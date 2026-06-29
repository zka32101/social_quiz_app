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
    id: 'constitution',
    title: '憲法の三大原則',
    description: '国民主権・基本的人権の尊重・平和主義の三つの原則について学ぼう。',
    icon: Icons.gavel,
    color: Colors.purple,
    route: '/civics-quiz/constitution',
  ),
  _SectionInfo(
    id: 'separation_of_powers',
    title: '三権分立',
    description: '国会・内閣・裁判所の役割と、権力がバランスを保つしくみを学ぼう。',
    icon: Icons.account_balance,
    color: Colors.indigo,
    route: '/civics-quiz/separation_of_powers',
  ),
  _SectionInfo(
    id: 'national_assembly',
    title: '国会のしくみ',
    description: '衆議院と参議院の二院制と、法律が作られるしくみを学ぼう。',
    icon: Icons.people,
    color: Colors.blue,
    route: '/civics-quiz/national_assembly',
  ),
  _SectionInfo(
    id: 'taxes',
    title: '税金',
    description: '消費税・所得税など税金の種類と、使われ方について学ぼう。',
    icon: Icons.monetization_on,
    color: Colors.green,
    route: '/civics-quiz/taxes',
  ),
  _SectionInfo(
    id: 'elections',
    title: '選挙・地方自治',
    description: '選挙の仕組みと地方自治体のはたらきについて学ぼう。',
    icon: Icons.how_to_vote,
    color: Colors.orange,
    route: '/civics-quiz/elections',
  ),
];

// ─────────────────────────────────────────────────────────────
// Screen
// ─────────────────────────────────────────────────────────────

class CivicsScreen extends ConsumerWidget {
  const CivicsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coins = ref.watch(coinsProvider);

    return Scaffold(
      backgroundColor: const Color(AppColors.bgLight),
      appBar: AppBar(
        title: const Text('小学6年生・公民'),
        centerTitle: true,
        backgroundColor: Colors.purple,
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
