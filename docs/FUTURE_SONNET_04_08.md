# 将来実装設計書④⑧（Sonnet推奨）

---

# 実装設計書④ ニュースクイズ（週刊時事問題）

**優先度**: v1.3+ 後回し  
**推定工期**: 3週間（運用体制含む）  
**実装モデル**: **Sonnet 強く推奨** (Claude API 連携)  
**難易度**: 高（API・運用体制）

## 概要
今週の子ども向けニュースをクイズ化して毎週配信。中学受験の時事問題対策を兼ねる。Claude API でニュース→クイズ化を半自動化。

## Sonnet推奨理由

```
【複雑性】
- Claude API との連携（プロンプトチューニング必須）
- ニュース記事 → 子ども向けクイズ化の品質判定
- 複数のニュースソースからの選定・優先度判定
- 不適切なコンテンツフィルタリング

【高度な思考力が必要】
- ニュース分析 → 教育的観点での価値判定
- 背景知識の追加・文脈整備
- 記述問題への誘導的な選択肢設計

【Haikuの限界】
- トークン窓が小さく、複数記事の同時分析困難
- 複雑なプロンプトチューニングで精度低下傾向
- 子ども向け表現への変換品質が不安定

→ Sonnet の高い推論能力が必須
```

## データフロー

```
【週次パイプライン】

1. ニュース情報源（複数）から記事収集
   - NHK for School
   - 朝日新聞 EduA
   - 読売新聞オンライン子ども向け

2. Claude API に投げる
   プロンプト:
   """
   以下のニュース記事を、小学5-6年生向けの
   社会科クイズ3問に変換してください。
   
   要件:
   - 4択一答形式
   - 中学受験頻出テーマに関連
   - 解説は100字以内で子ども向けに
   - 不適切な内容は除外
   
   記事: [記事本文]
   """

3. API が生成
   ↓
   
4. 人間レビュー（1時間）
   - 正答確認
   - 表現の妥当性
   - 子ども向け適切性

5. Firebase に配信
   ↓
   
6. アプリ側で受信・表示
```

## 実装概要

### Cloud Functions でスケジュール実行
```python
# functions/generate_weekly_quiz.py

import anthropic
import firebase_admin
from firebase_admin import firestore

def generate_weekly_news_quiz(request):
    """毎週日曜 20:00 に実行"""
    
    client = anthropic.Anthropic(api_key=os.environ.get('ANTHROPIC_API_KEY'))
    
    # 1. ニュース記事を収集
    articles = fetch_news_articles()
    
    # 2. Claude API で処理
    quizzes = []
    for article in articles[:5]:  # トップ5記事に限定
        message = client.messages.create(
            model="claude-opus-4-8",
            max_tokens=1000,
            messages=[
                {
                    "role": "user",
                    "content": f"""
この週のニュースを小学生向けクイズに変換：

【記事】
{article['title']}
{article['content']}

【要件】
- 4択×3問
- 中学受験対策の視点
- 子ども向け説明
- JSON形式で返却

【出力形式】
{{
  "quizzes": [
    {{
      "question": "...",
      "options": ["...", "...", "...", "..."],
      "correctIndex": 0,
      "explanation": "..."
    }},
    ...
  ]
}}
"""
                }
            ]
        )
        
        # JSON パース
        result = json.loads(message.content[0].text)
        quizzes.extend(result['quizzes'])
    
    # 3. Firebase に保存
    db = firestore.client()
    db.collection('weekly_quizzes').add({
        'created_at': datetime.now(),
        'week': get_week_number(),
        'quizzes': quizzes,
        'status': 'pending_review',  # 人間レビュー待ち
    })
    
    return {'status': 'success', 'quiz_count': len(quizzes)}
```

### Dart 側（受け取り・表示）
```dart
// lib/screens/news_quiz_screen.dart

class NewsQuizScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weeklyQuiz = ref.watch(weeklyNewsQuizProvider);
    
    return Scaffold(
      appBar: AppBar(title: Text('週刊ニュースクイズ')),
      body: weeklyQuiz.when(
        data: (quiz) => Column(
          children: [
            Text('今週のテーマ: ${quiz.theme}'),
            Text('配信日: ${quiz.publishedAt.format()}'),
            
            // 3問を順番に表示
            Expanded(
              child: PageView.builder(
                itemCount: quiz.quizzes.length,
                itemBuilder: (context, index) {
                  return QuizWidget(
                    quiz: quiz.quizzes[index],
                    onAnswer: (answer) => _recordAnswer(index, answer),
                  );
                },
              ),
            ),
            
            // 完了ボタン
            ElevatedButton(
              onPressed: _submitAnswers,
              child: Text('送信'),
            ),
          ],
        ),
        loading: () => Center(child: CircularProgressIndicator()),
        error: (err, st) => Center(child: Text('ニュースクイズはまだ配信されていません')),
      ),
    );
  }
}
```

