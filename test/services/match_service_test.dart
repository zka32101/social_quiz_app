import 'package:flutter_test/flutter_test.dart';
import 'package:social_quiz_app/models/match.dart';

void main() {
  group('Match Model', () {
    test('Match creation with default values', () {
      final match = Match(
        id: 'match_001',
        player1Id: 'user_001',
        player2Id: 'user_002',
        player1Score: 0,
        player2Score: 0,
        totalQuestions: 10,
        createdAt: DateTime(2026, 6, 12),
        status: 'ongoing',
      );

      expect(match.id, 'match_001');
      expect(match.player1Id, 'user_001');
      expect(match.player2Id, 'user_002');
      expect(match.player1Score, 0);
      expect(match.player2Score, 0);
      expect(match.isOngoing, true);
      expect(match.isCompleted, false);
    });

    test('Match toJson serialization', () {
      final match = Match(
        id: 'match_001',
        player1Id: 'user_001',
        player2Id: 'user_002',
        player1Score: 5,
        player2Score: 3,
        totalQuestions: 10,
        createdAt: DateTime(2026, 6, 12),
        status: 'completed',
      );

      final json = match.toJson();
      expect(json['id'], 'match_001');
      expect(json['player1Score'], 5);
      expect(json['status'], 'completed');
    });

    test('Match fromJson deserialization', () {
      final json = {
        'id': 'match_001',
        'player1Id': 'user_001',
        'player2Id': 'user_002',
        'player1Score': 7,
        'player2Score': 6,
        'totalQuestions': 10,
        'createdAt': '2026-06-12T10:00:00.000Z',
        'completedAt': '2026-06-12T10:15:00.000Z',
        'status': 'completed',
      };

      final match = Match.fromJson(json);
      expect(match.id, 'match_001');
      expect(match.player1Score, 7);
      expect(match.winner, 'user_001');
    });

    test('Match winner determination', () {
      final matchP1Win = Match(
        id: 'match_001',
        player1Id: 'user_001',
        player2Id: 'user_002',
        player1Score: 8,
        player2Score: 2,
        totalQuestions: 10,
        createdAt: DateTime(2026, 6, 12),
        status: 'completed',
      );

      expect(matchP1Win.winner, 'user_001');

      final matchDraw = Match(
        id: 'match_002',
        player1Id: 'user_003',
        player2Id: 'user_004',
        player1Score: 5,
        player2Score: 5,
        totalQuestions: 10,
        createdAt: DateTime(2026, 6, 12),
        status: 'completed',
      );

      expect(matchDraw.winner, 'draw');
    });
  });
}
