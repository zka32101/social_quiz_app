import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('小3 地図記号クイズの正解が正しい', () {
    final list = jsonDecode(
            File('assets/data/quizzes_grade3.json').readAsStringSync())
        as List;
    final byId = {for (final q in list) q['id']: q as Map};
    expect(byId['g3_001']!['correctAnswer'], '文'); // 学校
    expect(byId['g3_004']!['correctAnswer'], '✖'); // 交番
    for (final q in list.where((q) => q['subcategory'] == 'map_symbols')) {
      expect(q['options'], contains(q['correctAnswer']));
    }
  });
}
