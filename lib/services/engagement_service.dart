import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_progress.dart';

/// 親向けエンゲージメント管理サービス
/// ストリーク追跡、ウィークリーチャレンジ、セーフティスコア、マイルストーン検出
class EngagementService {
  final FirebaseFirestore _firestore;

  EngagementService(this._firestore);

  // ─── (1) Daily Checkin & Streak Tracking ─────────────────────────

  /// Daily checkin を記録し、ストリークを更新する
  /// 親ID（parentId）とタイムスタンプを基に、連続学習日数を計算
  Future<void> recordDailyCheckin(
    String parentId,
    DateTime timestamp,
  ) async {
    final docRef = _firestore.collection('parent_engagement').doc(parentId);

    // 現在のストリーク情報を取得
    final docSnap = await docRef.get();
    final data = docSnap.data() ?? {};

    final lastCheckinDate = data['lastCheckinDate'] != null
        ? (data['lastCheckinDate'] as Timestamp).toDate()
        : null;

    int currentStreak = data['currentStreak'] ?? 0;
    int maxStreak = data['maxStreak'] ?? 0;

    // ストリークロジック
    final now = DateTime(timestamp.year, timestamp.month, timestamp.day);
    final lastCheck = lastCheckinDate != null
        ? DateTime(lastCheckinDate.year, lastCheckinDate.month,
            lastCheckinDate.day)
        : null;

    if (lastCheck == null) {
      // 初回
      currentStreak = 1;
    } else if (now.difference(lastCheck).inDays == 1) {
      // 連続（昨日から続いている）
      currentStreak += 1;
    } else if (now.difference(lastCheck).inDays > 1) {
      // ストリーク途切れ、リセット
      currentStreak = 1;
    }
    // else: 同じ日（スキップ）

    maxStreak = currentStreak > maxStreak ? currentStreak : maxStreak;

    // Firestore に記録
    await docRef.set({
      'parentId': parentId,
      'lastCheckinDate': Timestamp.fromDate(now),
      'currentStreak': currentStreak,
      'maxStreak': maxStreak,
      'totalCheckins': (data['totalCheckins'] ?? 0) + 1,
      'updatedAt': Timestamp.now(),
    }, SetOptions(merge: true));
  }

  /// 親のストリーク情報を取得
  Future<Map<String, dynamic>?> getStreakData(String parentId) async {
    final docSnap = await _firestore
        .collection('parent_engagement')
        .doc(parentId)
        .get();
    return docSnap.data();
  }

  // ─── (2) Weekly Challenge Generation ─────────────────────────────

  /// 親の弱い詐欺パターンに基づいて、ウィークリーチャレンジを生成
  /// weakFraudPattern: 親が引っかかりやすい詐欺タイプ（'phishing', 'fake_news', 'social_engineering' など）
  Future<Map<String, dynamic>> generateWeeklyChallenge(
    String parentId,
    String weakFraudPattern,
  ) async {
    final docRef = _firestore
        .collection('parent_engagement')
        .doc(parentId)
        .collection('weekly_challenges')
        // 年をキーに含めないと翌年の同じ週番号でドキュメントが衝突し、
        // 前年のチャレンジ記録を上書きしてしまうため年を含める
        .doc('${DateTime.now().year}_week_${DateTime.now().weekOfYear}');

    // チャレンジテンプレート
    final challengeTemplates = <String, Map<String, dynamic>>{
      'phishing': {
        'title': 'フィッシング詐欺対策チャレンジ',
        'description': '今週は疑わしいメールリンクを見つけ出す練習をしましょう',
        'difficulty': 'medium',
        'quizzesCount': 5,
        'reward': 50,
      },
      'fake_news': {
        'title': '偽情報検証チャレンジ',
        'description': 'SNS上の誤情報を判定し、信頼できる情報源を見つけます',
        'difficulty': 'hard',
        'quizzesCount': 5,
        'reward': 75,
      },
      'social_engineering': {
        'title': 'ソーシャルエンジニアリング回避チャレンジ',
        'description': '詐欺師の心理操作テクニックを学び、対抗策を練習',
        'difficulty': 'hard',
        'quizzesCount': 5,
        'reward': 75,
      },
      'password_security': {
        'title': 'パスワードセキュリティチャレンジ',
        'description': '強力で安全なパスワードの作り方を学ぶ',
        'difficulty': 'easy',
        'quizzesCount': 3,
        'reward': 30,
      },
      'payment_fraud': {
        'title': '決済詐欺検出チャレンジ',
        'description': '不正な支払いリクエストを識別する',
        'difficulty': 'medium',
        'quizzesCount': 5,
        'reward': 50,
      },
    };

    final challenge = challengeTemplates[weakFraudPattern] ??
        challengeTemplates['phishing']!;

    final challengeData = {
      'parentId': parentId,
      'weekNumber': DateTime.now().weekOfYear,
      'startDate': Timestamp.now(),
      'endDate': Timestamp.fromDate(
        DateTime.now().add(const Duration(days: 7)),
      ),
      'fraudPattern': weakFraudPattern,
      ...challenge,
      'completed': false,
      'completedAt': null,
      'quizzesCompleted': 0,
    };

    await docRef.set(challengeData);
    return challengeData;
  }

