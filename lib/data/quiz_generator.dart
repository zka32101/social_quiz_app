// quiz_generator.dart
// 都道府県データから自動でクイズ10問を生成する
// Firebase / JSON なしで全47都道府県対応

import 'dart:math';
import '../models/quiz.dart';
import 'prefecture_data.dart';

const _regionFullNames = <String, String>{
  'hokkaido': '北海道地方',
  'tohoku':   '東北地方',
  'kanto':    '関東地方',
  'chubu':    '中部地方',
  'kinki':    '近畿地方',
  'chugoku':  '中国地方',
  'shikoku':  '四国地方',
  'kyushu':   '九州・沖縄地方',
};

class QuizGenerator {
  /// 都道府県IDから10問のクイズを生成（決定論的）
  static List<Quiz> forPrefecture(String prefId) {
    final pref = PrefectureDataList.findById(prefId);
    if (pref == null) return [];

    final all  = PrefectureDataList.all;
    final others      = all.where((p) => p.id != prefId).toList();
    final sameRegion  = others.where((p) => p.region == pref.region).toList();
    final diffRegion  = others.where((p) => p.region != pref.region).toList();

    final quizzes = <Quiz>[];

    // ── Step 1：基本知識 ──────────────────────────────────────────

    // Q1: 県庁所在地
    {
      final wrong = _pick(others, 3, seed: _s(prefId, 1))
          .map((p) => p.capital)
          .where((c) => c != pref.capital)
          .take(3)
          .toList();
      quizzes.add(_q(
        id: '${prefId}_g01', stepNo: 1,
        question: '${pref.name}の県庁所在地はどこ？',
        correct: pref.capital,
        wrong: wrong,
        explanation: '${pref.name}の県庁所在地は${pref.capital}です。',
        seed: _s(prefId, 1),
      ));
    }

    // Q2: 地方
    {
      final correctR = _regionFullNames[pref.region] ?? pref.region;
      final wrongR   = _regionFullNames.values
          .where((r) => r != correctR)
          .toList()
        ..shuffle(Random(_s(prefId, 2)));
      quizzes.add(_q(
        id: '${prefId}_g02', stepNo: 1,
        question: '${pref.name}はどの地方に属しますか？',
        correct: correctR,
        wrong: wrongR.take(3).toList(),
        explanation: '${pref.name}は${correctR}にあります。',
        seed: _s(prefId, 2),
      ));
    }

    // Q3: 名産品①（○○県の名産品はどれ？）
    {
      final cs = pref.specialties[0];
      final ws = _otherSpecialties(pref, others, count: 3, seed: _s(prefId, 3));
      quizzes.add(_q(
        id: '${prefId}_g03', stepNo: 1,
        question: '${pref.name}の名産品はどれ？',
        correct: cs,
        wrong: ws,
        explanation: '${pref.name}では${pref.specialties.take(3).join('・')}などが有名です。',
        seed: _s(prefId, 3),
      ));
    }

    // Q4: 名産品②（もう1品）
    {
      final idx = pref.specialties.length > 1 ? 1 : 0;
      final cs  = pref.specialties[idx];
      final ws  = _otherSpecialties(pref, others, count: 3, seed: _s(prefId, 4));
      quizzes.add(_q(
        id: '${prefId}_g04', stepNo: 1,
        question: '${pref.name}で有名な食べ物・特産品はどれ？',
        correct: cs,
        wrong: ws,
        explanation: '${pref.name}では$csが有名です。',
        seed: _s(prefId, 4),
      ));
    }

    // ── Step 2：産業・文化 ──────────────────────────────────────

    // Q5: 名産品逆問①（名産品名→県名を答える）
    {
      final sp  = pref.specialties.length > 2 ? pref.specialties[2] : pref.specialties.last;
      final wp  = _pickNames(others, 3, seed: _s(prefId, 5));
      quizzes.add(_q(
        id: '${prefId}_g05', stepNo: 2,
        question: '「$sp」が名物の都道府県はどこ？',
        correct: pref.name,
        wrong: wp,
        explanation: '「$sp」は${pref.name}の名物・特産品です。',
        seed: _s(prefId, 5),
      ));
    }

    // Q6: 名産品逆問②
    {
      final sp = pref.specialties.length > 3 ? pref.specialties[3] : pref.specialties[0];
      final pool = sameRegion.isNotEmpty ? sameRegion : others;
      final wp  = _pickNames(pool, 3, seed: _s(prefId, 6));
      quizzes.add(_q(
        id: '${prefId}_g06', stepNo: 2,
        question: '「$sp」で知られる都道府県はどれ？',
        correct: pref.name,
        wrong: wp,
        explanation: '${pref.name}は$spが有名です。',
        seed: _s(prefId, 6),
      ));
    }

    // Q7: 説明文当て（都道府県名を答える）
    {
      final desc = pref.description.split('。').first + '。';
      final pool = sameRegion.isNotEmpty ? sameRegion : others;
      final wp   = _pickNames(pool, 3, seed: _s(prefId, 7));
      quizzes.add(_q(
        id: '${prefId}_g07', stepNo: 2,
        question: 'この説明はどこの都道府県のこと？\n「$desc」',
        correct: pref.name,
        wrong: wp,
        explanation: 'この説明は${pref.name}のことです。',
        seed: _s(prefId, 7),
      ));
    }

    // Q8: 豆知識当て（都道府県名を答える）
    {
      final fact = pref.funFact.split('。').first + '。';
      final wp   = _pickNames(diffRegion, 3, seed: _s(prefId, 8));
      quizzes.add(_q(
        id: '${prefId}_g08', stepNo: 2,
        question: 'この豆知識はどこの都道府県のこと？\n「$fact」',
        correct: pref.name,
        wrong: wp,
        explanation: 'これは${pref.name}の豆知識です。${pref.funFact}',
        seed: _s(prefId, 8),
      ));
    }

    // ── Step 3：まとめ ───────────────────────────────────────────

    // Q9: 名産品「でないものはどれ？」（ひっかけ）
    {
      final notMine = _otherSpecialties(pref, others, count: 1, seed: _s(prefId, 9)).first;
      final actual  = pref.specialties
          .where((s) => s != notMine)
          .take(3)
          .toList();
      final choices  = [...actual, notMine];
      choices.shuffle(Random(_s(prefId, 9)));
      quizzes.add(Quiz(
        id: '${prefId}_g09', stepNo: 3,
        question: '次のうち、${pref.name}の名産品で「ない」のはどれ？',
        choices: choices,
        correctIndex: choices.indexOf(notMine),
        explanation:
            '${pref.name}の名産品は${pref.specialties.take(5).join('・')}などです。'
            '$notMineは別の都道府県のものです。',
      ));
    }

    // Q10: 同じ地方の都道府県（またはもう1問の逆問）
    {
      if (sameRegion.isNotEmpty) {
        final samePref = _pick(sameRegion, 1, seed: _s(prefId, 10)).first;
        final wp       = _pickNames(diffRegion, 3, seed: _s(prefId, 10));
        final regionN  = _regionFullNames[pref.region] ?? pref.region;
        quizzes.add(_q(
          id: '${prefId}_g10', stepNo: 3,
          question: '${pref.name}と同じ地方（$regionN）の都道府県はどれ？',
          correct: samePref.name,
          wrong: wp,
          explanation:
              '${pref.name}と${samePref.name}はどちらも${regionN}にあります。',
          seed: _s(prefId, 10),
        ));
      } else {
        // 北海道など同地方がない場合は追加の名産品逆問
        final sp = pref.specialties.length > 4 ? pref.specialties[4] : pref.specialties.last;
        final wp = _pickNames(others, 3, seed: _s(prefId, 10));
        quizzes.add(_q(
          id: '${prefId}_g10', stepNo: 3,
          question: '「$sp」が有名な都道府県はどこ？',
          correct: pref.name,
          wrong: wp,
          explanation: '${pref.name}では$spが有名です。',
          seed: _s(prefId, 10),
        ));
      }
    }

    return quizzes;
  }

