import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:shared_core/shared_core.dart'
//     show globalRankingProvider, GlobalRankingEntry;
import '../models/ranking_entry_model.dart';
import '../models/user_stats_model.dart';
import 'friend_provider.dart';

final rankingTypeProvider = StateProvider<String>((ref) => 'global');

/// グローバルランキング（全ユーザーのスコア順）
final globalRankingProvider = FutureProvider<List<RankingEntry>>((ref) async {
  final firestore = FirebaseFirestore.instance;
  final snapshot =
      await firestore.collection('leaderboards/global/entries').get();

  final entries = snapshot.docs
      .asMap()
      .entries
      .map((e) => RankingEntry.fromFirestore(e.value, e.key + 1))
      .toList();

  entries.sort((a, b) => b.totalScore.compareTo(a.totalScore));
  return [
    for (var i = 0; i < entries.length; i++) entries[i].copyWith(rank: i + 1),
  ];
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
