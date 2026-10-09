import 'package:shared_core/shared_core.dart' show AppShopItem, ShopItemKind;

/// きせかえの種類。
enum DecorKind {
  background('背景'),
  frame('フレーム'),
  effect('エフェクト');

  const DecorKind(this.label);
  final String label;
}

/// コインで買えるきせかえ（背景・フレーム・エフェクト）。見た目だけで、学習には影響しない。
///
/// 画像は `assets/shop/<id>.webp`、一覧用のサムネイルは `assets/shop/thumb/<id>.webp`。
/// 画像と価格は design/小学コレ！/共通/コインショップ詳細実装設計書 と images/小学コレ！/コインショップ/README.md に対応。
class DecorItem {
  const DecorItem({
    required this.id,
    required this.name,
    required this.description,
    required this.kind,
    required this.coinCost,
    this.season,
  });

  final String id;
  final String name;
  final String description;
  final DecorKind kind;
  final int coinCost;

  /// null なら常設。spring / summer / autumn / winter は期間限定タブに出る。
  final String? season;

  String get asset => 'assets/shop/$id.webp';
  String get thumb => 'assets/shop/thumb/$id.webp';

  String get emoji {
    switch (kind) {
      case DecorKind.background:
        return '🖼️';
      case DecorKind.frame:
        return '🪞';
      case DecorKind.effect:
        return '✨';
    }
  }

  AppShopItem toShopItem() => AppShopItem(
        id: id,
        emoji: emoji,
        name: name,
        description: description,
        category: kind.label,
        coinCost: coinCost,
        // shared_core の CoinShopPage は emoji 以外の種別を「装着する」ボタン付きで出し、
        // assetPath を SVG として読む。きせかえは専用の「きせかえ」画面でつけるため、
        // 種別は emoji（装着ボタンなし・購入のみ）、サムネは絵文字で出す。
        kind: ShopItemKind.emoji,
      );
}

