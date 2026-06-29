# 実装設計書③ きょうは何の日？デイリー歴史配信

**優先度**: 🥈 次優先  
**推定工期**: 3-4日（データ作成含む）  
**実装モデル**: Haiku で十分  
**難易度**: 低〜中（日付判定 + UI）

---

## 1. 機能概要

### ユーザーストーリー
```
毎日アプリを開くと、その日の日付に関連した
歴史イベント1問が配信される。

「今日は時の記念日⏰」
「671年、天智天皇が日本初の時計『漏刻』を設置した日！」
→ 関連クイズに正解でボーナスコイン +10

翌日には異なるイベントが配信される。
```

### ゴール・メリット
| 観点 | 効果 |
|------|------|
| **毎日開く理由** | 「今日は何が出るか」という楽しみ |
| **学習** | 今日の日付と歴史がつながる体験 |
| **継続性** | デイリーボーナス機構としての効果 |
| **親子話題** | 夕食で「今日はこんなことあった日だって」と共有可能 |
| **受験対策** | 365日分の時事・歴史イベント知識が蓄積 |

---

## 2. データモデル設計

### 2.1 DailyHistory（日付別歴史イベント）

```dart
@freezed
class DailyHistory with _$DailyHistory {
  const factory DailyHistory({
    required String id,                // "0610" (月日)
    required int month,                // 6
    required int day,                  // 10
    required String eventName,         // "時の記念日"
    required String eventDescription,  // "671年、天智天皇が..."
    required int year,                 // 671 (最初の記録年)
    required String historicalContext, // 背景知識
    required int quizId,               // 対応するクイズID
    required String category,          // "記念日" / "歴史事件" / "人物誕生日"
  }) = _DailyHistory;
}
```

### 2.2 クイズとの対応

```dart
// DailyHistory.quizId → Quiz.id へのリンク

// 例：6月10日（時の記念日）
DailyHistory(
  id: "0610",
  month: 6,
  day: 10,
  eventName: "時の記念日",
  eventDescription: "671年、天智天皇が日本初の時計『漏刻』を設置した日",
  year: 671,
  historicalContext: "漏刻は水時計で、宮殿に設置された。...",
  quizId: 1234,  // このIDのクイズが配信される
  category: "記念日",
)

// 対応する Quiz
Quiz(
  id: 1234,
  question: "日本初の時計『漏刻』が設置されたのは何年か？",
  options: ["621年", "671年", "721年", "771年"],
  correctIndex: 1,
  explanation: "天智天皇の時代（7世紀）に中国から伝わった水時計『漏刻』が設置されました。",
  category: "history",
  prefectureId: null, // マップとは独立
)
```

---

## 3. データソース（365日分）

### 3.1 データ構造

```
assets/data/daily_history.json
```

```json
{
  "daily_history": [
    {
      "id": "0101",
      "month": 1,
      "day": 1,
      "eventName": "元日",
      "eventDescription": "新年。日本では古来より祝いの日とされてきた",
      "year": 645,
      "historicalContext": "大化の改新が起きた年（645年）も1月1日を基準としていた可能性がある",
      "quizId": 1001,
      "category": "記念日"
    },
    {
      "id": "0102",
      "month": 1,
      "day": 2,
      "eventName": "初売り",
      "eventDescription": "商家の初売りは江戸時代から存在した",
      "year": 1603,
      "historicalContext": "江戸時代、商人たちは新年の営業を『初売り』と呼んだ",
      "quizId": 1002,
      "category": "文化"
    },
    // ... 1月31日まで
    {
      "id": "0201",
      "month": 2,
      "day": 1,
      "eventName": "テレビ放送開始の日",
      "eventDescription": "1953年、日本初のテレビ放送がNHKから開始された",
      "year": 1953,
      "historicalContext": "昭和28年（1953年）2月1日、NHKがテレビ放送をスタート。当時は限定的な放送だった",
      "quizId": 1033,
      "category": "歴史事件"
    },
    // ... 365日分（閏年対応は2月29日のみ）
  ]
}
```

### 3.2 カテゴリ定義

```dart
enum DailyHistoryCategory {
  kinenbi,         // 記念日（公式）
  event,           // 歴史事件
  person_birthday, // 人物誕生日
  culture,         // 文化・風習
  politics,        // 政治・制度
  disaster,        // 災害・事故（歴史的）
}
```

---

## 4. UI/UX 設計

### 4.1 ホーム画面への組み込み

