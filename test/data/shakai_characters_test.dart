import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:social_quiz_app/data/shakai_characters.dart';

void main() {
  group('kShakaiCharacters', () {
    test('16体すべて定義されている', () {
      expect(kShakaiCharacters.length, 16);
    });

    test('idが重複していない', () {
      final ids = kShakaiCharacters.map((c) => c.id).toList();
      expect(ids.toSet().length, ids.length);
    });

    test('全キャラ・全レベル(1-5)の画像アセットが assets/characters/ に実在する', () {
      for (final c in kShakaiCharacters) {
        for (var level = 1; level <= 5; level++) {
          final path = c.imageAssetForLevel(level);
          expect(path, isNotNull, reason: '${c.id} の imageAsset が未設定');
          final file = File(path!);
          expect(
            file.existsSync(),
            isTrue,
            reason: '${c.id} (Lv.$level) の画像ファイルが見つからない: $path',
          );
        }
      }
    });

    test('全キャラ、Lv.1〜Lv.MAXですべて異なる画像パスを持つ（levelImagesが機能している）',
        () {
      for (final c in kShakaiCharacters) {
        final paths = [for (var level = 1; level <= 5; level++) c.imageAssetForLevel(level)];
        expect(
          paths.toSet().length,
          5,
          reason:
              '${c.id}: Lv別に異なる画像が設定されているはずが、一部のLvが同じ画像になっている '
              '（levelImagesの設定漏れの可能性）: $paths',
        );
      }
    });

    test('unlockAtが昇順（tier内・全体を通して段階的に解放される）', () {
      final unlockValues = kShakaiCharacters.map((c) => c.unlockAt).toList();
      for (var i = 1; i < unlockValues.length; i++) {
        expect(unlockValues[i], greaterThan(unlockValues[i - 1]),
            reason:
                '${kShakaiCharacters[i].id} の unlockAt が直前のキャラ以下になっている');
      }
    });
  });
}
