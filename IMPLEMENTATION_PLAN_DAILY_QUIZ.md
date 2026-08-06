# 今日のニュースクイズ — 実装計画

**実装期間**: 1-2日  
**優先度**: 🔴 HIGH  
**開始日**: 2026-06-27

---

## 📋 機能概要

毎日 1問の社会ニュース連動クイズを配信。年中行事・季節・時事ニュースと連動させて、「今日の学習」という動機付けを作成。

```
[ユーザーがアプリを開く]
    ↓
[ホーム画面に「今日のクイズ」タブ表示]
    ↓
[1問出題 + Firebase Messaging で朝8時通知]
    ↓
[正解するとボーナスポイント +50点]
    ↓
[毎日プレイの習慣化]
```

---

## 🏗️ 技術アーキテクチャ

### **Step 1: Firebase Remote Config セットアップ**

```json
// Firebase Console → Remote Config → Create Configuration
{
  "daily_quiz": {
    "enabled": true,
    "date": "2026-06-27",
    "question": "今日6月27日は？",
    "options": ["憲法記念日", "七夕", "お正月", "敬老の日"],
    "correct_index": 0,
    "explanation": "6月27日は...",
    "quiz_id": "daily_20260627",
    "difficulty": "easy",
    "category": "event"
  }
}
```

### **Step 2: Dart 実装**

**ファイル構成:**
```
lib/
  ├── providers/
  │   └── daily_quiz_provider.dart       ← 新規
  ├── models/
  │   └── daily_quiz_model.dart          ← 新規
  ├── screens/
  │   └── daily_quiz_screen.dart         ← 新規
  └── services/
      └── daily_quiz_service.dart        ← 新規
```

**daily_quiz_model.dart:**
```dart
class DailyQuiz {
  final String quizId;
  final String question;
  final List<String> options;
  final int correctIndex;
  final String explanation;
  final String category;      // "event", "history", "geography"
  final String difficulty;    // "easy", "medium", "hard"
  final DateTime date;
  final bool isAnswered;
  final bool isCorrect;
  final int bonusPoints;

  DailyQuiz({
    required this.quizId,
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.explanation,
    required this.category,
    required this.difficulty,
    required this.date,
    this.isAnswered = false,
    this.isCorrect = false,
    this.bonusPoints = 50,
  });

  factory DailyQuiz.fromJson(Map<String, dynamic> json) {
    return DailyQuiz(
      quizId: json['quiz_id'] as String? ?? '',
      question: json['question'] as String? ?? '',
      options: List<String>.from(json['options'] as List? ?? []),
      correctIndex: json['correct_index'] as int? ?? 0,
      explanation: json['explanation'] as String? ?? '',
      category: json['category'] as String? ?? 'event',
      difficulty: json['difficulty'] as String? ?? 'easy',
      date: json['date'] != null 
          ? DateTime.parse(json['date'] as String)
          : DateTime.now(),
    );
  }
}
```

**daily_quiz_provider.dart:**
```dart
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final dailyQuizProvider = FutureProvider<DailyQuiz?>((ref) async {
  final remoteConfig = FirebaseRemoteConfig.instance;
  
  try {
    await remoteConfig.fetchAndActivate();
    
    final quizJson = remoteConfig.getJson('daily_quiz');
    if (quizJson.isEmpty) return null;
    
    return DailyQuiz.fromJson(quizJson);
  } catch (e) {
    print('Error loading daily quiz: $e');
    return null;
  }
});

// ユーザーの今日の回答状態
final userDailyAnswerProvider = 
  FutureProvider.family<bool?, String>((ref, quizId) async {
  final prefs = await SharedPreferences.getInstance();
  final key = 'daily_quiz_answered_$quizId';
  return prefs.getBool(key);
});

// ボーナスポイント管理
final dailyBonusPointsProvider = 
  StateNotifierProvider<DailyBonusNotifier, int>((ref) {
  return DailyBonusNotifier();
});

class DailyBonusNotifier extends StateNotifier<int> {
  DailyBonusNotifier() : super(0);
  
  void addBonus(int points) async {
    state += points;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('daily_bonus_points', state);
  }
}
```