```
┌─────────────────────────────────────┐
│ ホーム画面                          │
├─────────────────────────────────────┤
│ プレイヤー名: 太郎                  │
│ スコア: 1250点                      │
├─────────────────────────────────────┤
│                                     │
│  ⭐ 🎁 きょうは何の日？🎁 ⭐       │
│                                     │
│  ┌───────────────────────────────┐ │
│  │  2026年 6月 10日（水）         │ │
│  │                               │ │
│  │  🕐 時の記念日                │ │
│  │                               │ │
│  │  671年、天智天皇が日本初の    │ │
│  │  時計『漏刻』を設置した日     │ │
│  │                               │ │
│  │  ★ クイズに正解で            │ │
│  │     ボーナスコイン +10        │ │
│  │                               │ │
│  │  【クイズに挑戦】             │ │
│  │      [実施済み✓]              │ │
│  └───────────────────────────────┘ │
│                                     │
│  【クイズをプレイ】                 │
│  【スコア確認】                     │
│  【マップ制覇】                     │
│                                     │
└─────────────────────────────────────┘
```

### 4.2 クイズ実施状態の管理

```dart
// 当日のクイズ実施状態をトラッキング

'app_daily_quiz_[YYYYMMDD]'  // bool
// 例: 'app_daily_quiz_20260610' -> true

// ボーナスコインを既に獲得したか
'app_daily_bonus_[YYYYMMDD]'  // int (0 or 10)
// 例: 'app_daily_bonus_20260610' -> 10
```

### 4.3 状態表示パターン

```
【未実施】
┌───────────────────────────────────┐
│ 2026年 6月 10日（水）             │
│ 🕐 時の記念日                    │
│ 671年、天智天皇が...             │
│                                   │
│ ★ クイズに正解でボーナス +10     │
│                                   │
│ 【クイズに挑戦】← タップで遷移   │
└───────────────────────────────────┘

【実施済み（正解）】
┌───────────────────────────────────┐
│ 2026年 6月 10日（水）             │
│ 🕐 時の記念日                    │
│ 671年、天智天皇が...             │
│                                   │
│ ✅ 正解！ボーナス +10獲得        │
│                                   │
│ 【本編クイズをプレイ】            │
└───────────────────────────────────┘

【実施済み（不正解）】
┌───────────────────────────────────┐
│ 2026年 6月 10日（水）             │
│ 🕐 時の記念日                    │
│ 671年、天智天皇が...             │
│                                   │
│ ❌ 残念... 明日もチャレンジ！    │
│                                   │
│ 【解説を読む】 【本編をプレイ】   │
└───────────────────────────────────┘
```

---

## 5. 実装ステップ

### Phase 1: データ準備（Day 1）

**Task 1.1: 365日分の歴史イベントデータ作成**

```
実装方法：
1. Google Sheet で日本の主要な記念日・歴史イベントをリスト化
2. Claude で子ども向け説明文に翻訳
3. JSON に変換して assets/data/daily_history.json に配置

参考データソース：
- 国立国会図書館「日本の記念日」
- NHK for School「歴史的出来事」
- 社会教育委員会資料

最小要件：
- 1月1日～12月31日（365日）
- 1日1イベント（閏年時は2月29日を含める）
- 各イベントに対応するクイズID
```

**Task 1.2: DailyHistory モデル & JSON パース実装**

```dart
// lib/models/daily_history.dart
@freezed
class DailyHistory with _$DailyHistory {
  // ...
}

// lib/services/daily_history_service.dart
class DailyHistoryService {
  Future<DailyHistory?> getTodayHistory() async {
    final json = await rootBundle.loadString('assets/data/daily_history.json');
    final data = jsonDecode(json) as Map<String, dynamic>;
    
    final today = DateTime.now();
    final monthDay = '${today.month.toString().padLeft(2, '0')}${today.day.toString().padLeft(2, '0')}';
    
    final histories = (data['daily_history'] as List)
        .map((h) => DailyHistory.fromJson(h))
        .toList();
    
    return histories.firstWhere((h) => h.id == monthDay, orElse: () => null);
  }
  
  Future<DailyHistory?> getHistoryByDate(int month, int day) async {
    // 任意の日付の歴史イベントを取得
  }
}
```

---

### Phase 2: UI 実装（Day 2）

**Task 2.1: DailyHistoryCard ウィジェット作成**

