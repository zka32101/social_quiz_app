import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:social_quiz_app/services/map_service.dart';

void main() {
  group('MapService Tests', () {
    late SharedPreferences prefs;
    late MapService mapService;

    setUpAll(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
    });

    setUp(() {
      mapService = MapService(prefs);
    });

    tearDown(() async {
      await prefs.clear();
    });

    test('初期状態は未クリア', () async {
      final states = await mapService.getPrefectureStates();
      expect(states.isEmpty, true);
    });

    test('都道府県をクリアできる', () async {
      await mapService.setPrefectureCleared('tokyo');
      final isCleared = await mapService.isPrefectureCleared('tokyo');
      expect(isCleared, true);
    });

    test('クリア済み県数が正しくカウントされる', () async {
      await mapService.setPrefectureCleared('tokyo');
      await mapService.setPrefectureCleared('kyoto');
      final count = await mapService.getClearedPrefectureCount();
      expect(count, 2);
    });

    test('全県がクリアされたか判定できる', () async {
      var isAll = await mapService.isAllPrefecturesCleared();
      expect(isAll, false);
    });

    test('クリア日時が記録される', () async {
      await mapService.setPrefectureCleared('tokyo');
      final clearedAt = mapService.getPrefectureClearedAt('tokyo');
      expect(clearedAt, isNotNull);
    });
  });
}
