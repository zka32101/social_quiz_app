import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:social_quiz_app/app.dart';
import 'package:social_quiz_app/utils/constants.dart';

void main() {
  late Directory tempDir;

  setUpAll(() async {
    // テスト用の一時ディレクトリで Hive を初期化
    tempDir = await Directory.systemTemp.createTemp('hive_test_');
    Hive.init(tempDir.path);
    await Hive.openBox(AppConstants.contentBoxName);
    await Hive.openBox(AppConstants.settingsBoxName);
    await Hive.openBox(AppConstants.quizHistoryBoxName);
  });

  tearDownAll(() async {
    await Hive.close();
    await tempDir.delete(recursive: true);
  });

  testWidgets('スプラッシュ画面が表示される', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: SocialQuizApp()),
    );

    // MaterialApp が存在することを確認
    expect(find.byType(MaterialApp), findsOneWidget);

    // スプラッシュ画面のタイトルテキストを確認
    expect(find.text('小学コレ！社会'), findsOneWidget);

    // SplashScreen の 1800ms タイマーを消費してテストを正常終了させる
    await tester.pump(const Duration(milliseconds: 1800));
    await tester.pump(); // GoRouter のナビゲーション処理
  });
}