## 課金戦略
```
【基本無料】
- 過去のニュースクイズはすべて無料プレイ可能

【課金オプション】
- 「受験対策パック（¥300/月）」
  → 週刊ニュースクイズ配信日に即座にプレイ可能
  → 過去3ヶ月のニュース履歴へのアクセス
  → 「ニュースクイズ成績表」（グラフ表示）

受験生の親は「時事対策」に関しては課金に積極的
→ 最強の課金正当性
```

## チェックリスト
- [ ] Claude API キー設定
- [ ] Cloud Functions セットアップ
- [ ] ニュース収集パイプライン構築
- [ ] プロンプトチューニング（複数パターンテスト）
- [ ] JSON パースロジック
- [ ] Firebase Firestore スキーマ設計
- [ ] 人間レビュー UI（管理画面）
- [ ] NewsQuizScreen 実装
- [ ] RevenueCat との課金連携（将来）
- [ ] テスト実装

---

# 実装設計書⑧ 旅行GPS連動「ほんものチェックイン」

**優先度**: v1.4+ 後回し  
**推定工期**: 3週間（位置情報・複雑UI）  
**実装モデル**: **Sonnet 強く推奨** (複雑なUI・位置判定)  
**難易度**: 高（位置情報・プライバシー）

## 概要
家族旅行で実際に訪れた都道府県をGPSでチェックイン。①マップ上で「行った県」に特別マーク。「クイズで知ってる県」と「行ったことある県」の二重地図。

## Sonnet推奨理由

```
【複雑な位置判定ロジック】
- GPS座標 → 都道府県の自動判定
- 位置精度が低い（100m以内 vs 10km以内）場合の判断
- 県境での判定曖昧性の処理
- フェンシングアルゴリズムの実装

【UI/UXの複雑性】
- 既存マップUI + 新しい「実訪問」レイヤーの重ね合わせ
- インタラクション設計（タップ・ピンチ・ドラッグの統合）
- パフォーマンス最適化（SVG + GPS リアルタイム更新）

【プライバシー・セキュリティ】
- 位置情報の取得・保存・削除
- 親・子の同意フロー（COPPA対応）
- 規制への対応（位置情報の利用目的明示）

【複数の難しい判定】
- 県境での「どちらにカウント？」問題
- 2回目の訪問時の扱い
- オフラインでの GPS データ同期

→ これらの複合的な課題解決には Sonnet の推論能力が必須
```

## データモデル

```dart
@freezed
class VisitedLocation with _$VisitedLocation {
  const factory VisitedLocation({
    required String prefectureId,
    required double latitude,
    required double longitude,
    required DateTime visitedAt,
    required String checkInType,  // "gps_auto" or "manual"
    required bool photoProof,      // 写真証拠がある？
  }) = _VisitedLocation;
}

// マップに「訪問」マークを追加
@freezed
class PrefectureWithVisit with _$PrefectureWithVisit {
  const factory PrefectureWithVisit({
    required Prefecture prefecture,
    required bool visited,         // GPS チェックイン済み
    required int visitCount,       // 訪問回数
    required List<VisitedLocation> visits,
  }) = _PrefectureWithVisit;
}
```

## UI 設計

```
【二重地図表示】

既存: クイズクリア状態
   ✓ = 青く塗りつぶし
   ○ = グレー

新規: 実訪問状態を重ねる
   🚩 = 赤い旗（実訪問）
   📸 = カメラマーク（写真証拠あり）

┌──────────────────────────┐
│ あなたの日本地図          │
│                          │
│ ■ クイズでクリア         │
│ 🚩 実際に訪れた         │
│ 📸 写真で証明           │
├──────────────────────────┤
│                          │
│  北海道                  │
│  ✓ クイズOK / 🚩 訪問   │
│                          │
│  東北                    │
│  青森県: ✓ クイズ        │
│  岩手県: ✓ クイズ/🚩訪問 │
│  秋田県: ○ 未実施       │
│  ...                     │
│                          │
└──────────────────────────┘
```

## 実装概略

