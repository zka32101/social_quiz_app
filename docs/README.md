# 社会アプリ（社会） - 完全実装ガイド

**最終更新**: 2026年6月8日  
**バージョン**: 1.0 Release Candidate → 拡張ロードマップ v1.1-2.1

---

## 📚 ドキュメント一覧

### 現在リリース済み
- ✅ **PROJECT_GUIDE.md** - プロジェクト概要・コンセプト・技術スタック

### 実装設計書（Haiku で即実装可能）

| ファイル | 機能 | 優先度 | 工期 |
|---------|------|--------|------|
| **DESIGN_01_MAP_SYSTEM.md** | ① 日本一周マップ踏破システム | 🥇 1位 | 4-5日 |
| **DESIGN_03_DAILY_HISTORY.md** | ③ きょうは何の日デイリー配信 | 🥈 2位 | 3-4日 |
| **DESIGN_02_05_06_07_09_10.md** | ② じぶん年表タイムライン | 🥉 3位 | 4-5日 |
| | ⑤ ごとうち名産カード | 4位 | 4-5日 |
| | ⑥ もしも歴史（思考型クイズ） | 6位 | 3日 |
| | ⑦ shared_core統合 | 5位 | 2-3日 |
| | ⑨ 親子都道府県バトル | 7位 | 3-4日 |
| | ⑩ 中学受験モード | 8位 | 2-3日 |

### 将来実装設計書（Sonnet推奨・後回し）

| ファイル | 機能 | 難易度 | 工期 |
|---------|------|--------|------|
| **FUTURE_SONNET_04_08.md** | ④ ニュースクイズ（Claude API） | 高 | 3週間 |
| | ⑧ 旅行GPS連動チェックイン | 高 | 3週間 |

---

## 🎯 推奨実装フェーズ

### Phase 1: v1.1（2週間）- **MVP強化版**

```
優先度: ★★★ 必須
成果物: マップ踏破 + デイリークイズで毎日開く理由が生まれる

実装対象:
  ① 日本一周マップ踏破システム
  ③ きょうは何の日デイリー配信

理由:
  - 最小限のコストで「ゲーム性」が大幅向上
  - Google Play スクリーンショットが映える
  - 「社会科の本質（地図・時間軸）」を両立
```

### Phase 2: v1.2（3週間）- **学習深度化**

```
優先度: ★★☆ 高推奨
成果物: 年表 + カード + shared_core で完全なゲーミフィケーション

実装対象:
  ② じぶん年表タイムライン
  ⑤ ごとうち名産カード
  ⑦ shared_core統合（バッジ・コイン・キャラ）

効果:
  - 「地図・時間軸・文化」が統合された学習体験
  - シリーズ（国語・算数・理科・社会）の統一感
  - 視認性・やる気向上
```

### Phase 3: v1.3（2週間）- **思考力・対戦機能**

```
優先度: ★☆☆ 中
成果物: 思考型クイズ + 親子対戦で知的興奮

実装対象:
  ⑥ もしも歴史（思考型クイズ）
  ⑨ 親子都道府県バトル
  ⑩ 中学受験モード

効果:
  - 受験生向けへの訴求力強化
  - 親世代が一緒に遊べる
  - 単なる「クイズアプリ」から「学習パートナー」へ進化
```

### Phase 4: v2.0（3週間）- **AI連携・課金化**

```
優先度: ★☆☆ 将来（Sonnet必須）
成果物: AI で自動生成されるニュースクイズ + 課金体系

実装対象:
  ④ ニュースクイズ（Claude API 連携）
  運用体制整備（週次配信パイプライン）

効果:
  - 「受験対策教材」として最強の課金正当性
  - 「生きた教材」→ 毎週開く理由
  - ¥300/月の継続課金可能
```

### Phase 5: v2.1（3週間）- **現実連動**

```
優先度: ★☆☆ 将来（Sonnet必須）
成果物: GPS で実訪問を記録 + 二重地図

実装対象:
  ⑧ 旅行GPS連動チェックイン

効果:
  - 「クイズで知ってる県」と「行ったことある県」の融合
  - 家族旅行との連動で粘着性向上
  - 親子で遊ぶきっかけ（位置情報同意フロー）
```

---

## 📊 実装ロードマップ（ガントチャート）

```
       6月         7月         8月         9月
      W24 W25 W26 W27 W28 W29 W30 W31 W32 W33
v1.1   [======①===③======]              ← マップ+デイリー
v1.2              [========②⑤⑦========]   ← 年表+カード+基盤
v1.3                          [====⑥⑨⑩====]  ← 思考型+対戦
v2.0   (Sonnet待ち)           [④ニュース...]  ← API連携
v2.1   (Sonnet待ち)                   [⑧GPS...]  ← GPS

総工期: 10-12週間（フルタイム開発・1-2名）
```

---

## 🔧 各ドキュメントの使い方

