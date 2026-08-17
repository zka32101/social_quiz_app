import 'package:flutter/material.dart';

/// A single labeled row shown across both columns of a
/// [ComparisonColumnsDiagram], e.g. "定数" → "465人" / "248人".
class ComparisonRow {
  final String label;
  final String leftValue;
  final String rightValue;

  const ComparisonRow({
    required this.label,
    required this.leftValue,
    required this.rightValue,
  });
}

/// A simple two-column comparison table used for civics concepts that are
/// best understood side by side, e.g. 衆議院 vs 参議院. Wraps each column in
/// its own tinted card with a header, and lines up the same [ComparisonRow]
/// across both columns.
class ComparisonColumnsDiagram extends StatelessWidget {
  final String leftTitle;
  final String rightTitle;
  final Color leftColor;
  final Color rightColor;
  final List<ComparisonRow> rows;

  const ComparisonColumnsDiagram({
    super.key,
    required this.leftTitle,
    required this.rightTitle,
    required this.leftColor,
    required this.rightColor,
    required this.rows,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _column(leftTitle, leftColor, isLeft: true)),
        const SizedBox(width: 10),
        Expanded(child: _column(rightTitle, rightColor, isLeft: false)),
      ],
    );
  }

  Widget _column(String title, Color color, {required bool isLeft}) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: color,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          for (final row in rows)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Column(
                children: [
                  Text(
                    row.label,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11,
                      color: color.withOpacity(0.9),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    isLeft ? row.leftValue : row.rightValue,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF333333),
                    ),
                  ),
                  const Divider(height: 14),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