```dart
// lib/widgets/daily_history_card.dart
class DailyHistoryCard extends ConsumerWidget {
  final DailyHistory history;
  final bool isCompleted;
  final bool isCorrect;
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 日付
            Text(
              _formatTodayDate(),
              style: Theme.of(context).textTheme.bodySmall,
            ),
            SizedBox(height: 8),
            
            // イベント名
            Text(
              history.eventName,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            SizedBox(height: 8),
            
            // イベント説明
            Text(
              history.eventDescription,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            SizedBox(height: 16),
            
            // 背景知識
            Container(
              padding: EdgeInsets.all(8),
              color: Colors.grey[100],
              child: Text(
                history.historicalContext,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
            SizedBox(height: 16),
            
            // ボーナス表示 & ボタン
            if (!isCompleted)
              Column(
                children: [
                  Text('⭐ クイズに正解でボーナスコイン +10'),
                  SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () => _playDailyQuiz(context, ref),
                    child: Text('クイズに挑戦'),
                  ),
                ],
              )
            else
              Column(
                children: [
                  if (isCorrect)
                    Text('✅ 正解！ボーナス +10獲得')
                  else
                    Text('❌ 残念... 明日もチャレンジ！'),
                  SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () => _showExplanation(context),
                    child: Text('解説を読む'),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
```

**Task 2.2: ホーム画面への組み込み**

```dart
// lib/screens/home_screen.dart に以下を追加

class HomeScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dailyHistory = ref.watch(dailyHistoryProvider);
    
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 既存のホーム要素
            _buildPlayerInfo(context, ref),
            
            // ============ NEW: デイリーカード ============
            Padding(
              padding: EdgeInsets.all(16),
              child: dailyHistory.when(
                data: (history) => DailyHistoryCard(
                  history: history,
                  isCompleted: _isDailyCompleted(ref),
                  isCorrect: _isDailyCorrect(ref),
                ),
                loading: () => CircularProgressIndicator(),
                error: (err, stack) => SizedBox.shrink(),
              ),
            ),
            // ===========================================
            
            // その他のメニュー
            _buildMainMenu(context, ref),
          ],
        ),
      ),
    );
  }
}
```

---

### Phase 3: Riverpod 実装（Day 3）

**Task 3.1: DailyHistoryProvider**

```dart
// lib/providers/daily_history_provider.dart

final dailyHistoryServiceProvider = Provider((_) => DailyHistoryService());

// 今日の歴史イベントを取得
final dailyHistoryProvider = FutureProvider<DailyHistory?>((ref) async {
  final service = ref.watch(dailyHistoryServiceProvider);
  return await service.getTodayHistory();
});

// 当日クイズが実施済みかチェック
final isDailyCompletedProvider = Provider<bool>((ref) {
  final today = DateTime.now();
  final key = 'app_daily_quiz_${today.year}${today.month.toString().padLeft(2, '0')}${today.day.toString().padLeft(2, '0')}';
  return _prefs.getBool(key) ?? false;
});

// 当日クイズが正解かチェック
final isDailyCorrectProvider = Provider<bool>((ref) {
  final today = DateTime.now();
  final key = 'app_daily_correct_${today.year}${today.month.toString().padLeft(2, '0')}${today.day.toString().padLeft(2, '0')}';
  return _prefs.getBool(key) ?? false;
});
```

**Task 3.2: デイリークイズ実行ロジック**

```dart
// lib/providers/quiz_provider.dart に追加

class ScoreNotifier extends StateNotifier<int> {
  Ref ref;
  
  // ...
  
  void playDailyQuiz(Quiz quiz, int selectedIndex) {
    final isCorrect = selectedIndex == quiz.correctIndex;
    
    if (isCorrect) {
      // ボーナスコイン +10
      state += (quiz.difficulty * 10) + 10;  // 通常スコア + ボーナス
      
      // クリア状態を保存
      final today = DateTime.now();
      final key = 'app_daily_quiz_${today.year}${today.month.toString().padLeft(2, '0')}${today.day.toString().padLeft(2, '0')}';
      _prefs.setBool(key, true);
      
      final correctKey = 'app_daily_correct_${today.year}${today.month.toString().padLeft(2, '0')}${today.day.toString().padLeft(2, '0')}';
      _prefs.setBool(correctKey, true);
      
      // Provider をリフレッシュ
      ref.refresh(isDailyCompletedProvider);
      ref.refresh(isDailyCorrectProvider);
    } else {
      // 不正解でもクリア状態は保存（リトライ不可）
      final today = DateTime.now();
      final key = 'app_daily_quiz_${today.year}${today.month.toString().padLeft(2, '0')}${today.day.toString().padLeft(2, '0')}';
      _prefs.setBool(key, true);
      
      ref.refresh(isDailyCompletedProvider);
    }
  }
}
```

---

### Phase 4: データ検証 & ポーリッシング（Day 4）

**Task 4.1: JSON データ検証**
```dart
testWidgets('DailyHistory JSON loading', (WidgetTester tester) async {
  final service = DailyHistoryService();
  
  for (int month = 1; month <= 12; month++) {
    for (int day = 1; day <= DateTime(2026, month, day).day; day++) {
      final history = await service.getHistoryByDate(month, day);
      expect(history, isNotNull);
      expect(history!.quizId, greaterThan(0));
    }
  }
});
```

