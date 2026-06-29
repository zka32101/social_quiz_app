# Engagement Service - Quick Reference Card

## API クイックリファレンス

### (1) Daily Checkin & Streak

```dart
// チェックインを記録
await service.recordDailyCheckin(parentId, DateTime.now());

// ストリーク情報を取得
final streakData = await service.getStreakData(parentId);
// 戻り値: {
//   'currentStreak': 7,
//   'maxStreak': 30,
//   'totalCheckins': 45,
//   'lastCheckinDate': Timestamp
// }

// Riverpod で監視
final streakFuture = ref.watch(streakDataProvider(parentId));
```

### (2) Weekly Challenge

```dart
// チャレンジを生成
final challenge = await service.generateWeeklyChallenge(
  parentId,
  'phishing', // weakFraudPattern
);
// 戻り値: {
//   'title': 'フィッシング詐欺対策チャレンジ',
//   'difficulty': 'medium',
//   'quizzesCount': 5,
//   'reward': 50,
//   'fraudPattern': 'phishing'
// }

// 進捗を更新
await service.updateChallengeProgress(
  parentId,
  '24', // weekNumber
  3,    // completedQuizzes
);
```

### (3) Safety Score

```dart
// スコアを計算（集計）
final score = await service.calculateSafetyScore(parentId);
// 戻り値: 0.0 ~ 100.0

// アドバイスを取得
final advice = service.getSafetyAdvice(score);
// 戻り値例: "優秀です！詐欺への対策意識が高いです。"

// Riverpod で監視
final scoreFuture = ref.watch(safetyScoreProvider(parentId));
```

### (4) Badges & Milestones

```dart
// マイルストーンを検出
final badges = await service.detectMilestones(parentId, userProgress);
// 戻り値: ['streak_7days', 'safety_expert', 'engaged_10']

// バッジ定義を取得
final defs = service.getBadgeDefinitions();
// 戻り値: {
//   'streak_7days': {
//     'name': '7日連続達成',
//     'description': '7日連続でチェックインしました',
//     'emoji': '🔥'
//   },
//   ...
// }

// Riverpod で監視
final badgesFuture = ref.watch(
  milestonesProvider((parentId, userProgress))
);
```

### (5) Activity Logging

```dart
// 正常な活動をログ
await service.logActivity(
  parentId,
  'quiz_completed',
  {'score': 85, 'timestamp': DateTime.now().toIso8601String()},
  'low',
);

// 疑わしい活動をログ
await service.logActivity(
  parentId,
  'suspicious',
  {'type': 'unknown_link_click'},
  'high',
);
```

---

## ウィジェット使用例

### ストリーク表示

```dart
StreakWidget(parentId: parentId)
// 出力: 
// 🔥 7日
// 最長: 30日
// 累計チェックイン: 45回
```

### セーフティスコア表示

```dart
SafetyScoreWidget(parentId: parentId)
// 出力:
// [大きい円グラフ]
// セーフティスコア: 85.0
// 💡 優秀です！...
```

### バッジ表示

```dart
BadgesWidget(parentId: parentId, userProgress: userProgress)
// 出力: グリッドで最大3列のバッジ表示
// 🔥 7日連続達成
// 🛡️ セーフティマスター
// ✅ エンゲージ10
```

### ダッシュボード

```dart
ParentEngagementDashboard(
  parentId: parentId,
  userProgress: userProgress,
)
// 全機能を統合表示
```

---

## Cloud Functions リファレンス

### Scheduled (自動実行)

| 名前 | スケジュール | 説明 |
|------|----------|------|
| `generateWeeklyChallenges` | 毎週月曜日 0:00 | チャレンジ生成 |
| `aggregateSafetyScores` | 毎日 1:00 | スコア集計 |
| `detectAndAwardMilestones` | 毎日 2:00 | バッジ検出 |

### Callable (オンデマンド)

```javascript
// Dart から呼び出し
final result = await FirebaseFunctions.instance
  .httpsCallable('updateChallengeProgress')
  .call({
    'parentId': 'parent_123',
    'weekNumber': '24',
    'completedQuizzes': 3,
  });

final result = await FirebaseFunctions.instance
  .httpsCallable('logParentActivity')
  .call({
    'parentId': 'parent_123',
    'actionType': 'quiz_completed',
    'details': {'score': 85},
    'riskLevel': 'low',
  });
```

---

## バッジ一覧

### ストリーク系

| ID | 条件 | 絵文字 |
|-----|------|--------|
| `streak_7days` | 7日連続 | 🔥 |
| `streak_14days` | 14日連続 | 🌟 |
| `streak_30days` | 30日連続 | 👑 |

### セーフティ系

| ID | 条件 | 絵文字 |
|-----|------|--------|
| `safety_expert` | スコア >= 70 | 🔐 |
| `safety_master` | スコア >= 85 | 🛡️ |

### エンゲージメント系

| ID | 条件 | 絵文字 |
|-----|------|--------|
| `engaged_10` | チェックイン 10回 | ✅ |
| `engaged_30` | チェックイン 30回 | 💪 |
| `engaged_100` | チェックイン 100回 | 🚀 |

### 複合系

| ID | 条件 | 絵文字 |
|-----|------|--------|
| `child_achievement_5` | 子が5バッジ獲得 | 👨‍👩‍👧 |
| `challenge_master_5` | チャレンジ5個完了 | 🏆 |

---

## Firestore クエリ集

### 親のデータ取得

