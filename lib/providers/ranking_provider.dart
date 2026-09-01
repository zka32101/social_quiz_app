import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/ranking_entry_model.dart';
import '../models/user_stats_model.dart';

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
    final entry = RankingEntry.fromFirestore(snapshot.docs[i], i + 1);

    // Fetch user's isNamePublic preference
    try {
      final userDoc = await firestore.collection('users').doc(entry.userId).get();
      final isNamePublic = (userDoc.data()?['isNamePublic'] as bool?) ?? false;
      entries.add(entry.copyWith(isNamePublic: isNamePublic));
    } catch (_) {
      // If fetch fails, keep the default from Firestore
      entries.add(entry);
    }
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
    final entry = RankingEntry.fromFirestore(snapshot.docs[i], i + 1);

    // Fetch user's isNamePublic preference
    try {
      final userDoc = await firestore.collection('users').doc(entry.userId).get();
      final isNamePublic = (userDoc.data()?['isNamePublic'] as bool?) ?? false;
      entries.add(entry.copyWith(isNamePublic: isNamePublic));
    } catch (_) {
      // If fetch fails, keep the default from Firestore
      entries.add(entry);
    }
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

  final count = snapshot.count ?? 0;
  return count + 1;
});
