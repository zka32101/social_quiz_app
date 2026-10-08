import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:social_quiz_app/widgets/startup_splash.dart';

void main() {
  testWidgets('起動画面: 白背景にアプリアイコン・シリーズロゴ・組織ロゴ', (tester) async {
    await tester.pumpWidget(const MaterialApp(
        themeMode: ThemeMode.dark,
        darkTheme: null,
        home: StartupSplash()));
    await tester.pump();
    expect(find.byKey(const ValueKey('splash_app_icon')), findsOneWidget);
    expect(find.byKey(const ValueKey('splash_series_logo')), findsOneWidget);
    expect(find.byKey(const ValueKey('splash_org_logo')), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
    expect(scaffold.backgroundColor, const Color(0xFFFFFFFF));
    final icon = tester.getCenter(find.byKey(const ValueKey('splash_app_icon')));
    final series = tester.getCenter(find.byKey(const ValueKey('splash_series_logo')));
    final org = tester.getCenter(find.byKey(const ValueKey('splash_org_logo')));
    expect(series.dy, greaterThan(icon.dy));
    expect(org.dy, greaterThan(series.dy));
  });

  testWidgets('起動画面: 小画面(360x600)でも溢れず、ロゴが大きい', (tester) async {
    tester.view.physicalSize = const Size(360, 600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const MaterialApp(home: StartupSplash()));
    await tester.pump();
    expect(tester.takeException(), isNull);
    expect(tester.getSize(find.byKey(const ValueKey('splash_app_icon'))).width, 168);
    expect(tester.getSize(find.byKey(const ValueKey('splash_series_logo'))).width, 260);
    expect(tester.getSize(find.byKey(const ValueKey('splash_org_logo'))).height, 84);
  });
}
