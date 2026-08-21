import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../models/daily_history.dart';

/// 日付ごとの歴史イベント管理サービス
class DailyHistoryService {
  static const String _dataPath = 'assets/data/daily_history.json';
  late List<DailyHistory> _historiesCache;
  bool _isLoaded = false;

  /// JSON からデータをロード
  Future<void> loadData() async {
    if (_isLoaded) return;

    try {
      final json = await rootBundle.loadString(_dataPath);
      final data = jsonDecode(json) as Map<String, dynamic>;
      final list = data['daily_history'] as List<dynamic>? ?? [];

      _historiesCache = list
          .map((h) => DailyHistory.fromJson(h as Map<String, dynamic>))
          .toList();
      _isLoaded = true;
    } catch (e) {
      debugPrint('DailyHistoryService: Failed to load data - $e');
      _historiesCache = [];
      _isLoaded = true;
    }
  }

  /// 今日の歴史イベントを取得
  Future<DailyHistory?> getTodayHistory() async {
    await loadData();
    final today = DateTime.now();
    return getHistoryByDate(today.month, today.day);
  }

  /// 指定の日付の歴史イベントを取得
  Future<DailyHistory?> getHistoryByDate(int month, int day) async {
    await loadData();
    final monthDayStr =
        '${month.toString().padLeft(2, '0')}${day.toString().padLeft(2, '0')}';

    try {
      return _historiesCache
          .firstWhere((h) => h.id == monthDayStr, orElse: () => throw 'Not found');
    } catch (e) {
      return null;
    }
  }

  /// すべての歴史イベントを取得（キャッシュ）
  Future<List<DailyHistory>> getAllHistories() async {
    await loadData();
    return _historiesCache;
  }

  /// カテゴリで絞り込み
  Future<List<DailyHistory>> getHistoriesByCategory(
    DailyHistoryCategory category,
  ) async {
    await loadData();
    return _historiesCache.where((h) => h.category == category).toList();
  }

  /// キャッシュをクリア
  void clearCache() {
    _isLoaded = false;
    _historiesCache = [];
  }
}
