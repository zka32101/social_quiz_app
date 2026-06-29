import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/match.dart';
import '../services/match_service.dart';

final matchServiceProvider = Provider((ref) => MatchService());

/// 現在進行中のマッチ状態
final currentMatchProvider =
    StateNotifierProvider<CurrentMatchNotifier, Match?>((ref) {
  return CurrentMatchNotifier(ref.watch(matchServiceProvider));
});

class CurrentMatchNotifier extends StateNotifier<Match?> {
  final MatchService _service;

  CurrentMatchNotifier(this._service) : super(null);

  /// マッチ開始
  Future<String> startMatch(String player1Id, String player2Id) async {
    final matchId = await _service.createMatch(
      player1Id: player1Id,
      player2Id: player2Id,
    );
    return matchId;
  }

  /// スコア更新（個別）
  Future<void> updateScore(String matchId, bool isPlayer1, int score) async {
    try {
      await _service.updateScore(
        matchId: matchId,
        isPlayer1: isPlayer1,
        score: score,
      );
    } catch (e) {
      // エラーログを記録（本番環境ではFirebase Crashlyticsに送信）
      print('スコア更新エラー: $e');
    }
  }

  /// スコア更新（バッチ）
  Future<void> updateMatchState({
    required String matchId,
    required int player1Score,
    required int player2Score,
    bool shouldComplete = false,
  }) async {
    try {
      await _service.updateMatchState(
        matchId: matchId,
        player1Score: player1Score,
        player2Score: player2Score,
        shouldComplete: shouldComplete,
      );
    } catch (e) {
      print('マッチ状態更新エラー: $e');
    }
  }

  /// マッチ終了
  Future<void> finishMatch(String matchId) async {
    try {
      await _service.completeMatch(matchId);
    } catch (e) {
      print('マッチ終了エラー: $e');
    }
  }

  /// マッチ状態を読み込み
  Future<void> loadMatch(String matchId) async {
    final match = await _service.getMatch(matchId);
    state = match;
  }
}

/// リアルタイムマッチ監視
final watchMatchProvider =
    StreamProvider.family<Match?, String>((ref, matchId) {
  final service = ref.watch(matchServiceProvider);
  return service.watchMatch(matchId);
});

/// ユーザーのマッチ履歴
final userMatchHistoryProvider =
    FutureProvider.family<List<Match>, String>((ref, userId) async {
  final service = ref.watch(matchServiceProvider);
  return service.getUserMatches(userId);
});

/// ランキング取得
final leaderboardProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final service = ref.watch(matchServiceProvider);
  return service.getLeaderboard();
});

/// 進行中のマッチ取得
final ongoingMatchesProvider =
    FutureProvider.family<List<Match>, String>((ref, userId) async {
  final service = ref.watch(matchServiceProvider);
  return service.getOngoingMatches(userId);
});
