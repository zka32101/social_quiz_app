import 'package:flutter/material.dart';
import 'package:shared_core/shared_core.dart';
import '../../data/shakai_characters.dart';
import '../../screens/avatar_selection_screen.dart';

// ── 社会コレ！交換所アイテム ──────────────────────────────────────

// 2026-09: 帽子・BGM・アプリ独自の背景/フレームは、装着できる場所が
// どこにも実装されていなかったため削除（購入しても何も反映されない
// 「行き止まり」商品だった）。
// 2026-09: LINEスタンプ引換券は運用フローが用意できていないため削除。
// 2026-09: 全アプリ共通の背景・フレーム（kCommonShopItems）も削除。
// アバター（id 5-16）は models/avatar.dart + AvatarPurchaseService に
// 既に実装済みの専用購入フローがあるため、そちらへの導線を下に追加する
// （CoinShopPage 側の交換所アイテムとしては扱わない）。
const _exchangeItems = <AppShopItem>[];

// ── 社会コレ！季節限定アイテム ────────────────────────────────────
// 2026-09: 装着できる場所がなかったため季節限定アイテムも無効化。

const _seasonalItems = <String, List<AppShopItem>>{};

// ── ShopScreen ────────────────────────────────────────────────────

/// 社会コレ！ショップ画面。
/// 交換所レイアウトは CoinShopPage に委譲しつつ、
/// アバター購入への導線を上部に表示する。
class ShopScreen extends StatelessWidget {
  const ShopScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CoinShopPage(
          characters: kShakaiCharacters,
          exchangeItems: _exchangeItems,
          seasonalItems: _seasonalItems,
          showBackButton: true,
        ),
        Positioned(
          right: 16,
          bottom: 16,
          child: FloatingActionButton.extended(
            heroTag: 'avatar_shop_fab',
            onPressed: () => showAvatarSelectionDialog(context),
            icon: const Icon(Icons.face_retouching_natural),
            label: const Text('アバターを購入'),
          ),
        ),
      ],
    );
  }
}
