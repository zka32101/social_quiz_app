# ステージシステム実装ドキュメント

## 実装完了: Week 1-2 Phase 1 - ステージシステムの基礎

### 📋 概要

小学校社会勉強アプリに**10段階のステージ学習システム**を実装しました。ユーザーは段階的に難易度を上げながら社会学習を進めることができます。

---

## 1. 実装した内容

### 1.1 モデル層 (`lib/models/`)

#### ✅ `stage.dart` - ステージシステムの中核データモデル
- **Quest クラス**: 各ステージ内の個別クエスト
  - id, questNo, title, description, type（map_tap / multiple_choice / fill_blank）
  - pointsReward, isCompleted, completedAt
  - Firestore 連携用の fromJson/toJson

- **Stage クラス**: 学習ステージ（1-10段階）
  - stageNo, title, description, level（初級/中級/上級）
  - gradeRange（対象学年: 1-2, 3-4, 5-6）
  - prefectureRange（対応地域）
  - quests リスト、totalPoints
  - isUnlocked, isCompleted フラグ
  - completionPercentage 計算プロパティ

- **StageLevel enum**: 難易度レベル管理
  - beginner（初級）, intermediate（中級）, advanced（上級）

- **StageData**: MVP 10ステージのマスターデータ
  - Stage 1-2: 低学年向け基礎（北海道・東北、関東）
  - Stage 3-5: 中学年向け（近畿、九州、産業基礎）
  - Stage 6-10: 高学年向け（農業、工業、文化、交通、マスター認定）

### 1.2 ユーザー進捗モデル更新 (`lib/models/user_progress.dart`)

#### ✅ StageProgress クラス追加
- 各ステージの進捗を個別に管理
- completedQuests[], isUnlocked, isCompleted フラグ
- unlockedAt, completedAt タイムスタンプ

#### ✅ UserProgress クラス拡張
- stageProgress map を追加（`Map<String, StageProgress>`）
- completedStageCount, unlockedStageCount 計算プロパティ
- getStageProgress() ヘルパーメソッド
- getNextStageToUnlock() 次のアンロック対象を自動検出

### 1.3 リポジトリ層 (`lib/repositories/`)

#### ✅ `stage_repository.dart` - ステージコンテンツ管理
- StageRepository クラス
  - getAllStages(): 全ステージ取得
  - getStage(stageId): 特定ステージ取得
  - getStagesByGrade(grade): 学年別ステージフィルタリング
  - getQuestsByStage(stageId): ステージのクエスト取得

- Riverpod FutureProviders
  - `allStagesProvider`: 全ステージリスト
  - `stagesByGradeProvider`: 学年別ステージ
  - `stageProvider`: 単一ステージ（FutureProvider.family）
  - `questsByStageProvider`: ステージのクエスト

#### ✅ `progress_repository.dart` 拡張
- StageProgress の Hive ローカルストレージ化
- _loadStageProgress(): ローカルから進捗読み込み
  - Stage 1 はデフォルトで開放（unlockedAt 設定）
- completeQuest(stageId, questNo): クエスト完了記録
- unlockStage(stageId): ステージ開放
- _checkAndAwardStageBadges(): ステージ完了時のバッジ判定スケルトン

#### ✅ UserProgressNotifier StateNotifier 実装
- completeQuest(), unlockStage() メソッドを StateNotifier に統合
- setGrade(), setParentEmail() などの既存メソッドを拡張
- _reloadFromLocal(): 状態の一貫性確保

#### ✅ Riverpod Providers
- `userProgressProvider`: StateNotifierProvider（段階的な進捗更新）
- `userIdProvider`: StateProvider（認証 UID 管理）

### 1.4 UI 層 (`lib/features/stage/`)

#### ✅ `stage_selection_screen.dart` - ステージ選択画面
**機能**:
- 全 10 ステージをカード形式で表示
- ステージの状態を視覚的に表現:
  - 🔒 ロック状態（未開放）
  - ✓ 完了状態（チェックマーク表示）
  - → アクティブ状態（矢印表示）

**UI コンポーネント**:
- _StageCard: ステージ情報カード
  - ステージ番号、タイトル、説明
  - 難易度バッジ（初級/中級/上級、色分け）
  - 対象学年バッジ（1-2年生向けなど）
  - 進捗バー（完了クエスト数/総クエスト数）
  - 獲得可能ポイント表示

- _DifficultyBadge: 難易度表示
- _GradeBadge: 対象学年表示

