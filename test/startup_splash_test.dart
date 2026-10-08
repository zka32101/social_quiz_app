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
}
