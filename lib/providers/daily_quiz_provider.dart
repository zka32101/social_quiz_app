import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/daily_quiz_model.dart';

/// 今日のクイズを Firebase Remote Config から取得
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
    if (quizJsonString.isEmpty) {
      return null;
    }

    final quizJson = jsonDecode(quizJsonString) as Map<String, dynamic>;
    return DailyQuiz.fromJson(quizJson);
  } catch (e) {
    print('Error loading daily quiz: $e');
    return null;
  }
});

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