#### ✅ `stage_detail_screen.dart` - ステージ詳細画面（クエスト一覧）
**機能**:
- ステージ内の全クエストを一覧表示
- クエスト完了状況をリアルタイム表示
- ステージ全体の進捗率表示（プログレスバー）

**UI コンポーネント**:
- SliverAppBar: スクロール可能なヘッダー
  - ステージタイトル、説明
  - 進捗表示（完了クエスト数/総数）
  - 獲得可能ポイント
  - 進捗バー

- _QuestTile: クエスト行
  - クエスト番号（サークル内表示）
  - タイトル、説明
  - クエストタイプバッジ
  - ポイント報酬表示
  - 完了状態の視覚的フィードバック

**クエストタイプ分類**:
- 🗺️ map_tap（地図タップ）
- ⚪ multiple_choice（選択肢式）
- ✏️ fill_blank（穴埋め問題）

---

## 2. アーキテクチャ設計

```
┌─────────────────────────────────────────────────┐
│  UI Layer (Screens)                             │
│  ├─ StageSelectionScreen  (全ステージ選択)      │
│  └─ StageDetailScreen     (クエスト一覧)        │
└────────────────┬──────────────────────────────┘
                 │
┌────────────────▼──────────────────────────────┐
│  Riverpod Providers (State Management)        │
│  ├─ userProgressProvider (StateNotifier)      │
│  ├─ allStagesProvider (FutureProvider)        │
│  ├─ stagesByGradeProvider (FutureProvider.fm) │
│  └─ questsByStageProvider (FutureProvider.fm) │
└────────────────┬──────────────────────────────┘
                 │
┌────────────────▼──────────────────────────────┐
│  Repository Layer                             │
│  ├─ StageRepository (コンテンツ管理)          │
│  ├─ ProgressRepository (進捗管理)             │
│  └─ UserProgressNotifier (状態更新)           │
└────────────────┬──────────────────────────────┘
                 │
┌────────────────▼──────────────────────────────┐
│  Model Layer                                  │
│  ├─ Stage, Quest (コンテンツ定義)             │
│  ├─ StageProgress (進捗追跡)                  │
│  └─ UserProgress (ユーザー全体進捗)           │
└────────────────┬──────────────────────────────┘
                 │
┌────────────────▼──────────────────────────────┐
│  Data Layer                                   │
│  ├─ Hive Box (ローカル永続化)                │
│  ├─ StageData MVP (マスターデータ)            │
│  └─ Firestore (クラウド同期)                 │
└─────────────────────────────────────────────────┘
```

---

## 3. 学習フロー（ユーザー体験）

### 初期状態
```
UserProgress.initial()
  └─ stageProgress: { 'stage_1': StageProgress(isUnlocked: true) }
  └─ 他のステージは locked
```

### ユーザー操作フロー
```
1. StageSelectionScreen でステージ一覧を表示
   - Stage 1 のみ開放（✓ 1 つの矢印アイコン）
   - Stage 2-10 はロック状態
   
2. Stage 1 をタップ
   → StageDetailScreen へ遷移
   
3. StageDetailScreen で 5 つのクエストを表示
   - Quest 1-5 の状態を表示
   - 未完了: 番号表示、アクティブ
   - 完了: チェックマーク表示
   
4. Quest 1 をタップ
   → QuizScreen or MapScreen へ遷移 (実装予定)
   
5. クイズ完了時
   → completeQuest('stage_1', 1) を呼び出し
   → userProgressProvider が自動更新
   → StageDetailScreen が進捗を再表示
   
6. 全 5 クエスト完了時
   → Stage 1 が isCompleted: true に
   → Stage 2 が自動的に unlockStage('stage_2') される (予定)
```

---

## 4. MVP ステージ定義

| Stage No. | タイトル | 難易度 | 対象学年 | 対応地域 | ポイント |
|-----------|---------|------|--------|---------|---------|
| 1 | 北海道・東北地方を学ぼう | 初級 | 1-2年 | hokkaido_tohoku | 100 |
| 2 | 関東地方を学ぼう | 初級 | 1-2年 | kanto | 100 |
| 3 | 近畿地方を学ぼう | 中級 | 3-4年 | kinki | 150 |
| 4 | 九州地方を学ぼう | 中級 | 3-4年 | kyushu | 150 |
| 5 | 日本の産業を学ぼう | 中級 | 3-4年 | all | 150 |
| 6 | 農業と食べ物 | 上級 | 5-6年 | all | 200 |
| 7 | 工業と製造業 | 上級 | 5-6年 | all | 200 |
| 8 | 文化と観光地 | 上級 | 5-6年 | all | 200 |
| 9 | 交通と流通 | 上級 | 5-6年 | all | 200 |
| 10 | 社会博士への道 | 上級 | 5-6年 | all | 250 |

