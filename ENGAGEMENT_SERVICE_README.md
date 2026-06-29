# Engagement Service - 親向けエンゲージメント管理システム

## 概要

`engagement_service.dart` は、親のエンゲージメント向上に特化した包括的なサービスです。以下4つの主要機能を提供します：

1. **Daily Checkin & Streak Tracking** - 連続学習日数の追跡
2. **Weekly Challenge Generation** - 親の弱い詐欺パターンに基づくチャレンジ自動生成
3. **Safety Score Calculation** - AI 真実判定・詐欺クイズ・リスク評価の統合スコア
4. **Milestone Detection & Badges** - 成果に応じた自動バッジ授与

## ファイル構成

```
social_quiz_app/
├── lib/services/
│   ├── engagement_service.dart          # メインサービス実装
│   └── engagement_service_example.dart  # 使用例とベストプラクティス
├── firebase/functions/
│   └── engagement_functions.js          # Cloud Functions バックエンド
└── ENGAGEMENT_SERVICE_README.md         # このファイル
```

## 機能詳細

### (1) Daily Checkin & Streak Tracking

#### 概要
子どもの学習完了時に親のチェックインを自動記録し、ストリーク（連続学習日数）を更新します。

#### API

```dart
Future<void> recordDailyCheckin(
  String parentId,
  DateTime timestamp,
)
```

#### ロジック
- **初回チェックイン**: ストリーク = 1
- **昨日からの連続**: ストリーク += 1
- **1日以上ブレイク**: ストリーク = 1（リセット）
- **同じ日**: スキップ

#### Firestore スキーマ

```json
// parent_engagement/{parentId}
{
  "parentId": "parent_123",
  "lastCheckinDate": Timestamp,
  "currentStreak": 7,
  "maxStreak": 30,
  "totalCheckins": 45,
  "updatedAt": Timestamp
}
```

#### 使用例

```dart
// 子どものクイズ完了トリガー
final service = ref.read(engagementServiceProvider);
await service.recordDailyCheckin(parentId, DateTime.now());
```

---

### (2) Weekly Challenge Generation

#### 概要
親の弱い詐欺パターンを分析し、それに特化したチャレンジを毎週月曜日に自動生成します。

#### API

```dart
Future<Map<String, dynamic>> generateWeeklyChallenge(
  String parentId,
  String weakFraudPattern,  // 'phishing', 'fake_news', etc.
)

Future<void> updateChallengeProgress(
  String parentId,
  String weekNumber,
  int completedQuizzes,
)
```

#### 詐欺パターンの種類

| パターン | タイトル | 難易度 | クイズ数 | 報酬 |
|---------|---------|--------|---------|------|
| `phishing` | フィッシング詐欺対策 | medium | 5 | 50 |
| `fake_news` | 偽情報検証 | hard | 5 | 75 |
| `social_engineering` | ソーシャルエンジニアリング回避 | hard | 5 | 75 |
| `password_security` | パスワードセキュリティ | easy | 3 | 30 |
| `payment_fraud` | 決済詐欺検出 | medium | 5 | 50 |

#### Firestore スキーマ

```json
// parent_engagement/{parentId}/weekly_challenges/week_{weekNumber}
{
  "parentId": "parent_123",
  "weekNumber": 24,
  "startDate": Timestamp,
  "endDate": Timestamp,
  "fraudPattern": "phishing",
  "title": "フィッシング詐欺対策チャレンジ",
  "description": "疑わしいメールリンクを見つけ出す練習",
  "difficulty": "medium",
  "quizzesCount": 5,
  "reward": 50,
  "completed": false,
  "quizzesCompleted": 0,
  "completedAt": null
}
```

#### 使用例

```dart
// チャレンジ生成（Cloud Scheduler が自動実行）
final challenge = await service.generateWeeklyChallenge(
  parentId,
  'phishing',
);

// 進捗更新
await service.updateChallengeProgress(
  parentId,
  '24',  // week number
  3,     // completed quizzes
);
```

---

### (3) Safety Score Calculation

#### 概要
3つの要素を加重平均して、親のセーフティスコア（0-100）を計算します。

#### API

```dart
Future<double> calculateSafetyScore(String parentId)

String getSafetyAdvice(double safetyScore)
```

#### スコア構成（加重平均）

```
セーフティスコア = 
  AI真実スコア × 0.30 +
  詐欺クイズスコア × 0.40 +
  リスク評価スコア × 0.30
```

