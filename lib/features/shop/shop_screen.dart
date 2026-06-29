import 'package:flutter/material.dart';
import 'package:shared_core/shared_core.dart';
import '../../data/shakai_characters.dart';

// ── 社会コレ！交換所アイテム ──────────────────────────────────────

const _exchangeItems = [
  AppShopItem(id: 'hat_map',      emoji: '🗺️', name: '地図帽子',
      description: 'キャラに日本地図の帽子をかぶせる', category: '帽子', coinCost: 100),
  AppShopItem(id: 'hat_history',  emoji: '🎩', name: '歴史帽子',
      description: 'レトロな山高帽でかっこよく', category: '帽子', coinCost: 80),
  AppShopItem(id: 'hat_globe',    emoji: '🌍', name: '地球帽子',
      description: '世界を背負う地球柄の帽子', category: '帽子', coinCost: 120),
  AppShopItem(id: 'bg_japan',     emoji: '🗾', name: '日本地図の背景',
      description: '美しい日本列島の背景', category: '背景', coinCost: 200),
  AppShopItem(id: 'bg_world',     emoji: '🌏', name: '世界地図の背景',
      description: '青い地球が広がる背景', category: '背景', coinCost: 200),
  AppShopItem(id: 'bg_edo',       emoji: '🏯', name: '江戸の町の背景',
      description: '歴史情緒あふれる江戸の背景', category: '背景', coinCost: 200),
  AppShopItem(id: 'bgm_shamisen', emoji: '🎵', name: '三味線BGM',
      description: '学習中のBGMを三味線調に', category: 'BGM', coinCost: 150),
  AppShopItem(id: 'bgm_nature',   emoji: '🌿', name: '自然の音BGM',
      description: '田んぼの風の音、自然BGM', category: 'BGM', coinCost: 150),
  AppShopItem(id: 'frame_flag',   emoji: '🚩', name: '国旗フレーム',
      description: 'プロフカードに世界の国旗フレーム', category: 'フレーム', coinCost: 250),
  AppShopItem(id: 'frame_castle', emoji: '🏯', name: 'お城フレーム',
      description: '日本のお城をモチーフにした豪華フレーム', category: 'フレーム', coinCost: 200),
  AppShopItem(id: 'stamp_coupon_shakai', emoji: '🎫',
      name: 'LINEスタンプ無料交換券',
      description: '好きなスタンプセットが無料で！',
      category: 'スペシャル', coinCost: 1000),
];

// ── 社会コレ！季節限定アイテム ────────────────────────────────────

const _seasonalItems = <String, List<AppShopItem>>{
  'spring': [
    AppShopItem(id: 'bg_sakura',      emoji: '🌸', name: '桜の背景',
        description: '春の日本列島、桜満開の背景', category: '季節限定', coinCost: 300),
    AppShopItem(id: 'hat_hanami',     emoji: '🎪', name: 'お花見傘',
        description: 'お花見シーズンに合う和傘', category: '季節限定', coinCost: 150),
    AppShopItem(id: 'frame_entrance', emoji: '🏫', name: '入学式フレーム',
        description: '新学期スタートに', category: '季節限定', coinCost: 200),
  ],
  'summer': [
    AppShopItem(id: 'bg_fireworks',   emoji: '🎆', name: '花火の背景',
        description: '夏祭りの打ち上げ花火', category: '季節限定', coinCost: 300),
    AppShopItem(id: 'hat_summer',     emoji: '👒', name: 'むぎわら帽子',
        description: '夏の農業学習にぴったり', category: '季節限定', coinCost: 100),
    AppShopItem(id: 'effect_ocean',   emoji: '🌊', name: '波エフェクト',
        description: '水産業イメージの波エフェクト', category: '季節限定', coinCost: 250),
  ],
  'autumn': [
    AppShopItem(id: 'bg_koyo',        emoji: '🍂', name: '紅葉の背景',
        description: '秋の日本の山々の背景', category: '季節限定', coinCost: 300),
    AppShopItem(id: 'frame_harvest',  emoji: '🌾', name: '収穫フレーム',
        description: '稲穂たわわな収穫フレーム', category: '季節限定', coinCost: 200),
    AppShopItem(id: 'hat_samurai',    emoji: '⛩️', name: '神社お守り帽',
        description: '歴史学習のお守り帽', category: '季節限定', coinCost: 120),
  ],
  'winter': [
    AppShopItem(id: 'bg_snow_japan',  emoji: '⛄', name: '雪の日本の背景',
        description: '北海道の雪景色', category: '季節限定', coinCost: 300),
    AppShopItem(id: 'hat_santa',      emoji: '🎅', name: 'サンタ帽',
        description: 'クリスマスのサンタ帽', category: '季節限定', coinCost: 150),
    AppShopItem(id: 'frame_newyear',  emoji: '🎍', name: 'お正月フレーム',
        description: '日本のお正月をモチーフに', category: '季節限定', coinCost: 200),
  ],
};

// ── ShopScreen ────────────────────────────────────────────────────

/// 社会コレ！ショップ画面。
/// レイアウト・購入ロジックはすべて CoinShopPage に委譲。
class ShopScreen extends StatelessWidget {
  const ShopScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CoinShopPage(
      characters: kShakaiCharacters,
      exchangeItems: _exchangeItems,
      seasonalItems: _seasonalItems,
    );
  }
}
