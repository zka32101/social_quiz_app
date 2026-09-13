# 社会コレ！マスコットキャラ刷新 — 引き継ぎ書

**作成日**: 2026-08-17
**対象**: `social_quiz_app`（小学コレ！社会）
**状態**: 画像生成は完了。アプリへの組み込み（コード実装）はこれから。

---

## 1. 何をやったか（サマリ）

- 既存16体のマスコット（チズコ・キタコ…全員「〜コ」で終わる女の子）を、
  性別・種族を混ぜた新ラインナップに刷新（デザイン確定済み）。
- 国語コレ（`kokugo-kore`）で確立済みの **Lv.1〜Lv.MAX 5段階進化イラスト方式** を踏襲。
- Leonardo AI（Phoenix 1.0固定・1枚ずつ逐次生成・低コスト設定）で
  **16体 × 5レベル = 80枚を全て生成済み**。
- **未着手**: Dartコード側（データ定義・アセット登録・画面表示ロジック）への反映。

---

## 2. 新キャラクターラインナップ（旧→新 対応表）

| # | id | 新名称 | 種別 | 教科テーマ | 旧名称 |
|---|---|---|---|---|---|
| 1 | `mapple` | マップル | 男の子（狐耳の探検少年） | 地図記号 | チズコ |
| 2 | `yukina` | ユキナ | 動物（雪うさぎ） | 北海道・東北 | キタコ |
| 3 | `haruka` | はるか | 女の子 | 関東・中部 | ハルコ |
| 4 | `miyabi` | みやび | 架空（狐の妖精・和装） | 近畿・中国・四国 | ニシコ |
| 5 | `minori` | みのり | 男の子（案山子キャラ） | 農業 | ムギコ |
| 6 | `namika` | なみか | 動物（いるか） | 水産業 | ウミコ |
| 7 | `geana` | ギアナ | 架空（小型ロボット） | 工業・工業地帯 | コウジコ |
| 8 | `michiru` | みちる | 架空（新幹線精霊） | 交通・情報化 | ミチコ |
| 9 | `fumika` | ふみか | 女の子 | 古代・中世の歴史 | フミコ |
| 10 | `tsubaki` | つばき | 男の子（少年侍） | 江戸・幕末 | サムコ |
| 11 | `haikara` | はいから | 男の子（ハイカラ紳士） | 明治・近代 | メイジコ |
| 12 | `tera` | テラ | 架空（地球の精霊） | 国際・世界地理 | セカイコ |
| 13 | `seigi` | せいぎ | 動物（ふくろう） | 憲法・三権分立 | シミンコ |
| 14 | `takara` | たから | 動物（たぬき） | 税金・選挙 | ゼイコ |
| 15 | `michinori` | みちのり | 動物（鶴） | 都道府県マスター | ケンコ |
| 16 | `shakai_star` | シャカイスター | 架空（星の精霊・伝説級） | 社会科完全マスター | （変更なし） |

各キャラの外見コンセプト（服装・小道具・カラー等）は
[`tools/social_quiz_app_image_gen/character_data.js`](tools/social_quiz_app_image_gen/character_data.js)
の `CHARACTERS` 配列に1体1文（`appearance`フィールド）で定義済み。
バックストーリー・決め台詞は**旧キャラの内容を流用しつつ新名称に差し替える**想定（本文の再作文は未着手）。

---

## 3. 生成済み画像アセット