  /// ウィークリーチャレンジの進捗を更新
  Future<void> updateChallengeProgress(
    String parentId,
    String weekNumber,
    int completedQuizzes,
  ) async {
    final docRef = _firestore
        .collection('parent_engagement')
        .doc(parentId)
        .collection('weekly_challenges')
        .doc('week_$weekNumber');

    final docSnap = await docRef.get();
    if (!docSnap.exists) return;

    final data = docSnap.data()!;
    final totalQuizzes = data['quizzesCount'] as int? ?? 5;

    await docRef.update({
      'quizzesCompleted': completedQuizzes,
      'completed': completedQuizzes >= totalQuizzes,
      'completedAt': completedQuizzes >= totalQuizzes ? Timestamp.now() : null,
    });
  }

  // ─── (3) Safety Score Calculation ────────────────────────────────

  /// セーフティスコアを計算（AI 真実スコア + 詐欺クイズスコア + リスク評価）
  Future<double> calculateSafetyScore(String parentId) async {
    final docRef = _firestore.collection('parent_engagement').doc(parentId);
    final docSnap = await docRef.get();

    if (!docSnap.exists) return 0.0;

    final data = docSnap.data()!;

    // 1. AI 真実スコア（AI が検出した詐欺判定精度）
    // 親が正しく詐欺を判定できた割合
    final aiTruthScore = (data['aiTruthScore'] as num?)?.toDouble() ?? 0.0;

    // 2. 詐欺クイズスコア（スコア範囲: 0-100）
    final crimeQuizScore = (data['crimeQuizScore'] as num?)?.toDouble() ?? 0.0;

    // 3. セーフティリスク評価（過去90日間の疑わしい行動）
    final safetyRiskScore = await _calculateSafetyRisk(parentId);

    // 加重平均: AI 30% + クイズ 40% + リスク評価 30%
    final safetyScore =
        (aiTruthScore * 0.30) + (crimeQuizScore * 0.40) + (safetyRiskScore * 0.30);

    // Firestore に保存
    await docRef.update({
      'aiTruthScore': aiTruthScore,
      'crimeQuizScore': crimeQuizScore,
      'safetyRiskScore': safetyRiskScore,
      'totalSafetyScore': safetyScore,
      'safetyScoreUpdatedAt': Timestamp.now(),
    });

    return safetyScore;
  }

