import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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

      // デイリーミッション（Firebase から取得、失敗時は日付ベースで選出）
      final todayMissionId = await _getTodayMissionId();

      state = HomeState(
        userProgress: progress,
        todayMissionPrefId: todayMissionId,
        isLoading: false,
      );
    } catch (e) {
      state = HomeState(isLoading: false, error: e.toString());
    }
  }

  /// 今日のデイリーミッション都道府県を決定（Firebase から取得）
  Future<String> _getTodayMissionId() async {
    final today = DateTime.now();
    final dateKey =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    try {
      // Firebase dailyMissions/{today} から取得
      final firestore = FirebaseFirestore.instance;
      final docSnapshot = await firestore
          .collection('dailyMissions')
          .doc(dateKey)
          .get();

      if (docSnapshot.exists) {
        final prefId = docSnapshot.data()?['prefId'] as String?;
        if (prefId != null && prefId.isNotEmpty) {
          return prefId;
        }
      }
    } catch (e) {
      // Firebase アクセスに失敗した場合はログを出力して続行
      print('Failed to fetch daily mission from Firebase: $e');
    }

    // フォールバック: 日付ベースのシンプルな選出
    const prefIds = [
      'hokkaido',
      'aomori',
      'miyagi',
      'tokyo',
      'kanagawa',
      'saitama',
      'osaka',
      'kyoto',
      'hyogo',
      'nara',
      'fukuoka',
      'kumamoto',
      'kagoshima',
      'okinawa',
    ];
    final index = (today.year * 365 + today.month * 30 + today.day) %
        prefIds.length;
    return prefIds[index];
  }

  Future<void> refresh() => _loadData();
}

/// HomeNotifier プロバイダー
final homeNotifierProvider =
    NotifierProvider<HomeNotifier, HomeState>(HomeNotifier.new);
