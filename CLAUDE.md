# Social Quiz App（社会） - 開発ガイド

## プロジェクト概要

社会科クイズを通じて、小学生が日本の地理・歴史・政治・経済を楽しく学べるアプリです。友人とのスコア競争機能を備えており、ゲーム感覚での学習を実現します。

- **アーキテクチャ**: フラット構成（models, providers, screens, widgets）
- **状態管理**: Riverpod 2.6.x StateNotifier
- **永続化**: SharedPreferences 2.x+

## 主要機能

- クイズ出題・採点
- ユーザースコア管理（SharedPreferences）
- マルチプレイ（將来実装）

## 重要ファイル

| ファイル | 説明 |
|---------|------|
| `lib/main.dart` | アプリエントリーポイント |
| `lib/models/quiz.dart` | Quiz モデル（Freezed 使用） |
| `lib/providers/quiz_provider.dart` | クイズ状態管理 Provider |
| `lib/screens/quiz_screen.dart` | クイズ表示 UI |
| `lib/services/score_service.dart` | スコア保存・読込 |

## 技術スタック

- Flutter 3.11.5+
- Riverpod 2.6.x
- SharedPreferences 2.2.0+
- Material Design 3

## Riverpod パターン

### StateNotifierProvider（スコア管理）
```dart
final scoreProvider = StateNotifierProvider<ScoreNotifier, int>((ref) {
  return ScoreNotifier();
});

class ScoreNotifier extends StateNotifier<int> {
  ScoreNotifier() : super(0);
  
  void addScore(int points) {
    state += points;
  }
}
```

### FutureProvider（非同期データ読込）
```dart
final savedScoreProvider = FutureProvider<int>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getInt('quiz_score') ?? 0;
});
```

## SharedPreferences キー名

```dart
// 形式: 'app_[feature]_[name]'
'app_quiz_player_name'      // プレイヤー名
'app_quiz_best_score'       // 最高スコア
'app_quiz_total_played'     // 総プレイ数
'app_quiz_history'          // プレイ履歴（JSON）
```

## 開発フロー

### 新規機能追加
1. Model を `lib/models/` に追加
2. Provider を `lib/providers/` に追加
3. Screen/Widget を `lib/screens/` に追加
4. テストを `test/` に追加

### UI コンポーネント
- Theme: Material Design 3（`ThemeData.useMaterial3`）
- ボタン: `ElevatedButton`, `TextButton`
- フォーム: `TextField` + バリデーション

## よくあるエラー

| エラー | 原因 | 解決方法 |
|--------|------|--------|
| `State is not being watched` | Provider 参照なし | `ref.watch(provider)` 使用 |
| `JSON 解析エラー` | 形式不正 | `jsonDecode()` で検証 |
| `SharedPreferences キー重複` | キー名が同じ | ネーミング規則を確認 |

## Claude Code コマンド

```bash
# Lint チェック
rtk flutter analyze

# テスト実行
rtk flutter test

# ビルド確認
rtk flutter pub get

# 形式チェック・修正
dart format lib/

# APK ビルド
cd apps/social_quiz_app
python ../../.claude/skills/flutter-release-complete/scripts/orchestrator.py . android 10
```

## ビルド注意事項（低メモリマシン対応）

このマシンは RAM 3GB のため、APK ビルド前に必ずメモリを解放すること。

```powershell
# ① ビルド前にメモリ解放（Java プロセス等を終了）
Get-Process -Name "java","msedge","chrome" -ErrorAction SilentlyContinue | Stop-Process -Force

# ② Dart VM ヒープを制限してビルド
$env:DART_VM_OPTIONS="--old_gen_heap_size=200 --new_gen_semi_max_size=32"
flutter build apk --release --split-per-abi
```

**gradle.properties 設定値（固定 — 変更禁止）**:
- `-Xmx1G` — 8G/4G に戻すと JVM がクラッシュする
- `org.gradle.daemon=false` — daemon を有効にするとメモリ不足になる

## チェックリスト（新規機能）

- [ ] Model を定義、テスト作成
- [ ] Provider で状態管理を実装
- [ ] Screen/Widget で UI 実装
- [ ] SharedPreferences 連携確認
- [ ] UI テスト実装
- [ ] エラーハンドリング追加
- [ ] flutter analyze でエラーなし

---

**最終更新**: 2026-05-26
