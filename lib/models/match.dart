class Match {
  final String id;
  final String player1Id;
  final String player2Id;
  final int player1Score;
  final int player2Score;
  final int totalQuestions;
  final DateTime createdAt;
  final DateTime? completedAt;
  final String status;

  Match({
    required this.id,
    required this.player1Id,
    required this.player2Id,
    required this.player1Score,
    required this.player2Score,
    required this.totalQuestions,
    required this.createdAt,
    this.completedAt,
    required this.status,
  });

  bool get isCompleted => status == 'completed';
  bool get isOngoing => status == 'ongoing';
  String get winner {
    if (!isCompleted) return '';
    if (player1Score > player2Score) return player1Id;
    if (player2Score > player1Score) return player2Id;
    return 'draw';
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'player1Id': player1Id,
    'player2Id': player2Id,
    'player1Score': player1Score,
    'player2Score': player2Score,
    'totalQuestions': totalQuestions,
    'createdAt': createdAt.toIso8601String(),
    'completedAt': completedAt?.toIso8601String(),
    'status': status,
  };

  factory Match.fromJson(Map<String, dynamic> json) => Match(
    id: json['id'] as String,
    player1Id: json['player1Id'] as String,
    player2Id: json['player2Id'] as String,
    player1Score: json['player1Score'] as int? ?? 0,
    player2Score: json['player2Score'] as int? ?? 0,
    totalQuestions: json['totalQuestions'] as int? ?? 10,
    createdAt: DateTime.parse(json['createdAt'] as String),
    completedAt: json['completedAt'] != null
        ? DateTime.parse(json['completedAt'] as String)
        : null,
    status: json['status'] as String? ?? 'ongoing',
  );
}
