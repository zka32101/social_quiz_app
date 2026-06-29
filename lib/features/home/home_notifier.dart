import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/user_progress.dart';
import '../../repositories/progress_repository.dart';

/// ホーム画面の状態
class HomeState {
  final UserProgress? userProgress;
  final String? todayMissionPrefId; // デイリーミッション対象県
  final bool isLoading;
  final String? error;

  const HomeState({
    this.userProgress,
    this.todayMissionPrefId,
    this.isLoading = false,
    this.error,
  });

  HomeState copyWith({
    UserProgress? userProgress,
    String? todayMissionPrefId,
    bool? isLoading,
    String? error,
  }) {
    return HomeState(
      userProgress: userProgress ?? this.userProgress,
      todayMissionPrefId: todayMissionPrefId ?? this.todayMissionPrefId,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// ホーム画面の Notifier（Riverpod 2.x 推奨パターン）
class HomeNotifier extends Notifier<HomeState> {
  @override
  HomeState build() {
    // 初期状態
    Future.microtask(() => _loadData());
    return const HomeState(isLoading: true);
  }

  Future<void> _loadData() async {
    try {
      final repo = ref.read(progressRepositoryProvider);
      // 匿名認証後は Firebase UID を使う（現在は仮 ID）
      final progress = repo.loadLocal();

      // デイリーミッション（今日の日付からランダム選出）
      final todayMissionId = _getTodayMissionId();

      state = HomeState(
        userProgress: progress,
        todayMissionPrefId: todayMissionId,
        isLoading: false,
      );
    } catch (e) {
      state = HomeState(isLoading: false, error: e.toString());
    }
  }

  /// 今日のデイリーミッション都道府県を決定
  String _getTodayMissionId() {
    // TODO: Firebase dailyMissions/{today} から取得
    // フォールバック: 日付ベースのシンプルな選出
    const prefIds = [
      'hokkaido', 'aomori', 'miyagi',
      'tokyo', 'kanagawa', 'saitama',
      'osaka', 'kyoto', 'hyogo', 'nara',
      'fukuoka', 'kumamoto', 'kagoshima', 'okinawa',
    ];
    final today = DateTime.now();
    final index = (today.year * 365 + today.month * 30 + today.day) %
        prefIds.length;
    return prefIds[index];
  }

  Future<void> refresh() => _loadData();
}

/// HomeNotifier プロバイダー
final homeNotifierProvider =
    NotifierProvider<HomeNotifier, HomeState>(HomeNotifier.new);
