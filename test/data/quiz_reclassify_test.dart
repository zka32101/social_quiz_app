import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

List<Map<String, dynamic>> _load(String name) =>
    (jsonDecode(File('assets/data/$name').readAsStringSync()) as List)
        .cast<Map<String, dynamic>>();

void main() {
  test('知事の任期の問題は地方自治(civics/local_government)に分類される', () {
    final civics = _load('quizzes_civics.json');
    final grade4 = _load('quizzes_grade4.json');
    bool isTerm(Map<String, dynamic> q) =>
        (q['question'] as String).contains('知事の任期');
    final moved = civics.where(isTerm).toList();
    expect(moved, hasLength(1));
    expect(moved.single['id'], 'cv_021');
    expect(moved.single['subcategory'], 'local_government');
    expect(grade4.where(isTerm), isEmpty);
    expect(grade4.any((q) => q['id'] == 'g4_036'), isFalse);
  });

  test('全クイズのIDが重複しない', () {
    final ids = <String>[];
    for (final f in Directory('assets/data').listSync()) {
      final name = f.uri.pathSegments.last;
      if (!name.startsWith('quizzes_') || !name.endsWith('.json')) continue;
      ids.addAll(_load(name).map((q) => q['id'] as String));
    }
    expect(ids.toSet().length, ids.length);
  });
}
