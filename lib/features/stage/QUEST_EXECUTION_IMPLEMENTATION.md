# クエスト実行システム実装ドキュメント（Phase 2）

## 概要

ステージシステムの基礎に基づき、実際にクエスト（問題）を実行・解答するシステムを実装しました。ユーザーはステージ内の5つのクエストを順序に進め、回答を通じてポイントを獲得し、バッジを獲得できるようになります。

**実装完了日**: 2026-05-28  
**フェーズ**: Week 2-3 Phase 2

---

## 実装した内容

### 1. クエスト実行スクリーン（3種類）

#### 1.1 `quiz_execution_screen.dart` - 選択肢式問題
**目的**: 複数の選択肢から正解を選ぶクイズ形式

**機能**:
- A/B/C/D 4択の選択肢表示
- 選択肢のタップで回答送信
- 正解時：チェックマーク表示 + ポイント獲得ダイアログ
- 不正解時：正解表示 + 再試行/スキップオプション
- リアルタイムフィードバック（色変化による正誤判定表示）

**UI コンポーネント**:
- `_OptionTile`: 選択肢タイル（A/B/C/D ラベル、選択状態表示）
- `_buildQuestion()`: 問題文表示
- `_buildOptions()`: 選択肢グリッド生成

**状態管理**:
```dart
int? selectedIndex       // ユーザーが選択したインデックス
bool isAnswered         // 回答済みか否か
bool isCorrect          // 正解判定
```

#### 1.2 `fill_blank_screen.dart` - 穴埋め問題
**目的**: テキスト入力で空欄を埋める形式

**機能**:
- TextField で自由入力
- 「回答を確認」ボタンで送信
- 大文字小文字を区別して検証
- 正解時：ポイント獲得
- 不正解時：正解表示 + 再試行オプション

**UI コンポーネント**:
- `_buildInputField()`: テキスト入力欄
- `_buildProblem()`: 問題文と穴埋め文章表示
- 入力フィールドの有効/無効状態管理

**状態管理**:
```dart
TextEditingController _controller  // ユーザー入力
bool isAnswered                   // 回答済みか否か
bool isCorrect                    // 正解判定
```

#### 1.3 `map_tap_game.dart` - 地図タップゲーム
**目的**: インタラクティブな地図から地域を選択する形式

**機能**:
- 8つの地域タイル（北海道、東北、関東、中部、近畿、中国、四国、九州）
- タップで地域選択
- 正解地域が緑色でハイライト
- 誤選択時は赤色で表示
- 視覚的なフィードバック

**UI コンポーネント**:
- `_MapTile`: 地域タイル（ラベル + 選択状態表示）
- GridView で 2×4 レイアウト配置
- 説明用の info ウィジェット

**状態管理**:
```dart
String? selectedRegion    // ユーザーが選択した地域ID
bool isAnswered          // 回答済みか否か
bool isCorrect           // 正解判定
```

---

## アーキテクチャ設計

```
┌─────────────────────────────────────────────────────────────┐
│  StageDetailScreen (クエスト一覧)                           │
│  ├─ _startQuest() メソッド（クエストタイプ判定）           │
│  └─ クエスト実行スクリーンへナビゲート                     │
└────────────────┬────────────────────────────────────────────┘
                 │
    ┌────────────┼────────────┬──────────────────┐
    │            │            │                  │
    ▼            ▼            ▼                  ▼
┌─────────┐ ┌──────────┐ ┌──────────┐ ┌──────────────┐
│ Quiz    │ │FillBlank │ │ MapTap   │ │ (拡張可能)   │
│Execute  │ │ Screen   │ │ Game     │ │              │
│ Screen  │ │          │ │          │ └──────────────┘
└────┬────┘ └────┬─────┘ └────┬─────┘
     │           │             │
     └───────────┴─────────────┘
            │
     ┌──────▼──────┐
     │ 回答処理     │
     │ - 検証       │
     │ - ポイント加算 │
     │ - バッジ判定  │
     └──────┬──────┘
            │
     ┌──────▼──────────────┐
     │ UserProgressProvider │
     │ (StateNotifier)      │
     └──────┬───────────────┘
            │
     ┌──────▼──────────┐
     │ ProgressRepository │
     │ - completeQuest() │
     │ - addPoints()     │
     │ - Hive 永続化      │
     └───────────────────┘
```

---

## 共通機能

### 1. 回答検証フロー

**共通パターン（3つのスクリーン）**:
```
ユーザー回答
  ↓
_handleAnswer() または _checkAnswer()
  ↓
正解判定（isCorrect = true/false）
  ↓
2秒待機
  ↓
_completeQuest() 実行
  ↓
├─ isCorrect == true
│  ├─ completeQuest(stageId, questNo)
│  ├─ addPoints(pointsReward)
│  └─ _showSuccessDialog()
│
└─ isCorrect == false
   └─ _showRetryDialog()
      ├─ 再試行（状態リセット）
      └─ スキップ（ステージ詳細へ戻る）
```

### 2. ポイント獲得とバッジ判定

**ポイント加算**:
```dart
await ref.read(userProgressProvider.notifier)
    .addPoints(widget.quest.pointsReward);
```

**バッジ自動判定** (ProgressRepository):
- ステージ完了時 → `_checkAndAwardStageBadges()` 実行
- バッジ判定内容:
  1. 難易度別バッジ（初級/中級/上級マスター）
  2. 全ステージ制覇バッジ
  3. スピードランナーバッジ（7日以内にステージ3完了）

### 3. ダイアログ設計

**成功時ダイアログ**:
```
┌─────────────────────────┐
│ ✓ 正解！               │
│                        │
│ 🎉 大きなチェックマーク  │
│                        │
│ +XXpt 獲得！           │
│ [次へ] ボタン         │
└─────────────────────────┘
```