  // ─── 内部ヘルパー ───────────────────────────────────────────────

  /// シード値（prefecture + question番号で一意）
  static int _s(String prefId, int q) => prefId.hashCode ^ (q * 1000003);

  /// クイズを作成（正解と不正解をシャッフル）
  static Quiz _q({
    required String id,
    required int stepNo,
    required String question,
    required String correct,
    required List<String> wrong,
    required String explanation,
    required int seed,
  }) {
    final choices = [correct, ...wrong.take(3).where((w) => w != correct)];
    // 4択に満たない場合の補填
    while (choices.length < 4) {
      choices.add('—');
    }
    choices.shuffle(Random(seed));
    return Quiz(
      id: id,
      stepNo: stepNo,
      question: question,
      choices: choices,
      correctIndex: choices.indexOf(correct),
      explanation: explanation,
    );
  }

  /// プールからN個の都道府県を選択（決定論的）
  static List<PrefectureData> _pick(List<PrefectureData> pool, int count,
      {required int seed}) {
    final copy = List<PrefectureData>.from(pool);
    copy.shuffle(Random(seed));
    return copy.take(count).toList();
  }

  /// プールからN個の都道府県名を選択（決定論的）
  static List<String> _pickNames(List<PrefectureData> pool, int count,
      {required int seed}) {
    return _pick(pool, count, seed: seed).map((p) => p.name).toList();
  }

  /// 対象都道府県の名産品以外からN個の名産品を選択
  static List<String> _otherSpecialties(
    PrefectureData pref,
    List<PrefectureData> others, {
    required int count,
    required int seed,
  }) {
    final all = others
        .expand((p) => p.specialties)
        .where((s) => !pref.specialties.contains(s))
        .toSet()
        .toList()
      ..shuffle(Random(seed));
    return all.take(count).toList();
  }
}
