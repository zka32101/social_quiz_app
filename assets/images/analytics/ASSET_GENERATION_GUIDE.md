# 社会コレ！ 分析画面アセット生成ガイド

## 📋 概要

このディレクトリには、クイズ分析・パフォーマンス表示画面で使用する装飾画像のテンプレートと生成指南が含まれています。

**すべてのアセットは商用利用OKです（CC0またはCC-BY相当）**

---

## 📁 ファイル構成

```
analytics/
├── icons/                          # パフォーマンスメトリック用アイコン
│   ├── icon_accuracy_rate.svg     ✅ SVG完成版
│   ├── icon_consecutive_streak.svg ✅ SVG完成版
│   ├── icon_best_score.svg         ✅ SVG完成版
│   └── icon_total_attempts.svg     ✅ SVG完成版
├── backgrounds/
│   ├── analytics_header_pattern.svg ✅ SVG完成版
│   └── stage_analysis_bg.svg        ✅ SVG完成版
├── headers/                        # ヘッダーイメージ（要生成）
│   └── (PNG/JPG形式を生成予定)
├── decorations/                    # ガイダンスイラスト（要生成）
│   └── (PNG/JPG形式を生成予定)
└── ASSET_GENERATION_GUIDE.md       📄 このファイル
```

---

## ✅ 完成済みアセット

### SVG アイコン（256×256px）

すべてのアイコンはSVG形式で完成しています。**そのまま使用可能**または PNG/JPG に変換できます。

| ファイル | 用途 | 説明 |
|---------|------|------|
| `icon_accuracy_rate.svg` | 正答率表示 | チェックマークと%記号 |
| `icon_consecutive_streak.svg` | 連続記録 | 炎と数字で連続正解を表現 |
| `icon_best_score.svg` | 最高スコア | トロフィーと星で成績を表現 |
| `icon_total_attempts.svg` | 試行回数 | 同心円のプログレス表示 |

### 背景パターン（SVG）

| ファイル | 用途 | サイズ |
|---------|------|--------|
| `analytics_header_pattern.svg` | クイズ分析画面ヘッダー背景 | 1200×400px |
| `stage_analysis_bg.svg` | ステージ分析画面背景 | 1200×800px |

---

## 🎨 生成が必要なアセット

以下の画像は、商用利用OK なサービスを使って生成してください。

### 1. クイズ分析画面ヘッダー（1200×400px）

**用途**: `lib/features/quiz_result/analytics_screen.dart` の AppBar or 上部バナー

**生成プロンプト:**
```
Educational illustration for quiz analytics dashboard header,
showing colorful bar charts and statistics with upward trends,
green color scheme (#2ECC71 primary, #27AE60 secondary),
friendly and energetic style for elementary school children,
Japanese prefecture/map theme with learning elements,
watercolor or soft illustration style, no text or watermarks,
commercial license ok, high quality PNG, 1200x400 pixels
```

**推奨サービス:**
- 🆓 **Lexica.art** (CC0, 無料)
- 🆓 **Pixabay** (CC0)
- 🆓 **Unsplash** (CC0)
- 💰 **Midjourney** (商用ライセンス: $96/月から)
- 💰 **DALL-E 3** (商用ライセンス: $0.08/image)

---

### 2. パフォーマンスウィジェット装飾イラスト（4種類, 各256×256px）

既存の SVG アイコンを使用するか、以下のプロンプトで PNG 版を生成:

#### 2-1. 正答率アイコン
```
Cute flat icon for quiz accuracy rate, showing green checkmark
and percentage (%) symbol, green colors (#2ECC71),
elementary school style, centered, solo character,
commercial use ok, 256x256 PNG
```

#### 2-2. 連続正解アイコン
```
Cute flat icon for streak/consecutive correct answers,
showing fire 🔥 or lightning bolt with number,
energetic and motivating, green and gold colors,
elementary school style, centered, 256x256 PNG, commercial ok
```

#### 2-3. 最高スコアアイコン
```
Cute flat icon for best score achievement, showing trophy or crown
with stars ⭐, gold and green colors, celebratory style,
elementary school friendly, centered, 256x256 PNG, commercial ok
```

#### 2-4. 試行回数アイコン
```
Cute flat icon for total attempts/practice count, showing
repeated action or cycle/loop symbol, green colors,
flat design, centered, 256x256 PNG, commercial use ok
```

