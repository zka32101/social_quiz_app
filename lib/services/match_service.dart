import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/match.dart';

class MatchService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// マッチ作成
  Future<String> createMatch({
    required String player1Id,
    required String player2Id,
    int totalQuestions = 10,
  }) async {
    final docRef = _firestore.collection('matches').doc();
    final match = Match(
      id: docRef.id,
      player1Id: player1Id,
      player2Id: player2Id,
      player1Score: 0,
      player2Score: 0,
      totalQuestions: totalQuestions,
      createdAt: DateTime.now(),
      status: 'ongoing',
    );

    await docRef.set(match.toJson());
    return docRef.id;
  }

  /// マッチ取得（一度だけ）
  Future<Match?> getMatch(String matchId) async {
    final doc = await _firestore.collection('matches').doc(matchId).get();
    return doc.exists ? Match.fromJson(doc.data()!) : null;
  }

  /// マッチ取得（リアルタイム）
  Stream<Match?> watchMatch(String matchId) {
    return _firestore
        .collection('matches')
        .doc(matchId)
        .snapshots()
        .map((doc) => doc.exists ? Match.fromJson(doc.data()!) : null);
  }

  /// スコア更新
  Future<void> updateScore({
    required String matchId,
    required bool isPlayer1,
    required int score,
  }) async {
    final field = isPlayer1 ? 'player1Score' : 'player2Score';
    await _firestore.collection('matches').doc(matchId).update({
      field: score,
    });
  }

  /// マッチ終了
  Future<void> completeMatch(String matchId) async {
    try {
      await _firestore.collection('matches').doc(matchId).update({
        'status': 'completed',
        'completedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('マッチ終了に失敗: $e');
    }
  }

  /// スコア同期（バッチ更新）
  Future<void> updateMatchState({
    required String matchId,
    required int player1Score,
    required int player2Score,
    required bool shouldComplete,
  }) async {
    try {
      final updates = {
        'player1Score': player1Score,
        'player2Score': player2Score,
        if (shouldComplete) ...{
          'status': 'completed',
          'completedAt': DateTime.now().toIso8601String(),
        }
      };

      await _firestore.collection('matches').doc(matchId).update(updates);
    } catch (e) {
      throw Exception('マッチ状態更新に失敗: $e');
    }
  }

  /// ユーザーの対戦履歴取得
  Future<List<Match>> getUserMatches(String userId, {int limit = 20}) async {
    final snapshot = await _firestore
        .collection('matches')
        .where('status', isEqualTo: 'completed')
        .orderBy('completedAt', descending: true)
        .limit(limit)
        .get();

    return snapshot.docs
        .map((doc) => Match.fromJson(doc.data()))
        .where((match) =>
            match.player1Id == userId || match.player2Id == userId)
        .toList();
  }

  /// ランキング取得
  Future<List<Map<String, dynamic>>> getLeaderboard({int limit = 50}) async {
    final snapshot = await _firestore
        .collection('users')
        .orderBy('ratingScore', descending: true)
        .limit(limit)
        .get();

    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  /// 進行中のマッチ取得
  Future<List<Match>> getOngoingMatches(String userId) async {
    final snapshot = await _firestore
        .collection('matches')
        .where('status', isEqualTo: 'ongoing')
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => Match.fromJson(doc.data()))
        .where((match) =>
            match.player1Id == userId || match.player2Id == userId)
        .toList();
  }
}
