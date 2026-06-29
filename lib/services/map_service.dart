import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// 都道府県のマップクリア状態を管理するサービス
class MapService {
  static const String _prefStatesKey = 'app_pref_states';
  static const String _prefClearedAtKey = 'app_pref_cleared_at_';

  final SharedPreferences _prefs;

  MapService(this._prefs);

  /// すべての都道府県のクリア状態を取得
  /// キー: prefectureId, 値: 0（未クリア）or 1（クリア）
  Future<Map<String, int>> getPrefectureStates() async {
    final json = _prefs.getString(_prefStatesKey);
    if (json == null) return {};
    try {
      return Map<String, int>.from(jsonDecode(json) as Map);
    } catch (e) {
      return {};
    }
  }

  /// 都道府県のクリア状態を取得
  Future<bool> isPrefectureCleared(String prefId) async {
    final states = await getPrefectureStates();
    return (states[prefId] ?? 0) == 1;
  }

  /// 都道府県をクリア状態に更新
  Future<void> setPrefectureCleared(String prefId) async {
    final states = await getPrefectureStates();
    states[prefId] = 1;
    await _prefs.setString(_prefStatesKey, jsonEncode(states));

    // クリア日時を記録
    await _prefs.setString(
      '$_prefClearedAtKey$prefId',
      DateTime.now().toIso8601String(),
    );
  }

  /// 都道府県のクリア日時を取得
  DateTime? getPrefectureClearedAt(String prefId) {
    final dateStr = _prefs.getString('$_prefClearedAtKey$prefId');
    if (dateStr == null) return null;
    try {
      return DateTime.parse(dateStr);
    } catch (e) {
      return null;
    }
  }

  /// クリア済みの都道府県数を取得
  Future<int> getClearedPrefectureCount() async {
    final states = await getPrefectureStates();
    return states.values.where((v) => v == 1).length;
  }

  /// すべての都道府県がクリア済みか確認
  Future<bool> isAllPrefecturesCleared() async {
    final count = await getClearedPrefectureCount();
    return count == 47;
  }

  /// 地方別のクリア状態を確認（各地方のすべての県がクリア）
  Future<bool> isRegionCleared(String region) async {
    // 地方と県の対応（後で定数に移動）
    const regionPrefectures = {
      'hokkaido': ['hokkaido'],
      'tohoku': [
        'aomori',
        'iwate',
        'miyagi',
        'akita',
        'yamagata',
        'fukushima',
      ],
      'kanto': [
        'tokyo',
        'kanagawa',
        'saitama',
        'chiba',
        'ibaraki',
        'tochigi',
        'gunma',
      ],
      'chubu': [
        'niigata',
        'toyama',
        'ishikawa',
        'fukui',
        'yamanashi',
        'nagano',
        'gifu',
        'shizuoka',
        'aichi',
      ],
      'kansai': [
        'mie',
        'shiga',
        'kyoto',
        'osaka',
        'hyogo',
        'nara',
        'wakayama',
      ],
      'chugoku': ['tottori', 'shimane', 'okayama', 'hiroshima', 'yamaguchi'],
      'shikoku': ['tokushima', 'kagawa', 'ehime', 'kochi'],
      'kyushu': [
        'fukuoka',
        'saga',
        'nagasaki',
        'kumamoto',
        'oita',
        'miyazaki',
        'kagoshima',
        'okinawa',
      ],
    };

    final prefectures = regionPrefectures[region];
    if (prefectures == null) return false;

    final states = await getPrefectureStates();
    return prefectures.every((prefId) => (states[prefId] ?? 0) == 1);
  }

  /// 状態をリセット（テスト用）
  Future<void> clearAllStates() async {
    await _prefs.remove(_prefStatesKey);
    for (int i = 0; i < 47; i++) {
      final keys = _prefs.getKeys();
      for (final key in keys) {
        if (key.startsWith(_prefClearedAtKey)) {
          await _prefs.remove(key);
        }
      }
    }
  }
}
