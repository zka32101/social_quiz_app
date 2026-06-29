# Engagement Service - セットアップガイド

このガイドでは、engagement_service.dart をプロジェクトに統合するための手順を説明します。

## 前提条件

- Flutter 3.0+
- Dart 3.0+
- Firebase プロジェクト（Cloud Firestore 有効）
- Cloud Scheduler API 有効

## Step 1: 依存パッケージのインストール

### pubspec.yaml に追加

```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # Firebase
  firebase_core: ^2.24.0
  cloud_firestore: ^4.14.0
  firebase_functions: ^5.0.0
  
  # 状態管理
  flutter_riverpod: ^2.6.0
  
  # JSON シリアライゼーション
  json_serializable: ^6.7.1
  
  # 既存依存関係
  intl: ^0.19.0
  
dev_dependencies:
  # テスト
  mockito: ^4.4.4
  build_runner: ^2.4.0
```

### インストール実行

```bash
flutter pub get
```

### build_runner で JSON 生成（UserProgress が freezed を使用する場合）

```bash
dart run build_runner build
```

## Step 2: ファイルの配置

### ディレクトリ構造

```
social_quiz_app/
├── lib/
│   ├── services/
│   │   ├── engagement_service.dart          # ← 作成済み
│   │   └── engagement_service_example.dart  # ← 作成済み
│   └── models/
│       └── user_progress.dart               # 既存
├── firebase/
│   └── functions/
│       ├── engagement_functions.js          # ← 作成済み
│       ├── package.json
│       └── index.js                         # メインファイル
├── test/
│   └── services/
│       └── engagement_service_test.dart     # ← 作成済み
└── ENGAGEMENT_SERVICE_README.md             # ← 作成済み
```

## Step 3: Cloud Functions の設定

### firebase/functions/index.js

```javascript
const admin = require('firebase-admin');

// 必須: Firebase Admin SDK を初期化
admin.initializeApp();

// engagement_functions.js のエクスポート
module.exports = require('./engagement_functions');
```

### firebase/functions/package.json

```json
{
  "name": "engagement-functions",
  "version": "1.0.0",
  "description": "Engagement Service Cloud Functions",
  "engines": {
    "node": "18"
  },
  "main": "index.js",
  "scripts": {
    "deploy": "firebase deploy --only functions",
    "test": "jest",
    "logs": "firebase functions:log"
  },
  "dependencies": {
    "firebase-admin": "^12.0.0",
    "firebase-functions": "^4.5.0"
  },
  "devDependencies": {
    "@types/node": "^20.0.0",
    "jest": "^29.0.0"
  }
}
```

## Step 4: Firebase 初期化（Dart側）

### lib/main.dart

```dart
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Firebase 初期化
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  runApp(const MyApp());
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Social Quiz',
      theme: ThemeData.light(
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
```

## Step 5: Cloud Functions デプロイ

### 1. Firebase CLI のインストール

```bash
npm install -g firebase-tools
firebase login
```

### 2. 関数をデプロイ

```bash
# firebase/functions ディレクトリへ移動
cd firebase/functions

# パッケージインストール
npm install

# デプロイ
firebase deploy --only functions
```

### 3. デプロイ確認

```bash
firebase functions:list
```

出力例:
```
Function         Status  Trigger
────────────────────────────────────────
generateWeeklyChallenges       OK  Pub/Sub
aggregateSafetyScores         OK  Pub/Sub
detectAndAwardMilestones      OK  Pub/Sub
updateChallengeProgress       OK  HTTPS
logParentActivity             OK  HTTPS
```

## Step 6: Cloud Scheduler ジョブ作成

### GCP CLI のセットアップ

```bash
gcloud init
gcloud auth application-default login
gcloud config set project YOUR_PROJECT_ID
```

### Scheduler ジョブ作成

```bash
# 毎週月曜日 0:00 にチャレンジ生成
gcloud scheduler jobs create pubsub generate-weekly-challenges \
  --schedule "0 0 ? * MON" \
  --timezone "Asia/Tokyo" \
  --topic="generate-weekly-challenges" \
  --message-body="{}" \
  --location asia-northeast1

# 毎日 1:00 にセーフティスコア集計
gcloud scheduler jobs create pubsub aggregate-safety-scores \
  --schedule "0 1 * * *" \
  --timezone "Asia/Tokyo" \
  --topic="aggregate-safety-scores" \
  --message-body="{}" \
  --location asia-northeast1

# 毎日 2:00 にマイルストーン検出
gcloud scheduler jobs create pubsub detect-and-award-milestones \
  --schedule "0 2 * * *" \
  --timezone "Asia/Tokyo" \
  --topic="detect-and-award-milestones" \
  --message-body="{}" \
  --location asia-northeast1
```

