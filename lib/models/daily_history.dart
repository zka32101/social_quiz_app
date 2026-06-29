enum DailyHistoryCategory {
  kinenbi,         // 記念日（公式）
  event,           // 歴史事件
  personBirthday,  // 人物誕生日
  culture,         // 文化・風習
  politics,        // 政治・制度
  disaster,        // 災害・事故（歴史的）
}

/// 日付ごとの歴史イベント
class DailyHistory {
  final String id;                     // "0610"（月日）
  final int month;                     // 6
  final int day;                       // 10
  final String eventName;              // "時の記念日"
  final String eventDescription;       // "671年、天智天皇が..."
  final int year;                      // 671
  final String historicalContext;      // 背景知識
  final int quizId;                    // 対応するクイズID
  final DailyHistoryCategory category;

  const DailyHistory({
    required this.id,
    required this.month,
    required this.day,
    required this.eventName,
    required this.eventDescription,
    required this.year,
    required this.historicalContext,
    required this.quizId,
    required this.category,
  });

  factory DailyHistory.fromJson(Map<String, dynamic> json) {
    final categoryStr = json['category'] as String? ?? 'event';
    final DailyHistoryCategory category = switch (categoryStr) {
      'kinenbi' => DailyHistoryCategory.kinenbi,
      'person_birthday' => DailyHistoryCategory.personBirthday,
      'culture' => DailyHistoryCategory.culture,
      'politics' => DailyHistoryCategory.politics,
      'disaster' => DailyHistoryCategory.disaster,
      _ => DailyHistoryCategory.event,
    };

    return DailyHistory(
      id: json['id'] as String? ?? '',
      month: json['month'] as int? ?? 1,
      day: json['day'] as int? ?? 1,
      eventName: json['eventName'] as String? ?? '',
      eventDescription: json['eventDescription'] as String? ?? '',
      year: json['year'] as int? ?? 0,
      historicalContext: json['historicalContext'] as String? ?? '',
      quizId: json['quizId'] as int? ?? 0,
      category: category,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'month': month,
        'day': day,
        'eventName': eventName,
        'eventDescription': eventDescription,
        'year': year,
        'historicalContext': historicalContext,
        'quizId': quizId,
        'category': category.toString().split('.').last,
      };

  @override
  String toString() => 'DailyHistory($id: $eventName)';
}
