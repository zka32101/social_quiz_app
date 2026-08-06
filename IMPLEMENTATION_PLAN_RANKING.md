# ランキング機能 — 実装計画

**実装期間**: 3-4日  
**優先度**: 🔴 HIGH  
**依存**: Firebase Cloud Firestore  
**開始日**: 2026-06-29（ニュースクイズ完了後）

---

## 📋 機能概要

ユーザーのスコアを Firestore にリアルタイム保存し、「全国ランキング」「週間ランキング」「フレンドランキング」を表示。競争心を刺激してユーザー再訪問率 +40% を実現。

```
[クイズ完了] 
    ↓
[スコア Firestore に自動保存]
    ↓
[ホーム画面「ランキング」タブ表示]
    ↓
[ユーザーの順位・全国順位を表示]
    ↓
[「全国○位！」で達成感 → 再プレイ動機付け]
```

---

## 🏗️ Firestore スキーマ

### **Collection: `/users/{userId}`**

```json
{
  "userId": "user_12345",
  "displayName": "太郎",
  "profileImageUrl": "...",
  "createdAt": "2026-06-27T10:00:00Z",
  "lastPlayedAt": "2026-06-27T14:30:00Z",
  
  // リアルタイム統計
  "stats": {
    "totalScore": 4250,           // 全クイズの合計スコア
    "totalCorrect": 185,          // 全正解問題数
    "totalPlayed": 300,           // プレイ問題数
    "correctRate": 0.617,         // 正解率
    "longestStreak": 12,          // 最長連続学習日数
    "currentStreak": 3,           // 現在の連続学習日数
    "badgeCount": 18,             // 獲得バッジ数
    "bonusPointsEarned": 350,     // 累計ボーナスポイント
    "dailyQuizPlayed": 15         // 今日のクイズプレイ数
  },
  
  // ランキング用フラット化フィールド
  "rankingMetrics": {
    "globalRank": 1247,           // 全体順位（クエリ用）
    "weeklyRank": 89,             // 週間順位（クエリ用）
    "monthlyRank": 342,           // 月間順位（クエリ用）
  }
}
```

### **Collection: `/leaderboards/global/entries`**

```json
{
  "userId": "user_12345",
  "displayName": "太郎",
  "profileImageUrl": "...",
  "totalScore": 4250,
  "totalCorrect": 185,
  "correctRate": 0.617,
  "badgeCount": 18,
  "updatedAt": "2026-06-27T14:35:00Z",
  "timestamp": 4250              // ソート用（totalScore と同値）
}

// インデックス設定
// Query: where("active", "==", true)
//        orderBy("timestamp", "descending")
//        limit(100)
```

### **Collection: `/leaderboards/weekly/entries`**

```json
{
  // globalと同じスキーマ
  // ただし、週単位でリセット（毎週日曜 00:00）
  "weekStartDate": "2026-06-22",
  "weekEndDate": "2026-06-29"
}
```

### **Collection: `/leaderboards/friends/{userId}/entries`**

```json
{
  // フレンドのランキング表示用
  "friendId": "user_54321",
  "displayName": "花子",
  "profileImageUrl": "...",
  "totalScore": 3100,
  "isFriend": true,
  "lastPlayedAt": "2026-06-27T12:00:00Z"
}
```

---

## 🎯 実装ファイル構成

```
lib/
  ├── models/
  │   ├── ranking_entry_model.dart       ← 新規
  │   └── user_stats_model.dart          ← 新規
  ├── providers/
  │   ├── ranking_provider.dart          ← 新規
  │   └── user_stats_provider.dart       ← 新規
  ├── screens/
  │   └── ranking_screen.dart            ← 新規
  └── services/
      └── ranking_service.dart           ← 新規
```

---

## 💾 Dart 実装

### **ranking_entry_model.dart**

