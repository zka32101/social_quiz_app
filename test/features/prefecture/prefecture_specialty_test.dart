import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:social_quiz_app/data/prefecture_data.dart';
import 'package:social_quiz_app/features/prefecture/data/prefecture_specialty.dart';
import 'package:social_quiz_app/features/prefecture/result_screen.dart';

Widget _wrap(String id) => MaterialApp(
      home: ResultScreen(
          prefectureId: id, totalPoints: 10, correctCount: 5, totalCount: 10),
    );

void main() {
  test('47県すべてに対応しファイルが存在する(fujiは不使用)', () {
    expect(PrefectureDataList.all.length, 47);
    for (final p in PrefectureDataList.all) {
      final a = prefectureSpecialtyAsset(p.id);
      expect(a, isNotNull, reason: p.id);
      expect(File(a!).existsSync(), isTrue, reason: a);
    }
    expect(kPrefectureSpecialtyFiles.length, 47);
    expect(kPrefectureSpecialtyFiles.values.any((v) => v.startsWith('fuji')),
        isFalse);
  });

  testWidgets('結果画面に名物とキャプションを表示(小画面でもoverflowなし)', (t) async {
    t.view.physicalSize = const Size(320, 568);
    t.view.devicePixelRatio = 1.0;
    addTearDown(t.view.reset);
    await t.pumpWidget(_wrap('tokyo'));
    await t.pump();
    expect(find.byKey(const Key('prefecture_specialty')), findsOneWidget);
    expect(find.text('東京都の めいぶつ'), findsOneWidget);
    expect(t.takeException(), isNull);
  });

  testWidgets('未知の県IDでは何も出さない', (t) async {
    await t.pumpWidget(_wrap('unknown'));
    await t.pump();
    expect(find.byKey(const Key('prefecture_specialty')), findsNothing);
  });
}
