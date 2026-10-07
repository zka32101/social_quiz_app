import 'dart:math';

import '../models/quiz.dart';

/// 選択肢をシャッフルした結果（選択肢と、付け替え後の正解インデックス）。
class ShuffledChoices {
  final List<String> choices;
  final int correctIndex;
  const ShuffledChoices(this.choices, this.correctIndex);
}

/// 「上記のすべて」「どれでもない」など、位置が意味を持つ選択肢は末尾に固定する。
bool isPinnedLastChoice(String s) {
  return s.contains('上記のすべて') ||
      s.contains('上のすべて') ||
      s.contains('どれでもない') ||
      s.contains('どれもあてはまらない') ||
      s.contains('すべて正しい') ||
      s.contains('全部正しい');
}

/// 選択肢をシャッフルし、正解の位置を付け替えて返す。
/// 値ではなくインデックスを並べ替えるので、重複する選択肢があっても正解を見失わない。
/// 元データは正解位置が偏っているので、出題時に必ず通す。
ShuffledChoices shuffleChoices(
  List<String> choices,
  int correctIndex, [
  Random? rng,
]) {
  if (choices.length < 2 ||
      correctIndex < 0 ||
      correctIndex >= choices.length) {
    return ShuffledChoices(List<String>.of(choices), correctIndex);
  }
  final movable = <int>[];
  final pinned = <int>[];
  for (var i = 0; i < choices.length; i++) {
    (isPinnedLastChoice(choices[i]) ? pinned : movable).add(i);
  }
  movable.shuffle(rng ?? Random());
  final order = [...movable, ...pinned];
  return ShuffledChoices([
    for (final i in order) choices[i],
  ], order.indexOf(correctIndex));
}

/// Map形式(choices/options/answers のキーと正解インデックスのキーを指定)の問題用。
Map<String, dynamic> shuffleQuestionMap(
  Map<String, dynamic> q, {
  String choicesKey = 'choices',
  String correctKey = 'correctIndex',
  Random? rng,
}) {
  final raw = q[choicesKey];
  final idx = q[correctKey];
  if (raw is! List || idx is! int) return Map<String, dynamic>.from(q);
  final r = shuffleChoices(List<String>.from(raw), idx, rng);
  return {...q, choicesKey: r.choices, correctKey: r.correctIndex};
}

extension QuizShuffle on Quiz {
  /// 選択肢をシャッフルし正解インデックスを付け替えた Quiz を返す。
  Quiz shuffledChoices([Random? rng]) {
    final r = shuffleChoices(choices, correctIndex, rng);
    return Quiz(
      id: id,
      stepNo: stepNo,
      question: question,
      choices: r.choices,
      correctIndex: r.correctIndex,
      explanation: explanation,
      prefectureId: prefectureId,
      prefectureName: prefectureName,
    );
  }
}

/// 正解を文字列(correctAnswer)で持つ形式用: options だけを並べ替える。
/// 正解の位置は options.indexOf(correctAnswer) で導出されるため自動で追従する。
Map<String, dynamic> shuffleOptionsKeepAnswer(
  Map<String, dynamic> q, {
  String optionsKey = 'options',
  String answerKey = 'correctAnswer',
  Random? rng,
}) {
  final raw = q[optionsKey];
  final ans = q[answerKey];
  if (raw is! List || ans is! String) return Map<String, dynamic>.from(q);
  final opts = List<String>.from(raw);
  final idx = opts.indexOf(ans);
  if (idx < 0) return Map<String, dynamic>.from(q);
  final r = shuffleChoices(opts, idx, rng);
  return {...q, optionsKey: r.choices};
}
