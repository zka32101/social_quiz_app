# Stage 16-20 拡充済み説明文 統合ガイド

## クイックスタート

### 1. ファイルの確認
以下3つのファイルが揃っていることを確認してください：

```
lib/data/
├── quiz_expanded_s16_s20.dart           ← 拡充済みデータ（新規）
├── quiz_mock_data.dart                 ← 既存データ（統合対象）

その他：
├── EXPLANATION_ENHANCEMENT_SUMMARY.md    ← 改善内容の詳細レポート
├── BEFORE_AFTER_EXAMPLES.txt            ← 改善前後の具体例比較
└── INTEGRATION_GUIDE.md                 ← このファイル
```

### 2. 統合方法の選択

#### 【方法A】完全置き換え（推奨・全置き換え）
既存の Stage 16-20 データを丸ごと新しいものに置き換える方法

```bash
# Step 1: バックアップ作成
cp lib/data/quiz_mock_data.dart lib/data/quiz_mock_data.dart.backup

# Step 2: quiz_expanded_s16_s20.dart から該当部分をコピー
# vim/nano などで以下の部分をコピー：
#  - 's16q1' ～ 's20q15' の全データ
```

#### 【方法B】段階的統合（推奨・慎重派向け）
1ステージずつ検証しながら統合する方法

```bash
# Step 1: Stage 16 のみ先に統合してテスト
# Step 2: 問題なければ Stage 17 を統合
# ... (以下同様)
# Step 5: Stage 20 を統合
```

---

## 詳細な統合手順

### 【方法A】で統合する場合

#### 1. quiz_mock_data.dart を開く
```dart
// H:\マイドライブ\apps\social_quiz_app\lib\data\quiz_mock_data.dart
// 約1918行目から 2548行目までが Stage 16-20 のデータ
```

#### 2. 既存の Stage 16-20 データをバックアップ
```dart
// バックアップ用に別ファイルに保存しておく
// quiz_mock_data.dart.stage_16_20_backup.dart
```

#### 3. 拡充済みデータをコピー
```dart
// quiz_expanded_s16_s20.dart の以下をコピー：
const Map<String, Map<String, dynamic>> quizExpandedS16S20 = {
  's16q1': { 'explanation': '...' },
  ...
  's20q15': { 'explanation': '...' },
};
```

#### 4. quiz_mock_data.dart に統合
```dart
// quiz_mock_data.dart の該当部分を置き換え：
's16q1': {
  'questId': 'quest_16_1',
  'quizType': 'multiple_choice',
  'question': '地図に田んぼ（水田）を表す地図記号はどれかな？',
  'explanation': '水田（田んぼ）の地図記号は「田」という漢字に似た、縦横に線が入った...',  // ← 拡充版に変更
  'options': ['縦横に線が入った正方形', '点々が散らばった記号', '木が並んだ記号', '波線の記号'],
  'correctIndex': 0,
},
```

#### 5. 構文チェック
```bash
cd H:\マイドライブ\apps\social_quiz_app
flutter analyze
```

**期待される結果**: エラーなし

#### 6. テスト実行
```bash
# ホットリロード確認
flutter run

# または
flutter run -d <device_id>
```

**テストポイント**:
- [ ] Stage 16-20 の問題が表示される
- [ ] 説明文が正しく表示される
- [ ] 日本語の表示が崩れていない
- [ ] 絵文字が正しく表示される

#### 7. テスト環境での検証
```bash
# 実機テスト（推奨）
flutter run -d <real_device>

# エミュレータテスト
flutter run -d emulator-5554
```

**チェック項目**:
- [ ] APK/IPA で正常に動作
- [ ] 問題表示に遅延なし
- [ ] クリップボード操作が正常
- [ ] タップ入力が反応する

#### 8. APK ビルド
```bash
# メモリ制限のある環境用：
$env:DART_VM_OPTIONS="--old_gen_heap_size=200 --new_gen_semi_max_size=32"

# リリースビルド
flutter build apk --release --split-per-abi

# または APK ビルドスキルを使用
/build-flutter-apk
```

**ビルド後の確認**:
- [ ] APK ファイルが生成された
- [ ] ファイルサイズが異常でない（70-100 MB 程度）
- [ ] 署名が正常に行われた

---

### 【方法B】で段階的統合する場合

