import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:social_quiz_app/data/explain_images.dart';

void main() {
  test('economics/international fall back to learn images that exist', () {
    for (final id in ['seiji', 'senkyo', 'zeikin', 'sangyo', 'boeki', 'kankyo']) {
      final p = quizExplainImage('economics', id)!;
      expect(File(p).existsSync(), isTrue, reason: p);
    }
    for (final id in ['un', 'sdgs', 'contribution', 'world_issues', 'culture', 'global_citizen']) {
      final p = quizExplainImage('international', id)!;
      expect(File(p).existsSync(), isTrue, reason: p);
      expect(learnExplainImage(id), p);
    }
    expect(quizExplainImage('economics', 'nope'), isNull);
  });

  test('map symbols images', () {
    expect(mapSymbolsImage('学校をあらわす地図記号はどれですか？'), endsWith('_town.jpg'));
    expect(mapSymbolsImage('畑（はたけ）をあらわす地図記号はどれですか？'), endsWith('_country.jpg'));
    expect(mapSymbolsImage('灯台（とうだい）をあらわす地図記号はどれですか？'), endsWith('_sea.jpg'));
    expect(mapSymbolsImage('地図で「北（きた）」はふつうどの方向ですか？'), isNull);
    for (final k in ['town', 'country', 'sea']) {
      expect(File('assets/images/explain/quiz/grade3_map_symbols_$k.jpg').existsSync(), isTrue);
    }
  });
}
