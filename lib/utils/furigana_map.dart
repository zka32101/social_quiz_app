/// Common difficult kanji used in elementary social studies,
/// mapped to their hiragana readings.
const Map<String, String> kFuriganaMap = {
  '都道府県': 'とどうふけん',
  '農業': 'のうぎょう',
  '漁業': 'ぎょぎょう',
  '工業': 'こうぎょう',
  '商業': 'しょうぎょう',
  '産業': 'さんぎょう',
  '文化': 'ぶんか',
  '歴史': 'れきし',
  '政治': 'せいじ',
  '経済': 'けいざい',
  '国会': 'こっかい',
  '選挙': 'せんきょ',
  '輸出': 'ゆしゅつ',
  '輸入': 'ゆにゅう',
  '貿易': 'ぼうえき',
  '交通': 'こうつう',
  '観光': 'かんこう',
  '人口': 'じんこう',
  '面積': 'めんせき',
  '気候': 'きこう',
  '地形': 'ちけい',
  '河川': 'かせん',
  '自然': 'しぜん',
  '環境': 'かんきょう',
  '資源': 'しげん',
  '伝統': 'でんとう',
  '祭り': 'まつり',
  '先人': 'せんじん',
  '発展': 'はってん',
  '平和': 'へいわ',
  '縄文': 'じょうもん',
  '弥生': 'やよい',
  '飛鳥': 'あすか',
  '奈良': 'なら',
  '平安': 'へいあん',
  '鎌倉': 'かまくら',
  '室町': 'むろまち',
  '江戸': 'えど',
  '明治': 'めいじ',
  '大正': 'たいしょう',
  '昭和': 'しょうわ',
  '令和': 'れいわ',
  '憲法': 'けんぽう',
  '税金': 'ぜいきん',
  '公共': 'こうきょう',
  '福祉': 'ふくし',
  '外交': 'がいこう',
  '条約': 'じょうやく',
  '内閣': 'ないかく',
  '首相': 'しゅしょう',
  '留学': 'りゅうがく',
  '裁判所': 'さいばんしょ',
  '三権分立': 'さんけんぶんりつ',
  '国民主権': 'こくみんしゅけん',
  '基本的人権': 'きほんてきじんけん',
  '衆議院': 'しゅうぎいん',
  '参議院': 'さんぎいん',
  '内閣総理大臣': 'ないかくそうりだいじん',
  '行政': 'ぎょうせい',
  '司法': 'しほう',
  '立法': 'りっぽう',
  '条例': 'じょうれい',
  '国連': 'こくれん',
  '国際連合': 'こくさいれんごう',
  '国際連盟': 'こくさいれんめい',
  '難民': 'なんみん',
  '飢餓': 'きが',
  '発展途上国': 'はってんとじょうこく',
  '先進国': 'せんしんこく',
  '温暖化': 'おんだんか',
  '公害': 'こうがい',
  '循環型社会': 'じゅんかんがたしゃかい',
  '再生可能': 'さいせいかのう',
  '情報化社会': 'じょうほうかしゃかい',
  '少子高齢化': 'しょうしこうれいか',
  '過疎': 'かそ',
  '過密': 'かみつ',
  '養殖': 'ようしょく',
  '畜産': 'ちくさん',
  '製造業': 'せいぞうぎょう',
  '加工': 'かこう',
  '原料': 'げんりょう',
  '流通': 'りゅうつう',
  '運搬': 'うんぱん',
  '干拓': 'かんたく',
  '盆地': 'ぼんち',
  '半島': 'はんとう',
  '海流': 'かいりゅう',
  '梅雨': 'つゆ',
  '台風': 'たいふう',
  '災害': 'さいがい',
  '防災': 'ぼうさい',
  '避難': 'ひなん',
  '古墳': 'こふん',
  '幕府': 'ばくふ',
  '武士': 'ぶし',
  '将軍': 'しょうぐん',
  '開国': 'かいこく',
  '鎖国': 'さこく',
  '藩': 'はん',
  '身分制度': 'みぶんせいど',
  '納税': 'のうぜい',
  '義務教育': 'ぎむきょういく',
};

/// Extension on [String] to convert kanji found in [kFuriganaMap]
/// into annotated form: "漢字[かんじ]".
///
/// Example:
/// ```dart
/// '農業と漁業'.withRuby
/// // returns '農業[のうぎょう]と漁業[ぎょぎょう]'
/// ```
extension FuriganaExtension on String {
  String get withRuby {
    // Sort keys by length descending so longer matches take priority.
    final sortedKeys = kFuriganaMap.keys.toList()
      ..sort((a, b) => b.length.compareTo(a.length));

    String result = this;
    for (final kanji in sortedKeys) {
      final reading = kFuriganaMap[kanji]!;
      // Replace all occurrences that are not already annotated.
      // We avoid double-annotating by checking the character after the match
      // is not '['.
      result = result.splitMapJoin(
        kanji,
        onMatch: (m) {
          final matchEnd = m.end;
          // Check if already followed by '['
          if (matchEnd < result.length && result[matchEnd] == '[') {
            return m.group(0)!;
          }
          return '$kanji[$reading]';
        },
        onNonMatch: (s) => s,
      );
    }
    return result;
  }
}