#### Stage 16 のみ統合（例）
```dart
// quiz_mock_data.dart 内の 's16q1' ～ 's16q15' を拡充版に置き換え

's16q1': {
  'questId': 'quest_16_1',
  'quizType': 'multiple_choice',
  'question': '地図に田んぼ（水田）を表す地図記号はどれかな？',
  'explanation': '【拡充版 s16q1 の explanation をここに挿入】',
  ...
},
// ... (s16q2 ～ s16q15 も同様に置き換え)
```

#### 各ステージの検証ポイント

**Stage 16（地図記号）テスト項目**:
- [ ] 記号の由来が正しく説明されているか
- [ ] 覚え方のコツが実用的か
- [ ] 日本全国の統計情報（例：「全国約19,000の郵便局」）が正確か

**Stage 17（都道府県）テスト項目**:
- [ ] 人口統計が2024年基準か
- [ ] 県庁所在地と最大都市の関係が正しいか
- [ ] 特産品の説明が文化的背景まで含んでいるか

**Stage 18（年中行事）テスト項目**:
- [ ] 行事の由来が平安時代など歴史的背景を含んでいるか
- [ ] 各習慣の意味が括弧で明示されているか
- [ ] 来場者数などの統計情報が盛り込まれているか

**Stage 19（歴史）テスト項目**:
- [ ] 年号が正確か
- [ ] 人物名と業績が正しく関連付けられているか
- [ ] 時代の流れが因果関係として説明されているか
- [ ] 動員人数や被害者数などの具体的数値が盛り込まれているか

**Stage 20（公民）テスト項目**:
- [ ] 制度が「なぜ必要か」を説明しているか
- [ ] 国民生活への直接的な関連性が示されているか
- [ ] 統計情報（年号、人数など）が正確か
- [ ] 課題や将来展望が付記されているか

---

## トラブルシューティング

### 問題 1: Dart構文エラー
```
Error: Missing closing brace on line XXX
```

**原因**: クォート・括弧の不一致

**解決策**:
```dart
// エラー行を確認
flutter analyze --verbose

// 该当行を修正（括弧・クォート・カンマの確認）
's16q1': {
  'explanation': '...説明文...',  // ← カンマを確認
},  // ← 閉じ括弧を確認
```

### 問題 2: 日本語が文字化けする
```
例：「水田」が「æ°¶ç"°」と表示される
```

**原因**: ファイルエンコーディングが UTF-8 でない

**解決策**:
```bash
# ファイルが UTF-8 で保存されているか確認
file -i lib/data/quiz_mock_data.dart

# VS Code の場合：
# 1. 下部のステータスバーの「UTF-8」をクリック
# 2. 「エンコーディングで保存」を選択
# 3. 「UTF-8」を選択
```

### 問題 3: アプリが起動しない
```
Exception: Failed to load quiz data
```

**原因**: JSON/Dart マップの構文エラー

**解決策**:
```bash
# Step 1: 構文チェック
flutter analyze

# Step 2: ホットリスタート
flutter run --hot

# Step 3: キャッシュをクリアして再度実行
flutter clean
flutter pub get
flutter run
```

### 問題 4: 説明文が表示されない
```
画面に説明文が何も表示されない
```

**原因**: キー名（例：'explanation'）の不一致

**解決策**:
```dart
// 正しい形式を確認
's16q1': {
  'questId': 'quest_16_1',
  'explanation': '...',  // ← キー名が 'explanation' であることを確認
  ...
},
```

### 問題 5: APK ビルドがメモリ不足で失敗
```
OutOfMemoryError: Java heap space
```

**原因**: Gradle メモリ設定が不足

**解決策**:
```powershell
# メモリを制限して実行
$env:DART_VM_OPTIONS="--old_gen_heap_size=200 --new_gen_semi_max_size=32"
flutter build apk --release --split-per-abi

# gradle.properties で確認（変更禁止）
# -Xmx1G は保持（8G などに戻さない）
```

---

## デプロイ（Google Play / App Store）

### Google Play へのデプロイ

#### 1. APK / AAB の生成確認
```bash
# リリース AAB（Android App Bundle）を生成
flutter build appbundle --release

# または
flutter build apk --release
```

**出力ファイル**:
- `build/app/outputs/bundle/release/app-release.aab`
- `build/app/outputs/apk/release/app-release.apk`

#### 2. Google Play Console にアップロード
```
https://play.google.com/console
→ [社会コレ] → [リリース] → [新しいリリースを作成]
→ AAB ファイルをアップロード
→ リリース ノート（必須）
→ テスター情報を入力（オプション）
```

