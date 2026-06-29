import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/badge_definitions.dart';
import '../../repositories/progress_repository.dart';
import '../../utils/constants.dart';

// ---------------------------------------------------------------------------
// Category tab helpers
// ---------------------------------------------------------------------------

const _tabLabels = [
  'すべて',
  '地理',
  'クイズ',
  'ストリーク',
  'コレクション',
  'マスター',
];

const _tabCategories = <BadgeCategory?>[
  null,
  BadgeCategory.geography,
  BadgeCategory.quiz,
  BadgeCategory.streak,
  BadgeCategory.collection,
  BadgeCategory.master,
];

// ---------------------------------------------------------------------------
// BadgeScreen
// ---------------------------------------------------------------------------

class BadgeScreen extends ConsumerStatefulWidget {
  const BadgeScreen({super.key});

  @override
  ConsumerState<BadgeScreen> createState() => _BadgeScreenState();
}

class _BadgeScreenState extends ConsumerState<BadgeScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabLabels.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progress = ref.watch(userProgressProvider);
    final earnedIds = Set<String>.from(progress.badges);
    final total = BadgeDefinitions.all.length;
    final earned = BadgeDefinitions.all.where((b) => earnedIds.contains(b.id)).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('キャラクターコレクション ✨'),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          tabs: _tabLabels.map((label) => Tab(text: label)).toList(),
        ),
      ),
      body: Column(
        children: [
          _SummaryBanner(earned: earned, total: total),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: _tabCategories.map((category) {
                final badges = category == null
                    ? BadgeDefinitions.all
                    : BadgeDefinitions.all.where((b) => b.category == category).toList();
                return _BadgeGrid(badges: badges, earnedIds: earnedIds);
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Summary banner
// ---------------------------------------------------------------------------

class _SummaryBanner extends StatelessWidget {
  final int earned;
  final int total;

  const _SummaryBanner({required this.earned, required this.total});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('✨', style: TextStyle(fontSize: 20)),
          const SizedBox(width: 8),
          Text(
            'コレクション $earned / $total 個',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Badge grid
// ---------------------------------------------------------------------------

class _BadgeGrid extends StatelessWidget {
  final List<BadgeDef> badges;
  final Set<String> earnedIds;

  const _BadgeGrid({required this.badges, required this.earnedIds});

  @override
  Widget build(BuildContext context) {
    if (badges.isEmpty) {
      return const Center(child: Text('バッジがありません'));
    }
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 0.78,
      ),
      itemCount: badges.length,
      itemBuilder: (context, index) {
        final badge = badges[index];
        final isEarned = earnedIds.contains(badge.id);
        return _BadgeTile(badge: badge, isEarned: isEarned, earnedAt: null);
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Badge tile
// ---------------------------------------------------------------------------

class _BadgeTile extends StatelessWidget {
  final BadgeDef badge;
  final bool isEarned;
  final DateTime? earnedAt;

  const _BadgeTile({
    required this.badge,
    required this.isEarned,
    this.earnedAt,
  });

  bool get _isHidden =>
      !isEarned &&
      (badge.rarity == BadgeRarity.rare ||
          badge.rarity == BadgeRarity.epic ||
          badge.rarity == BadgeRarity.legendary);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showDetail(context),
      child: Card(
        elevation: isEarned ? 3 : 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              isEarned
                  ? Text(
                      badge.emoji,
                      style: const TextStyle(fontSize: 36),
                    )
                  : ColorFiltered(
                      colorFilter: const ColorFilter.matrix([
                        0.2126, 0.7152, 0.0722, 0, 0,
                        0.2126, 0.7152, 0.0722, 0, 0,
                        0.2126, 0.7152, 0.0722, 0, 0,
                        0,      0,      0,      1, 0,
                      ]),
                      child: Opacity(
                        opacity: 0.5,
                        child: Text(
                          badge.emoji,
                          style: const TextStyle(fontSize: 36),
                        ),
                      ),
                    ),
              const SizedBox(height: 6),
              Text(
                isEarned
                    ? badge.name
                    : (_isHidden ? '???' : badge.name),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight:
                          isEarned ? FontWeight.bold : FontWeight.normal,
                      color: isEarned
                          ? null
                          : Colors.grey.shade500,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDetail(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _BadgeDetailSheet(
        badge: badge,
        isEarned: isEarned,
        earnedAt: earnedAt,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Badge detail bottom sheet
// ---------------------------------------------------------------------------

class _BadgeDetailSheet extends StatelessWidget {
  final BadgeDef badge;
  final bool isEarned;
  final DateTime? earnedAt;

  const _BadgeDetailSheet({
    required this.badge,
    required this.isEarned,
    this.earnedAt,
  });

  bool get _isHidden =>
      !isEarned &&
      (badge.rarity == BadgeRarity.rare ||
          badge.rarity == BadgeRarity.epic ||
          badge.rarity == BadgeRarity.legendary);

  String get _rarityLabel {
    switch (badge.rarity) {
      case BadgeRarity.common:
        return 'コモン';
      case BadgeRarity.uncommon:
        return 'アンコモン';
      case BadgeRarity.rare:
        return 'レア';
      case BadgeRarity.epic:
        return 'エピック';
      case BadgeRarity.legendary:
        return 'レジェンド';
    }
  }

  Color _rarityColor(BuildContext context) {
    switch (badge.rarity) {
      case BadgeRarity.common:
        return Colors.grey;
      case BadgeRarity.uncommon:
        return Colors.green;
      case BadgeRarity.rare:
        return Colors.blue;
      case BadgeRarity.epic:
        return Colors.purple;
      case BadgeRarity.legendary:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _rarityColor(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),

          isEarned
              ? Text(badge.emoji, style: const TextStyle(fontSize: 56))
              : ColorFiltered(
                  colorFilter: const ColorFilter.matrix([
                    0.2126, 0.7152, 0.0722, 0, 0,
                    0.2126, 0.7152, 0.0722, 0, 0,
                    0.2126, 0.7152, 0.0722, 0, 0,
                    0,      0,      0,      1, 0,
                  ]),
                  child: Opacity(
                    opacity: 0.4,
                    child:
                        Text(badge.emoji, style: const TextStyle(fontSize: 56)),
                  ),
                ),
          const SizedBox(height: 12),

          Chip(
            label: Text(
              _rarityLabel,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold),
            ),
            backgroundColor: color,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            visualDensity: VisualDensity.compact,
          ),
          const SizedBox(height: 10),

          Text(
            _isHidden ? '???' : badge.name,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),

          Text(
            _isHidden ? 'このバッジの情報は隠されています' : badge.description,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('🪙', style: TextStyle(fontSize: 18)),
              const SizedBox(width: 4),
              Text(
                '${badge.coinReward} コイン',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.amber.shade700,
                    ),
              ),
            ],
          ),

          if (isEarned && earnedAt != null) ...[
            const SizedBox(height: 10),
            Text(
              '獲得日: ${earnedAt!.year}年${earnedAt!.month}月${earnedAt!.day}日',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey.shade600,
                  ),
            ),
          ],

          if (!isEarned) ...[
            const SizedBox(height: 10),
            Text(
              '未獲得',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey.shade500,
                    fontStyle: FontStyle.italic,
                  ),
            ),
          ],
        ],
      ),
    );
  }
}