**保存先**: `H:\マイドライブ\images\小学コレ！\社会\キャラクター\`

**命名規則**（1体あたり5ファイル、16体×5=80枚）:

| Lv | ファイル名 | 内容 |
|---|---|---|
| Lv.1 | `{id}.png` | 基本イラスト（標準ポーズ） |
| Lv.2 | `{id}_lv2.png` | 表情差分①（喜び） |
| Lv.3 | `{id}_lv3.png` | 表情差分②（集中・思考） |
| Lv.4 | `{id}_lv4.png` | 別ポーズ（アクション） |
| Lv.5 | `{id}_lvmax.png` | きらきらMAXエフェクト |

例: `mapple.png` / `mapple_lv2.png` / `mapple_lv3.png` / `mapple_lv4.png` / `mapple_lvmax.png`

同フォルダの `manifest.json` に、各ファイルの characterId・name・subject・level・使用プロンプト・
生成日時が記録されている。

**⚠️ 既知の課題（要目視チェック）**: `mapple` の Lv.3/Lv.4 で顔が「狐そのもの」から
「狐耳の人間の少年寄り」に変化しており、Lv.1/Lv.2/Lv.MAXの狐顔と統一感がやや崩れている。
他キャラも同様のブレがないか、実装前に全80枚をひととおり目視確認し、気になるものは
下記コマンドで個別に再生成すること。

```powershell
cd "H:\マイドライブ\apps\social_quiz_app\tools\social_quiz_app_image_gen"
$env:LEONARDO_API_KEY = [Environment]::GetEnvironmentVariable("LEONARDO_API_KEY", "User")
node generate_leonardo.js --ids mapple --levels lv3,lv4 --force
```

---

## 4. 現状のデータモデル（実装前の把握）

### `shared_core`（`H:\マイドライブ\apps\shared_core`）— 小学コレ全シリーズ共通基盤

- `lib/models/character_data.dart`
  - `BaseCharacter`: id/name/emoji/tier/unlockAt/subject/backstory/stampPhrases/**imageAsset（1枚のみ）**
  - `CharacterState`: isUnlocked/**level(1-5)**/hasExpressions/hasPoses/hasBackstory/hasSparkle/hasStampCoupon
  - `kLevelUpCost`: `{2:50, 3:100, 4:200, 5:500}`（コイン）
  - レベルアップの状態管理・コイン消費ロジックは**既にshared_core側に実装済み**
- `lib/widgets/character_collection_page.dart`
  - `character.imageAsset` を**1枚だけ**表示する汎用ウィジェット
  - `state.hasSparkle`等はキラキラ枠やバッジ表示のみで、**画像そのものをLv別に切り替える機能は無い**

### `social_quiz_app` の現状

- `lib/data/shakai_characters.dart` — `kShakaiCharacters`（`BaseCharacter`のリスト、`imageAsset`未設定＝emoji表示のまま）
- `lib/providers/character_provider.dart` — `CharacterNotifier extends BaseCharacterNotifier`（shared_core標準をそのまま使用）
- `lib/features/character/character_screen.dart` — shared_coreの`CharacterCollectionPage`をそのまま呼んでいるだけ

→ **つまり現状は「Lv別に画像を切り替える」仕組みがまだ無い**（shared_coreの汎用ウィジェットは単一画像前提）。

### 参考実装: `kokugo-kore`（同じLv.1-5方式を先行実装）

kokugo-koreはshared_coreの汎用ウィジェットを使わず、**独自の画面を追加**してLv別画像切り替えを実現している:

- `lib/widgets/kokugo_character_collection.dart` — `KokugoCharacterCollectionPage`（shared_coreの`BaseCharacter`/`characterStateProvider`は流用しつつ、表示は完全に自前実装）
- `lib/data/kokugo_characters.dart` — `imageAsset: 'assets/characters/01_honhon.png'`（Lv.1画像パスのみ登録、Lv2以降は上記ウィジェット内でファイル名パターン組み立て）
- 画像ファイルは `assets/character_levels/{charCode}_{charName}_lv2_{i}.jpg` のような命名で個別配置
- `organize_character_images.py` で手動収集した画像をリネーム・配置

**社会コレでの実装方針は2択**:

| 方針 | メリット | デメリット |
|---|---|---|
| A. kokugo-kore同様に`SocialCharacterCollectionPage`を独自実装 | 既存の他アプリに影響しない、社会コレ独自の見せ方も可能 | コード重複（kokugoとほぼ同じロジックを再度書く） |
| B. shared_core側を拡張し、`BaseCharacter`に`imageAssetForLevel(int level)`的なgetterを追加、`CharacterCollectionPage`をLv別画像対応にする | 全シリーズ共通化・今後の新アプリでも再利用可 | shared_coreの変更は他アプリ（国語コレ含む）への影響確認が必要 |

**推奨**: 方針B（shared_core拡張）。ただし国語コレは既に独自実装で動いているため、
shared_core拡張後にkokugo-kore側を移行するかは任意（当面は共存でも問題ない）。

---

## 5. 実装チェックリスト（未着手・GitHub側で対応）

### Step 1: データ定義の更新
- [ ] `lib/data/shakai_characters.dart` を新ラインナップに全面書き換え
  - id/name を上記表の新名称に変更
  - backstory・stampPhrases 内の名前を新名称に置換（内容は流用可）
  - `imageAsset: 'assets/characters/{id}.png'` を全16体に追加

### Step 2: アセット配置・登録
- [ ] `H:\マイドライブ\images\小学コレ！\社会\キャラクター\` の80枚を
      `social_quiz_app/assets/characters/` にコピー
- [ ] `pubspec.yaml` の `assets:` に `- assets/characters/` を追加
  （現状は `assets/images/`, `assets/data/`, `assets/icon/` のみ登録済み。
  参考: [reference_flutter_asset_subfolder_not_recursive] — サブフォルダは直下のみ、
  今回はフォルダ単位追加なので該当しないが、ファイル数が多い場合はビルド時間に注意）

### Step 3: Lv別画像切り替えの実装（方針A/Bを選択）
- [ ] （方針B推奨）`shared_core`の`BaseCharacter`に、`imageAsset`のファイル名から
      `_lv2`/`_lv3`/`_lv4`/`_lvmax`サフィックスを付けたパスを返すgetter/メソッドを追加
- [ ] `CharacterCollectionPage`（or 新規`SocialCharacterCollectionPage`）で
      `state.level`に応じて表示画像を切り替える

### Step 4: 動作確認
- [ ] `flutter analyze` エラー0件確認
- [ ] Android実機/エミュレータでキャラクター図鑑画面を開き、Lv.1〜MAXの画像切り替えを確認
- [ ] 既存セーブデータ（`shakai_char_states`キー、旧キャラID基準）との互換性確認
      — **⚠️ キャラID変更（chizuko→mapple等）により、旧セーブデータの解放状況が引き継げない
      可能性がある**。マイグレーション処理を入れるか、「初回起動時にキャラ状態リセット」で
      割り切るか、方針を決めること。

---

## 6. 関連ファイル・ツール

| 用途 | パス |
|---|---|
| 画像生成ツール一式 | `H:\マイドライブ\apps\social_quiz_app\tools\social_quiz_app_image_gen\` |
| 生成済み画像＋manifest | `H:\マイドライブ\images\小学コレ！\社会\キャラクター\` |
| 現行キャラデータ（書き換え対象） | `lib/data/shakai_characters.dart` |
| 参考実装（Lv別画像切替の先行例） | `H:\マイドライブ\apps\kokugo-kore\lib\widgets\kokugo_character_collection.dart` |
| 共通基盤（BaseCharacter/CharacterState定義） | `H:\マイドライブ\apps\shared_core\lib\models\character_data.dart` |
| Leonardo生成スキル（再生成・追加生成時に参照） | `leonardo-ai-image-gen`スキル（本セッションで手順を追記済み） |

---

**次にこの引き継ぎ書を使う人へ**: Step 1〜4の順で進めれば実装できます。
方針A/Bの選択と、Step 4のセーブデータ互換性方針だけは実装前にユーザー確認を推奨します。