### Step 1: 位置情報パーミッション
```dart
// lib/services/location_service.dart

class LocationService {
  Future<bool> requestLocationPermission() async {
    // iOS: Info.plist に設定
    // Android: AndroidManifest.xml に設定
    
    final status = await Permission.location.request();
    return status.isGranted;
  }
  
  // GPS の定期ポーリング
  Stream<LatLng> startLocationTracking() {
    return geolocator.getPositionStream().map((pos) {
      return LatLng(pos.latitude, pos.longitude);
    });
  }
}
```

### Step 2: 位置 → 都道府県の判定
```dart
// lib/services/prefecture_detection_service.dart

class PrefectureDetectionService {
  // 都道府県の Boundary（座標範囲）を定義
  // または、GeojSON を使用
  
  Future<String?> detectPrefecture(LatLng location) async {
    for (var boundary in _prefBoundaries) {
      if (boundary.contains(location)) {
        return boundary.prefectureId;
      }
    }
    return null;
  }
  
  // 県内にいることを確認
  bool isPrefectureArea(LatLng location, String prefId) {
    final boundary = _prefBoundaries[prefId];
    return boundary.contains(location);
  }
}
```

### Step 3: チェックイン UI
```dart
// ユーザーが訪問した県に滞在中 → チェックインボタンを表示

if (currentPrefecture != null && !isAlreadyCheckedIn) {
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text('${currentPrefecture} にようこそ！'),
      content: Text('この県をチェックインしますか？'),
      actions: [
        ElevatedButton(
          onPressed: () => _performCheckin(currentPrefecture),
          child: Text('チェックイン'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: Text('あとで'),
        ),
      ],
    ),
  );
}
```

### Step 4: マップへの可視化
```dart
// 既存の JapanMapPainter を拡張
// 訪問フラグを重ね描画

void paint(Canvas canvas, Size size) {
  // 既存: クイズクリア状態を描画
  for (var pref in prefectures) {
    Path path = japanMapPaths[pref.id];
    Paint paint = Paint()
      ..color = pref.cleared == 1 ? Colors.blue : Colors.grey;
    canvas.drawPath(path, paint);
  }
  
  // NEW: 訪問フラグを重ね描画
  for (var visit in visitedPrefectures) {
    Path path = japanMapPaths[visit.prefectureId];
    Paint flagPaint = Paint()
      ..color = Colors.red;
    
    // 県の中心に🚩を描画
    final center = path.getBounds().center;
    canvas.drawCircle(center, 10, flagPaint);
  }
}
```

## プライバシー・規制対応

```dart
// 親権者（13歳未満の児童の）の同意を取得

class LocationConsentFlow {
  void showParentConsent() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('お子さんの位置情報について'),
        content: Text('''
このアプリは、GPS を使ってお子さんが
訪れた都道府県を自動的に記録します。

記録される情報：
- 訪問日時
- 位置座標（都道府県判定のみに使用）

記録されない情報：
- 訪問施設の詳細
- 自宅住所

削除権：
いつでもお子さんの訪問履歴を削除できます。

同意しますか？
'''),
        actions: [
          TextButton(
            onPressed: () => _acceptLocationTracking(),
            child: Text('同意する'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('同意しない'),
          ),
        ],
      ),
    );
  }
}
```

## チェックリスト
- [ ] LocationService 実装
- [ ] PrefectureDetectionService 実装（座標境界データ）
- [ ] GPS リアルタイム追跡
- [ ] チェックイン UI
- [ ] VisitedLocation モデル作成
- [ ] マップ可視化（フラグ重ね描画）
- [ ] 親権者同意フロー（COPPA対応）
- [ ] プライバシーポリシー更新
- [ ] テスト実装（位置判定・境界テスト）

---

## 📋 総合実装ロードマップ

```
【v1.1 / 2週間】Haiku
├─ ① マップ踏破システム
└─ ③ きょうは何の日

【v1.2 / 3週間】Haiku
├─ ② じぶん年表
├─ ⑤ 名産カード
└─ ⑦ shared_core統合

【v1.3 / 2週間】Haiku
├─ ⑥ もしも歴史
├─ ⑨ 親子バトル
└─ ⑩ 受験モード

【v2.0 / 3週間】Sonnet
├─ ④ ニュースクイズ（Claude API）
└─ 運用体制整備

【v2.1 / 3週間】Sonnet
└─ ⑧ GPS チェックイン

---

【シリーズ統合】
四教科すべてが揃い次第、以下を実装：
- 「四教科コレクター」統合バッジ
- クロスゲーム（例：算数×社会）
- シリーズランキング（Firebase連携）
```

---

**このドキュメントは Sonnet での実装が確定した時点で詳細設計書に進化します**

