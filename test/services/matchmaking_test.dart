import 'package:flutter_test/flutter_test.dart';
import 'package:social_quiz_app/models/player_stats.dart';
import 'package:social_quiz_app/models/matchmaking_entry.dart';

void main() {
  group('PlayerStats', () {
    test('初期レートは1500', () {
      final stats = PlayerStats.initial(
        userId: 'u1',
        userName: 'テストくん',
        userEmoji: '🦊',
      );
      expect(stats.ratingScore, 1500.0);
      expect(stats.matchCount, 0);
      expect(stats.winRate, 0.0);
    });

    test('勝率計算', () {
      const stats = PlayerStats(
        userId: 'u1',
        userName: 'テストくん',
        userEmoji: '🦊',
        matchCount: 10,
        matchWins: 7,
        matchLosses: 3,
      );
      expect(stats.winRate, 0.7);
    });

    test('Eloレーティング — 同レート相手に勝利', () {
      const stats = PlayerStats(
        userId: 'u1',
        userName: 'テストくん',
        userEmoji: '🦊',
        ratingScore: 1500.0,
      );
      final newRating =
          stats.calcNewRating(isWin: true, opponentRating: 1500.0);
      // 同レートに勝利 → +16程度
      expect(newRating, greaterThan(1500.0));
      expect(newRating, lessThan(1520.0));
    });

    test('Eloレーティング — 格上相手に勝利', () {
      const stats = PlayerStats(
        userId: 'u1',
        userName: 'テストくん',
        userEmoji: '🦊',
        ratingScore: 1500.0,
      );
      final newRating =
          stats.calcNewRating(isWin: true, opponentRating: 1800.0);
      // 格上に勝利 → 大幅アップ
      expect(newRating, greaterThan(1520.0));
    });

    test('copyWith でレート更新', () {
      const stats = PlayerStats(
        userId: 'u1',
        userName: 'テストくん',
        userEmoji: '🦊',
        ratingScore: 1500.0,
        matchCount: 5,
        matchWins: 3,
      );
      final updated = stats.copyWith(
        ratingScore: 1525.0,
        matchCount: 6,
        matchWins: 4,
      );
      expect(updated.ratingScore, 1525.0);
      expect(updated.matchCount, 6);
      expect(updated.matchWins, 4);
      expect(updated.userId, 'u1');
    });
  });

  group('MatchmakingEntry', () {
    test('toJson / fromJson', () {
      final entry = MatchmakingEntry(
        userId: 'u1',
        userName: 'テストくん',
        userEmoji: '🦊',
        ratingScore: 1500.0,
        joinedAt: DateTime(2026, 6, 12, 10, 0),
        status: 'waiting',
      );

      final json = entry.toJson();
      final restored = MatchmakingEntry.fromJson(json);

      expect(restored.userId, entry.userId);
      expect(restored.ratingScore, entry.ratingScore);
      expect(restored.status, 'waiting');
      expect(restored.isWaiting, true);
      expect(restored.isMatched, false);
    });

    test('matched状態の判定', () {
      final entry = MatchmakingEntry(
        userId: 'u1',
        userName: 'テストくん',
        userEmoji: '🦊',
        ratingScore: 1500.0,
        joinedAt: DateTime(2026, 6, 12),
        status: 'matched',
        matchId: 'match_001',
      );
      expect(entry.isMatched, true);
      expect(entry.isWaiting, false);
      expect(entry.matchId, 'match_001');
    });
  });
}
