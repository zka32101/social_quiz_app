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