```dart
// 単一親
final docSnap = await FirebaseFirestore.instance
  .collection('parent_engagement')
  .doc(parentId)
  .get();

// ストリーク 7日以上の親
final snapshot = await FirebaseFirestore.instance
  .collection('parent_engagement')
  .where('currentStreak', '>=', 7)
  .get();

// スコア 85以上の親
final snapshot = await FirebaseFirestore.instance
  .collection('parent_engagement')
  .where('totalSafetyScore', '>=', 85)
  .get();
```

### チャレンジ取得

```dart
// 今週のチャレンジ
final challenge = await FirebaseFirestore.instance
  .collection('parent_engagement')
  .doc(parentId)
  .collection('weekly_challenges')
  .doc('week_24')
  .get();

// 完了したチャレンジ一覧
final snapshot = await FirebaseFirestore.instance
  .collection('parent_engagement')
  .doc(parentId)
  .collection('weekly_challenges')
  .where('completed', '==', true)
  .get();
```

### アクティビティログ取得

```dart
// 過去90日のログ
final ninetyDaysAgo = DateTime.now().subtract(Duration(days: 90));
final snapshot = await FirebaseFirestore.instance
  .collection('parent_engagement')
  .doc(parentId)
  .collection('activity_logs')
  .where('timestamp', '>=', 
    Timestamp.fromDate(ninetyDaysAgo))
  .get();

// 高リスク活動
final snapshot = await FirebaseFirestore.instance
  .collection('parent_engagement')
  .doc(parentId)
  .collection('activity_logs')
  .where('riskLevel', '==', 'high')
  .get();
```

---

## トラブルシューティング早見表

| 症状 | 原因 | 解決方法 |
|------|------|--------|
| スコアが 0 | Firestore にデータなし | `calculateSafetyScore()` を手動実行 |
| バッジが増えない | Cloud Scheduler が未実行 | `gcloud scheduler jobs run ...` |
| Riverpod でロード中 | async データ取得中 | `.when(loading: ...)` を実装 |
| Firestore エラー | 認証/ルール不正 | Firebase Console でルール確認 |
| Functions エラー | デプロイ失敗 | `firebase deploy --only functions` 再実行 |

---

## デプロイコマンド集

### Dart 側

```bash
# 依存パッケージ取得
flutter pub get

# 静的解析
dart analyze

# ユニットテスト
flutter test test/services/engagement_service_test.dart

# ビルド（確認用）
flutter build apk --release
```

### Firebase Functions 側

```bash
# 依存パッケージ取得
cd firebase/functions
npm install

# デプロイ
firebase deploy --only functions

# 特定関数のみデプロイ
firebase deploy --only functions:generateWeeklyChallenges

# ログ確認
firebase functions:log --limit 50
```

### Cloud Scheduler

```bash
# ジョブ作成
gcloud scheduler jobs create pubsub generate-weekly-challenges \
  --schedule "0 0 ? * MON" \
  --timezone "Asia/Tokyo" \
  --topic="generate-weekly-challenges" \
  --message-body="{}" \
  --location asia-northeast1

# ジョブ一覧
gcloud scheduler jobs list --location asia-northeast1

# ジョブ実行
gcloud scheduler jobs run generate-weekly-challenges \
  --location asia-northeast1

# ジョブ削除
gcloud scheduler jobs delete generate-weekly-challenges \
  --location asia-northeast1
```

---

## パフォーマンス チューニング

### キャッシング

```dart
// FutureProvider に自動キャッシュ（60秒）
ref.cacheFor(const Duration(minutes: 1));
```

### Firestore インデックス

```
// 複合インデックス（Cloud Console で自動作成される）
Collection: parent_engagement
Fields:
  - currentStreak (Ascending)
  - totalSafetyScore (Descending)
```

### Cloud Functions 最適化

```javascript
// バッチ処理（複数親を効率的に処理）
const batch = db.batch();
for (const parentId of parentIds) {
  batch.update(db.collection('parent_engagement').doc(parentId), {
    totalSafetyScore: newScore,
  });
}
await batch.commit();
```

---

## セキュリティチェックリスト

- [ ] Firestore ルールで `request.auth.uid` チェック
- [ ] Cloud Functions はサービスアカウント認証
- [ ] API キーに制限設定（Firebase Console）
- [ ] 本番環境では HTTPS のみ使用
- [ ] ログは PII を含まない
- [ ] バックアップを定期実行

---

## ファイル構成（再掲）

```
social_quiz_app/
├── lib/
│   └── services/
│       ├── engagement_service.dart
│       └── engagement_service_example.dart
├── firebase/
│   └── functions/
│       ├── engagement_functions.js
│       ├── package.json
│       └── index.js
├── test/
│   └── services/
│       └── engagement_service_test.dart
├── ENGAGEMENT_SERVICE_README.md
├── ENGAGEMENT_SERVICE_SETUP.md
├── ENGAGEMENT_SERVICE_SUMMARY.md
└── ENGAGEMENT_SERVICE_QUICK_REFERENCE.md (このファイル)
```

---

## リソース リンク

- [Flutter Riverpod](https://riverpod.dev)
- [Cloud Firestore](https://firebase.google.com/docs/firestore)
- [Cloud Functions](https://firebase.google.com/docs/functions)
- [Cloud Scheduler](https://cloud.google.com/scheduler/docs)
- [Firebase Console](https://console.firebase.google.com)

---

**最後に**: 質問があれば `ENGAGEMENT_SERVICE_README.md` の詳細セクションを参照してください。

**バージョン**: 1.0.0 (2026-06-15)