**daily_quiz_screen.dart:**
```dart
class DailyQuizScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dailyQuizAsync = ref.watch(dailyQuizProvider);
    
    return dailyQuizAsync.when(
      data: (quiz) {
        if (quiz == null) {
          return Center(
            child: Text('今日のクイズはありません'),
          );
        }
        
        return DailyQuizContent(quiz: quiz);
      },
      loading: () => Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(
        child: Text('エラーが発生しました'),
      ),
    );
  }
}

class DailyQuizContent extends ConsumerStatefulWidget {
  final DailyQuiz quiz;
  
  const DailyQuizContent({required this.quiz});
  
  @override
  ConsumerState<DailyQuizContent> createState() => _DailyQuizContentState();
}

class _DailyQuizContentState extends ConsumerState<DailyQuizContent> {
  int? selectedIndex;
  bool? isCorrect;
  
  void submitAnswer() {
    if (selectedIndex == null) return;
    
    final isCorrect = selectedIndex == widget.quiz.correctIndex;
    
    setState(() {
      this.isCorrect = isCorrect;
    });
    
    if (isCorrect) {
      ref.read(dailyBonusPointsProvider.notifier).addBonus(50);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('正解！ +50ボーナスポイント'),
          backgroundColor: Colors.green,
        ),
      );
    }
    
    // 回答履歴を保存
    _saveDailyAnswer();
  }
  
  Future<void> _saveDailyAnswer() async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'daily_quiz_answered_${widget.quiz.quizId}';
    await prefs.setBool(key, true);
  }
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ヘッダー: 今日の日付 + カテゴリ
        Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '今日のクイズ',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blue.shade100,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  widget.quiz.category,
                  style: TextStyle(color: Colors.blue),
                ),
              ),
            ],
          ),
        ),
        
        // 問題文
        Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            widget.quiz.question,
            style: Theme.of(context).textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
        ),
        
        // 選択肢
        Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: List.generate(
              widget.quiz.options.length,
              (index) => GestureDetector(
                onTap: isCorrect == null 
                    ? () => setState(() => selectedIndex = index)
                    : null,
                child: Container(
                  margin: EdgeInsets.only(bottom: 12),
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: selectedIndex == index 
                          ? Colors.blue 
                          : Colors.grey.shade300,
                      width: selectedIndex == index ? 2 : 1,
                    ),
                    borderRadius: BorderRadius.circular(8),
                    color: isCorrect != null && index == widget.quiz.correctIndex
                        ? Colors.green.shade100
                        : selectedIndex == index && isCorrect == false
                            ? Colors.red.shade100
                            : Colors.white,
                  ),
                  child: Text(widget.quiz.options[index]),
                ),
              ),
            ),
          ),
        ),
        
        // 提出ボタン / 解説表示
        if (isCorrect == null)
          ElevatedButton(
            onPressed: selectedIndex != null ? submitAnswer : null,
            child: Text('提出する'),
          )
        else
          Column(
            children: [
              Container(
                margin: EdgeInsets.all(16),
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isCorrect! ? '✅ 正解！' : '❌ 不正解',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isCorrect! ? Colors.green : Colors.red,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      widget.quiz.explanation,
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ],
          ),
      ],
    );
  }
}
```

---

## 📅 Firebase Remote Config データセット（初期30日分）

```json
[
  {
    "date": "2026-06-27",
    "question": "今日6月27日は？",
    "options": ["憲法記念日", "七夕", "お正月", "敬老の日"],
    "correct_index": 2,
    "explanation": "憲法記念日は5月3日です。今日は特別な日ではありませんが...",
    "category": "event"
  },
  {
    "date": "2026-06-28",
    "question": "日本の世界遺産は全部でいくつ？",
    "options": ["20件", "26件", "35件", "50件"],
    "correct_index": 1,
    "explanation": "2024年時点で日本には26件の世界遺産があります。文化遺産21件、自然遺産5件です。",
    "category": "geography"
  },
  {
    "date": "2026-07-07",
    "question": "七夕は何月何日？",
    "options": ["6月7日", "7月7日", "8月7日", "9月7日"],
    "correct_index": 1,
    "explanation": "七夕は毎年7月7日に祝われる日本の伝統行事です。織姫と彦星の伝説に由来します。",
    "category": "event"
  },
  // ... 30日分
]
```

---

## 🔔 Firebase Messaging 通知設定

```dart
// firebase_messaging_service.dart
class DailyQuizNotification {
  static Future<void> scheduleDailyNotification() async {
    final messaging = FirebaseMessaging.instance;
    
    // 毎日朝8時に通知
    // ※ 実装: Firebase Cloud Functions で Cloud Scheduler 使用
    
    await messaging.requestPermission();
  }
}
```

**Cloud Functions (Node.js):**
```javascript
// functions/scheduleDailyQuiz.js
const functions = require('firebase-functions');
const admin = require('firebase-admin');

exports.scheduleDailyQuiz = functions.pubsub
  .schedule('every day 08:00')  // Asia/Tokyo
  .timeZone('Asia/Tokyo')
  .onRun(async (context) => {
    const today = new Date().toISOString().split('T')[0];
    const remoteConfig = await admin.remoteConfig().getTemplate();
    
    // Remote Config を今日のクイズに更新
    const updatedConfig = {
      ...remoteConfig,
      parameters: {
        ...remoteConfig.parameters,
        daily_quiz: {
          defaultValue: {
            value: JSON.stringify({
              date: today,
              enabled: true
            })
          }
        }
      }
    };
    
    await admin.remoteConfig().publishTemplate(updatedConfig);
    
    // 全ユーザーに通知
    await admin.messaging().sendMulticast({
      notification: {
        title: '今日のクイズが出題されました！',
        body: 'ボーナスポイント +50をゲットしましょう'
      },
      data: {
        type: 'daily_quiz',
        deeplink: 'app://daily-quiz'
      },
      tokens: [...] // 登録済みユーザー全員
    });
    
    return null;
  });
```

---

## ✅ 実装チェックリスト

- [ ] **Day 1 (4時間)**
  - [ ] `daily_quiz_model.dart` 作成
  - [ ] `daily_quiz_provider.dart` 作成（Remote Config 連携）
  - [ ] `daily_quiz_screen.dart` UI 実装
  - [ ] SharedPreferences に回答履歴保存

- [ ] **Day 2 (3時間)**
  - [ ] Firebase Remote Config を Console で 30日分設定
  - [ ] Firebase Messaging 権限要求 実装
  - [ ] Cloud Functions 作成（毎日8時配信）
  - [ ] ホーム画面に「今日のクイズ」タブ追加
  - [ ] テスト・デバッグ

- [ ] **Day 3 (1時間)**
  - [ ] APK ビルド＆テスト
  - [ ] ストア更新

---

## 🎯 期待効果

- **毎日開く理由作成** → DAU +30%
- **習慣化** → 継続率 +25%
- **ボーナスポイント** → ユーザー満足度 UP
- **年中行事連動** → 学習と現実のリンク