```dart
class RankingEntry {
  final String userId;
  final String displayName;
  final String? profileImageUrl;
  final int totalScore;
  final int totalCorrect;
  final int totalPlayed;
  final double correctRate;
  final int badgeCount;
  final int rank;                    // 順位（1位、2位...）
  final DateTime updatedAt;

  RankingEntry({
    required this.userId,
    required this.displayName,
    this.profileImageUrl,
    required this.totalScore,
    required this.totalCorrect,
    required this.totalPlayed,
    required this.correctRate,
    required this.badgeCount,
    required this.rank,
    required this.updatedAt,
  });

  factory RankingEntry.fromFirestore(
    DocumentSnapshot doc,
    int rank,
  ) {
    final data = doc.data() as Map<String, dynamic>;
    return RankingEntry(
      userId: doc.id,
      displayName: data['displayName'] as String? ?? '名無しさん',
      profileImageUrl: data['profileImageUrl'] as String?,
      totalScore: data['totalScore'] as int? ?? 0,
      totalCorrect: data['totalCorrect'] as int? ?? 0,
      totalPlayed: data['totalPlayed'] as int? ?? 0,
      correctRate: data['correctRate'] as double? ?? 0.0,
      badgeCount: data['badgeCount'] as int? ?? 0,
      rank: rank,
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}

class RankingType {
  static const String global = 'global';
  static const String weekly = 'weekly';
  static const String friends = 'friends';
}
```

### **user_stats_model.dart**

```dart
class UserStats {
  final String userId;
  final int totalScore;
  final int totalCorrect;
  final int totalPlayed;
  final double correctRate;
  final int longestStreak;
  final int currentStreak;
  final int badgeCount;
  final int bonusPointsEarned;
  final DateTime lastPlayedAt;

  UserStats({
    required this.userId,
    required this.totalScore,
    required this.totalCorrect,
    required this.totalPlayed,
    required this.correctRate,
    required this.longestStreak,
    required this.currentStreak,
    required this.badgeCount,
    required this.bonusPointsEarned,
    required this.lastPlayedAt,
  });

  factory UserStats.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final stats = data['stats'] as Map<String, dynamic>? ?? {};
    return UserStats(
      userId: doc.id,
      totalScore: stats['totalScore'] as int? ?? 0,
      totalCorrect: stats['totalCorrect'] as int? ?? 0,
      totalPlayed: stats['totalPlayed'] as int? ?? 0,
      correctRate: stats['correctRate'] as double? ?? 0.0,
      longestStreak: stats['longestStreak'] as int? ?? 0,
      currentStreak: stats['currentStreak'] as int? ?? 0,
      badgeCount: stats['badgeCount'] as int? ?? 0,
      bonusPointsEarned: stats['bonusPointsEarned'] as int? ?? 0,
      lastPlayedAt: (data['lastPlayedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'stats': {
      'totalScore': totalScore,
      'totalCorrect': totalCorrect,
      'totalPlayed': totalPlayed,
      'correctRate': correctRate,
      'longestStreak': longestStreak,
      'currentStreak': currentStreak,
      'badgeCount': badgeCount,
      'bonusPointsEarned': bonusPointsEarned,
    },
    'lastPlayedAt': Timestamp.fromDate(lastPlayedAt),
    'updatedAt': FieldValue.serverTimestamp(),
  };
}
```

### **ranking_provider.dart**

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final rankingTypeProvider = StateProvider<String>((ref) => 'global');

final globalRankingProvider = FutureProvider<List<RankingEntry>>((ref) async {
  final firestore = FirebaseFirestore.instance;
  
  final snapshot = await firestore
      .collection('leaderboards/global/entries')
      .orderBy('totalScore', descending: true)
      .limit(100)
      .get();
  
  final entries = <RankingEntry>[];
  for (var i = 0; i < snapshot.docs.length; i++) {
    entries.add(
      RankingEntry.fromFirestore(snapshot.docs[i], i + 1),
    );
  }
  
  return entries;
});

final weeklyRankingProvider = FutureProvider<List<RankingEntry>>((ref) async {
  final firestore = FirebaseFirestore.instance;
  
  final snapshot = await firestore
      .collection('leaderboards/weekly/entries')
      .orderBy('totalScore', descending: true)
      .limit(100)
      .get();
  
  final entries = <RankingEntry>[];
  for (var i = 0; i < snapshot.docs.length; i++) {
    entries.add(
      RankingEntry.fromFirestore(snapshot.docs[i], i + 1),
    );
  }
  
  return entries;
});

