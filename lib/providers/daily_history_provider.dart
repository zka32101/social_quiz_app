import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/daily_history.dart';
import '../services/daily_history_service.dart';

/// DailyHistoryService プロバイダー
final dailyHistoryServiceProvider = Provider<DailyHistoryService>((ref) {
  return DailyHistoryService();
});

/// 今日の歴史イベント取得プロバイダー
final todayHistoryProvider = FutureProvider<DailyHistory?>((ref) async {
  final service = ref.watch(dailyHistoryServiceProvider);
  return await service.getTodayHistory();
});

/// 指定日の歴史イベント取得プロバイダー
final historyByDateProvider = FutureProvider.family<DailyHistory?, (int, int)>(
  (ref, date) async {
    final service = ref.watch(dailyHistoryServiceProvider);
    return await service.getHistoryByDate(date.$1, date.$2);
  },
);

/// SharedPreferences プロバイダー
final sharedPreferencesProvider =
    FutureProvider<SharedPreferences>((ref) async {
  return await SharedPreferences.getInstance();
});

/// 当日クイズが実施済みかチェックプロバイダー
final isDailyQuizCompletedProvider = FutureProvider<bool>((ref) async {
  final prefs = await ref.watch(sharedPreferencesProvider.future);
  final today = DateTime.now();
  final key = 'app_daily_quiz_'
      '${today.year}'
      '${today.month.toString().padLeft(2, '0')}'
      '${today.day.toString().padLeft(2, '0')}';
  return prefs.getBool(key) ?? false;
});

/// 当日クイズが正解かチェックプロバイダー
final isDailyQuizCorrectProvider = FutureProvider<bool>((ref) async {
  final prefs = await ref.watch(sharedPreferencesProvider.future);
  final today = DateTime.now();
  final key = 'app_daily_correct_'
      '${today.year}'
      '${today.month.toString().padLeft(2, '0')}'
      '${today.day.toString().padLeft(2, '0')}';
  return prefs.getBool(key) ?? false;
});

/// デイリークイズ実行通知プロバイダー
final dailyQuizNotifierProvider =
    StateNotifierProvider<DailyQuizNotifier, DailyQuizState>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider).when(
        data: (p) => p,
        loading: () => null,
        error: (e, st) => null,
      );
  return DailyQuizNotifier(prefs);
});

/// デイリークイズの状態
class DailyQuizState {
  final bool isCompleted;
  final bool isCorrect;
  final bool isLoading;

  const DailyQuizState({
    required this.isCompleted,
    required this.isCorrect,
    required this.isLoading,
  });

  DailyQuizState copyWith({
    bool? isCompleted,
    bool? isCorrect,
    bool? isLoading,
  }) {
    return DailyQuizState(
      isCompleted: isCompleted ?? this.isCompleted,
      isCorrect: isCorrect ?? this.isCorrect,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

/// デイリークイズ実行状態管理
class DailyQuizNotifier extends StateNotifier<DailyQuizState> {
  final SharedPreferences? _prefs;

  DailyQuizNotifier(this._prefs)
      : super(const DailyQuizState(
          isCompleted: false,
          isCorrect: false,
          isLoading: false,
        )) {
    _loadState();
  }

  /// 当日の状態をロード
  void _loadState() {
    if (_prefs == null) return;

    final today = DateTime.now();
    final dateKey = '${today.year}'
        '${today.month.toString().padLeft(2, '0')}'
        '${today.day.toString().padLeft(2, '0')}';

    final completed = _prefs!.getBool('app_daily_quiz_$dateKey') ?? false;
    final correct = _prefs!.getBool('app_daily_correct_$dateKey') ?? false;

    state = state.copyWith(isCompleted: completed, isCorrect: correct);
  }

  /// クイズを実行
  Future<void> executeQuiz(bool isCorrect) async {
    if (_prefs == null) return;

    state = state.copyWith(isLoading: true);

    try {
      final today = DateTime.now();
      final dateKey = '${today.year}'
          '${today.month.toString().padLeft(2, '0')}'
          '${today.day.toString().padLeft(2, '0')}';

      await _prefs!.setBool('app_daily_quiz_$dateKey', true);
      if (isCorrect) {
        await _prefs!.setBool('app_daily_correct_$dateKey', true);
      }

      state = state.copyWith(
        isCompleted: true,
        isCorrect: isCorrect,
        isLoading: false,
      );
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  /// リセット（テスト用）
  void reset() {
    state = const DailyQuizState(
      isCompleted: false,
      isCorrect: false,
      isLoading: false,
    );
  }
}
