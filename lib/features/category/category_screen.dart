import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../repositories/progress_repository.dart';
import '../../utils/constants.dart';

class _CategoryInfo {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final bool isAvailable;
  final bool isNew;
  final String? route;

  const _CategoryInfo({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.isAvailable,
    this.isNew = false,
    this.route,
  });
}

const List<_CategoryInfo> _categories = [
  // ── 地理 ───────────────────────────────────────────
  _CategoryInfo(
    title: '日本の地理',
    description: '都道府県・地方区分・特産物を覚えよう',
    icon: Icons.map,
    color: Colors.green,
    isAvailable: true,
    route: '/japan-map',
  ),
  _CategoryInfo(
    title: '世界の地理',
    description: '世界の国々・首都・地形を学ぼう',
    icon: Icons.public,
    color: Colors.blue,
    isAvailable: true,
    route: '/world-geography',
  ),
  // ── 学年別 ─────────────────────────────────────────
  _CategoryInfo(
    title: '小3 社会科',
    description: '地図記号・方位・昔のくらし・消防・警察',
    icon: Icons.school,
    color: Color(0xFF00ACC1),
    isAvailable: true,
    route: '/grade3',
  ),
  _CategoryInfo(
    title: '小4 社会科',
    description: '都道府県・地方区分・山川湖・防災',
    icon: Icons.map_outlined,
    color: Color(0xFF00897B),
    isAvailable: true,
    isNew: true,
    route: '/grade4',
  ),
  _CategoryInfo(
    title: '環境・SDGs',
    description: '地球温暖化・SDGs・3R・公害',
    icon: Icons.eco,
    color: Color(0xFF43A047),
    isAvailable: true,
    isNew: true,
    route: '/environment',
  ),
  _CategoryInfo(
    title: '小5 産業・環境',
    description: '農業・水産業・工業・公害・情報化社会',
    icon: Icons.factory,
    color: Color(0xFF00897B),
    isAvailable: true,
    route: '/industry',
  ),
  _CategoryInfo(
    title: '小6 公民',
    description: '憲法・三権分立・税金・選挙',
    icon: Icons.gavel,
    color: Color(0xFF6A1B9A),
    isAvailable: true,
    route: '/civics',
  ),
  // ── 総合 ───────────────────────────────────────────
  _CategoryInfo(
    title: '経済・政治',
    description: '日本の経済と政治のしくみ',
    icon: Icons.account_balance,
    color: Colors.orange,
    isAvailable: true,
    route: '/economics',
  ),
  _CategoryInfo(
    title: '国際',
    description: '世界とのつながりを学ぼう',
    icon: Icons.language,
    color: Colors.purple,
    isAvailable: true,
    route: '/international',
  ),
  _CategoryInfo(
    title: '歴史',
    description: '日本の歴史の流れをつかもう',
    icon: Icons.history_edu,
    color: Colors.brown,
    isAvailable: true,
    route: '/history',
  ),
  // ── 復習 ───────────────────────────────────────────
  _CategoryInfo(
    title: 'まちがい復習',
    description: '間違えた問題をもう一度やり直そう',
    icon: Icons.replay,
    color: Color(0xFFE53935),
    isAvailable: true,
    route: '/wrong-answer-review',
  ),
];

// 新カテゴリ抽出（バナー用）
final _newCategories = _categories.where((c) => c.isNew).toList();

class CategoryScreen extends ConsumerWidget {
  const CategoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coins = ref.watch(coinsProvider);
    final hasNew = _newCategories.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text('小学コレ！社会'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.military_tech),
            tooltip: 'バッジ',
            onPressed: () => context.go('/badges'),
          ),
          // ショップ（実装中のため非表示）
          if (AppConstants.enableShop)
            IconButton(
              icon: const Icon(Icons.store),
              tooltip: 'ショップ',
              onPressed: () => context.go('/shop'),
            ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _CoinBanner(coins: coins)),
          // ── 新着バナー ──────────────────────────────────
          if (hasNew)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.orange,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text('NEW',
                              style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(width: 8),
                        const Text('新しいカテゴリが追加されました！',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 80,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _newCategories.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 10),
                        itemBuilder: (context, i) {
                          final cat = _newCategories[i];
                          return GestureDetector(
                            onTap: cat.isAvailable ? () => context.go(cat.route!) : null,
                            child: Container(
                              width: 160,
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [cat.color, cat.color.withOpacity(0.7)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: cat.color.withOpacity(0.3),
                                    blurRadius: 6,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Icon(cat.icon, color: Colors.white, size: 28),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      cat.title,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Divider(),
                  ],
                ),
              ),
            ),
          // ── カテゴリグリッド ────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.85,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) => _CategoryCard(
                  info: _categories[index],
                  onTap: _categories[index].isAvailable
                      ? () => context.go(_categories[index].route!)
                      : null,
                ),
                childCount: _categories.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

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
        border: Border(bottom: BorderSide(color: Theme.of(context).dividerColor, width: 0.5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          const Text('🪙', style: TextStyle(fontSize: 18)),
          const SizedBox(width: 4),
          Text('$coins', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final _CategoryInfo info;
  final VoidCallback? onTap;

  const _CategoryCard({
    required this.info,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isAvailable = info.isAvailable;

    return Card(
      elevation: isAvailable ? 3 : 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                color: isAvailable
                    ? info.color.withValues(alpha: 0.08)
                    : Colors.grey.withValues(alpha: 0.06),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    info.icon,
                    size: 52,
                    color: isAvailable ? info.color : Colors.grey.shade400,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    info.title,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isAvailable ? null : Colors.grey.shade400,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    info.description,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: isAvailable ? null : Colors.grey.shade400,
                        ),
                  ),
                ],
              ),
            ),
            if (!isAvailable)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade500,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Coming Soon',
                    style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            if (isAvailable && info.isNew)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(color: Colors.orange.withOpacity(0.4), blurRadius: 4, offset: const Offset(0, 2)),
                    ],
                  ),
                  child: const Text(
                    'NEW',
                    style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}