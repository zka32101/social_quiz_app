import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:social_quiz_app/models/quiz.dart';
import 'package:social_quiz_app/utils/shuffle_choices.dart';

void main() {
  group('shuffleChoices', () {
    test('正解の文字列が付け替え後のインデックスでも同じ', () {
      final rng = Random(1);
      for (var n = 0; n < 200; n++) {
        const choices = ['A', 'B', 'C', 'D'];
        final c = n % 4;
        final r = shuffleChoices(choices, c, rng);
        expect(r.choices.toSet(), choices.toSet());
        expect(r.choices[r.correctIndex], choices[c]);
      }
    });

    test('3択でも動く', () {
      final r = shuffleChoices(['x', 'y', 'z'], 2, Random(3));
      expect(r.choices.length, 3);
      expect(r.choices[r.correctIndex], 'z');
    });

    test('重複する選択肢があっても正解の元位置を追従する', () {
      // 同じ文字列が2つ。正解は2番目の "同じ"(index 1)
      final choices = ['同じ', '同じ', 'ちがう', 'べつ'];
      for (var seed = 0; seed < 50; seed++) {
        final r = shuffleChoices(choices, 1, Random(seed));
        expect(r.choices[r.correctIndex], '同じ');
        expect(r.choices.length, 4);
      }
    });

    test('「上記のすべて」「どれでもない」は末尾に固定', () {
      for (var seed = 0; seed < 50; seed++) {
        final r = shuffleChoices(['あ', 'い', 'う', '上記のすべて'], 3, Random(seed));
        expect(r.choices.last, '上記のすべて');
        expect(r.correctIndex, 3);
        final r2 = shuffleChoices(['あ', 'い', 'う', 'どれでもない'], 1, Random(seed));
        expect(r2.choices.last, 'どれでもない');
        expect(r2.choices[r2.correctIndex], 'い');
      }
    });

    test('不正な入力はそのまま返す', () {
      expect(shuffleChoices(['a'], 0).correctIndex, 0);
      expect(shuffleChoices(['a', 'b'], 5).correctIndex, 5);
    });

    test('正解が常に先頭の問題でも、位置が各選択肢に散らばる', () {
      final rng = Random(42);
      final counts = List<int>.filled(4, 0);
      for (var i = 0; i < 4000; i++) {
        counts[shuffleChoices(['a', 'b', 'c', 'd'], 0, rng).correctIndex]++;
      }
      for (final c in counts) {
        expect(c, inInclusiveRange(800, 1200));
      }
    });
  });

  group('shuffleOptionsKeepAnswer', () {
    test('correctAnswer は変えず options だけ並べ替える', () {
      final Map<String, dynamic> q = {
        'id': 'q1',
        'options': ['東京', '大阪', '京都', '奈良'],
        'correctAnswer': '京都',
      };
      for (var seed = 0; seed < 30; seed++) {
        final r = shuffleOptionsKeepAnswer(q, rng: Random(seed));
        expect(r['correctAnswer'], '京都');
        expect((r['options'] as List).toSet(), (q['options'] as List).toSet());
        expect(r['id'], 'q1');
      }
      expect(q['options'], ['東京', '大阪', '京都', '奈良']); // 元は変更しない
    });

    test('正解が options に無いデータはそのまま返す', () {
      final Map<String, dynamic> q = {'options': ['a', 'b'], 'correctAnswer': 'z'};
      expect(shuffleOptionsKeepAnswer(q)['options'], ['a', 'b']);
    });
  });

  group('shuffleQuestionMap / Quiz.shuffledChoices', () {
    test('map形式の正解インデックスを付け替える', () {
      final Map<String, dynamic> q = {'choices': ['a', 'b', 'c', 'd'], 'correctIndex': 1, 'x': 1};
      final r = shuffleQuestionMap(q, rng: Random(7));
      expect((r['choices'] as List)[r['correctIndex'] as int], 'b');
      expect(r['x'], 1);
    });

    test('Quiz は他のフィールドを保ったまま正解を追従する', () {
      const quiz = Quiz(
        id: 'q',
        stepNo: 2,
        question: '?',
        choices: ['a', 'b', 'c'],
        correctIndex: 0,
        explanation: 'e',
        prefectureId: 'tokyo',
      );
      for (var seed = 0; seed < 30; seed++) {
        final s = quiz.shuffledChoices(Random(seed));
        expect(s.correctAnswer, 'a');
        expect(s.stepNo, 2);
        expect(s.prefectureId, 'tokyo');
        expect(s.id, 'q');
      }
    });
  });
}