**Task 4.2: UI ポーリッシング**
- 背景色の調整
- フォント・レイアウトの微調整
- アニメーション追加（カード表示時のスライドイン）

---

## 6. データ作成手順（詳細）

### 6.1 Google Sheet で作成

| 月日 | イベント名 | 説明 | 年 | 背景知識 | クイズID | カテゴリ |
|------|-----------|------|-----|---------|---------|---------|
| 0101 | 元日 | 新年。日本では古来より祝いの日とされてきた | 645 | 大化の改新が... | 1001 | 記念日 |
| 0102 | 初売り | 商家の初売りは江戸時代から存在した | 1603 | 江戸時代... | 1002 | 文化 |
| ... | ... | ... | ... | ... | ... | ... |

### 6.2 Claude API で説明文を生成（オプション）

```python
import anthropic

client = anthropic.Anthropic()

events = [
    {"date": "01-01", "name": "元日", "year": 645},
    {"date": "01-02", "name": "初売り", "year": 1603},
]

for event in events:
    message = client.messages.create(
        model="claude-opus-4-8",
        max_tokens=200,
        messages=[
            {
                "role": "user",
                "content": f"""
日本の{event['date']}は「{event['name']}」という記念日です。
{event['year']}年に関連する歴史的背景を、小学5-6年生向けに
200字以内の簡潔な説明で書いてください。

出力形式:
背景知識: [説明文]
クイズ問題案: [4択クイズ1問]
"""
            }
        ]
    )
    print(message.content[0].text)
```

### 6.3 JSON への変換

```bash
# Python スクリプトで Google Sheet CSV を JSON に変換
python convert_csv_to_json.py --input daily_history.csv --output assets/data/daily_history.json
```

---

## 7. テスト計画

### 7.1 ユニットテスト
```dart
test('DailyHistoryService.getTodayHistory', () async {
  final service = DailyHistoryService();
  final history = await service.getTodayHistory();
  
  expect(history, isNotNull);
  expect(history!.month, greaterThanOrEqualTo(1));
  expect(history.day, greaterThanOrEqualTo(1));
});

test('Daily quiz completion tracking', () async {
  final prefs = await SharedPreferences.getInstance();
  final today = DateTime.now();
  final key = 'app_daily_quiz_${today.year}${today.month}${today.day}';
  
  await prefs.setBool(key, true);
  expect(prefs.getBool(key), true);
});
```

### 7.2 ウィジェットテスト
```dart
testWidgets('DailyHistoryCard displays event', (WidgetTester tester) async {
  final history = DailyHistory(
    id: '0610',
    month: 6,
    day: 10,
    eventName: '時の記念日',
    eventDescription: '671年、天智天皇が...',
    year: 671,
    historicalContext: '...',
    quizId: 1234,
    category: 'kinenbi',
  );
  
  await tester.pumpWidget(
    MaterialApp(home: DailyHistoryCard(history: history, isCompleted: false, isCorrect: false))
  );
  
  expect(find.text('時の記念日'), findsOneWidget);
  expect(find.byType(ElevatedButton), findsOneWidget);
});
```

---

## 8. 実装チェックリスト

- [ ] 365日分のデータ作成（Google Sheet）
- [ ] DailyHistory モデル実装
- [ ] DailyHistoryService 実装
- [ ] 365日分のクイズ ID 付与（既存問題から選定 or 新規作成）
- [ ] daily_history.json をアセットに配置
- [ ] DailyHistoryCard ウィジェット実装
- [ ] HomeScreen への組み込み
- [ ] DailyHistoryProvider 実装
- [ ] デイリークイズ実行ロジック
- [ ] ボーナスコイン獲得機構
- [ ] SharedPreferences クリア状態管理
- [ ] ユニットテスト実装
- [ ] ウィジェットテスト実装
- [ ] UI ポーリッシング（背景色・フォント・アニメーション）

---

## 9. 拡張案（将来）

```dart
// A. 過去の日付の歴史イベントをクイズプレイ可能に
Widget buildPastHistoryCalendar() {
  // 6月のカレンダー表示
  // 各日付をタップ → その日の歴史イベント表示
}

// B. 「○月○日は何があった日？」ゲーム
Widget buildHistoryGuessingGame() {
  // イベント説明だけを見て、日付を当てるクイズ
}

// C. 通知機能（v1.2+）
void scheduleNotification() {
  // 毎朝8時に「きょうは何の日？」通知を送信
}
```

---

**次ステップ**: Task #3 「② じぶん年表」設計書へ

