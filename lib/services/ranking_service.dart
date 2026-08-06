import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RankingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// クイズ完了後にユーザースタッツを更新
  ///
  /// リーダーボード（leaderboards/*/entries）への反映は Cloud Functions
  /// (updateRankingMetadata) が users/{userId} の変更を検知して行う。
  /// クライアントは users ドキュメントのみを更新する（二重書き込み防止・改ざん防止）。
  ///
  /// トランザクションで読み取り→加算を行うため、ドキュメント未作成でも
  /// エラーにならず自動的に作成される。不正解時は pointsEarned を加算しない。
  Future<void> updateUserStats({
    required int pointsEarned,
    required bool isCorrect,
    required String categoryId,
  }) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    final userRef = _firestore.collection('users').doc(userId);

    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(userRef);
      final data = snapshot.data();
      final stats = (data?['stats'] as Map<String, dynamic>?) ?? {};

      final totalScore =
          (stats['totalScore'] as int? ?? 0) + (isCorrect ? pointsEarned : 0);
      final totalCorrect =
          (stats['totalCorrect'] as int? ?? 0) + (isCorrect ? 1 : 0);
      final totalPlayed = (stats['totalPlayed'] as int? ?? 0) + 1;
      final correctRate = totalPlayed > 0 ? totalCorrect / totalPlayed : 0.0;

      transaction.set(
        userRef,
        {
          'stats': {
            'totalScore': totalScore,
            'totalCorrect': totalCorrect,
            'totalPlayed': totalPlayed,
            'correctRate': correctRate,
          },
          'lastPlayedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
    });
  }
}
