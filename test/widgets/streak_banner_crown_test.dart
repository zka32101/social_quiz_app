import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:social_quiz_app/features/home/widgets/streak_banner.dart';

void main() {
  for (final d in [6, 7, 14, 30]) {
    testWidgets('StreakBanner crown, no overflow at 320px (days=$d)', (tester) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(MaterialApp(home: Scaffold(body: StreakBanner(streak: d))));
      await tester.pump();
      expect(tester.takeException(), isNull);
      expect(find.byKey(const Key('streak_crown')),
          d == 6 ? findsNothing : findsOneWidget);
    });
  }
}