| 要素 | 説明 | 範囲 | 比重 |
|-----|------|------|------|
| **AI 真実スコア** | AI が検出した詐欺判定精度 | 0-100 | 30% |
| **詐欺クイズスコア** | ウィークリーチャレンジの成績 | 0-100 | 40% |
| **リスク評価スコア** | 過去90日の疑わしい行動分析 | 0-100 | 30% |

#### リスク評価ロジック

```dart
リスクスコア = 100 - (疑わしい行動数 / 総行動数 × 100)
```

#### アドバイス生成

```
スコア >= 85: "優秀です！詐欺への対策意識が高いです。"
スコア >= 70: "良好です。さらにチャレンジに挑戦して知識を深めましょう。"
スコア >= 50: "注意が必要です。詐欺パターンの学習を強化してください。"
スコア <  50: "危険です。緊急に詐欺対策の学習を開始してください。"
```

#### Firestore スキーマ

```json
// parent_engagement/{parentId}
{
  "aiTruthScore": 82.5,
  "crimeQuizScore": 75.0,
  "safetyRiskScore": 95.0,
  "totalSafetyScore": 83.1,
  "safetyScoreUpdatedAt": Timestamp
}
```

#### 使用例

```dart
final safetyScore = await service.calculateSafetyScore(parentId);
final advice = service.getSafetyAdvice(safetyScore);

print('セーフティスコア: $safetyScore');
print('アドバイス: $advice');
```

---

### (4) Milestone Detection & Badge Achievements

#### 概要
親のエンゲージメント成長に応じて、自動的にバッジを検出・授与します。

#### API

```dart
Future<List<String>> detectMilestones(
  String parentId,
  UserProgress userProgress,
)

Map<String, Map<String, String>> getBadgeDefinitions()
```

#### バッジ一覧

| バッジID | 条件 | 説明 |
|----------|------|------|
| `streak_7days` | currentStreak >= 7 | 7日連続達成 🔥 |
| `streak_14days` | currentStreak >= 14 | 14日連続達成 🌟 |
| `streak_30days` | currentStreak >= 30 | 1ヶ月連続達成 👑 |
| `safety_master` | safetyScore >= 85 | セーフティマスター 🛡️ |
| `safety_expert` | safetyScore >= 70 | セーフティエキスパート 🔐 |
| `engaged_10` | totalCheckins >= 10 | 10回チェックイン達成 ✅ |
| `engaged_30` | totalCheckins >= 30 | 30回チェックイン達成 💪 |
| `engaged_100` | totalCheckins >= 100 | 100回チェックイン達成 🚀 |
| `child_achievement_5` | 子どもが5バッジ獲得 | パパママ応援者 👨‍👩‍👧 |
| `challenge_master_5` | 5つのチャレンジ完了 | チャレンジマスター 🏆 |

#### Firestore スキーマ

```json
// parent_engagement/{parentId}
{
  "badges": [
    "streak_7days",
    "safety_expert",
    "engaged_10"
  ],
  "badgesUpdatedAt": Timestamp
}
```

#### 使用例

```dart
final badges = await service.detectMilestones(parentId, userProgress);
final definitions = service.getBadgeDefinitions();

for (final badgeId in badges) {
  final def = definitions[badgeId];
  print('🎉 バッジ獲得: ${def?['name']}');
  print('   ${def?['description']}');
}
```

---

## Cloud Functions 統合

### (1) セットアップ

#### 必須パッケージ

```bash
cd firebase/functions
npm install firebase-functions firebase-admin
```

#### 構成ファイル

`firebase/functions/package.json`:
```json
{
  "name": "engagement-functions",
  "version": "1.0.0",
  "dependencies": {
    "firebase-functions": "^4.5.0",
    "firebase-admin": "^12.0.0"
  },
  "engines": {
    "node": "18"
  }
}
```

### (2) Functions 一覧と実行スケジュール

#### Scheduled Functions（自動実行）

| Function | トリガー | 説明 |
|----------|---------|------|
| `generateWeeklyChallenges` | 毎週月曜日 0:00 | チャレンジ自動生成 |
| `aggregateSafetyScores` | 毎日 1:00 | セーフティスコア集計 |
| `detectAndAwardMilestones` | 毎日 2:00 | バッジ検出・授与 |

#### Callable Functions（オンデマンド）

| Function | 説明 |
|----------|------|
| `updateChallengeProgress` | チャレンジ進捗更新 |
| `logParentActivity` | アクティビティログ記録 |

### (3) デプロイ手順