  /// セーフティリスク評価（内部関数）
  /// 過去90日間の疑わしい行動から安全スコアを計算（0-100）
  Future<double> _calculateSafetyRisk(String parentId) async {
    try {
      final logsSnap = await _firestore
          .collection('parent_engagement')
          .doc(parentId)
          .collection('activity_logs')
          .where('timestamp',
              isGreaterThan: Timestamp.fromDate(
                DateTime.now().subtract(const Duration(days: 90)),
              ))
          .get();

      if (logsSnap.docs.isEmpty) return 100.0; // 活動なし → 安全

      int suspiciousActions = 0;
      for (final doc in logsSnap.docs) {
        final data = doc.data();
        if (data['actionType'] == 'suspicious' ||
            data['riskLevel'] == 'high') {
          suspiciousActions++;
        }
      }

      // リスクスコア = 100 - (疑わしい行動数 / 総行動数 * 100)
      final riskPercentage = (suspiciousActions / logsSnap.docs.length) * 100;
      return (100 - riskPercentage).clamp(0, 100).toDouble();
    } catch (e) {
      return 50.0; // エラー時はニュートラル
    }
  }

  /// セーフティスコアに基づいて、親へのアドバイスを生成
  String getSafetyAdvice(double safetyScore) {
    if (safetyScore >= 85) {
      return '優秀です！詐欺への対策意識が高いです。この知識を家族と共有してください。';
    } else if (safetyScore >= 70) {
      return '良好です。さらに「ウィークリーチャレンジ」に挑戦して知識を深めましょう。';
    } else if (safetyScore >= 50) {
      return '注意が必要です。詐欺パターンの学習を強化してください。';
    } else {
      return '危険です。緊急に詐欺対策の学習を開始してください。';
    }
  }

  // ─── (4) Milestone Detection & Badge Achievements ─────────────────

  /// マイルストーン検出し、バッジを授与
  /// 親の成長に応じて、バッジを自動付与
  Future<List<String>> detectMilestones(
    String parentId,
    UserProgress userProgress,
  ) async {
    final earnedBadges = <String>[];
    final docRef = _firestore.collection('parent_engagement').doc(parentId);
    final docSnap = await docRef.get();

    if (!docSnap.exists) return [];

    final data = docSnap.data()!;
    final currentStreak = data['currentStreak'] as int? ?? 0;
    final totalCheckins = data['totalCheckins'] as int? ?? 0;
    final safetyScore = (data['totalSafetyScore'] as num?)?.toDouble() ?? 0.0;
    final existingBadges = List<String>.from(data['badges'] as List? ?? []);

    // ─── ストリークバッジ ────────────────────────────────────
    if (currentStreak >= 7 && !existingBadges.contains('streak_7days')) {
      earnedBadges.add('streak_7days');
    }
    if (currentStreak >= 14 && !existingBadges.contains('streak_14days')) {
      earnedBadges.add('streak_14days');
    }
    if (currentStreak >= 30 && !existingBadges.contains('streak_30days')) {
      earnedBadges.add('streak_30days');
    }

    // ─── セーフティバッジ ──────────────────────────────────
    if (safetyScore >= 85 && !existingBadges.contains('safety_master')) {
      earnedBadges.add('safety_master');
    }
    if (safetyScore >= 70 && !existingBadges.contains('safety_expert')) {
      earnedBadges.add('safety_expert');
    }

    // ─── エンゲージメントバッジ ──────────────────────────────
    if (totalCheckins >= 10 && !existingBadges.contains('engaged_10')) {
      earnedBadges.add('engaged_10');
    }
    if (totalCheckins >= 30 && !existingBadges.contains('engaged_30')) {
      earnedBadges.add('engaged_30');
    }
    if (totalCheckins >= 100 && !existingBadges.contains('engaged_100')) {
      earnedBadges.add('engaged_100');
    }

    // ─── 子どもの学習バッジ（UserProgress連携）──────────────
    if (userProgress.badges.contains('quiz_master') &&
        !existingBadges.contains('child_achievement_5')) {
      earnedBadges.add('child_achievement_5');
    }

    // ─── 複数チャレンジ完了バッジ ──────────────────────────
    final challengesSnap = await _firestore
        .collection('parent_engagement')
        .doc(parentId)
        .collection('weekly_challenges')
        .where('completed', isEqualTo: true)
        .get();

    final completedCount = challengesSnap.docs.length;
    if (completedCount >= 5 && !existingBadges.contains('challenge_master_5')) {
      earnedBadges.add('challenge_master_5');
    }

    // Firestore に保存
    if (earnedBadges.isNotEmpty) {
      final updatedBadges = {...existingBadges, ...earnedBadges}.toList();
      await docRef.update({
        'badges': updatedBadges,
        'badgesUpdatedAt': Timestamp.now(),
      });
    }

    return earnedBadges;
  }

