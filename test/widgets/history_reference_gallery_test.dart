import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:social_quiz_app/data/history_reference_images.dart';
import 'package:social_quiz_app/widgets/history_reference_gallery.dart';

Future<void> _pump(WidgetTester tester, List<HistoryImageRef> images) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: HistoryReferenceGallery(images: images, accentColor: Colors.brown),
      ),
    ),
  );
  // rootBundle.load() の失敗/成功を待つため settle させる。
  await tester.pumpAndSettle();
}

void main() {
  group('HistoryReferenceGallery', () {
    testWidgets('画像参照が空リストなら何も表示しない', (tester) async {
      await _pump(tester, const []);
      expect(find.byType(Card), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('画像ファイルがまだ存在しない場合は静かに何も表示しない（クラッシュしない）',
        (tester) async {
      await _pump(tester, const [
        HistoryImageRef(
          assetPath: 'assets/history/does_not_exist_yet.jpg',
          caption: 'まだ用意されていない画像',
        ),
      ]);
      expect(find.byType(Card), findsNothing);
      expect(find.text('まだ用意されていない画像'), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('実在するアセットは表示される', (tester) async {
      // リポジトリに既に存在する実アセットで存在確認ロジックを検証する。
      await _pump(tester, const [
        HistoryImageRef(
          assetPath: 'assets/icon/app_icon.jpg',
          caption: 'テスト画像',
          credit: '出典: テスト',
        ),
      ]);
      expect(find.byType(Card), findsOneWidget);
      expect(find.text('参考画像'), findsOneWidget);
      expect(find.text('テスト画像'), findsOneWidget);
      expect(find.text('出典: テスト'), findsOneWidget);
    });

    testWidgets('存在する画像と存在しない画像が混在する場合、存在するものだけ表示', (tester) async {
      await _pump(tester, const [
        HistoryImageRef(
          assetPath: 'assets/history/does_not_exist_yet.jpg',
          caption: 'まだ用意されていない画像',
        ),
        HistoryImageRef(
          assetPath: 'assets/icon/app_icon.jpg',
          caption: 'テスト画像',
        ),
      ]);
      expect(find.byType(Card), findsOneWidget);
      expect(find.text('まだ用意されていない画像'), findsNothing);
      expect(find.text('テスト画像'), findsOneWidget);
    });
  });

  group('historyImagesFor', () {
    test('抽象的な出来事しかない時代（yayoi/taisho/heisei_reiwa）は空を返す', () {
      expect(historyImagesFor('yayoi'), isEmpty);
      expect(historyImagesFor('taisho'), isEmpty);
      expect(historyImagesFor('heisei_reiwa'), isEmpty);
    });

    test('未知のeraIdは空を返す', () {
      expect(historyImagesFor('unknown_era'), isEmpty);
    });

    test('定義済みの各時代は1件以上の画像参照を持つ', () {
      for (final entry in kHistoryReferenceImages.entries) {
        expect(entry.value, isNotEmpty, reason: '${entry.key} が空');
      }
    });
  });
}