---

### 3. ステージ分析スクリーン背景（1200×800px）

**用途**: `lib/features/stage/stage_analytics_screen.dart` の背景

**生成プロンプト:**
```
Beautiful educational background pattern combining
Japan prefecture map outline and quiz statistics graphs,
green color scheme (#2ECC71, #27AE60), light gray background (#F8F9FA),
clean and minimal design suitable for elementary school children,
watercolor or soft illustration style, no text/watermarks,
high quality PNG, 1200x800 pixels, commercial license ok
```

---

### 4. 学習ガイダンスイラスト（3種類, 各400×300px）

#### 4-1. 繰り返し学習のイラスト
```
Cute educational illustration for "repeat learning" concept,
showing stacked books or practice symbols, green colors,
encouraging and motivating atmosphere, elementary school style,
400x300 PNG, commercial use ok, no text
```

#### 4-2. 毎日学習のイラスト
```
Cute educational illustration for "daily learning consistency",
showing calendar, checkmarks, and upward progress,
green and gold colors, positive motivation,
elementary school appropriate, 400x300 PNG, commercial ok
```

#### 4-3. 正答率向上目標のイラスト
```
Cute educational illustration for "accuracy improvement goal" (90% target),
showing upward arrow, target/bullseye symbol, percentage,
green and gold colors, motivating style,
elementary school friendly, 400x300 PNG, commercial use ok
```

---

## 🚀 使用方法

### SVG をそのまま使う場合

Flutter では SVG を直接使用できます:

```dart
import 'package:flutter_svg/flutter_svg.dart';

SvgPicture.asset(
  'assets/images/analytics/icons/icon_accuracy_rate.svg',
  width: 256,
  height: 256,
)
```

### SVG を PNG に変換する場合

**オンラインツール:**
- https://cloudconvert.com/ (SVG → PNG)
- https://www.online-convert.com/ (無料)

**コマンドラインツール:**
```bash
# ImageMagick を使う
convert -density 300 icon_accuracy_rate.svg -background transparent icon_accuracy_rate.png

# Inkscape を使う
inkscape --export-type=png icon_accuracy_rate.svg
```

---

## 📝 生成済みアセットの管理

新しい PNG/JPG を配置する場合:

```
analytics/
├── headers/
│   └── analytics_header_main.png    ← ここに配置
├── backgrounds/
│   ├── stage_analysis_bg.png        ← ここに配置
│   └── stage_analysis_bg.svg        (元のSVG)
└── decorations/
    ├── guidance_repeat_learning.png     ← ここに配置
    ├── guidance_daily_consistency.png   ← ここに配置
    └── guidance_accuracy_goal.png       ← ここに配置
```

---

## 🎯 商用利用OKなサービス比較

| サービス | ライセンス | コスト | 品質 | 生成速度 |
|---------|-----------|--------|------|---------|
| **Pixabay** | CC0 | 無料 | 高 | 高速検索 |
| **Unsplash** | CC0 | 無料 | 高 | 高速検索 |
| **Pexels** | CC0 | 無料 | 高 | 高速検索 |
| **Lexica.art** | CC0推奨 | 無料/有料 | 中〜高 | 中程度 |
| **DALL-E 3** | 商用ライセンス | $0.08/img | 非常に高 | 中程度 |
| **Midjourney** | 商用ライセンス | $96/月 | 非常に高 | 高速 |
| **Stable Diffusion** | モデルによる | 無料/有料 | 中〜高 | 高速 |

---

## ✨ クオリティチェックリスト

新規アセットを追加する前に以下を確認してください:

- [ ] 小学4-5年生向けの親しみやすいデザイン
- [ ] グリーン基調のカラースキーム（#2ECC71/#27AE60）
- [ ] テキスト・ウォーターマークなし
- [ ] 商用利用OKのライセンス表記確認
- [ ] 高解像度（PNG は 300 DPI 推奨）
- [ ] 教育的な価値を持つ内容
- [ ] 背景の透過性確認（必要に応じて）

---

## 📚 参考資料

- [Flutter SVG パッケージ](https://pub.dev/packages/flutter_svg)
- [Material Design Icons](https://fonts.google.com/icons)
- [CC0 ライセンス説明](https://creativecommons.org/publicdomain/zero/1.0/deed.ja)

---

**更新**: 2026-09-01  
**バージョン**: 1.0