### ジョブ確認

```bash
gcloud scheduler jobs list --location asia-northeast1
```

## Step 7: Firestore セキュリティルール更新

### Firebase Console で設定

1. **Firebase Console** → **Firestore Database** → **ルール**
2. 以下を追加:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Parent Engagement
    match /parent_engagement/{parentId} {
      allow read, write: if request.auth.uid == parentId;
      
      // Weekly Challenges
      match /weekly_challenges/{challengeId} {
        allow read, write: if request.auth.uid == parentId;
      }
      
      // Activity Logs
      match /activity_logs/{logId} {
        allow create: if request.auth.uid == parentId;
        allow read: if request.auth.uid == parentId;
      }
    }
  }
}
```

## Step 8: テスト実行

### ユニットテスト

```bash
# テスト実行
flutter test test/services/engagement_service_test.dart

# カバレッジ確認
flutter test --coverage test/services/engagement_service_test.dart
```

### ローカル エミュレータテスト（オプション）

```bash
# Firestore エミュレータ開始
firebase emulators:start

# 別のターミナルでテスト
FIRESTORE_EMULATOR_HOST=localhost:8080 flutter test
```

## Step 9: Dart コード統合

### 使用例

```dart
// lib/screens/parent_engagement_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/engagement_service.dart';
import '../services/engagement_service_example.dart';

class ParentEngagementScreen extends ConsumerWidget {
  final String parentId;
  final UserProgress userProgress;

  const ParentEngagementScreen({
    required this.parentId,
    required this.userProgress,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('親向けエンゲージメント'),
      ),
      body: ParentEngagementDashboard(
        parentId: parentId,
        userProgress: userProgress,
      ),
    );
  }
}
```

## Step 10: 動作確認チェックリスト

- [ ] `flutter pub get` が成功
- [ ] `dart analyze` でエラーなし
- [ ] `flutter test` でユニットテスト合格
- [ ] Cloud Functions デプロイ成功
- [ ] Cloud Scheduler ジョブが 3つ作成されている
- [ ] Firestore ルールが更新されている
- [ ] `ParentEngagementDashboard` ウィジェットが表示される
- [ ] チェックインボタンをタップするとストリーク更新される
- [ ] セーフティスコアが計算される

## トラブルシューティング

### Issue: `cloud_firestore` パッケージエラー

**解決**:
```bash
flutter pub upgrade cloud_firestore firebase_core
```

### Issue: Cloud Functions デプロイ失敗

**確認**:
```bash
firebase projects:list
firebase deploy --only functions --debug
```

### Issue: Scheduler ジョブが実行されない

**確認**:
```bash
gcloud scheduler jobs run generate-weekly-challenges --location asia-northeast1
gcloud functions:log generate-weekly-challenges --limit 50
```

### Issue: Firestore ルールエラー

**確認**:
- Firebase Console で認証が有効か
- ドキュメントパスが正しいか
- `request.auth.uid` が `parentId` と一致しているか

## パフォーマンス最適化

### Firestore インデックス作成

複合クエリの場合、Firebase が自動的にインデックスを提案します。

```bash
# インデックス確認
gcloud firestore indexes list

# インデックス作成（Firebase Console から可能）
```

### Riverpod キャッシング

```dart
// 例: 1分間キャッシュ
final streakDataProvider = FutureProvider.family<
    Map<String, dynamic>?,
    String,
>((ref, parentId) async {
  final service = ref.watch(engagementServiceProvider);
  
  // キャッシュ時間: 60秒
  ref.cacheFor(const Duration(minutes: 1));
  
  return service.getStreakData(parentId);
});
```

## セキュリティ注意事項

1. **API キー** - Firebase Console から制限を設定
2. **認証** - Cloud Functions は Google Cloud 認証を使用
3. **Firestore ルール** - `request.auth.uid` で個人データを保護
4. **Cloud Scheduler** - サービスアカウントに必要な権限を付与

## リソース削除（テスト後）

```bash
# Scheduler ジョブ削除
gcloud scheduler jobs delete generate-weekly-challenges \
  --location asia-northeast1

# Functions 削除
firebase functions:delete generateWeeklyChallenges
```

## 次のステップ

1. **UI カスタマイズ** - `engagement_service_example.dart` のウィジェットをカスタマイズ
2. **データ可視化** - グラフライブラリ（fl_chart など）でスコア表示
3. **通知機能** - Cloud Messaging でバッジ授与時に通知
4. **分析** - Google Analytics でエンゲージメント追跡

---

**最終更新**: 2026-06-15