final currentUserStatsProvider = FutureProvider<UserStats?>((ref) async {
  final auth = FirebaseAuth.instance;
  final firestore = FirebaseFirestore.instance;
  
  final userId = auth.currentUser?.uid;
  if (userId == null) return null;
  
  final doc = await firestore.collection('users').doc(userId).get();
  if (!doc.exists) return null;
  
  return UserStats.fromFirestore(doc);
});

final currentUserRankProvider = FutureProvider<int?>((ref) async {
  final stats = await ref.watch(currentUserStatsProvider.future);
  if (stats == null) return null;
  
  final firestore = FirebaseFirestore.instance;
  
  final snapshot = await firestore
      .collection('leaderboards/global/entries')
      .where('totalScore', isGreaterThan: stats.totalScore)
      .count()
      .get();
  
  return snapshot.count + 1;  // 0-indexed を 1-indexed に
});
```

### **ranking_screen.dart**

```dart
class RankingScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rankingType = ref.watch(rankingTypeProvider);
    
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          // タブバー
          TabBar(
            tabs: [
              Tab(text: '全国ランキング'),
              Tab(text: '週間ランキング'),
            ],
            onTap: (index) {
              ref.read(rankingTypeProvider.notifier).state = 
                  index == 0 ? 'global' : 'weekly';
            },
          ),
          
          // タブコンテンツ
          Expanded(
            child: TabBarView(
              children: [
                RankingListView(rankingType: 'global'),
                RankingListView(rankingType: 'weekly'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class RankingListView extends ConsumerWidget {
  final String rankingType;
  
  const RankingListView({required this.rankingType});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rankingAsync = rankingType == 'global'
        ? ref.watch(globalRankingProvider)
        : ref.watch(weeklyRankingProvider);
    
    final currentStatsAsync = ref.watch(currentUserStatsProvider);
    
    return rankingAsync.when(
      data: (entries) => Column(
        children: [
          // ユーザーの現在順位
          currentStatsAsync.when(
            data: (stats) => stats != null
                ? CurrentUserRankCard(stats: stats)
                : SizedBox.shrink(),
            loading: () => SizedBox.shrink(),
            error: (_, __) => SizedBox.shrink(),
          ),
          
          // ランキングリスト
          Expanded(
            child: ListView.builder(
              itemCount: entries.length,
              itemBuilder: (context, index) {
                final entry = entries[index];
                return RankingListTile(
                  entry: entry,
                  isCurrentUser: false,
                );
              },
            ),
          ),
        ],
      ),
      loading: () => Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(
        child: Text('ランキングを読み込めません'),
      ),
    );
  }
}

class CurrentUserRankCard extends StatelessWidget {
  final UserStats stats;
  
  const CurrentUserRankCard({required this.stats});
  
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        border: Border.all(color: Colors.blue),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            'あなたの順位',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          SizedBox(height: 8),
          Text(
            '${stats.totalScore} 点',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.blue,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _StatItem(label: '正解', value: '${stats.totalCorrect}'),
              _StatItem(label: '正解率', value: '${(stats.correctRate * 100).toStringAsFixed(1)}%'),
              _StatItem(label: 'バッジ', value: '${stats.badgeCount}'),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  
  const _StatItem({required this.label, required this.value});
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey)),
        SizedBox(height: 4),
        Text(value, style: TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }
}

class RankingListTile extends StatelessWidget {
  final RankingEntry entry;
  final bool isCurrentUser;
  
  const RankingListTile({
    required this.entry,
    required this.isCurrentUser,
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isCurrentUser ? Colors.blue.shade50 : Colors.white,
        border: Border.all(
          color: isCurrentUser ? Colors.blue : Colors.grey.shade200,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          // 順位アイコン
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _getRankColor(entry.rank),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '${entry.rank}',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          SizedBox(width: 12),
          
          // 名前 + スコア
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.displayName,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  '${entry.totalCorrect}問正解 (${(entry.correctRate * 100).toStringAsFixed(1)}%)',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          
          // スコア表示
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${entry.totalScore}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                'バッジ: ${entry.badgeCount}',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Color _getRankColor(int rank) {
    if (rank == 1) return Colors.amber;
    if (rank == 2) return Colors.grey.shade400;
    if (rank == 3) return Colors.orange.shade600;
    return Colors.blue;
  }
}
```

### **ranking_service.dart**

```dart
class RankingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  /// クイズ完了後にユーザースタッツを更新
  Future<void> updateUserStats({
    required int pointsEarned,
    required bool isCorrect,
    required String categoryId,
  }) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;
    
    final userRef = _firestore.collection('users').doc(userId);
    
    await userRef.update({
      'stats.totalScore': FieldValue.increment(pointsEarned),
      'stats.totalCorrect': FieldValue.increment(isCorrect ? 1 : 0),
      'stats.totalPlayed': FieldValue.increment(1),
      'lastPlayedAt': FieldValue.serverTimestamp(),
    });
    
    // 正解率を再計算して保存
    await _updateCorrectRate(userId);
    
    // ランキング用エントリを作成/更新
    await _updateRankingEntry(userId);
  }
  
  Future<void> _updateCorrectRate(String userId) async {
    final userDoc = await _firestore.collection('users').doc(userId).get();
    final data = userDoc.data() as Map<String, dynamic>;
    final stats = data['stats'] as Map<String, dynamic>;
    
    final totalCorrect = stats['totalCorrect'] as int? ?? 0;
    final totalPlayed = stats['totalPlayed'] as int? ?? 0;
    
    final correctRate = totalPlayed > 0 ? totalCorrect / totalPlayed : 0.0;
    
    await _firestore.collection('users').doc(userId).update({
      'stats.correctRate': correctRate,
    });
  }
  
  Future<void> _updateRankingEntry(String userId) async {
    final userDoc = await _firestore.collection('users').doc(userId).get();
    if (!userDoc.exists) return;
    
    final data = userDoc.data() as Map<String, dynamic>;
    final displayName = data['displayName'] as String? ?? '名無しさん';
    final stats = data['stats'] as Map<String, dynamic>;
    
    final entry = {
      'userId': userId,
      'displayName': displayName,
      'profileImageUrl': data['profileImageUrl'],
      'totalScore': stats['totalScore'] ?? 0,
      'totalCorrect': stats['totalCorrect'] ?? 0,
      'totalPlayed': stats['totalPlayed'] ?? 0,
      'correctRate': stats['correctRate'] ?? 0.0,
      'badgeCount': data['badgeCount'] ?? 0,
      'updatedAt': FieldValue.serverTimestamp(),
    };
    
    // グローバルランキングに追加/更新
    await _firestore
        .collection('leaderboards/global/entries')
        .doc(userId)
        .set(entry, SetOptions(merge: true));
    
    // 週間ランキングにも追加/更新
    await _firestore
        .collection('leaderboards/weekly/entries')
        .doc(userId)
        .set(entry, SetOptions(merge: true));
  }
  
  /// 週間ランキングをリセット（毎週日曜0時に実行）
  Future<void> resetWeeklyRanking() async {
    final batch = _firestore.batch();
    
    final snapshot = await _firestore
        .collection('leaderboards/weekly/entries')
        .get();
    
    for (var doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    
    await batch.commit();
  }
}
```

---

## ✅ 実装チェックリスト

- [ ] **Day 1 (4時間)**
  - [ ] Firestore スキーマ設計・コレクション作成
  - [ ] `ranking_entry_model.dart` / `user_stats_model.dart` 実装
  - [ ] `ranking_provider.dart` 実装（Firestore クエリ）
  - [ ] インデックス作成（Firestore）

- [ ] **Day 2 (4時間)**
  - [ ] `ranking_screen.dart` UI 実装（2つのタブ）
  - [ ] `ranking_service.dart` 実装（更新ロジック）
  - [ ] クイズ完了時に `updateUserStats()` 呼び出し

- [ ] **Day 3 (3時間)**
  - [ ] Cloud Functions 実装（週間リセット）
  - [ ] ホーム画面に「ランキング」タブ追加
  - [ ] テスト・デバッグ
  - [ ] APK ビルド

---

## 🎯 期待効果

- **競争心刺激** → 再訪問率 +40%
- **達成感の可視化** → ユーザー満足度 UP
- **「全国○位」表示** → SNS シェア動機付け
- **週間リセット** → 毎週新たな競争開始

