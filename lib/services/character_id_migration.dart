import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// 2026-08 のキャラクターリニューアルで id を変更したキャラの旧→新 対応表。
/// （`lib/data/shakai_characters.dart` の刷新に合わせて追加）
/// `shakai_star` は id 変更なしのため含まれない。
const Map<String, String> kShakaiCharacterIdMigrationMap = {
  'chizuko': 'mapple',
  'kitako': 'yukina',
  'haruko': 'haruka',
  'nishiko': 'miyabi',
  'mugiko': 'minori',
  'umiko': 'namika',
  'kojiko': 'geana',
  'michiko': 'michiru',
  'fumiko': 'fumika',
  'samuko': 'tsubaki',
  'meijiko': 'haikara',
  'sekaiko': 'tera',
  'shiminko': 'seigi',
  'zeiko': 'takara',
  'kenko': 'michinori',
};

/// アプリ起動時に一度だけ呼び出す（`main()` で `runApp` より前に await する）。
///
/// `CharacterNotifier`（`shared_core` の `BaseCharacterNotifier`）が
/// SharedPreferences の `shakai_char_states` キーからキャラ解放状況・Lvを
/// 読み込むより前に、旧キャラID（chizuko等）で保存されたデータを新ID
/// （mapple等）に書き換えておくことで、キャラリニューアルによる
/// 「せっかく育てたキャラがLv.1・未解放に戻る」という体験を防ぐ。
///
/// 冪等: 旧IDが見つからない（未プレイ、または既に移行済み）場合は何もしない。
class CharacterIdMigration {
  static const _storageKey = 'shakai_char_states';

  static Future<void> migrateIfNeeded() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw == null) return; // 初回起動：新IDで新規保存されるので何もしなくてよい

    Map<String, dynamic> map;
    try {
      map = jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      // 壊れたデータはこのマイグレーションの責務外（CharacterNotifier側で
      // 従来通りエラーになる）。
      return;
    }

    var changed = false;
    final migrated = <String, dynamic>{};
    map.forEach((id, value) {
      final newId = kShakaiCharacterIdMigrationMap[id];
      if (newId != null) {
        migrated[newId] = value;
        changed = true;
      } else {
        migrated[id] = value;
      }
    });

    if (changed) {
      await prefs.setString(_storageKey, jsonEncode(migrated));
    }
  }
}