```bash
# 1. Firebase プロジェクトでローカルテスト
firebase emulators:start --only functions

# 2. functions をデプロイ
firebase deploy --only functions

# 3. 特定の function をデプロイ
firebase deploy --only functions:generateWeeklyChallenges

# 4. Cloud Scheduler ジョブを確認
gcloud scheduler jobs list --location asia-northeast1
```

### (4) Cloud Scheduler セットアップ（必須）

Firebase Functions 内の Pub/Sub トリガーは、**Cloud Scheduler で明示的にジョブ作成が必要**です。

```bash
# 毎週月曜日 0:00 にチャレンジ生成
gcloud scheduler jobs create pubsub generate-weekly-challenges \
  --schedule "0 0 ? * MON" \
  --timezone "Asia/Tokyo" \
  --topic="generate-weekly-challenges" \
  --message-body="{}"

# 毎日 1:00 にセーフティスコア集計
gcloud scheduler jobs create pubsub aggregate-safety-scores \
  --schedule "0 1 * * *" \
  --timezone "Asia/Tokyo" \
  --topic="aggregate-safety-scores" \
  --message-body="{}"

# 毎日 2:00 にマイルストーン検出
gcloud scheduler jobs create pubsub detect-and-award-milestones \
  --schedule "0 2 * * *" \
  --timezone "Asia/Tokyo" \
  --topic="detect-and-award-milestones" \
  --message-body="{}"
```

---

## Dart 統合

### (1) Riverpod Providers

```dart
// サービスプロバイダー
final engagementServiceProvider = Provider<EngagementService>((ref) {
  return EngagementService(FirebaseFirestore.instance);
});

// ストリーク情報プロバイダー
final streakDataProvider = FutureProvider.family<
    Map<String, dynamic>?,
    String,
>((ref, parentId) async {
  final service = ref.watch(engagementServiceProvider);
  return service.getStreakData(parentId);
});

// セーフティスコアプロバイダー
final safetyScoreProvider = FutureProvider.family<
    double,
    String,
>((ref, parentId) async {
  final service = ref.watch(engagementServiceProvider);
  return service.calculateSafetyScore(parentId);
});

// マイルストーンプロバイダー
final milestonesProvider = FutureProvider.family.autoDispose<
    List<String>,
    (String parentId, UserProgress userProgress),
>((ref, args) async {
  final service = ref.watch(engagementServiceProvider);
  return service.detectMilestones(args.$1, args.$2);
});
```

### (2) ウィジェット統合

```dart
// ストリーク表示
class StreakWidget extends ConsumerWidget {
  final String parentId;
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final streakFuture = ref.watch(streakDataProvider(parentId));
    
    return streakFuture.when(
      loading: () => const CircularProgressIndicator(),
      error: (error, _) => Text('エラー: $error'),
      data: (streakData) {
        final streak = streakData?['currentStreak'] ?? 0;
        return Text('🔥 $streak日連続');
      },
    );
  }
}

// セーフティスコア表示
class SafetyScoreWidget extends ConsumerWidget {
  final String parentId;
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scoreFuture = ref.watch(safetyScoreProvider(parentId));
    final service = ref.watch(engagementServiceProvider);
    
    return scoreFuture.when(
      loading: () => const CircularProgressIndicator(),
      error: (error, _) => Text('エラー: $error'),
      data: (safetyScore) {
        final advice = service.getSafetyAdvice(safetyScore);
        return Column(
          children: [
            Text('セーフティスコア: ${safetyScore.toStringAsFixed(1)}'),
            Text(advice),
          ],
        );
      },
    );
  }
}

// バッジ表示
class BadgesWidget extends ConsumerWidget {
  final String parentId;
  final UserProgress userProgress;
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final badgesFuture = ref.watch(
      milestonesProvider((parentId, userProgress))
    );
    final service = ref.watch(engagementServiceProvider);
    
    return badgesFuture.when(
      loading: () => const CircularProgressIndicator(),
      error: (error, _) => Text('エラー: $error'),
      data: (badges) {
        final defs = service.getBadgeDefinitions();
        return GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
          ),
          itemCount: badges.length,
          itemBuilder: (context, index) {
            final badge = defs[badges[index]];
            return Column(
              children: [
                Text(badge?['emoji'] ?? '', style: const TextStyle(fontSize: 32)),
                Text(badge?['name'] ?? ''),
              ],
            );
          },
        );
      },
    );
  }
}
```

### (3) アクティビティログ記録

