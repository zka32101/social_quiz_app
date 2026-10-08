import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_core/shared_core.dart' show inventoryProvider;
import 'package:shared_preferences/shared_preferences.dart';
import 'decor_items.dart';

/// いま「つけている」きせかえ。種類ごとに1つ。何もつけていなければ null。
class DecorState {
  const DecorState({this.background, this.frame, this.effect});

  final String? background;
  final String? frame;
  final String? effect;

  String? of(DecorKind kind) {
    switch (kind) {
      case DecorKind.background:
        return background;
      case DecorKind.frame:
        return frame;
      case DecorKind.effect:
        return effect;
    }
  }

  DecorState with_(DecorKind kind, String? id) {
    switch (kind) {
      case DecorKind.background:
        return DecorState(background: id, frame: frame, effect: effect);
      case DecorKind.frame:
        return DecorState(background: background, frame: id, effect: effect);
      case DecorKind.effect:
        return DecorState(background: background, frame: frame, effect: id);
    }
  }
}

class DecorNotifier extends Notifier<DecorState> {
  static const _keyOf = {
    DecorKind.background: 'shakai_decor_background',
    DecorKind.frame: 'shakai_decor_frame',
    DecorKind.effect: 'shakai_decor_effect',
  };

  @override
  DecorState build() {
    Future.microtask(load);
    return const DecorState();
  }

  /// 保存されているきせかえを読み込む（起動直後に自動で呼ばれる）。
  Future<void> load() async {
    final p = await SharedPreferences.getInstance();
    state = DecorState(
      background: p.getString(_keyOf[DecorKind.background]!),
      frame: p.getString(_keyOf[DecorKind.frame]!),
      effect: p.getString(_keyOf[DecorKind.effect]!),
    );
  }

  /// 買ったきせかえをつける。持っていない・種類が違うものはつけられない。
  Future<bool> equip(DecorItem item) async {
    final owned = ref.read(inventoryProvider);
    if (!owned.contains(item.id)) return false;
    state = state.with_(item.kind, item.id);
    final p = await SharedPreferences.getInstance();
    await p.setString(_keyOf[item.kind]!, item.id);
    return true;
  }

  /// はずす。
  Future<void> unequip(DecorKind kind) async {
    state = state.with_(kind, null);
    final p = await SharedPreferences.getInstance();
    await p.remove(_keyOf[kind]!);
  }
}

final decorProvider = NotifierProvider<DecorNotifier, DecorState>(DecorNotifier.new);

/// 持っているものだけに絞った「いまのきせかえ」。持っていない・知らないIDは無視する。
final activeDecorProvider = Provider<DecorState>((ref) {
  final s = ref.watch(decorProvider);
  final owned = ref.watch(inventoryProvider);
  String? valid(DecorKind k) {
    final id = s.of(k);
    final item = decorItemById(id);
    return (item != null && item.kind == k && owned.contains(item.id)) ? item.id : null;
  }

  return DecorState(
    background: valid(DecorKind.background),
    frame: valid(DecorKind.frame),
    effect: valid(DecorKind.effect),
  );
});
