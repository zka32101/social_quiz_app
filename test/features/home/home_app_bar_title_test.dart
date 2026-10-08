import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:social_quiz_app/features/home/widgets/home_app_bar_title.dart';

/// 旧実装(Row[固定幅アバター, SizedBox, Flexible(Text)])の再現用。
Widget _legacyTitle() => Row(children: const [
      SizedBox(width: 32, height: 32),
      SizedBox(width: 6),
      Flexible(child: Text('たろう', overflow: TextOverflow.ellipsis)),
    ]);

Widget _app(double w, double scale, Widget title) => MediaQuery(
      data: MediaQueryData(
          size: Size(w, 800), textScaler: TextScaler.linear(scale)),
      child: MaterialApp(
        home: Scaffold(
          // actions が幅を占有し、title に約30dpしか残らない状況(実機の 320dp + 多数のアイコン相当)
          appBar: AppBar(title: title, actions: [
            Container(width: w - 16 - 30, height: 24, color: Colors.amber),
          ]),
        ),
      ),
    );

void main() {
  for (final w in [320.0, 360.0, 411.0]) {
    for (final s in [1.0, 1.3]) {
      testWidgets('HomeAppBarTitle no overflow w=$w scale=$s', (t) async {
        t.view.devicePixelRatio = 1;
        t.view.physicalSize = Size(w, 800);
        addTearDown(t.view.reset);
        await t.pumpWidget(_app(
            w,
            s,
            const HomeAppBarTitle(
                avatar: SizedBox(width: 32, height: 32), name: 'たろうたろうたろう')));
        expect(t.takeException(), isNull);
      });
    }
  }

  testWidgets('legacy title overflows at 320 (guards the test)', (t) async {
    t.view.devicePixelRatio = 1;
    t.view.physicalSize = const Size(320, 800);
    addTearDown(t.view.reset);
    await t.pumpWidget(_app(320, 1.3, _legacyTitle()));
    expect(t.takeException(), isNotNull);
  });
}
