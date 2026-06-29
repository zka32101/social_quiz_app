import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/matchmaking_entry.dart';
import '../models/player_stats.dart';
import '../services/matchmaking_service.dart';

// ── サービス ────────────────────────────────────────────

final matchmakingServiceProvider =
    Provider((ref) => MatchmakingService());

// ── マッチング状態 ──────────────────────────────────────

enum MatchmakingStatus { idle, searching, matched, error }

class MatchmakingState {
  final MatchmakingStatus status;
  final String? matchId;
  final MatchmakingEntry? opponentEntry;
  final String? errorMessage;

  const MatchmakingState({
    this.status = MatchmakingStatus.idle,
    this.matchId,
    this.opponentEntry,
    this.errorMessage,
  });

  MatchmakingState copyWith({
    MatchmakingStatus? status,
    String? matchId,
    MatchmakingEntry? opponentEntry,
    String? errorMessage,
  }) =>
      MatchmakingState(
        status: status ?? this.status,
        matchId: matchId ?? this.matchId,
        opponentEntry: opponentEntry ?? this.opponentEntry,
        errorMessage: errorMessage ?? this.errorMessage,
      );
}

final matchmakingProvider =
    StateNotifierProvider<MatchmakingNotifier, MatchmakingState>((ref) {
  return MatchmakingNotifier(ref.watch(matchmakingServiceProvider));
});

class MatchmakingNotifier extends StateNotifier<MatchmakingState> {
  final MatchmakingService _service;
  StreamSubscription<MatchmakingEntry?>? _queueSub;
  Timer? _searchTimer;

  MatchmakingNotifier(this._service)
      : super(const MatchmakingState());

  /// マッチング開始
  Future<void> startSearching(PlayerStats playerStats) async {
    if (state.status == MatchmakingStatus.searching) return;

    state = state.copyWith(status: MatchmakingStatus.searching);

    try {
      await _service.joinQueue(playerStats);

      // 先に相手を探してみる
      final opponent = await _service.findOpponent(
        myUserId: playerStats.userId,
        myRating: playerStats.ratingScore,
      );

      if (opponent != null) {
        // 自分がイニシエーターとしてマッチを確定
        final myEntry = MatchmakingEntry(
          userId: playerStats.userId,
          userName: playerStats.userName,
          userEmoji: playerStats.userEmoji,
          ratingScore: playerStats.ratingScore,
          joinedAt: DateTime.now(),
          status: 'waiting',
        );

        final matchId = await _service.confirmMatch(
          player1Entry: myEntry,
          player2Entry: opponent,
        );

        if (matchId != null && mounted) {
          state = state.copyWith(
            status: MatchmakingStatus.matched,
            matchId: matchId,
            opponentEntry: opponent,
          );
          return;
        }
      }

      // 相手が見つからなければ、相手からのマッチング確定を待つ
      _listenForMatch(playerStats.userId);

      // タイムアウト（30秒）で再検索またはエラー
      _searchTimer = Timer(const Duration(seconds: 30), () async {
        if (state.status == MatchmakingStatus.searching) {
          // 範囲を広げて再検索
          final widerOpponent = await _service.findOpponent(
            myUserId: playerStats.userId,
            myRating: playerStats.ratingScore,
          );

          if (widerOpponent != null && mounted) {
            final myEntry = MatchmakingEntry(
              userId: playerStats.userId,
              userName: playerStats.userName,
              userEmoji: playerStats.userEmoji,
              ratingScore: playerStats.ratingScore,
              joinedAt: DateTime.now(),
              status: 'waiting',
            );

            final matchId = await _service.confirmMatch(
              player1Entry: myEntry,
              player2Entry: widerOpponent,
            );

            if (matchId != null && mounted) {
              state = state.copyWith(
                status: MatchmakingStatus.matched,
                matchId: matchId,
                opponentEntry: widerOpponent,
              );
            }
          } else if (mounted) {
            state = state.copyWith(
              status: MatchmakingStatus.error,
              errorMessage: '対戦相手が見つかりませんでした。もう一度お試しください。',
            );
            await _service.leaveQueue(playerStats.userId);
          }
        }
      });
    } catch (e) {
      if (mounted) {
        state = state.copyWith(
          status: MatchmakingStatus.error,
          errorMessage: 'マッチング中にエラーが発生しました: $e',
        );
      }
    }
  }

  /// 自分のキューエントリを監視して、相手から確定されたマッチを検知する
  void _listenForMatch(String userId) {
    _queueSub?.cancel();
    _queueSub = _service.watchMyEntry(userId).listen((entry) {
      if (entry == null) return;

      if (entry.isMatched && entry.matchId != null && mounted) {
        _searchTimer?.cancel();
        state = state.copyWith(
          status: MatchmakingStatus.matched,
          matchId: entry.matchId,
        );
      }
    });
  }

  /// マッチングキャンセル
  Future<void> cancelSearch(String userId) async {
    _searchTimer?.cancel();
    _queueSub?.cancel();

    await _service.leaveQueue(userId);

    if (mounted) {
      state = const MatchmakingState();
    }
  }

  /// 状態をリセット
  void reset() {
    _searchTimer?.cancel();
    _queueSub?.cancel();
    state = const MatchmakingState();
  }

  @override
  void dispose() {
    _searchTimer?.cancel();
    _queueSub?.cancel();
    super.dispose();
  }
}

// ── プレイヤー統計 ──────────────────────────────────────

final playerStatsProvider =
    FutureProvider.family<PlayerStats, Map<String, String>>((ref, args) async {
  final service = ref.watch(matchmakingServiceProvider);
  return service.getOrCreateStats(
    userId: args['userId']!,
    userName: args['userName']!,
    userEmoji: args['userEmoji']!,
  );
});
