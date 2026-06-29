# Social Quiz App（社会） - プロジェクトガイド

## 概要

**プロジェクト名**: 社会（Social Quiz App）
**パッケージ名**: `com.petitworksapps.shougakukore.shakai`
**対象**: 小学4～6年生、中学受験予定者
**プラットフォーム**: Android（Flutter）
**ステータス**: Google Play へのリリース準備完了

---

## コンセプト

### ミッション
社会科学習を「楽しいゲーム」に変える

### 学習アプローチ
- **暗記から理解へ**: 4択問題 + 詳細解説で深い理解を促進
- **継続性の確保**: ゲーム形式 + スコア競争で内発的動機づけ
- **教育効果**: 小学校学習指導要領に準拠、テスト対策対応

### ユーザーターゲット
1. **小学4～6年生**: 社会科基礎学習者
2. **中学受験予定者**: 受験対策学習者
3. **保護者層**: 家庭学習充実化を望む親

---

## 主要機能

### 1. クイズプレイ
```
4択一答問題 → リアルタイム採点 → 詳細解説表示
```
- 出題範囲: 地理・歴史・政治・経済・文化
- 難易度: 初級～上級（段階選択可能）
- 解説: 各問題に詳しい背景知識・ポイント付き

### 2. スコアシステム
- ローカルスコア記録・保存
- 最高記録トラッキング
- 総プレイ回数カウント
- 正答率統計（将来実装）

### 3. プレイヤー管理
- プレイヤー名の設定・変更
- SharedPreferences での保存
- マルチプレイヤー対応（将来）

### 4. スコアランキング（将来実装）
- ローカルランキング表示
- 友人とスコア共有（QRコード）
- オンラインランキング（Firebase連携）

### 5. 学習分析（将来実装）
- 問題別・カテゴリ別正答率
- 弱点分野の自動抽出
- 週間・月間学習レポート

---

## 学習カバー範囲

### 地理分野
- 47都道府県と地域特性
- 地形・気候・産業
- 日本周辺国家

### 歴史分野
- 縄文～昭和・平成
- 重要人物・事件
- 時代特徴

### 政治・経済
- 政治制度（国会・内閣・裁判所）
- 地方自治
- 経済基礎（生産・消費）
- 産業分類

### 文化
- 伝統文化（茶道・能など）
- 地方行事・祭り
- 食文化

---

## 技術構成

### フロントエンド
- **言語**: Dart
- **フレームワーク**: Flutter 3.11.5+
- **UI**: Material Design 3
- **状態管理**: Riverpod 2.6.x (StateNotifier)

### データ・バックエンド（現在）
- **ローカル永続化**: SharedPreferences 2.2.0+

### 将来対応
- Firebase Analytics
- Firebase Auth
- Cloud Firestore
- Google Mobile Ads
- RevenueCat（課金）

---

## データモデル（key）

### Player
```dart
id, name, createdAt, highScore, totalQuestions
```

### Quiz
```dart
id, question, options[], correctIndex, 
explanation, category, difficulty
```

### Score
```dart
playerId, score, correctAnswers, totalQuestions, 
playedAt, questionIds[]
```

---

## 画面構成

1. **スプラッシュ** → プレイヤー名入力
2. **ホーム** → クイズプレイ・スコア確認・設定
3. **クイズ** → 問題・選択肢・スコア表示
4. **結果** → 正解表示・解説・次へ
5. **スコア** → 履歴・最高記録・統計
6. **設定** → プレイヤー名・難易度・その他

---

## Google Play リリース情報

### 署名情報
- **キーストア**: `android/release.jks`
- **エイリアス**: `release`
- **パスフレーズ**: `SocialQuiz2024!`
- **有効期限**: 10,000日（～2045年）

### リリース設定
- **最小SDK**: Android 6.0 (API 21)
- **ターゲットSDK**: Android 14 (API 34)
- **パッケージ名**: `com.petitworksapps.shougakukore.shakai`

