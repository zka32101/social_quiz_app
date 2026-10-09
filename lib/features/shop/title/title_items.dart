import 'package:shared_core/shared_core.dart' show AppShopItem, ShopItemKind;

/// 称号の判定に使う進捗値（新規計測なし。既存の UserProgress から取れる値だけ）。
class TitleProgress {
  const TitleProgress({this.streak = 0, this.prefectures = 0, this.badges = 0});

  /// 連続学習日数
  final int streak;

  /// クリアした都道府県の数
  final int prefectures;

  /// 獲得したバッジの数
  final int badges;

  int valueOf(TitleUnlockKind kind) {
    switch (kind) {
      case TitleUnlockKind.streak:
        return streak;
      case TitleUnlockKind.prefectures:
        return prefectures;
      case TitleUnlockKind.badges:
        return badges;
    }
  }
}

enum TitleUnlockKind { streak, prefectures, badges }

class TitleUnlock {
  const TitleUnlock(this.kind, this.threshold);
  final TitleUnlockKind kind;
  final int threshold;

  /// 子ども向けの条件文。
  String get hint {
    switch (kind) {
      case TitleUnlockKind.streak:
        return '$threshold日つづけてべんきょうしよう';
      case TitleUnlockKind.prefectures:
        return '$threshold個のけんをクリアしよう';
      case TitleUnlockKind.badges:
        return 'バッジを$threshold個ゲットしよう';
    }
  }
}

/// 称号の定義。[coinCost] があればコインで購入、[unlock] があれば達成で自動解放。
class TitleDef {
  const TitleDef({required this.id, required this.name, this.coinCost, this.unlock})
      : assert((coinCost == null) != (unlock == null), 'coinCost か unlock のどちらか一方');

  final String id;
  final String name;
  final int? coinCost;
  final TitleUnlock? unlock;

  bool get isPurchasable => coinCost != null;

  AppShopItem toShopItem() => AppShopItem(
        id: id,
        emoji: '🏅',
        name: name,
        description: 'ホーム画面に表示できる称号',
        category: '称号',
        coinCost: coinCost!,
        // きせかえと同じく、購入のみ（装着は「きせかえ」画面）。
        kind: ShopItemKind.emoji,
      );
}

const List<TitleDef> kTitleDefs = [
  // ── コインで購入 ──
  TitleDef(id: 'title_chizu', name: 'ちずはかせ', coinCost: 100),
  TitleDef(id: 'title_rekishi', name: 'れきしたんてい', coinCost: 150),
  TitleDef(id: 'title_chiri', name: 'ちりのたつじん', coinCost: 200),
  TitleDef(id: 'title_shakai', name: 'しゃかいはかせ', coinCost: 300),
  TitleDef(id: 'title_nihon', name: 'にっぽんめいじん', coinCost: 500),
  // ── 達成で解放 ──
  TitleDef(id: 'title_ganbari', name: 'がんばりやさん', unlock: TitleUnlock(TitleUnlockKind.streak, 7)),
  TitleDef(id: 'title_ken', name: 'けんチャレンジャー', unlock: TitleUnlock(TitleUnlockKind.prefectures, 10)),
  TitleDef(id: 'title_badge', name: 'バッジコレクター', unlock: TitleUnlock(TitleUnlockKind.badges, 5)),
];

TitleDef? titleDefById(String? id) {
  if (id == null) return null;
  for (final t in kTitleDefs) {
    if (t.id == id) return t;
  }
  return null;
}

/// コイン購入できる称号の商品一覧（ショップ交換所用）。
List<AppShopItem> titleExchangeItems() =>
    [for (final t in kTitleDefs) if (t.isPurchasable) t.toShopItem()];

/// 条件を満たしているか（購入型は所持、達成型は進捗値で判定）。
bool isTitleUnlocked(TitleDef def, {required Set<String> owned, required TitleProgress progress}) {
  final u = def.unlock;
  if (u == null) return owned.contains(def.id);
  return progress.valueOf(u.kind) >= u.threshold;
}

/// 未解放のときに出す条件文。解放済みなら null。
String? titleLockHint(TitleDef def, {required Set<String> owned, required TitleProgress progress}) {
  if (isTitleUnlocked(def, owned: owned, progress: progress)) return null;
  final u = def.unlock;
  if (u == null) return 'ショップで${def.coinCost}コインでこうかん';
  return u.hint;
}
