import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:social_quiz_app/features/prefecture/result_screen.dart';

Widget _wrap(String? badge) => MaterialApp(
      home: ResultScreen(
        prefectureId: 'tokyo',
        totalPoints: 100,
        correctCount: 8,
        totalCount: 10,
        newBadgeId: badge,
      ),
    );

void main() {
  testWidgets('newBadgeId があれば達成ダイアログを1回だけ表示し了解で閉じる', (t) async {
    await t.pumpWidget(_wrap('first_correct'));
    await t.pump();
    await t.pump(const Duration(milliseconds: 300));
    expect(find.text('おめでとう！'), findsOneWidget);
    expect(find.textContaining('はじめての正解'), findsWidgets);
    expect(find.text('了解'), findsOneWidget);
    await t.tap(find.text('了解'));
    await t.pumpAndSettle();
    expect(find.text('おめでとう！'), findsNothing);
    await t.pump(const Duration(seconds: 1));
    expect(find.text('おめでとう！'), findsNothing);
  });

  testWidgets('newBadgeId が null ならダイアログなし', (t) async {
    await t.pumpWidget(_wrap(null));
    await t.pump(const Duration(milliseconds: 300));
    expect(find.text('おめでとう！'), findsNothing);
  });
}
