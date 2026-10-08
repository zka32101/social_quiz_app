import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:social_quiz_app/widgets/startup_splash.dart';

void main() {
  testWidgets('起動画面: 中央に教科アイコン、下に組織ロゴ（1枚構成）', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: StartupSplash()));
    await tester.pump(const Duration(milliseconds: 1300));
    expect(find.text('小学コレ！社会'), findsOneWidget);
    expect(find.text('Your Wish'), findsOneWidget);
    final icon = tester.getCenter(find.byKey(const ValueKey('splash_app_icon')));
    final logo = tester.getCenter(find.byKey(const ValueKey('splash_company_logo')));
    expect(logo.dy, greaterThan(icon.dy));
    expect(tester.takeException(), isNull);
  });
}
