import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/map_service.dart';

/// SharedPreferences プロバイダー
final sharedPreferencesProvider =
    FutureProvider<SharedPreferences>((ref) async {
  return await SharedPreferences.getInstance();
});

/// MapService プロバイダー
final mapServiceProvider = FutureProvider<MapService>((ref) async {
  final prefs = await ref.watch(sharedPreferencesProvider.future);
  return MapService(prefs);
});

/// 都道府県クリア状態プロバイダー
final prefectureStatesProvider = FutureProvider<Map<String, int>>((ref) async {
  final service = await ref.watch(mapServiceProvider.future);
  return await service.getPrefectureStates();
});

/// クリア済み都道府県数プロバイダー
final clearedPrefectureCountProvider = FutureProvider<int>((ref) async {
  final service = await ref.watch(mapServiceProvider.future);
  return await service.getClearedPrefectureCount();
});

/// すべての都道府県がクリア済みか確認プロバイダー
final isAllPrefecturesClearedProvider = FutureProvider<bool>((ref) async {
  final service = await ref.watch(mapServiceProvider.future);
  return await service.isAllPrefecturesCleared();
});

/// 地方別クリア状態プロバイダー
final isRegionClearedProvider =
    FutureProvider.family<bool, String>((ref, region) async {
  final service = await ref.watch(mapServiceProvider.future);
  return await service.isRegionCleared(region);
});

/// マップ進捗プロバイダー（0-47）
final mapProgressProvider = FutureProvider<double>((ref) async {
  final count = await ref.watch(clearedPrefectureCountProvider.future);
  return count / 47.0;
});

/// マップ状態リフレッシュ用通知プロバイダー
final mapRefreshNotifierProvider =
    StateNotifierProvider<MapRefreshNotifier, int>((ref) {
  return MapRefreshNotifier();
});

class MapRefreshNotifier extends StateNotifier<int> {
  MapRefreshNotifier() : super(0);

  void refresh() {
    state++;
  }
}

/// 都道府県をクリア状態に設定
class SetPrefectureClearedUseCase {
  final MapService mapService;

  SetPrefectureClearedUseCase(this.mapService);

  Future<void> execute(String prefId, WidgetRef ref) async {
    await mapService.setPrefectureCleared(prefId);
    // プロバイダーをリフレッシュ
    ref.refresh(prefectureStatesProvider);
    ref.refresh(clearedPrefectureCountProvider);
    ref.refresh(isAllPrefecturesClearedProvider);
    ref.invalidate(mapRefreshNotifierProvider);
  }
}
