import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_core/shared_core.dart' show inventoryProvider;
import '../../../theme/app_theme.dart' show kSocialPrimary;
import 'decor_items.dart';
import 'decor_provider.dart';
import 'decor_scope.dart';
import '../title/title_items.dart';
import '../title/title_plate.dart';
import '../title/title_provider.dart';

/// 買ったきせかえ（背景・フレーム・エフェクト）をえらんでつける画面。
class DecorScreen extends ConsumerWidget {
  const DecorScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final owned = ref.watch(inventoryProvider);
    final active = ref.watch(activeDecorProvider);
    final mine = [for (final i in kDecorItems) if (owned.contains(i.id)) i];

    return Scaffold(
      backgroundColor: DecorScope.pageBg(context, const Color(0xFFF8F9FA)),
      appBar: AppBar(
        title: const Text('きせかえ'),
        backgroundColor: kSocialPrimary,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (mine.isEmpty) const _Empty(),
          for (final kind in DecorKind.values) ...[
            _Section(
              kind: kind,
              items: [for (final i in mine) if (i.kind == kind) i],
              activeId: active.of(kind),
            ),
            const SizedBox(height: 16),
          ],
          const TitleSection(),
        ],
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/shop/empty_closet.webp', width: 160, errorBuilder: (_, __, ___) => const SizedBox.shrink()),
            const SizedBox(height: 16),
            const Text(
              'まだきせかえをもっていないよ。\nショップでコインとこうかんして、背景やフレームをゲットしよう！',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, height: 1.6),
            ),
          ],
        ),
      ),
    );
  }
}

class _Section extends ConsumerWidget {
  const _Section({required this.kind, required this.items, required this.activeId});

  final DecorKind kind;
  final List<DecorItem> items;
  final String? activeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (items.isEmpty) return const SizedBox.shrink();
    final notifier = ref.read(decorProvider.notifier);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(kind.label, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            _Tile(
              label: 'なし',
              selected: activeId == null,
              onTap: () => notifier.unequip(kind),
              child: const Icon(Icons.block, color: Colors.grey),
            ),
            for (final item in items)
              _Tile(
                label: item.name,
                selected: activeId == item.id,
                onTap: () => notifier.equip(item),
                child: Image.asset(
                  item.thumb,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Center(child: Text(item.emoji, style: const TextStyle(fontSize: 26))),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({required this.label, required this.selected, required this.onTap, required this.child});

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final primary = kSocialPrimary;
    return Semantics(
      button: true,
      selected: selected,
      label: '$label${selected ? '、つけています' : ''}',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          width: 92,
          child: Column(
            children: [
              Container(
                width: 84,
                height: 84,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: selected ? primary : Colors.grey.shade300, width: selected ? 3 : 1),
                ),
                clipBehavior: Clip.antiAlias,
                child: child,
              ),
              const SizedBox(height: 4),
              Text(
                selected ? '✓ $label' : label,
                maxLines: 2,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 11, fontWeight: selected ? FontWeight.bold : FontWeight.normal),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 称号をえらぶ区分。買った称号と、達成で解放された称号をつけられる。
/// 未解放は鍵つきで条件を出す。
class TitleSection extends ConsumerWidget {
  const TitleSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final owned = ref.watch(inventoryProvider);
    final progress = ref.watch(titleProgressProvider);
    final activeId = ref.watch(activeTitleProvider)?.id;
    final notifier = ref.read(titleProvider.notifier);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('称号', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            _Tile(
              label: 'なし',
              selected: activeId == null,
              onTap: () => notifier.unequip(),
              child: const Icon(Icons.block, color: Colors.grey),
            ),
            for (final def in kTitleDefs)
              _titleTile(def, owned, progress, activeId, notifier),
          ],
        ),
      ],
    );
  }

  Widget _titleTile(TitleDef def, Set<String> owned, TitleProgress progress, String? activeId, TitleNotifier notifier) {
    final hint = titleLockHint(def, owned: owned, progress: progress);
    final locked = hint != null;
    return Semantics(
      button: true,
      label: locked ? '${def.name}、ロックちゅう。$hint' : def.name,
      child: InkWell(
        key: ValueKey('title_tile_${def.id}'),
        onTap: locked ? null : () => notifier.equip(def),
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          width: 92,
          child: Column(
            children: [
              Container(
                width: 84,
                height: 84,
                alignment: Alignment.center,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: activeId == def.id ? kSocialPrimary : Colors.grey.shade300,
                    width: activeId == def.id ? 3 : 1,
                  ),
                ),
                child: locked
                    ? const Icon(Icons.lock, color: Colors.grey, size: 30)
                    : TitlePlate(name: def.name, width: 76),
              ),
              const SizedBox(height: 4),
              Text(
                locked ? '🔒 ${def.name}' : (activeId == def.id ? '✓ ${def.name}' : def.name),
                maxLines: 1,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 11, fontWeight: activeId == def.id ? FontWeight.bold : FontWeight.normal),
              ),
              if (locked)
                Text(hint, maxLines: 3, textAlign: TextAlign.center, overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 9, color: Colors.grey.shade700)),
            ],
          ),
        ),
      ),
    );
  }
}
