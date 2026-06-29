/// ステージ難易度レベル
enum StageLevel { beginner, intermediate, advanced }

/// ステージ内の個別クエスト
class Quest {
  final String id;          // "stage1_quest1"
  final int questNo;        // 1-10 per stage
  final String title;       // "北海道の位置を学ぼう"
  final String description;
  final String type;        // "map_tap", "multiple_choice", "fill_blank"
  final int pointsReward;   // 10-50
  final String quizDataId;  // Reference to Firestore /quizData/{quizDataId}
  final bool isCompleted;
  final DateTime? completedAt;

  const Quest({
    required this.id,
    required this.questNo,
    required this.title,
    required this.description,
    required this.type,
    required this.pointsReward,
    required this.quizDataId,
    required this.isCompleted,
    this.completedAt,
  });

  factory Quest.fromJson(Map<String, dynamic> json) {
    return Quest(
      id: json['id'] as String? ?? '',
      questNo: json['questNo'] as int? ?? 1,
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      type: json['type'] as String? ?? 'multiple_choice',
      pointsReward: json['pointsReward'] as int? ?? 10,
      quizDataId: json['quizDataId'] as String? ?? '',
      isCompleted: json['isCompleted'] as bool? ?? false,
      completedAt: json['completedAt'] != null
          ? DateTime.tryParse(json['completedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'questNo': questNo,
        'title': title,
        'description': description,
        'type': type,
        'pointsReward': pointsReward,
        'quizDataId': quizDataId,
        'isCompleted': isCompleted,
        'completedAt': completedAt?.toIso8601String(),
      };

  Quest copyWith({
    bool? isCompleted,
    DateTime? completedAt,
  }) {
    return Quest(
      id: id,
      questNo: questNo,
      title: title,
      description: description,
      type: type,
      pointsReward: pointsReward,
      quizDataId: quizDataId,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}

/// 学習ステージ（1-10段階）
class Stage {
  final String id;                // "stage_1", "stage_2", ...
  final int stageNo;              // 1-10
  final String title;             // "北海道・東北地方を学ぼう"
  final String description;
  final StageLevel level;         // 難易度
  final String gradeRange;        // "1-2" or "3-4" or "5-6"
  final String prefectureRange;   // "hokkaido_tohoku"
  final List<Quest> quests;       // 5-10個のクエスト
  final int totalPoints;          // 全クエストのポイント合計
  final bool isUnlocked;          // アンロック済みか
  final bool isCompleted;
  final DateTime? unlockedAt;
  final DateTime? completedAt;

  const Stage({
    required this.id,
    required this.stageNo,
    required this.title,
    required this.description,
    required this.level,
    required this.gradeRange,
    required this.prefectureRange,
    required this.quests,
    required this.totalPoints,
    required this.isUnlocked,
    required this.isCompleted,
    this.unlockedAt,
    this.completedAt,
  });

  factory Stage.fromJson(Map<String, dynamic> json) {
    final questsList = (json['quests'] as List<dynamic>? ?? [])
        .map((q) => Quest.fromJson(q as Map<String, dynamic>))
        .toList();

    return Stage(
      id: json['id'] as String? ?? '',
      stageNo: json['stageNo'] as int? ?? 1,
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      level: _parseStageLevelString(json['level'] as String? ?? 'beginner'),
      gradeRange: json['gradeRange'] as String? ?? '1-2',
      prefectureRange: json['prefectureRange'] as String? ?? '',
      quests: questsList,
      totalPoints: json['totalPoints'] as int? ?? 0,
      isUnlocked: json['isUnlocked'] as bool? ?? false,
      isCompleted: json['isCompleted'] as bool? ?? false,
      unlockedAt: json['unlockedAt'] != null
          ? DateTime.tryParse(json['unlockedAt'] as String)
          : null,
      completedAt: json['completedAt'] != null
          ? DateTime.tryParse(json['completedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'stageNo': stageNo,
        'title': title,
        'description': description,
        'level': level.toString().split('.').last,
        'gradeRange': gradeRange,
        'prefectureRange': prefectureRange,
        'quests': quests.map((q) => q.toJson()).toList(),
        'totalPoints': totalPoints,
        'isUnlocked': isUnlocked,
        'isCompleted': isCompleted,
        'unlockedAt': unlockedAt?.toIso8601String(),
        'completedAt': completedAt?.toIso8601String(),
      };

  /// 完了したクエスト数
  int get completedQuestCount =>
      quests.where((q) => q.isCompleted).length;

  /// ステージ完了率（0.0-1.0）
  double get completionPercentage {
    if (quests.isEmpty) return 0.0;
    return completedQuestCount / quests.length;
  }

  Stage copyWith({
    bool? isUnlocked,
    bool? isCompleted,
    DateTime? unlockedAt,
    DateTime? completedAt,
    List<Quest>? quests,
  }) {
    return Stage(
      id: id,
      stageNo: stageNo,
      title: title,
      description: description,
      level: level,
      gradeRange: gradeRange,
      prefectureRange: prefectureRange,
      quests: quests ?? this.quests,
      totalPoints: totalPoints,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      isCompleted: isCompleted ?? this.isCompleted,
      unlockedAt: unlockedAt ?? this.unlockedAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}

/// MVP 10ステージ マスターデータ
class StageData {
  static const List<Map<String, dynamic>> mvpList = [
    // ステージ1: 低学年向け基礎地理
    {
      'id': 'stage_1',
      'stageNo': 1,
      'title': '北海道・東北地方を学ぼう',
      'description': '日本の北にある地方について学びます',
      'level': 'beginner',
      'gradeRange': '1-2',
      'prefectureRange': 'hokkaido_tohoku',
      'totalPoints': 100,
      'quests': [
        {
          'id': 'stage1_quest1',
          'questNo': 1,
          'title': '北海道の特徴',
          'description': '北海道の特徴について答えてください',
          'type': 'multiple_choice',
          'pointsReward': 10,
          'quizDataId': 'quiz_stage1_quest1_v1',
          'isCompleted': false,
        },
        {
          'id': 'stage1_quest2',
          'questNo': 2,
          'title': '日本の最北端',
          'description': '日本の最北端の地域を答えてください',
          'type': 'fill_blank',
          'pointsReward': 10,
          'quizDataId': 'quiz_stage1_quest2_v1',
          'isCompleted': false,
        },
        {
          'id': 'stage1_quest3',
          'questNo': 3,
          'title': '地図で北海道を選ぶ',
          'description': '地図から北海道を選んでください',
          'type': 'map_tap',
          'pointsReward': 10,
          'quizDataId': 'quiz_stage1_quest3_v1',
          'isCompleted': false,
        },
      ],
    },
    // ステージ2: 低学年向け関東地方
    {
      'id': 'stage_2',
      'stageNo': 2,
      'title': '関東地方を学ぼう',
      'description': '首都東京がある地方を学びます',
      'level': 'beginner',
      'gradeRange': '1-2',
      'prefectureRange': 'kanto',
      'totalPoints': 100,
    },
    // ステージ3: 中学年向け近畿地方
    {
      'id': 'stage_3',
      'stageNo': 3,
      'title': '近畿地方を学ぼう',
      'description': '古い文化が残る関西地方を学びます',
      'level': 'intermediate',
      'gradeRange': '3-4',
      'prefectureRange': 'kinki',
      'totalPoints': 150,
    },
    // ステージ4: 中学年向け九州地方
    {
      'id': 'stage_4',
      'stageNo': 4,
      'title': '九州地方を学ぼう',
      'description': '南の温かい地方を学びます',
      'level': 'intermediate',
      'gradeRange': '3-4',
      'prefectureRange': 'kyushu',
      'totalPoints': 150,
    },
    // ステージ5: 中学年向け産業基礎
    {
      'id': 'stage_5',
      'stageNo': 5,
      'title': '日本の産業を学ぼう',
      'description': '各地域の主な産業について学びます',
      'level': 'intermediate',
      'gradeRange': '3-4',
      'prefectureRange': 'all',
      'totalPoints': 150,
    },
    // ステージ6: 高学年向け農業産業
    {
      'id': 'stage_6',
      'stageNo': 6,
      'title': '農業と食べ物',
      'description': '日本の農業と食料生産について学びます',
      'level': 'advanced',
      'gradeRange': '5-6',
      'prefectureRange': 'all',
      'totalPoints': 200,
    },
    // ステージ7: 高学年向け工業産業
    {
      'id': 'stage_7',
      'stageNo': 7,
      'title': '工業と製造業',
      'description': 'ものづくり産業について学びます',
      'level': 'advanced',
      'gradeRange': '5-6',
      'prefectureRange': 'all',
      'totalPoints': 200,
    },
    // ステージ8: 高学年向け文化・観光
    {
      'id': 'stage_8',
      'stageNo': 8,
      'title': '文化と観光地',
      'description': '日本各地の文化と有名な観光地を学びます',
      'level': 'advanced',
      'gradeRange': '5-6',
      'prefectureRange': 'all',
      'totalPoints': 200,
    },
    // ステージ9: 高学年向け交通・流通
    {
      'id': 'stage_9',
      'stageNo': 9,
      'title': '交通と流通',
      'description': '日本全体の交通網と物流について学びます',
      'level': 'advanced',
      'gradeRange': '5-6',
      'prefectureRange': 'all',
      'totalPoints': 200,
    },
    // ステージ10: マスター認定
    {
      'id': 'stage_10',
      'stageNo': 10,
      'title': '社会博士への道',
      'description': 'これまで学んだ全てを使って、社会博士を目指します',
      'level': 'advanced',
      'gradeRange': '5-6',
      'prefectureRange': 'all',
      'totalPoints': 250,
    },
    // ステージ13: 日本の地形・自然
    {
      'id': 'stage_13',
      'stageNo': 13,
      'title': '日本の地形・自然',
      'description': '山脈・平野・川・気候など日本の地形と自然について学びます',
      'level': 'advanced',
      'gradeRange': '5',
      'prefectureRange': 'all',
      'totalPoints': 255,
    },
    // ステージ14: 農業の課題・米づくり
    {
      'id': 'stage_14',
      'stageNo': 14,
      'title': '農業と食の安全',
      'description': '米づくりのプロセス・農業の課題・食品ロスについて学びます',
      'level': 'advanced',
      'gradeRange': '5',
      'prefectureRange': 'all',
      'totalPoints': 255,
    },
    // ステージ15: 国際社会と日本
    {
      'id': 'stage_15',
      'stageNo': 15,
      'title': '国際社会と日本',
      'description': '国連・ODA・貿易など日本と世界のつながりを学びます',
      'level': 'advanced',
      'gradeRange': '6',
      'prefectureRange': 'all',
      'totalPoints': 280,
    },
    // ステージ11: 日本の歴史
    {
      'id': 'stage_11',
      'stageNo': 11,
      'title': '日本の歴史',
      'description': '縄文・弥生時代から明治時代まで、日本の歴史を学びます',
      'level': 'advanced',
      'gradeRange': '6',
      'prefectureRange': 'all',
      'totalPoints': 280,
    },
    // ステージ12: 環境・SDGs
    {
      'id': 'stage_12',
      'stageNo': 12,
      'title': '環境とSDGs',
      'description': '地球温暖化・SDGs・3Rなど環境問題について学びます',
      'level': 'advanced',
      'gradeRange': '6',
      'prefectureRange': 'all',
      'totalPoints': 280,
    },
    // ステージ16: 地図記号マスター
    {
      'id': 'stage_16',
      'stageNo': 16,
      'title': '地図記号マスター',
      'description': '地図記号・方位・縮尺など地図の読み方を学びます',
      'level': 'intermediate',
      'gradeRange': '3-4',
      'prefectureRange': 'all',
      'totalPoints': 270,
    },
    // ステージ17: 都道府県チャレンジ
    {
      'id': 'stage_17',
      'stageNo': 17,
      'title': '都道府県チャレンジ',
      'description': '47都道府県の県庁所在地・位置・特徴を学びます',
      'level': 'intermediate',
      'gradeRange': '4-5',
      'prefectureRange': 'all',
      'totalPoints': 280,
    },
    // ステージ18: 日本の年中行事
    {
      'id': 'stage_18',
      'stageNo': 18,
      'title': '日本の年中行事',
      'description': '正月・節分・七夕・お盆など日本の伝統行事を学びます',
      'level': 'beginner',
      'gradeRange': '3-4',
      'prefectureRange': 'all',
      'totalPoints': 230,
    },
    // ステージ19: 歴史チャレンジ上級
    {
      'id': 'stage_19',
      'stageNo': 19,
      'title': '歴史チャレンジ上級',
      'description': '飛鳥〜昭和まで重要な人物・出来事・年号を深堀り学習します',
      'level': 'advanced',
      'gradeRange': '6',
      'prefectureRange': 'all',
      'totalPoints': 310,
    },
    // ステージ20: 公民マスター
    {
      'id': 'stage_20',
      'stageNo': 20,
      'title': '公民マスター',
      'description': '税金・社会保障・地方自治・人権など公民の知識を完全マスターします',
      'level': 'advanced',
      'gradeRange': '6',
      'prefectureRange': 'all',
      'totalPoints': 320,
    },
  ];

  static const Map<String, String> levelLabels = {
    'beginner': '初級',
    'intermediate': '中級',
    'advanced': '上級',
  };

  static StageLevel? findByStageNo(int stageNo) {
    for (final stage in mvpList) {
      if (stage['stageNo'] == stageNo) {
        final levelStr = stage['level'] as String;
        return _parseStageLevelString(levelStr);
      }
    }
    return null;
  }
}

/// Helper function to parse stage level string
StageLevel _parseStageLevelString(String levelStr) {
  switch (levelStr) {
    case 'beginner':
      return StageLevel.beginner;
    case 'intermediate':
      return StageLevel.intermediate;
    case 'advanced':
      return StageLevel.advanced;
    default:
      return StageLevel.beginner;
  }
}