```dart
// 子どもがクイズを完了したとき
Future<void> onQuizCompleted(
  WidgetRef ref,
  String parentId,
  int score,
) async {
  final service = ref.read(engagementServiceProvider);
  
  // チェックイン記録
  await service.recordDailyCheckin(parentId, DateTime.now());
  
  // アクティビティログ記録
  await service.logActivity(
    parentId,
    'quiz_completed',
    {
      'score': score,
      'timestamp': DateTime.now().toIso8601String(),
    },
    'low',
  );
}

// 疑わしい行動を検出したとき
Future<void> onSuspiciousActivity(
  WidgetRef ref,
  String parentId,
  String activityType,
) async {
  final service = ref.read(engagementServiceProvider);
  
  await service.logActivity(
    parentId,
    'suspicious',
    {
      'type': activityType,
      'timestamp': DateTime.now().toIso8601String(),
    },
    'high',
  );
}
```

---

## Firestore セキュリティルール

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // ─── Parent Engagement ────────────────────────────────
    match /parent_engagement/{parentId} {
      // 自分のデータのみアクセス可
      allow read, write: if request.auth.uid == parentId;
    }
    
    // ─── Weekly Challenges ────────────────────────────────
    match /parent_engagement/{parentId}/weekly_challenges/{challengeId} {
      allow read, write: if request.auth.uid == parentId;
    }
    
    // ─── Activity Logs ────────────────────────────────────
    match /parent_engagement/{parentId}/activity_logs/{logId} {
      // ログ追加は自分のみ、読み取りは Cloud Functions
      allow create: if request.auth.uid == parentId;
      allow read: if request.auth.uid == parentId 
                   || request.auth.uid in get(/databases/$(database)/documents/parent_engagement/$(parentId)).data.adminIds;
    }
  }
}
```

---

## 使用例

完全な実装例は `engagement_service_example.dart` を参照してください。

### 例1: 親向けダッシュボード

```dart
class ParentEngagementDashboard extends ConsumerWidget {
  final String parentId;
  final UserProgress userProgress;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(
      children: [
        StreakWidget(parentId: parentId),
        SafetyScoreWidget(parentId: parentId),
        BadgesWidget(
          parentId: parentId,
          userProgress: userProgress,
        ),
      ],
    );
  }
}
```

### 例2: チャレンジ進捗更新

```dart
Future<void> completeChallengeQuiz(
  WidgetRef ref,
  String parentId,
  String weekNumber,
) async {
  final service = ref.read(engagementServiceProvider);
  
  // 現在の進捗を取得
  // クイズ完了処理
  
  // 進捗を更新（例: 5問中3問完了）
  await service.updateChallengeProgress(
    parentId,
    weekNumber,
    3,
  );
}
```

---

## トラブルシューティング

### Q: セーフティスコアが更新されない
**A:** Cloud Scheduler ジョブが実行されているか確認してください。

```bash
gcloud scheduler jobs describe aggregate-safety-scores --location asia-northeast1
gcloud scheduler jobs run aggregate-safety-scores --location asia-northeast1
```

### Q: バッジが授与されない
**A:** `detectAndAwardMilestones` が毎日 2:00 に実行されるか確認し、条件をチェックしてください。

### Q: Riverpod プロバイダーがエラーを返す
**A:** Firestore インスタンスが正しく初期化されているか確認してください。

```dart
import 'package:cloud_firestore/cloud_firestore.dart';

// main.dart で Firebase を初期化
await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);
```

---

## パフォーマンス最適化

### Firestore 読み取り最適化

- ページネーション: 大量のチャレンジを一度に読まない
- インデックス: `parent_engagement/{parentId}/weekly_challenges` に複合インデックス作成

### プロバイダーキャッシング

```dart
// 60秒キャッシュ
final streakDataProvider = FutureProvider.family<
    Map<String, dynamic>?,
    String,
>((ref, parentId) async {
  final cacheTime = ref.watch(streakCacheTime);
  
  return Future.delayed(
    const Duration(seconds: 60),
    () async {
      final service = ref.watch(engagementServiceProvider);
      return service.getStreakData(parentId);
    },
  );
});
```

---

## まとめ

このシステムにより、親のエンゲージメントを段階的に向上させることができます：

1. **Daily Checkin** で習慣形成
2. **Weekly Challenges** で学習機会提供
3. **Safety Score** で進捗可視化
4. **Badges** で達成感演出

すべての機能が Firestore + Cloud Functions で自動化され、リアルタイム更新が可能です。

---

**最終更新**: 2026-06-15