### DESIGN_01_MAP_SYSTEM.md
```
【対象】① マップ踏破システムの実装者

【内容】
- データモデル（Prefecture, Quiz拡張）
- SVG 設計（47県パス定義）
- UI/UX（地図+進捗バー）
- 実装ステップ（Phase 1-4）
- Provider設計（Riverpod）
- バッジシステム統合
- テスト計画

【使い方】
1. データモデルを lib/models/ に実装
2. SVG を assets/ に配置
3. 4択問題に prefectureId タグを付与
4. 実装ステップに従って Phase 1→4 を順次実装
5. テストケースを参考にテスト実装
```

### DESIGN_03_DAILY_HISTORY.md
```
【対象】③ きょうは何の日の実装者

【内容】
- 365日の歴史イベントデータ設計
- 日付判定ロジック
- デイリークイズ配信UI
- Claude API での自動生成（オプション）
- SharedPreferences クリア状態管理
- Riverpod Provider 設計

【使い方】
1. daily_history.json を作成（365日分）
2. DailyHistory モデルを実装
3. DailyHistoryCard ウィジェットを実装
4. ホーム画面に組み込む
5. クイズ実行ロジックを統合
```

### DESIGN_02_05_06_07_09_10.md
```
【対象】② ⑤ ⑥ ⑦ ⑨ ⑩ の各実装者（またはリーダー）

【内容】
- 各機能の概要（500字程度）
- データモデル
- UI 設計
- 実装ステップ（高レベル）
- チェックリスト

【使い方】
- 各機能ごとに「概要」を読んで理解
- データモデルを参考に lib/models/ に追加
- UI 設計を参考に lib/screens/ を実装
- チェックリストで進捗を追跡
```

### FUTURE_SONNET_04_08.md
```
【対象】④④⑧ の企画・意思決定者

【内容】
- Sonnet が推奨される理由
- 高レベルなデータフロー
- 実装概略
- 複雑性の説明

【使い方】
- v2.0 をコミット後、Sonnet での詳細設計に進化
- API 連携の複雑性を理解
- コスト・効果の判断に活用
```

---

## ✅ 実装開始チェックリスト

- [ ] PROJECT_GUIDE.md を読んで、全体コンセプトを理解
- [ ] DESIGN_01_MAP_SYSTEM.md を読んで ① の実装計画を立案
- [ ] DESIGN_03_DAILY_HISTORY.md を読んで ③ のデータ作成計画を立案
- [ ] git ブランチを作成: `feature/v1.1-map-and-daily`
- [ ] ① のデータモデルを実装（Quiz + Prefecture）
- [ ] ③ の 365 日分データを準備（CSV/JSON）
- [ ] チーム内で工期・タスク分割を決定
- [ ] 実装状況を DESIGN_*.md の「実装チェックリスト」で追跡

---

## 🔗 関連ファイル

```
H:\マイドライブ\apps\social_quiz_app\
├── docs/
│   ├── README.md ← 今ここ
│   ├── PROJECT_GUIDE.md ← プロジェクト概要
│   ├── DESIGN_01_MAP_SYSTEM.md
│   ├── DESIGN_03_DAILY_HISTORY.md
│   ├── DESIGN_02_05_06_07_09_10.md
│   └── FUTURE_SONNET_04_08.md
├── lib/
│   ├── models/
│   │   ├── quiz.dart ← Prefecture, DailyHistory 追加
│   │   ├── prefecture.dart ← NEW
│   │   └── ...
│   ├── screens/
│   │   ├── map_screen.dart ← NEW
│   │   ├── daily_history_screen.dart ← NEW
│   │   └── ...
│   └── ...
├── assets/
│   ├── maps/
│   │   └── japan_map.svg ← NEW（47県分割地図）
│   └── data/
│       └── daily_history.json ← NEW（365日データ）
├── android/
│   └── app/
│       └── build.gradle.kts ← パッケージ名確定
└── pubspec.yaml
```

---

## 💡 Tips

### データ作成を効率化したい場合
```python
# Python で CSV → JSON 変換
import pandas as pd
import json

df = pd.read_csv('daily_history.csv')
json_data = {
    'daily_history': df.to_dict('records')
}
with open('daily_history.json', 'w', encoding='utf-8') as f:
    json.dump(json_data, f, ensure_ascii=False, indent=2)
```

### Claude API で説明文を自動生成
```python
# 365日分の背景知識をバッチ生成
import anthropic

client = anthropic.Anthropic()
for event in events:
    message = client.messages.create(
        model="claude-opus-4-8",
        max_tokens=200,
        messages=[{
            "role": "user",
            "content": f"この歴史イベントの背景知識を小学5-6年向けに説明してください: {event['name']}年{event['year']}"
        }]
    )
    print(message.content[0].text)
```

### SVG 日本地図の入手
- **推奨**: Wikipedia Commons の日本地図（CC License）
- **代替**: Adobe Illustrator で自作
- **簡易版**: Figma の無料テンプレート

---

## 📞 質問・相談

各実装設計書に「よくあるエラーと対処」セクションがあります。  
不明な点があれば、該当する DESIGN_*.md を再度読んで確認してください。

---

**次のステップ**: Phase 1 の実装を開始してください！ 🚀

