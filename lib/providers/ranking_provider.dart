import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/ranking_entry_model.dart';
import '../models/user_stats_model.dart';
import 'friend_provider.dart';

final rankingTypeProvider = StateProvider<String>((ref) => 'global');

final globalRankingProvider = FutureProvider<List<RankingEntry>>((ref) async {
  final firestore = FirebaseFirestore.instance;

  final snapshot = await firestore
      .collection('leaderboards/global/entries')
      .orderBy('totalScore', descending: true)
      .limit(100)
      .get();

  // isNamePublic は Cloud Functions(updateRankingMetadata) が
  // leaderboards エントリ自体に書き込むため、ここでは追加のドキュメント
  // 取得は不要（他ユーザーの users/{userId} は読み取り不可のため、
  // 以前の実装では自分自身のエントリ以外は常にフォールバック値になっていた）。
  return [
    for (var i = 0; i < snapshot.docs.length; i++)
      RankingEntry.fromFirestore(snapshot.docs[i], i + 1),
  ];
});

final weeklyRankingProvider = FutureProvider<List<RankingEntry>>((ref) async {
  final firestore = FirebaseFirestore.instance;

  final snapshot = await firestore
      .collection('leaderboards/weekly/entries')
      .orderBy('totalScore', descending: true)
      .limit(100)
      .get();

  return [
    for (var i = 0; i < snapshot.docs.length; i++)
      RankingEntry.fromFirestore(snapshot.docs[i], i + 1),
  ];
});

/// 現在ログイン中ユーザーの学年・学習開始日（users/{uid} から取得。本人のみ読み取り可）
final currentUserGradeAndStartProvider =
    FutureProvider<({int? grade, DateTime? startedAt})>((ref) async {
  final auth = FirebaseAuth.instance;
  final firestore = FirebaseFirestore.instance;
  final userId = auth.currentUser?.uid;
  if (userId == null) return (grade: null, startedAt: null);

  final doc = await firestore.collection('users').doc(userId).get();
  final data = doc.data();
  return (
    grade: data?['grade'] as int?,
    startedAt: (data?['startedAt'] as Timestamp?)?.toDate(),
  );
});

/// 友達ランキング（自分 + 友達一覧のランキングエントリをスコア順に結合）
final friendsRankingProvider = FutureProvider<List<RankingEntry>>((ref) async {
  final auth = FirebaseAuth.instance;
  final firestore = FirebaseFirestore.instance;
  final userId = auth.currentUser?.uid;
  if (userId == null) return [];

  final friends = await ref.watch(friendsProvider.future);
  final targetIds = {userId, ...friends.map((f) => f.friendUserId)};

  final entries = <RankingEntry>[];
  for (final id in targetIds) {
    final doc =
        await firestore.collection('leaderboards/global/entries').doc(id).get();
    if (doc.exists) {
      entries.add(RankingEntry.fromFirestore(doc, 0));
    }
  }

  entries.sort((a, b) => b.totalScore.compareTo(a.totalScore));
  return [
    for (var i = 0; i < entries.length; i++) entries[i].copyWith(rank: i + 1),
  ];
});

/// 同学年ランキング
///
/// Firestore 側で grade == 自分の学年 && orderBy(totalScore) の
/// 複合インデックスが必要（初回クエリ失敗時のリンクから作成、または
/// firestore.indexes.json 参照）。
final sameGradeRankingProvider = FutureProvider<List<RankingEntry>>((ref) async {
  final firestore = FirebaseFirestore.instance;
  final meta = await ref.watch(currentUserGradeAndStartProvider.future);
  final grade = meta.grade;
  if (grade == null) return [];

  final snapshot = await firestore
      .collection('leaderboards/global/entries')
      .where('grade', isEqualTo: grade)
      .orderBy('totalScore', descending: true)
      .limit(100)
      .get();

  return [
    for (var i = 0; i < snapshot.docs.length; i++)
      RankingEntry.fromFirestore(snapshot.docs[i], i + 1),
  ];
});

/// 同学年 × 同時期（月単位）開始ランキング
///
/// grade の等価条件 + startedAt の範囲条件を同時に使うため
/// orderBy(totalScore) と組み合わせられない（Firestore の制約）。
/// 対象は「自分と同じ月に開始した同学年ユーザー」のみに絞られるため
/// 件数は多くない想定で、取得後にクライアント側でスコア順に並び替える。
final sameGradeSamePeriodRankingProvider =
    FutureProvider<List<RankingEntry>>((ref) async {
  final firestore = FirebaseFirestore.instance;
  final meta = await ref.watch(currentUserGradeAndStartProvider.future);
  final grade = meta.grade;
  final startedAt = meta.startedAt;
  if (grade == null || startedAt == null) return [];

  final monthStart = DateTime(startedAt.year, startedAt.month, 1);
  final monthEnd = DateTime(startedAt.year, startedAt.month + 1, 1);

  final snapshot = await firestore
      .collection('leaderboards/global/entries')
      .where('grade', isEqualTo: grade)
      .where('startedAt', isGreaterThanOrEqualTo: Timestamp.fromDate(monthStart))
      .where('startedAt', isLessThan: Timestamp.fromDate(monthEnd))
      .limit(200)
      .get();

  final entries = [
    for (final doc in snapshot.docs) RankingEntry.fromFirestore(doc, 0),
  ]..sort((a, b) => b.totalScore.compareTo(a.totalScore));

  return [
    for (var i = 0; i < entries.length; i++) entries[i].copyWith(rank: i + 1),
  ];
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

  final count = snapshot.count ?? 0;
  return count + 1;
});
