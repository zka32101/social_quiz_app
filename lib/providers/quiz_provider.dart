import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/quiz.dart';
import '../services/map_service.dart';
import 'map_provider.dart';

/// クイズ正解処理の状態
class QuizResultState {
  final bool isLoading;
  final String? error;
  final bool success;

  const QuizResultState({
    required this.isLoading,
    this.error,
    this.success = false,
  });

  QuizResultState copyWith({
    bool? isLoading,
    String? error,
    bool? success,
  }) {
    return QuizResultState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      success: success ?? this.success,
    );
  }
}

/// クイズ正解時にマップを更新するプロバイダー
final quizResultNotifierProvider =
    StateNotifierProvider<QuizResultNotifier, QuizResultState>((ref) {
  final mapServiceAsync = ref.watch(mapServiceProvider);
  return QuizResultNotifier(mapServiceAsync, ref);
});

/// クイズ結果処理
class QuizResultNotifier extends StateNotifier<QuizResultState> {
  final AsyncValue<MapService> _mapServiceAsync;
  final Ref _ref;

  QuizResultNotifier(this._mapServiceAsync, this._ref)
      : super(const QuizResultState(isLoading: false));

  /// クイズ正解処理（マップ更新を含む）
  Future<void> handleQuizAnswer(
    Quiz quiz,
    int selectedIndex,
    bool isCorrect,
  ) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // マップサービスを取得
      final mapService = await _mapServiceAsync.when(
        data: (service) => service,
        loading: () => throw 'MapService loading',
        error: (err, st) => throw 'MapService error: $err',
      );

      // 正解で、かつ prefectureId がある場合、マップを更新
      if (isCorrect && quiz.prefectureId != null) {
        await mapService.setPrefectureCleared(quiz.prefectureId!);

        // プロバイダーをリフレッシュ
        _ref.refresh(prefectureStatesProvider);
        _ref.refresh(clearedPrefectureCountProvider);
        _ref.refresh(mapProgressProvider);
        _ref.refresh(isAllPrefecturesClearedProvider);
      }

      state = state.copyWith(
        isLoading: false,
        success: true,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// リセット
  void reset() {
    state = const QuizResultState(isLoading: false);
  }
}
