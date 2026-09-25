import 'dart:math';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../data/prefecture_data.dart';
import '../data/quiz_generator.dart';
import '../models/daily_quiz_model.dart';

/// 今日のクイズを Firebase Remote Config から取得。
/// Remote Config が未設定/取得失敗の場合は、都道府県データから
/// 日付固定シードで決定論的に1問選び、ローカルフォールバックとして返す。
final dailyQuizProvider = FutureProvider<DailyQuiz?>((ref) async {
  final remoteConfig = FirebaseRemoteConfig.instance;

  try {
    // 前回の取得から12時間経過していれば新しいデータを取得
    await remoteConfig.setConfigSettings(
      RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 30),
        minimumFetchInterval: const Duration(hours: 12),
      ),
    );

    await remoteConfig.fetchAndActivate();

    final quizJsonString = remoteConfig.getString('daily_quiz');
    if (quizJsonString.isNotEmpty) {
      final quizJson = jsonDecode(quizJsonString) as Map<String, dynamic>;
      return DailyQuiz.fromJson(quizJson);
    }
  } catch (e) {
    debugPrint('Error loading daily quiz from Remote Config: $e');
  }

  // Remote Config が空/失敗の場合のローカルフォールバック
  return _localFallbackQuiz();
});

/// 都道府県データから日替わりで1問生成する（Remote Config 未設定時のフォールバック）。
DailyQuiz? _localFallbackQuiz() {
  const allPrefectures = PrefectureDataList.all;
  if (allPrefectures.isEmpty) return null;

  final today = DateTime.now();
  final seed = today.year * 10000 + today.month * 100 + today.day;
  final rng = Random(seed);
  final pref = allPrefectures[rng.nextInt(allPrefectures.length)];

  final quizzes = QuizGenerator.forPrefecture(pref.id);
  if (quizzes.isEmpty) return null;
  final quiz = quizzes[rng.nextInt(quizzes.length)];

  return DailyQuiz(
    quizId: 'daily_local_${today.toIso8601String().split('T')[0]}',
    question: quiz.question,
    options: quiz.choices,
    correctIndex: quiz.correctIndex,
    explanation: quiz.explanation,
    category: 'geography',
    difficulty: 'easy',
    date: today,
  );
}

/// ボーナスポイント管理
final dailyBonusPointsProvider =
    StateNotifierProvider<DailyBonusNotifier, int>((ref) {
  return DailyBonusNotifier();
});

class DailyBonusNotifier extends StateNotifier<int> {
  DailyBonusNotifier() : super(0) {
    _loadBonus();
  }

  Future<void> _loadBonus() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().split('T')[0];
    final key = 'daily_bonus_points_$today';
    state = prefs.getInt(key) ?? 0;
  }

  Future<void> addBonus(int points) async {
    state += points;
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().split('T')[0];
    final key = 'daily_bonus_points_$today';
    await prefs.setInt(key, state);
  }

  Future<void> reset() async {
    state = 0;
  }
}

/// 今日のクイズの回答を保存
final dailyQuizServiceProvider = Provider<DailyQuizService>((ref) {
  return DailyQuizService();
});

class DailyQuizService {
  Future<void> saveAnswer({
    required String quizId,
    required bool isCorrect,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().split('T')[0];

    final answeredKey = 'daily_quiz_answered_${today}_$quizId';
    final correctKey = 'daily_quiz_correct_${today}_$quizId';

    await prefs.setBool(answeredKey, true);
    await prefs.setBool(correctKey, isCorrect);
  }

  Future<bool?> getAnswerStatus({
    required String quizId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().split('T')[0];
    final key = 'daily_quiz_answered_${today}_$quizId';
    return prefs.getBool(key);
  }

  Future<bool?> getCorrectStatus({
    required String quizId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().split('T')[0];
    final key = 'daily_quiz_correct_${today}_$quizId';
    return prefs.getBool(key);
  }
}