const List<DecorItem> kDecorItems = [
  // ── 背景（常設） ──
  DecorItem(id: 'bg_shakai', name: '社会のせかい', description: '地球儀とみどりの町の背景', kind: DecorKind.background, coinCost: 200),
  DecorItem(id: 'bg_space', name: '宇宙の背景', description: '星と銀河のきれいな背景', kind: DecorKind.background, coinCost: 200),
  DecorItem(id: 'bg_ocean', name: '深海の背景', description: '海の中のような青い背景', kind: DecorKind.background, coinCost: 200),
  DecorItem(id: 'bg_forest', name: '森の背景', description: '光がさす緑の森の背景', kind: DecorKind.background, coinCost: 200),
  DecorItem(id: 'bg_sky', name: '空の背景', description: '虹と気球の青い空の背景', kind: DecorKind.background, coinCost: 200),
  // ── 背景（季節） ──
  DecorItem(id: 'bg_sakura', name: '桜の背景', description: '桜の花びらがまう春の背景', kind: DecorKind.background, coinCost: 300, season: 'spring'),
  DecorItem(id: 'bg_fireworks', name: '花火の背景', description: '夏まつりの花火の背景', kind: DecorKind.background, coinCost: 300, season: 'summer'),
  DecorItem(id: 'bg_leaves', name: '紅葉の背景', description: '赤や黄色の葉っぱの秋の背景', kind: DecorKind.background, coinCost: 300, season: 'autumn'),
  DecorItem(id: 'bg_snow', name: '雪の背景', description: '雪がふる冬の村の背景', kind: DecorKind.background, coinCost: 300, season: 'winter'),
  DecorItem(id: 'bg_christmas', name: 'クリスマスの背景', description: 'ツリーとプレゼントのクリスマスの背景', kind: DecorKind.background, coinCost: 300, season: 'winter'),
  DecorItem(id: 'bg_newyear', name: 'お正月の背景', description: '初日の出とかざりのお正月の背景', kind: DecorKind.background, coinCost: 300, season: 'winter'),
  // ── フレーム（常設） ──
  DecorItem(id: 'frame_rainbow', name: '虹色フレーム', description: 'アイコンに虹色のふち', kind: DecorKind.frame, coinCost: 250),
  DecorItem(id: 'frame_ribbon', name: 'リボンフレーム', description: 'かわいいリボンのふち', kind: DecorKind.frame, coinCost: 250),
  DecorItem(id: 'frame_star', name: 'スターフレーム', description: 'キラキラ星のふち', kind: DecorKind.frame, coinCost: 250),
  DecorItem(id: 'frame_party', name: 'お祝いフレーム', description: '風船とはたのふち', kind: DecorKind.frame, coinCost: 250),
  DecorItem(id: 'frame_shakai', name: 'しゃかいのフレーム', description: '地球儀と地図のかざり', kind: DecorKind.frame, coinCost: 250),
  // ── フレーム（季節） ──
  DecorItem(id: 'frame_entrance', name: '入学式フレーム', description: '桜とランドセルのふち', kind: DecorKind.frame, coinCost: 200, season: 'spring'),
  DecorItem(id: 'frame_book', name: '読書フレーム', description: '本と紅葉のふち', kind: DecorKind.frame, coinCost: 200, season: 'autumn'),
  DecorItem(id: 'frame_newyear', name: 'お正月フレーム', description: '松と梅のお正月のふち', kind: DecorKind.frame, coinCost: 200, season: 'winter'),
  DecorItem(id: 'frame_christmas', name: 'クリスマスフレーム', description: 'リースとベルのクリスマスのふち', kind: DecorKind.frame, coinCost: 200, season: 'winter'),
  // ── エフェクト（通年） ──
  DecorItem(id: 'effect_twinkle', name: 'きらきらほし', description: '画面のふちに星がきらきらひかる', kind: DecorKind.effect, coinCost: 250),
  DecorItem(id: 'effect_shakai', name: 'ちきゅうぎエフェクト', description: 'ちきゅうぎやちずがちらばるよ', kind: DecorKind.effect, coinCost: 200),
  // ── エフェクト（季節） ──
  DecorItem(id: 'effect_sakura', name: 'さくらふぶき', description: '画面にさくらの花びらがまう', kind: DecorKind.effect, coinCost: 200, season: 'spring'),
  DecorItem(id: 'effect_leaves', name: 'もみじのまい', description: '画面にもみじの葉っぱがまう', kind: DecorKind.effect, coinCost: 200, season: 'autumn'),
  DecorItem(id: 'effect_fireworks', name: 'はなび', description: '画面にはなびが打ち上がる', kind: DecorKind.effect, coinCost: 250, season: 'summer'),
  DecorItem(id: 'effect_waves', name: '波エフェクト', description: '画面の下にさざ波が広がる', kind: DecorKind.effect, coinCost: 250, season: 'summer'),
  DecorItem(id: 'effect_snow', name: '雪エフェクト', description: '画面に雪の結晶がふる', kind: DecorKind.effect, coinCost: 200, season: 'winter'),
  DecorItem(id: 'effect_christmas', name: 'クリスマスエフェクト', description: '画面にクリスマスのかざりがきらめく', kind: DecorKind.effect, coinCost: 200, season: 'winter'),
  DecorItem(id: 'effect_newyear', name: 'お正月エフェクト', description: '画面にお正月のかざりがまう', kind: DecorKind.effect, coinCost: 200, season: 'winter'),
];

DecorItem? decorItemById(String? id) {
  if (id == null) return null;
  for (final i in kDecorItems) {
    if (i.id == id) return i;
  }
  return null;
}

/// 常設の商品（交換所タブ用）。
List<AppShopItem> decorExchangeItems() =>
    [for (final i in kDecorItems) if (i.season == null) i.toShopItem()];

/// 季節の商品（期間限定タブ用）。キーは spring / summer / autumn / winter。
Map<String, List<AppShopItem>> decorSeasonalItems() {
  final m = <String, List<AppShopItem>>{};
  for (final i in kDecorItems) {
    final s = i.season;
    if (s != null) m.putIfAbsent(s, () => []).add(i.toShopItem());
  }
  return m;
}