#### 3. リリース ノート例
```
【バージョン XX】
- Stage 16-20 の説明文を大幅拡充
- 小学生向けの学習効果を向上
- 地図記号・都道府県・年中行事・歴史・公民の
  より詳しい解説を提供
- 文化的背景・統計情報・実生活との関連性を強化
```

#### 4. リリース スケジュール
```
上映開始: 【日付】
段階的提供: 有効
提供率: 100% （または 10% → 50% → 100% と段階的）
```

### App Store へのデプロイ（iOS）

#### 1. IPA の生成
```bash
flutter build ios --release
```

#### 2. Xcode でアーカイブ
```bash
# （省略）Xcode の操作が必要
```

#### 3. App Store Connect にアップロード
```
https://appstoreconnect.apple.com
→ [社会コレ] → [バージョン情報] → [構築物] → IPA をアップロード
```

---

## リバート（ロールバック）手順

万が一、統合後に問題が発生した場合：

```bash
# Step 1: バックアップから復元
cp lib/data/quiz_mock_data.dart.backup lib/data/quiz_mock_data.dart

# Step 2: 再度テスト
flutter clean
flutter pub get
flutter analyze
flutter run

# Step 3: Google Play で 「リリースを停止」
# （すでに配布済みの場合は「新しいリリース」で前のバージョンに戻す）
```

---

## 検証チェックリスト

### 統合前チェック
- [ ] `quiz_expanded_s16_s20.dart` を確認
- [ ] `quiz_mock_data.dart` のバックアップを取得
- [ ] 全75問の data が揃っているか確認

### 統合後（ローカル）チェック
- [ ] `flutter analyze` でエラーなし
- [ ] `flutter run` で正常に起動
- [ ] Stage 16-20 の全問が表示される
- [ ] 説明文が正しく表示される
- [ ] 日本語が文字化けしていない
- [ ] 絵文字が正しく表示される
- [ ] 選択肢をタップできる

### 実機テストチェック
- [ ] 実機（Android）で正常に動作
- [ ] 実機（iOS）で正常に動作
- [ ] ラグ・遅延がない
- [ ] メモリリークの兆候がない

### APK / AAB ビルドチェック
- [ ] APK ファイルが生成される
- [ ] ファイルサイズが正常（70-100 MB）
- [ ] デバイスにインストール可能
- [ ] インストール後、アプリが起動する

### リリース前チェック
- [ ] リリース ノートを準備
- [ ] バージョン番号を更新
- [ ] スクリーンショットを最新化（必要に応じて）
- [ ] テスターに配布して検証

### リリース後チェック（1週間）
- [ ] ユーザーレビューをモニタリング
- [ ] クラッシュレポートを確認
- [ ] 平均評価が低下していないか確認

---

## よくある質問（FAQ）

### Q1: 拡充済みデータはどこから入手？
A: このディレクトリに以下のファイルがあります：
- `lib/data/quiz_expanded_s16_s20.dart` ← これです

### Q2: 既存データとの互換性は？
A: 完全互換です。既存の `quizType`, `options`, `correctIndex` などは変わらず、`explanation` フィールドのみ拡充されています。

### Q3: 他のステージ（1-15）も拡充する？
A: 予定しています。次フェーズで同様の拡充を行う予定です。

### Q4: 多言語対応は？
A: 現在は日本語のみです。英語などの多言語対応は別途プロジェクトとします。

### Q5: オフライン対応は？
A: APK/IPA に完全に包含されているため、ネットワーク接続不要です。

### Q6: データベース（Firestore）への移行は？
A: 現在は mock data（ローカル）のみです。将来的に Firestore への移行を検討しますが、UI は変わりません。

---

## サポート連絡先

問題が発生した場合：
- **メール**: yourwishdev@gmail.com
- **開発チーム**: Petit Works Apps 開発部

---

## 参考ドキュメント

| ファイル | 説明 |
|---------|------|
| `EXPLANATION_ENHANCEMENT_SUMMARY.md` | 改善内容の詳細レポート |
| `BEFORE_AFTER_EXAMPLES.txt` | 改善前後の具体例比較 |
| `CLAUDE.md` | プロジェクト概要・技術スタック |

---

**最終更新**: 2026-06-23  
**バージョン**: v1.0  
**対応アプリ**: social_quiz_app v1.0 以降
