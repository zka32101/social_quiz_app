import 'package:flutter/material.dart';

/// A pair of kanji text and its furigana (ruby) reading.
class RubyPair {
  final String text;
  final String ruby;

  const RubyPair({required this.text, required this.ruby});
}

/// Displays kanji text with small furigana (ruby) above each pair.
///
/// Example:
/// ```dart
/// RubyText(pairs: [
///   RubyPair(text: '都道府県', ruby: 'とどうふけん'),
///   RubyPair(text: 'を', ruby: ''),
///   RubyPair(text: '学', ruby: 'まな'),
///   RubyPair(text: 'ぼう', ruby: ''),
/// ])
/// ```
class RubyText extends StatelessWidget {
  final List<RubyPair> pairs;
  final double rubyFontSize;
  final double textFontSize;
  final Color? textColor;
  final Color? rubyColor;
  final FontWeight? fontWeight;

  const RubyText({
    super.key,
    required this.pairs,
    this.rubyFontSize = 10.0,
    this.textFontSize = 16.0,
    this.textColor,
    this.rubyColor,
    this.fontWeight,
  });

  /// Parse annotated string like "都道府県[とどうふけん]を学[まな]ぼう"
  /// into a list of RubyPair objects.
  factory RubyText.fromAnnotated(
    String annotated, {
    Key? key,
    double rubyFontSize = 10.0,
    double textFontSize = 16.0,
    Color? textColor,
    Color? rubyColor,
    FontWeight? fontWeight,
  }) {
    final pairs = _parseAnnotated(annotated);
    return RubyText(
      key: key,
      pairs: pairs,
      rubyFontSize: rubyFontSize,
      textFontSize: textFontSize,
      textColor: textColor,
      rubyColor: rubyColor,
      fontWeight: fontWeight,
    );
  }

  static List<RubyPair> _parseAnnotated(String annotated) {
    final pairs = <RubyPair>[];
    // Simpler token-based parsing
    final buffer = StringBuffer();
    int i = 0;
    while (i < annotated.length) {
      if (annotated[i] == '[') {
        // Read until closing bracket
        final start = i + 1;
        final end = annotated.indexOf(']', start);
        if (end == -1) {
          // Malformed: no closing bracket, treat rest as plain text
          buffer.write(annotated.substring(i));
          i = annotated.length;
        } else {
          final ruby = annotated.substring(start, end);
          final text = buffer.toString();
          buffer.clear();
          if (text.isNotEmpty) {
            pairs.add(RubyPair(text: text, ruby: ruby));
          }
          i = end + 1;
        }
      } else {
        // Check if next char starts a bracket — if so, accumulate separately
        // We want each plain character before '[' to become its own pair if
        // the bracket follows immediately, but group plain runs without brackets.
        final nextBracket = annotated.indexOf('[', i);
        if (nextBracket == -1) {
          // No more brackets — rest is plain text
          buffer.write(annotated.substring(i));
          i = annotated.length;
        } else {
          // Find the kanji segment before the next bracket.
          // The character(s) immediately before '[' are the annotated kanji.
          // Characters before them (if any) are plain text runs.
          // Strategy: accumulate until we hit '[', then the last "word" before
          // '[' is the kanji that gets the ruby from the bracket.
          // For simplicity, accumulate one character at a time.
          buffer.write(annotated[i]);
          i++;
        }
      }
    }
    // Any remaining buffer is plain text with no ruby
    if (buffer.isNotEmpty) {
      // Split remaining plain text into individual characters or keep as block
      pairs.add(RubyPair(text: buffer.toString(), ruby: ''));
    }
    return _mergeConsecutivePlain(pairs);
  }

  /// Merge consecutive RubyPair entries that have no ruby into single entries
  /// to reduce widget count for plain kana/punctuation runs.
  static List<RubyPair> _mergeConsecutivePlain(List<RubyPair> pairs) {
    final merged = <RubyPair>[];
    final buffer = StringBuffer();
    for (final pair in pairs) {
      if (pair.ruby.isEmpty) {
        buffer.write(pair.text);
      } else {
        if (buffer.isNotEmpty) {
          merged.add(RubyPair(text: buffer.toString(), ruby: ''));
          buffer.clear();
        }
        merged.add(pair);
      }
    }
    if (buffer.isNotEmpty) {
      merged.add(RubyPair(text: buffer.toString(), ruby: ''));
    }
    return merged;
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.end,
      children: pairs.map((pair) => _buildPair(pair)).toList(),
    );
  }

  Widget _buildPair(RubyPair pair) {
    final effectiveTextColor = textColor ?? Colors.black;
    final effectiveRubyColor = rubyColor ?? Colors.black87;

    if (pair.ruby.isEmpty) {
      // No ruby: just render the text with bottom-aligned padding to match
      // the height of ruby+kanji blocks.
      return Padding(
        padding: EdgeInsets.only(top: rubyFontSize + 2),
        child: Text(
          pair.text,
          style: TextStyle(
            fontSize: textFontSize,
            color: effectiveTextColor,
            fontWeight: fontWeight,
            height: 1.0,
          ),
        ),
      );
    }

    return IntrinsicWidth(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Ruby text on top
          Text(
            pair.ruby,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: rubyFontSize,
              color: effectiveRubyColor,
              height: 1.0,
            ),
          ),
          const SizedBox(height: 1),
          // Kanji text below
          Text(
            pair.text,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: textFontSize,
              color: effectiveTextColor,
              fontWeight: fontWeight,
              height: 1.0,
            ),
          ),
        ],
      ),
    );
  }
}

/// Returns a [WidgetSpan] containing a ruby-annotated text widget.
/// Useful for embedding within a [Text.rich] or [RichText].
WidgetSpan rubySpan(
  String text,
  String ruby, {
  double rubyFontSize = 10.0,
  double textFontSize = 16.0,
  Color? textColor,
  Color? rubyColor,
  FontWeight? fontWeight,
}) {
  return WidgetSpan(
    alignment: PlaceholderAlignment.baseline,
    baseline: TextBaseline.alphabetic,
    child: RubyText(
      pairs: [RubyPair(text: text, ruby: ruby)],
      rubyFontSize: rubyFontSize,
      textFontSize: textFontSize,
      textColor: textColor,
      rubyColor: rubyColor,
      fontWeight: fontWeight,
    ),
  );
}
