import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
// ignore: depend_on_referenced_packages
import 'package:hive/hive.dart';
// ignore: depend_on_referenced_packages
import 'package:shared_preferences/shared_preferences.dart';
import 'package:social_quiz_app/features/shop/decor/decor_scope.dart';
import 'package:social_quiz_app/widgets/avatar_display_widget.dart';

Widget _app(String? frame, {double scale = 1.0}) => ProviderScope(
      child: MaterialApp(
        builder: (c, child) => MediaQuery(
          data: MediaQuery.of(c).copyWith(textScaler: TextScaler.linear(scale)),
          child: DecorScope(hasBackground: false, frameAsset: frame, child: child!),
        ),
        home: Scaffold(
          appBar: AppBar(
            title: const Row(children: [
              AvatarDisplayTiny(),
              SizedBox(width: 6),
              Flexible(child: Text('なまえ', overflow: TextOverflow.ellipsis)),
            ]),
          ),
        ),
      ),
    );

void main() {
  setUpAll(() async {
    Hive.init(Directory.systemTemp.createTempSync('decor_frame_').path);
    await Hive.openBox('profiles');
  });

  for (final frame in <String?>[null, 'assets/shop/frame_star.webp']) {
    for (final scale in [1.0, 1.5]) {
      testWidgets('AppBarの小アバター: frame=$frame scale=$scale でoverflowしない・寸法32', (t) async {
        SharedPreferences.setMockInitialValues({});
        await t.pumpWidget(_app(frame, scale: scale));
        await t.pump(const Duration(milliseconds: 50));
        expect(t.takeException(), isNull);
        expect(t.getSize(find.byType(DecorFrame)), const Size(32, 32));
      });
    }
  }
}
