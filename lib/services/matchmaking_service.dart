import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/matchmaking_entry.dart';
import '../models/player_stats.dart';
import '../models/match.dart';

class MatchmakingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const double _ratingRange = 300.0;
  static const Duration _searchTimeout = Duration(seconds: 30);

  // ── キュー操作 ──────────────────────────────────────────

  /// マッチングキューに参加
  Future<void> joinQueue(PlayerStats player) async {
    final entry = MatchmakingEntry(
      userId: player.userId,
      userName: player.userName,
      userEmoji: player.userEmoji,
      ratingScore: player.ratingScore,
      joinedAt: DateTime.now(),
      status: 'waiting',
    );

    await _firestore
        .collection('matchmaking_queue')
        .doc(player.userId)
        .set(entry.toJson());
  }

  /// マッチングキューから離脱
  Future<void> leaveQueue(String userId) async {
    await _firestore
        .collection('matchmaking_queue')
        .doc(userId)
        .delete();
  }

  /// キュー内で相手を検索（レート±300の範囲）
  Future<MatchmakingEntry?> findOpponent({
    required String myUserId,
    required double myRating,
  }) async {
    final lower = myRating - _ratingRange;
    final upper = myRating + _ratingRange;

    final snapshot = await _firestore
        .collection('matchmaking_queue')
        .where('status', isEqualTo: 'waiting')
        .where('ratingScore', isGreaterThanOrEqualTo: lower)
        .where('ratingScore', isLessThanOrEqualTo: upper)
        .orderBy('ratingScore')
        .orderBy('joinedAt')
        .limit(10)
        .get();

    final candidates = snapshot.docs
        .map((d) => MatchmakingEntry.fromJson(d.data()))
        .where((e) => e.userId != myUserId)
        .toList();

    if (candidates.isEmpty) return null;

    // レートが最も近い相手を選ぶ
    candidates.sort((a, b) =>
        (a.ratingScore - myRating).abs().compareTo(
            (b.ratingScore - myRating).abs()));

    return candidates.first;
  }

  /// マッチング確定（Firestoreトランザクション）
  Future<String?> confirmMatch({
    required MatchmakingEntry player1Entry,
    required MatchmakingEntry player2Entry,
  }) async {
    String? matchId;

    await _firestore.runTransaction((tx) async {
      // 両者がまだ'waiting'か確認
      final p1Doc = await tx.get(
        _firestore.collection('matchmaking_queue').doc(player1Entry.userId),
      );
      final p2Doc = await tx.get(
        _firestore.collection('matchmaking_queue').doc(player2Entry.userId),
      );

      if (!p1Doc.exists || !p2Doc.exists) return;

      final p1Status = p1Doc.data()?['status'] as String?;
      final p2Status = p2Doc.data()?['status'] as String?;

      if (p1Status != 'waiting' || p2Status != 'waiting') return;

      // マッチ作成
      final matchRef = _firestore.collection('matches').doc();
      matchId = matchRef.id;

      final match = Match(
        id: matchRef.id,
        player1Id: player1Entry.userId,
        player2Id: player2Entry.userId,
        player1Score: 0,
        player2Score: 0,
        totalQuestions: 10,
        createdAt: DateTime.now(),
        status: 'ongoing',
      );

      tx.set(matchRef, match.toJson());

      // 両者をキューから'matched'状態に更新
      tx.update(
        _firestore.collection('matchmaking_queue').doc(player1Entry.userId),
        {'status': 'matched', 'matchId': matchRef.id},
      );
      tx.update(
        _firestore.collection('matchmaking_queue').doc(player2Entry.userId),
        {'status': 'matched', 'matchId': matchRef.id},
      );
    });

    return matchId;
  }

  /// 自分のキューエントリをリアルタイム監視（マッチング確定を待つ）
  Stream<MatchmakingEntry?> watchMyEntry(String userId) {
    return _firestore
        .collection('matchmaking_queue')
        .doc(userId)
        .snapshots()
        .map((doc) =>
            doc.exists ? MatchmakingEntry.fromJson(doc.data()!) : null);
  }

  // ── プレイヤー統計 ──────────────────────────────────────

  /// プレイヤー統計を取得（なければ初期値）
  Future<PlayerStats> getOrCreateStats({
    required String userId,
    required String userName,
    required String userEmoji,
  }) async {
    final doc =
        await _firestore.collection('player_stats').doc(userId).get();

    if (doc.exists) {
      return PlayerStats.fromJson(doc.data()!);
    }

    final stats = PlayerStats.initial(
      userId: userId,
      userName: userName,
      userEmoji: userEmoji,
    );

    await _firestore
        .collection('player_stats')
        .doc(userId)
        .set(stats.toJson());

    return stats;
  }

  /// 試合結果でレーティング更新
  Future<void> updateRatingAfterMatch({
    required String winnerId,
    required String loserId,
    required String matchId,
    bool isDraw = false,
  }) async {
    await _firestore.runTransaction((tx) async {
      final winnerDoc =
          await tx.get(_firestore.collection('player_stats').doc(winnerId));
      final loserDoc =
          await tx.get(_firestore.collection('player_stats').doc(loserId));

      if (!winnerDoc.exists || !loserDoc.exists) return;

      final winnerStats = PlayerStats.fromJson(winnerDoc.data()!);
      final loserStats = PlayerStats.fromJson(loserDoc.data()!);

      final newWinnerRating = isDraw
          ? winnerStats.ratingScore
          : winnerStats.calcNewRating(
              isWin: true, opponentRating: loserStats.ratingScore);
      final newLoserRating = isDraw
          ? loserStats.ratingScore
          : loserStats.calcNewRating(
              isWin: false, opponentRating: winnerStats.ratingScore);

      tx.update(_firestore.collection('player_stats').doc(winnerId), {
        'ratingScore': newWinnerRating,
        'matchCount': winnerStats.matchCount + 1,
        'matchWins': isDraw ? winnerStats.matchWins : winnerStats.matchWins + 1,
        'lastMatchAt': DateTime.now().toIso8601String(),
      });

      tx.update(_firestore.collection('player_stats').doc(loserId), {
        'ratingScore': newLoserRating,
        'matchCount': loserStats.matchCount + 1,
        'matchLosses':
            isDraw ? loserStats.matchLosses : loserStats.matchLosses + 1,
        'lastMatchAt': DateTime.now().toIso8601String(),
      });
    });
  }
}