### App Bundle
- **ファイル**: `social_quiz_app-app-release.aab`
- **保存先**: `H:\マイドライブ\aab\`
- **サイズ**: 約62MB
- **署名**: リリースキー完全署名

---

## セキュリティ・プライバシー

### 児童保護
- 13歳未満: 親権者同意必須
- 個人識別情報非収集
- 匿名プレイヤー名推奨
- 位置情報未使用

### データ保護
- SSL/TLS通信暗号化
- SharedPreferences暗号化
- セキュリティ監査定期実施

### 外部サービス
- Firebase: Google プライバシーポリシー準拠
- 第三者への無断共有禁止
- 親権者による削除権付与

---

## Google Play 掲載文

### 簡潔説明（60文字）
```
社会科クイズで学ぶ！友人と競い合いながら日本の地理・歴史・政治を楽しく学べるアプリ。
```

### 詳細説明
- プレイヤー名登録 → クイズプレイ → スコア記録 → 友人と競争
- 地理・歴史・政治・経済・文化を網羅
- 解説付きで深い学習実現
- 小学4～6年、中学受験対応

---

## 開発手順（参考）

### ビルド
```bash
cd "H:\マイドライブ\apps\social_quiz_app"
flutter clean
flutter pub get
flutter build appbundle --release
```

### 出力確認
```
build/app/outputs/bundle/release/app-release.aab
```

### Google Play へのリリース
1. Google Play Console ログイン
2. 社会アプリ選択
3. テストトラック → 内部テスト → AAB アップロード
4. テスト検証後、本番トラックリリース

---

## ファイル構成

```
H:\マイドライブ\apps\social_quiz_app\
├── lib/                      # Dartソースコード
├── android/                  # Android設定
│   ├── app/build.gradle.kts  # パッケージ名設定
│   ├── gradle.properties     # Gradle設定
│   └── release.jks           # リリース署名キーストア
├── ios/                      # iOS設定（将来）
├── assets/                   # 画像・リソース
├── pubspec.yaml              # 依存関係定義
├── CLAUDE.md                 # 開発ガイド（詳細版）
├── PROJECT_GUIDE.md          # このファイル（プロジェクト概要版）
└── README.md                 # 使用方法

H:\マイドライブ\aab\
└── social_quiz_app-app-release.aab  # Google Play用AAB（62MB）
```

---

## 重要なファイル

### build.gradle.kts（Android設定）
```kotlin
// パッケージ名（重要）
applicationId = "com.petitworksapps.shougakukore.shakai"

// 署名設定
signingConfigs {
    create("release") {
        keyAlias = "release"
        keyPassword = "SocialQuiz2024!"
        storeFile = file("../release.jks")
        storePassword = "SocialQuiz2024!"
    }
}

buildTypes {
    release {
        signingConfig = signingConfigs.getByName("release")
    }
}
```

### release.jks（署名キーストア）
- ファイル: `android/release.jks`
- パスフレーズ: `SocialQuiz2024!`
- **重要**: このファイルを失うとアプリの更新ができなくなります。バックアップを取ってください。

---

## 最終チェックリスト

- [x] パッケージ名設定: `com.petitworksapps.shougakukore.shakai`
- [x] リリースキーストア生成: `release.jks`
- [x] build.gradle.kts 署名設定完了
- [x] AAB ビルド成功（62MB）
- [x] Google Drive へ保存完了
- [x] プライバシーポリシー作成
- [x] 簡潔説明・詳細説明作成
- [ ] Google Play Console への登録（待機中）
- [ ] 内部テスト実施
- [ ] 本番リリース

---

## クイックリファレンス

| 項目 | 値 |
|------|-----|
| アプリ名 | 社会 |
| パッケージ名 | com.petitworksapps.shougakukore.shakai |
| AAB ファイル | H:\マイドライブ\aab\social_quiz_app-app-release.aab |
| キーストア | android/release.jks |
| パスフレーズ | SocialQuiz2024! |
| 最小SDK | Android 6.0 (API 21) |
| ターゲットSDK | Android 14 (API 34) |
| Flutter版 | 3.11.5+ |
| 対象年齢 | 4+ / PEGI 3 |

---

**最終更新**: 2026年6月8日
**バージョン**: 1.0.0 Release Candidate
**開発者**: petit works apps
