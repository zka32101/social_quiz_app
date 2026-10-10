import 'package:flutter/material.dart';
import 'package:shared_core/shared_core.dart';
import '../../data/shakai_characters.dart';
import '../../screens/avatar_selection_screen.dart';
import 'decor/decor_items.dart';
import 'decor/decor_screen.dart';
import 'title/title_items.dart';

// ── 社会コレ！交換所アイテム ──────────────────────────────────────

// 2026-09: 帽子・BGM・アプリ独自の背景/フレームは、装着できる場所が
// どこにも実装されていなかったため削除（購入しても何も反映されない
// 「行き止まり」商品だった）。
// 2026-09: LINEスタンプ引換券は運用フローが用意できていないため削除。
// 2026-09: 全アプリ共通の背景・フレーム（kCommonShopItems）も削除。
// 2026-10: きせかえ（背景・フレーム・エフェクト）を features/shop/decor に実装し、
// 装着できる仕組みが揃ったので商品として復活（decorExchangeItems / decorSeasonalItems）。
// アバター（id 5-16）は models/avatar.dart + AvatarPurchaseService に
// 既に実装済みの専用購入フローがあるため、そちらへの導線を下に追加する
// （CoinShopPage 側の交換所アイテムとしては扱わない）。
final _exchangeItems = <AppShopItem>[
  ...decorExchangeItems(),
  ...titleExchangeItems(),
];

// ── 社会コレ！季節限定アイテム ────────────────────────────────────
// 2026-09: 装着できる場所がなかったため季節限定アイテムも無効化。

// 季節のきせかえは decorSeasonalItems() を使う。

// ── ShopScreen ────────────────────────────────────────────────────

/// 社会コレ！ショップ画面。
/// 交換所レイアウトは CoinShopPage に委譲しつつ、
/// アバター購入への導線を上部に表示する。
/// 右下の「きせかえ」「アバターを購入」FAB(56x2 + 間12 + 下余白16)に、交換所リスト末尾の
/// 「購入」ボタンが隠れないよう、ショップ本体の下に空ける余白。
const double kShopFabClearance = 56 * 2 + 12 + 16 + 16;

class ShopScreen extends StatelessWidget {
  const ShopScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // CoinShopPage は下に FAB 用の余白(kShopFabClearance)を空けて置くため、その余白の裏が
    // 透けて黒く見えないよう、ショップ本体と同じ背景色で全体を塗る。
    return ColoredBox(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Stack(
        children: [
          Padding(
            key: ValueKey('shop_fab_clearance'),
            padding: const EdgeInsets.only(bottom: kShopFabClearance),
            child: CoinShopPage(
              characters: kShakaiCharacters,
              exchangeItems: _exchangeItems,
              seasonalItems: decorSeasonalItems(),
              showBackButton: true,
            ),
          ),
          Positioned(
            right: 16,
            bottom: 16,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // 買った背景・フレーム・エフェクトをえらんでつける画面へ
                FloatingActionButton.extended(
                  heroTag: 'decor_fab',
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const DecorScreen(),
                    ),
                  ),
                  icon: const Icon(Icons.palette_outlined),
                  label: const Text('きせかえ'),
                ),
                const SizedBox(height: 12),
                FloatingActionButton.extended(
                  heroTag: 'avatar_shop_fab',
                  onPressed: () => showAvatarSelectionDialog(context),
                  icon: const Icon(Icons.face_retouching_natural),
                  label: const Text('アバターを購入'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
