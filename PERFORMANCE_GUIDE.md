# パフォーマンス最適化ガイド

## 概要
このガイドは、Social Quiz App のパフォーマンス最適化と効率的な実装に関する推奨事項を記載しています。

## パフォーマンスユーティリティ

### 1. CacheManager - キャッシュ管理
```dart
// キャッシュの有効期限チェック
if (CacheManager.isCacheExpired(lastUpdateTime)) {
  // キャッシュを更新
}

// 古いセッション履歴をクリア（30日以上前）
sessions = CacheManager.pruneOldSessions(sessions);
```

**推奨設定:**
- キャッシュ有効期限: 24時間
- 最大通知数: 100件
- 最大セッション履歴: 1000件

### 2. QueryOptimizer - クエリ最適化
```dart
// ページング処理（大量データの表示）
final page1 = QueryOptimizer.paginate(items, 0, 20);  // 最初の20件
final page2 = QueryOptimizer.paginate(items, 1, 20);  // 次の20件

// 効率的なフィルタリング
final completed = QueryOptimizer.efficientWhere(
  stages,
  (s) => s.isCompleted,
);
```

**使用例:**
- 都道府県リスト: ページサイズ = 10-15件
- ステージリスト: ページサイズ = 5件
- バッジリスト: ページサイズ = 20件

### 3. MemoryOptimizer - メモリ最適化
```dart
// 大量データをチャンク処理
for (final chunk in MemoryOptimizer.chunk(largeList, 100)) {
  // 各チャンク（100件）を処理
}

// サイズ制限以上のリストをクリア
MemoryOptimizer.clearIfNeeded(sessions, maxSize: 1000);
```

### 4. RateLimiter - レート制限
```dart
final rateLimiter = RateLimiter(delayMilliseconds: 1000);

if (rateLimiter.canProceed('api_call')) {
  // API呼び出しを実行
}
```

**API呼び出しの最小間隔:**
- Firestore クエリ: 500ms
- バッジ同期: 1000ms
- 進捗保存: 2000ms

### 5. StreamOptimizer - ストリーム最適化
```dart
// 連続した同じ値をフィルタリング
stream.pipe(StreamOptimizer.distinctUntilChanged());

// 出力をスロットル（2秒ごとに1回のみ）
stream.pipe(StreamOptimizer.throttle(Duration(seconds: 2)));
```

## 実装のベストプラクティス

### Riverpod Provider 最適化
```dart
// 悪い例: 毎回全計算
final stageCountProvider = StateProvider<int>((ref) {
  return ref.watch(userProgressProvider).stageProgress.length;
});

// 良い例: セレクターを使用
final stageCountProvider = StateProvider<int>((ref) {
  return ref.watch(
    userProgressProvider.select((p) => p.stageProgress.length),
  );
});
```

### ウィジェットの再構築最適化
```dart
// Const コンストラクタの使用
class StaticWidget extends StatelessWidget {
  const StaticWidget(); // const にすることで再構築回避
  
  @override
  Widget build(BuildContext context) => Container();
}

// RepaintBoundary で不要な再描画を防ぐ
RepaintBoundary(
  child: ExpensiveWidget(),
)
```

## テスト戦略

### ユニットテスト対象
- ✅ LearningSessionService
- ✅ MilestoneNotificationService
- ✅ AvatarPurchaseService
- ✅ ProgressRepository
- ✅ CacheManager

### テスト実行
```bash
# 全テスト実行
flutter test

# 特定のテストファイル実行
flutter test test/services/learning_session_service_test.dart

# カバレッジレポート生成
flutter test --coverage
```

## パフォーマンスベンチマーク

### 目標メトリクス
| メトリック | 目標値 | 現在値 |
|-----------|-------|-------|
| アプリ起動時間 | < 2秒 | - |
| ステージロード | < 500ms | - |
| クイズ表示 | < 300ms | - |
| UIフレームレート | 60fps | - |
| メモリ使用量 | < 150MB | - |

## キャッシング戦略

### 3段階キャッシング
1. **Hive (ローカル)**: 最速、永続的
2. **メモリ**: 高速、セッション限定
3. **Firestore**: リモート、信頼性重視

### キャッシュヒット率の目標
- **ステージデータ**: 95%+
- **都道府県データ**: 98%+
- **ユーザー進捗**: 100%（ローカル優先）

## モニタリング

### ログポイント
```dart
// パフォーマンス測定
final stopwatch = Stopwatch()..start();
// ... 処理 ...
debugPrint('処理時間: ${stopwatch.elapsedMilliseconds}ms');
```

### 問題検出
- フレームレート低下（< 60fps）
- メモリリーク
- Firestore レート制限エラー
- キャッシュミス率上昇

## 今後の最適化

### Phase 5 (計画中)
- [ ] ローカルDB最適化 (Hive インデックス)
- [ ] 画像遅延ロード
- [ ] オフラインモード強化
- [ ] Firestore クエリ最適化

### Phase 6 (計画中)
- [ ] CDN 統合
- [ ] APK 圧縮最適化
- [ ] 多言語対応パフォーマンス
- [ ] A/B テスト基盤

---

**最終更新**: 2026-09-01
**バージョン**: 1.0.0
