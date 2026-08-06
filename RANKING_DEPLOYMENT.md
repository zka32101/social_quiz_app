# ランキング機能 - デプロイ手順

## 📋 チェックリスト

### ✅ コード実装（完了）
- [x] `lib/models/ranking_entry_model.dart` — ランキングエントリ
- [x] `lib/models/user_stats_model.dart` — ユーザー統計
- [x] `lib/providers/ranking_provider.dart` — Firestore クエリ
- [x] `lib/screens/ranking_screen.dart` — UI画面
- [x] `lib/services/ranking_service.dart` — スコア更新ロジック
- [x] `lib/features/prefecture/quiz_screen.dart` — クイズ統合
- [x] `lib/features/multiplayer/multiplayer_quiz_screen.dart` — マルチプレイ統合
- [x] `firestore.rules` — セキュリティルール
- [x] `functions/index.js` — Cloud Functions
- [x] `functions/package.json` — 依存関係

---

## 🚀 デプロイ手順

### **Step 1: Firebase CLI インストール**

```bash
npm install -g firebase-tools
firebase login
```

### **Step 2: Firestore セキュリティルール デプロイ**

```bash
cd H:\マイドライブ\apps\social_quiz_app
firebase deploy --only firestore:rules
```

**確認**: Firebase Console → Firestore → Rules タブで規則が更新されたことを確認

---

### **Step 3: Cloud Functions デプロイ**

```bash
cd H:\マイドライブ\apps\social_quiz_app\functions
npm install
cd ..
firebase deploy --only functions
```

**確認**: Firebase Console → Functions タブで以下の関数が表示される
- ✅ `resetWeeklyRankingScheduled`
- ✅ `updateRankingMetadata`
- ✅ `initializeUserStats`

---

### **Step 4: Cloud Scheduler 設定**

Firebase Console で以下の手順を実行：

1. **ナビゲーション**: Cloud Scheduler（または「スケジュール」→「ジョブ」）
2. **ジョブを作成**
   - **名前**: `reset-weekly-ranking`
   - **周期**: `0 0 * * 0`（毎週日曜 00:00 JST）
   - **タイムゾーン**: `Asia/Tokyo`
   - **実行対象**: `Pub/Sub`
   - **Pub/Sub トピック**: `firebase-schedule-resetWeeklyRankingScheduled`
   - **メッセージ本体**: `{}`

---

### **Step 5: Firestore インデックス作成**

Firebase Console → Firestore → インデックス → 以下の複合インデックスを手動作成

**インデックス1: グローバルランキング**
```
Collection: leaderboards/global/entries
Fields:
  - totalScore (降順)
  - updatedAt (降順)
```

**インデックス2: 週間ランキング**
```
Collection: leaderboards/weekly/entries
Fields:
  - totalScore (降順)
  - updatedAt (降順)
```

---

## 📱 アプリデプロイ

### **APK ビルド & リリース**

```bash
cd H:\マイドライブ\apps\social_quiz_app
flutter pub get
flutter build apk --release
```

**出力**: `build/app/outputs/flutter-apk/app-release.apk`

Google Play Console にアップロード：
1. Internal Testing → APK アップロード
2. テスト → リリース本番

---

## 🧪 テスト検証

### **ローカルテスト（Firebase Emulator）**

```bash
firebase emulators:start --import=./emulator_data
```

### **本番テスト**

1. **ユーザー作成** → `/users/{userId}` が初期化される
2. **クイズ完了** → `/leaderboards/global/entries` が更新される
3. **マルチプレイ** → `/leaderboards/global/entries` が更新される
4. **毎週日曜0時** → `/leaderboards/weekly/entries` がリセットされる

---

## 🔍 トラブルシューティング

### エラー: "Permission denied" (Firestore)
→ `firestore.rules` が正しくデプロイされていることを確認
```bash
firebase deploy --only firestore:rules
```

### エラー: "Function not found" (Cloud Functions)
→ 関数がデプロイされているか確認
```bash
firebase deploy --only functions --debug
```

### ランキングが更新されない
→ Cloud Functions ログを確認
```bash
firebase functions:log
```

---

## 📊 運用チェック

- [ ] 毎週日曜 00:00 に週間ランキングがリセットされているか
- [ ] 新規ユーザーが作成されると `/users/{userId}` が自動初期化されているか
- [ ] クイズ完了時にランキング順位が更新されているか
- [ ] Firestore データ使用量が許容範囲内か

---

**最終更新**: 2026-07-06