**不正解時ダイアログ**:
```
┌─────────────────────────┐
│ ✗ 不正解               │
│                        │
│ ✗ キャンセルアイコン    │
│                        │
│ 正解は：XXXXXX         │
│ [もう一度] [スキップ] │
└─────────────────────────┘
```

---

## 数値設計

### ポイント報酬体系

| ステージ | ステージ難易度 | 1クエスト | 合計(5問) | 合計全体 |
|---------|-------------|---------|---------|---------|
| 1-2 | 初級 | 20pt | 100pt | 200pt |
| 3-5 | 中級 | 30pt | 150pt | 450pt |
| 6-9 | 上級 | 40pt | 200pt | 800pt |
| 10 | 最高 | 50pt | 250pt | 250pt |

**合計**: 1,500pt（全ステージ完了時）

### バッジ獲得条件

**ステージ完了バッジ**:
- `stage_master_beginner`: Stage 1-2 完了 → +20pt 相当
- `stage_master_intermediate`: Stage 3-5 完了 → +50pt 相当
- `stage_master_advanced`: Stage 6-10 完了 → +100pt 相当
- `stage_100_completion`: Stage 1-10 全制覇 → +200pt 相当（レジェンダリ）

---

## ファイル構成

```
lib/features/stage/
├── stage_selection_screen.dart        (既存・変更なし)
├── stage_detail_screen.dart           (更新: ナビゲーション追加)
├── quiz_execution_screen.dart         (新規作成)
├── fill_blank_screen.dart             (新規作成)
├── map_tap_game.dart                  (新規作成)
└── QUEST_EXECUTION_IMPLEMENTATION.md (このファイル)

lib/repositories/
├── progress_repository.dart           (更新: badge award logic)
└── stage_repository.dart              (既存・変更なし)

lib/models/
├── stage.dart                        (既存・変更なし)
├── user_progress.dart                (既存・変更なし)
└── badge_v2.dart                     (既存・v1.1対応済み)
```

---

## テスト仕様

### 機能テスト項目

| テスト項目 | 内容 | 期待結果 |
|----------|------|--------|
| 選択肢式クイズ | 選択肢をタップ | 正解・不正解判定、ポイント加算 |
| 穴埋め問題 | テキスト入力 + 確認 | 完全一致で正解判定 |
| 地図タップ | 地図をタップ | 地域選択、正解判定 |
| ポイント加算 | クエスト完了 | ユーザープログレスに加算 |
| バッジ付与 | ステージ完了 | 条件に応じてバッジ付与 |
| 再試行機能 | 「もう一度」ボタン | 状態リセット、再回答可能 |
| スキップ機能 | 「スキップ」ボタン | ステージ詳細へ戻る |

### パフォーマンス測定

- スクリーン遷移時間: < 200ms
- 回答判定: < 50ms
- ポイント加算: < 100ms
- バッジ判定: < 200ms

---

## 実装上の注意点

### 1. TODO コメント（将来実装予定）

```dart
// quiz_execution_screen.dart
// TODO: Firestore からクイズ詳細を取得
options = [ /* ダミーデータ */ ];

// fill_blank_screen.dart
// TODO: Firestore からクイズ詳細を取得
correctAnswer = '北海道';

// map_tap_game.dart
// TODO: Firestore からクイズ詳細を取得
correctAnswer = 'hokkaido';
```

**現在の仕様**: 各スクリーンにダミーデータを埋め込み  
**将来**: Firestore から動的取得に変更（Phase 3-4）

### 2. クエストタイプのマッピング

`stage_detail_screen.dart` で以下のように処理:

```dart
switch (quest.type) {
  case 'multiple_choice':
    → QuizExecutionScreen
  case 'fill_blank':
    → FillBlankScreen
  case 'map_tap':
    → MapTapGame
  default:
    → エラーメッセージ
}
```

### 3. 状態管理の一貫性

- ユーザープログレスは `UserProgressNotifier` で管理
- ローカル（Hive）に即座に保存
- Firestore 同期は TODO（将来実装）

---

## 次のステップ（Phase 3）

### 短期目標（Week 3）

1. **Firestore 統合**
   - クイズデータの動的読み込み
   - ダミーデータの置き換え
   - スキーマ検証

2. **UI/UX 改善**
   - アニメーション追加（正解時のエフェクト）
   - 親切な説明機能（「なぜ？」セクション）
   - スコア表示の詳細化

3. **拡張クエストタイプ**
   - マッチング問題（線でつなぐ）
   - 並べ替え問題
   - 複合型問題

### 中期目標（Week 4+）

1. **ゲーミフィケーション拡張**
   - コンボシステム（連続正解ボーナス）
   - タイムアタック モード
   - ランキング連携

2. **分析機能**
   - 弱点分析（どの地域が苦手か）
   - 学習時間トラッキング
   - 親への進捗報告機能

3. **オンボーディング**
   - クエスト説明画面
   - チュートリアル機能
   - 難易度調整

---

## 実装統計

- **新規ファイル数**: 3 ファイル
- **更新ファイル数**: 2 ファイル
- **合計行数**: 約 900 行（ドキュメント含まない）
- **コンパイル状態**: ✅ 成功（80 outputs, 175 actions）
- **APK ビルド**: ⏳ 進行中

---

## 参考資料

- `lib/features/stage/STAGE_SYSTEM_IMPLEMENTATION.md` - ステージシステム設計
- `lib/models/badge_v2.dart` - バッジシステム定義
- `lib/repositories/progress_repository.dart` - 進捗管理実装

---

**最終更新**: 2026-05-28 14:30 JST  
**ステータス**: Phase 2 実装完了、Phase 3 準備中