  /// バッジ定義を取得（表示用）
  Map<String, Map<String, String>> getBadgeDefinitions() {
    return {
      'streak_7days': {
        'name': '7日連続達成',
        'description': '7日連続でチェックインしました',
        'emoji': '🔥',
      },
      'streak_14days': {
        'name': '14日連続達成',
        'description': '2週間連続でエンゲージメント',
        'emoji': '🌟',
      },
      'streak_30days': {
        'name': '1ヶ月連続達成',
        'description': '1ヶ月間継続的に学習・参加',
        'emoji': '👑',
      },
      'safety_master': {
        'name': 'セーフティマスター',
        'description': 'セーフティスコア 85以上達成',
        'emoji': '🛡️',
      },
      'safety_expert': {
        'name': 'セーフティエキスパート',
        'description': 'セーフティスコア 70以上達成',
        'emoji': '🔐',
      },
      'engaged_10': {
        'name': 'エンゲージ10',
        'description': '10回チェックイン達成',
        'emoji': '✅',
      },
      'engaged_30': {
        'name': 'エンゲージ30',
        'description': '30回チェックイン達成',
        'emoji': '💪',
      },
      'engaged_100': {
        'name': 'エンゲージ100',
        'description': '100回チェックイン達成',
        'emoji': '🚀',
      },
      'child_achievement_5': {
        'name': 'パパママ応援者',
        'description': '子どもが5つのバッジを獲得',
        'emoji': '👨‍👩‍👧',
      },
      'challenge_master_5': {
        'name': 'チャレンジマスター',
        'description': '5つのウィークリーチャレンジを完了',
        'emoji': '🏆',
      },
    };
  }

  // ─── Helper: Activity Logging ───────────────────────────────────

  /// 活動ログを記録（セーフティリスク評価に使用）
  Future<void> logActivity(
    String parentId,
    String actionType, // 'quiz_completed', 'challenge_started', 'suspicious', etc.
    Map<String, dynamic> details,
    String riskLevel = 'low', // 'low', 'medium', 'high'
  ) async {
    await _firestore
        .collection('parent_engagement')
        .doc(parentId)
        .collection('activity_logs')
        .add({
      'timestamp': Timestamp.now(),
      'actionType': actionType,
      'riskLevel': riskLevel,
      'details': details,
    });
  }
}

// ─── Riverpod Providers ──────────────────────────────────────────────

/// EngagementService プロバイダー
final engagementServiceProvider = Provider<EngagementService>((ref) {
  return EngagementService(FirebaseFirestore.instance);
});

/// ストリーク情報プロバイダー
final streakDataProvider = FutureProvider.family<
    Map<String, dynamic>?,
    String,
>((ref, parentId) async {
  final service = ref.watch(engagementServiceProvider);
  return service.getStreakData(parentId);
});

/// セーフティスコアプロバイダー
final safetyScoreProvider = FutureProvider.family<
    double,
    String,
>((ref, parentId) async {
  final service = ref.watch(engagementServiceProvider);
  return service.calculateSafetyScore(parentId);
});

/// マイルストーン検出プロバイダー
final milestonesProvider = FutureProvider.family.autoDispose<
    List<String>,
    (String parentId, UserProgress userProgress),
>((ref, args) async {
  final service = ref.watch(engagementServiceProvider);
  return service.detectMilestones(args.$1, args.$2);
});

// Extension for week number (ISO 8601)
extension DateTimeExtension on DateTime {
  int get weekOfYear {
    final jan4 = DateTime(year, 1, 4);
    final daysSinceJan4 = difference(jan4).inDays;
    final weekOffset = (jan4.weekday - 1) % 7;
    return ((daysSinceJan4 + weekOffset) ~/ 7) + 1;
  }
}
