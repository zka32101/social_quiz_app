import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_core/shared_core.dart' show inventoryProvider;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../repositories/progress_repository.dart' show progressProvider;
import 'title_items.dart';

/// 称号判定用の進捗値。既存の UserProgress から取り出すだけ（新規計測なし）。
/// 進捗の保存先(Hive)が未初期化の環境(ウィジェットテスト等)では 0 扱いにする。
final titleProgressProvider = Provider<TitleProgress>((ref) {
  try {
    final p = ref.watch(progressProvider);
    return TitleProgress(
      streak: p.streak,
      prefectures: p.completedPrefectureCount,
      badges: p.badges.length,
    );
  } catch (_) {
    return const TitleProgress();
  }
});

/// いま「つけている」称号ID（未選択は null）。
class TitleNotifier extends Notifier<String?> {
  static const _key = 'shakai_title_equipped';

  @override
  String? build() {
    Future.microtask(load);
    return null;
  }

  Future<void> load() async {
    final p = await SharedPreferences.getInstance();
    state = p.getString(_key);
  }

  /// 解放済みの称号だけつけられる。
  Future<bool> equip(TitleDef def) async {
    final ok = isTitleUnlocked(def,
        owned: ref.read(inventoryProvider), progress: ref.read(titleProgressProvider));
    if (!ok) return false;
    state = def.id;
    final p = await SharedPreferences.getInstance();
    await p.setString(_key, def.id);
    return true;
  }

  Future<void> unequip() async {
    state = null;
    final p = await SharedPreferences.getInstance();
    await p.remove(_key);
  }
}

final titleProvider = NotifierProvider<TitleNotifier, String?>(TitleNotifier.new);

/// 解放済みのものだけに絞った「いまの称号」。未選択・未解放・知らないIDは null。
final activeTitleProvider = Provider<TitleDef?>((ref) {
  final def = titleDefById(ref.watch(titleProvider));
  if (def == null) return null;
  final ok = isTitleUnlocked(def,
      owned: ref.watch(inventoryProvider), progress: ref.watch(titleProgressProvider));
  return ok ? def : null;
});