**合計ポイント**: 1,500 pt（全ステージ完了時）

---

## 5. データ構造（Firestore スキーマ準備）

### Collection: `stages`
```json
{
  "id": "stage_1",
  "stageNo": 1,
  "title": "北海道・東北地方を学ぼう",
  "description": "日本の北にある地方について学びます",
  "level": "beginner",
  "gradeRange": "1-2",
  "prefectureRange": "hokkaido_tohoku",
  "totalPoints": 100,
  "quests": [
    {
      "id": "stage_1_quest_1",
      "questNo": 1,
      "title": "北海道の位置を学ぼう",
      "description": "日本地図から北海道をタップしてください",
      "type": "map_tap",
      "pointsReward": 20
    },
    ...
  ]
}
```

### Collection: `users/{userId}/progress/{stageId}`
```json
{
  "stageId": "stage_1",
  "stageNo": 1,
  "completedQuests": [1, 2, 3],
  "isUnlocked": true,
  "isCompleted": false,
  "unlockedAt": "2026-05-28T10:30:00Z",
  "completedAt": null
}
```

---

## 6. テスト状況

✅ **build_runner**: 成功 (69 outputs)
✅ **Dart コンパイル**: エラーなし
✅ **型安全性**: 全モデルで fromJson/toJson 実装済み
✅ **APK ビルド**: 実行中...

---

## 7. 次の実装ステップ（Week 2-3）

### Phase 2: クエスト実行システム
- **QuizExecutionScreen**: クイズ出題画面
- **MapTapGame**: 地図タップゲーム
- **FillBlankScreen**: 穴埋め問題画面
- スコア計算とポイント付与

### Phase 3: バッジシステム拡張
- ステージ完了バッジの自動付与
- 連続完了バッジ
- 難易度別バッジ

### Phase 4: 親ダッシュボード
- 子どもの学習進捗表示
- ステージ完了通知
- 学習時間トラッキング

---

## 8. ファイル一覧

新規作成ファイル:
```
lib/models/stage.dart                          [210 lines] ✅
lib/features/stage/stage_selection_screen.dart [280 lines] ✅
lib/features/stage/stage_detail_screen.dart    [290 lines] ✅
lib/repositories/stage_repository.dart         [110 lines] ✅

修正ファイル:
lib/models/user_progress.dart                  [+ StageProgress class]
lib/repositories/progress_repository.dart      [+ stage progress methods]
```

---

## 9. 実装済み機能まとめ

| 機能 | 実装状況 | 詳細 |
|------|--------|------|
| ステージモデル | ✅ 完了 | 10ステージ定義済み |
| クエストモデル | ✅ 完了 | タイプ分類実装 |
| 進捗追跡 | ✅ 完了 | Hive 永続化 |
| ステージ選択UI | ✅ 完了 | スクリーン実装済み |
| クエスト一覧UI | ✅ 完了 | スクリーン実装済み |
| Riverpod 統合 | ✅ 完了 | StateNotifier, FutureProviders |
| ローカル永続化 | ✅ 完了 | Hive ボックス設定 |
| Firestore 準備 | ✅ 準備完了 | スキーマ設計済み、実装は未実装 |
| クエスト実行 | ❌ 未実装 | Week 2-3 予定 |
| バッジ付与自動化 | ⚠️ スケルトン | 実装骨組みのみ |
| 親ダッシュボード | ❌ 未実装 | Week 4+ 予定 |

---

## 10. 開発環境コマンド

```bash
# ビルド確認
flutter pub run build_runner build --delete-conflicting-outputs

# APK ビルド
flutter build apk --split-per-abi

# 開発実行
flutter run --debug

# テスト実行 (作成予定)
flutter test
```

---

## 11. 注記・制約

- 現在、Firestore への同期は未実装（TODO コメント挿入）
- ステージのクエスト総数を 5 で仮定（後で調整可能）
- バッジ付与ロジックはスケルトン実装（フル実装は Week 3）
- 次のステージ自動開放は未実装（completeStep 時に手動呼び出し予定）

---

**実装完了日**: 2026-05-28
**次の レビュー**: Week 2 ステップ確認時
