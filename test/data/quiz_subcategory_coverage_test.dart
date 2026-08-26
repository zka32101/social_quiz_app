import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

/// quizzes_civics.json / quizzes_industry.json の各設問には subcategory が
/// 付いているが、画面側（civics_screen.dart / industry_screen.dart の
/// _sections、civics_quiz_screen.dart / industry_quiz_screen.dart の
/// _sectionTitles）にそのIDのセクションが無いと、設問が一切出題されない
/// まま埋もれてしまう（実際に local_government / industrial_zones が
/// この状態で見つかった）。
///
/// _sections/_sectionTitles は画面ファイルにprivateなためここから直接
/// 参照できないので、その代わりにJSON側のsubcategory集合を「対応する
/// セクションを画面側に用意した」既知の集合と突き合わせる。新しい
/// subcategoryを追加したのに画面側にセクションを足し忘れると、この
/// テストが失敗して気づける。
void main() {
  Set<String> subcategoriesIn(String path) {
    final data = jsonDecode(File(path).readAsStringSync()) as List<dynamic>;
    return data
        .cast<Map<String, dynamic>>()
        .map((q) => q['subcategory'] as String)
        .toSet();
  }

  test('quizzes_civics.json の全subcategoryに対応するセクションがある', () {
    const sectionsWithUi = {
      'constitution',
      'separation_of_powers',
      'national_assembly',
      'taxes',
      'elections',
      'local_government',
    };
    expect(subcategoriesIn('assets/data/quizzes_civics.json'), sectionsWithUi);
  });

  test('quizzes_industry.json の全subcategoryに対応するセクションがある', () {
    const sectionsWithUi = {
      'agriculture',
      'fishery',
      'manufacturing',
      'industrial_zones',
      'food_self_sufficiency',
      'pollution',
      'information_society',
    };
    expect(
        subcategoriesIn('assets/data/quizzes_industry.json'), sectionsWithUi);
  });
}
