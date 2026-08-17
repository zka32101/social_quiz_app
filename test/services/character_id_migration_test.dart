import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:social_quiz_app/services/character_id_migration.dart';

const _storageKey = 'shakai_char_states';

void main() {
  group('CharacterIdMigration', () {
    test('旧キャラIDのセーブデータを新IDに書き換える', () async {
      final oldData = {
        'chizuko': {
          'isUnlocked': true,
          'level': 3,
          'hasExpressions': true,
          'hasPoses': true,
          'hasBackstory': false,
          'hasSparkle': false,
          'hasStampCoupon': false,
        },
        'kenko': {
          'isUnlocked': true,
          'level': 5,
          'hasExpressions': true,
          'hasPoses': true,
          'hasBackstory': true,
          'hasSparkle': true,
          'hasStampCoupon': true,
        },
      };
      SharedPreferences.setMockInitialValues({
        _storageKey: jsonEncode(oldData),
      });

      await CharacterIdMigration.migrateIfNeeded();

      final prefs = await SharedPreferences.getInstance();
      final migrated =
          jsonDecode(prefs.getString(_storageKey)!) as Map<String, dynamic>;

      expect(migrated.containsKey('chizuko'), isFalse);
      expect(migrated.containsKey('kenko'), isFalse);
      expect(migrated['mapple']['level'], 3);
      expect(migrated['mapple']['isUnlocked'], true);
      expect(migrated['michinori']['level'], 5);
      expect(migrated['michinori']['hasSparkle'], true);
    });

    test('全16キャラの旧IDが1対1で新IDに移行される', () async {
      final oldData = {
        for (final oldId in kShakaiCharacterIdMigrationMap.keys)
          oldId: {'isUnlocked': true, 'level': 1},
      };
      SharedPreferences.setMockInitialValues({
        _storageKey: jsonEncode(oldData),
      });

      await CharacterIdMigration.migrateIfNeeded();

      final prefs = await SharedPreferences.getInstance();
      final migrated =
          jsonDecode(prefs.getString(_storageKey)!) as Map<String, dynamic>;

      expect(migrated.keys.toSet(),
          kShakaiCharacterIdMigrationMap.values.toSet());
    });

    test('新IDのみのデータは変更しない（既に移行済み、または新規プレイヤー）',
        () async {
      final newData = {
        'mapple': {'isUnlocked': true, 'level': 2},
        'shakai_star': {'isUnlocked': false, 'level': 1},
      };
      SharedPreferences.setMockInitialValues({
        _storageKey: jsonEncode(newData),
      });

      await CharacterIdMigration.migrateIfNeeded();

      final prefs = await SharedPreferences.getInstance();
      final result =
          jsonDecode(prefs.getString(_storageKey)!) as Map<String, dynamic>;

      expect(result, newData);
    });

    test('id変更のない shakai_star はそのまま残る', () async {
      final oldData = {
        'chizuko': {'isUnlocked': true, 'level': 1},
        'shakai_star': {'isUnlocked': true, 'level': 4},
      };
      SharedPreferences.setMockInitialValues({
        _storageKey: jsonEncode(oldData),
      });

      await CharacterIdMigration.migrateIfNeeded();

      final prefs = await SharedPreferences.getInstance();
      final migrated =
          jsonDecode(prefs.getString(_storageKey)!) as Map<String, dynamic>;

      expect(migrated['shakai_star']['level'], 4);
      expect(migrated['mapple']['level'], 1);
    });

    test('保存データが無い場合（初回起動）は何もしない', () async {
      SharedPreferences.setMockInitialValues({});

      await CharacterIdMigration.migrateIfNeeded();

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString(_storageKey), isNull);
    });

    test('壊れたJSONの場合は例外を投げずに何もしない', () async {
      SharedPreferences.setMockInitialValues({
        _storageKey: 'これはJSONではない',
      });

      await CharacterIdMigration.migrateIfNeeded();

      final prefs = await SharedPreferences.getInstance();
      // 壊れたデータはそのまま残る（このマイグレーションが書き換えない）
      expect(prefs.getString(_storageKey), 'これはJSONではない');
    });
  });
}
