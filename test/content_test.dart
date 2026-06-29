import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:social_quiz_app/repositories/content_repository.dart';
import 'package:social_quiz_app/utils/constants.dart';

void main() {
  late Directory tempDir;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    tempDir = await Directory.systemTemp.createTemp('hive_content_test_');
    Hive.init(tempDir.path);
    await Hive.openBox(AppConstants.contentBoxName);

    // assets/data/ を FlutterTest に登録
    final bundle = TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    bundle.setMockMethodCallHandler(
      const MethodChannel('flutter/assets'),
      null,
    );
  });

  tearDownAll(() async {
    await Hive.close();
    await tempDir.delete(recursive: true);
  });

  group('hokkaido.json の読み込みテスト', () {
    test('都道府県一覧が 14 件返る', () async {
      final repo = ContentRepository();
      final list = await repo.getPrefectures();
      expect(list.length, 14);
      expect(list.first.id, 'hokkaido');
      expect(list.first.name, '北海道');
    });

    test('学習ステップが 3 件あり各カードが存在する', () async {
      final repo = ContentRepository();
      final steps = await repo.getStudySteps('hokkaido');
      expect(steps.length, 3);
      expect(steps[0].title, '基本情報');
      expect(steps[1].title, '産業');
      expect(steps[2].title, '文化・観光・先人');
      // 各ステップのカード数確認
      expect(steps[0].cards.length, greaterThan(0));
      expect(steps[1].cards.length, greaterThan(0));
      expect(steps[2].cards.length, greaterThan(0));
    });

    test('クイズが 10 問あり正解インデックスが正しい範囲', () async {
      final repo = ContentRepository();
      final quizzes = await repo.getQuizzes('hokkaido');
      expect(quizzes.length, 10);
      for (final q in quizzes) {
        expect(q.correctIndex, greaterThanOrEqualTo(0));
        expect(q.correctIndex, lessThan(q.choices.length));
        expect(q.choices.length, 4);
        expect(q.question.isNotEmpty, true);
        expect(q.explanation.isNotEmpty, true);
      }
    });

    test('q1 の正解は 0（1番目・最大）', () async {
      final repo = ContentRepository();
      final quizzes = await repo.getQuizzes('hokkaido');
      final q1 = quizzes.firstWhere((q) => q.id == 'hokkaido_q1');
      expect(q1.correctIndex, 0);
      expect(q1.choices[0], '1番目（最大）');
    });

    test('q4 の正解は約80%（インデックス 2）', () async {
      final repo = ContentRepository();
      final quizzes = await repo.getQuizzes('hokkaido');
      final q4 = quizzes.firstWhere((q) => q.id == 'hokkaido_q4');
      expect(q4.correctIndex, 2);
      expect(q4.choices[2], '約80%');
    });
  });

  group('スタブ県のフォールバック', () {
    test('JSON なし県はフォールバックの 3 ステップを返す', () async {
      final repo = ContentRepository();
      // aomori は stub JSON あり
      final steps = await repo.getStudySteps('aomori');
      expect(steps.length, 3);
    });
  });
}
