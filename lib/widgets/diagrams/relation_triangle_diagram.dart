import 'package:flutter/material.dart';

/// A node (corner) of a [RelationTriangleDiagram], e.g. 国会 / 内閣 / 裁判所.
class TriangleNode {
  final String label;
  final IconData icon;
  final Color color;

  const TriangleNode({
    required this.label,
    required this.icon,
    required this.color,
  });
}

/// A single directional relation shown in the legend below the triangle,
/// e.g. "国会 → 内閣：内閣総理大臣の指名".
class TriangleRelation {
  /// Index into the diagram's [RelationTriangleDiagram.nodes] list this
  /// relation points *from*.
  final int fromIndex;

  /// Index into the diagram's [RelationTriangleDiagram.nodes] list this
  /// relation points *to*.
  final int toIndex;

  final String description;

  const TriangleRelation({
    required this.fromIndex,
    required this.toIndex,
    required this.description,
  });
}

/// Draws three labeled nodes arranged in a triangle (top / bottom-left /
/// bottom-right) connected by lines, with a legend underneath spelling out
/// each directional relation. Used for civics diagrams such as 三権分立
/// (the separation of the three branches of government) where a plain list
/// of quiz facts is hard for kids to picture as a whole.
///
/// This intentionally avoids drawing arrowheads/labels *along* each of the
/// (usually 6) directional relations directly on the triangle — with three
/// nodes that quickly becomes visual clutter that's hard to lay out
/// correctly at arbitrary widths. Instead each edge is drawn once as a
/// simple double-headed connector, and the specific directional meanings
/// are listed in a color-matched legend below.
class RelationTriangleDiagram extends StatelessWidget {
  /// Must have exactly 3 entries (top / bottom-left / bottom-right).
  final List<TriangleNode> nodes;
  final List<TriangleRelation> relations;

  // Note: intentionally no `assert(nodes.length == 3)` here — a `const`
  // constructor can't const-evaluate `List.length` on a constructor
  // parameter, so this is documented via the field comment above instead.
  const RelationTriangleDiagram({
    super.key,
    required this.nodes,
    required this.relations,
  });

  // Fractional (0..1) anchor positions for the three corners.
  static const List<Alignment> _anchors = [
    Alignment(0.0, -0.95), // top
    Alignment(-0.9, 0.85), // bottom-left
    Alignment(0.9, 0.85), // bottom-right
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AspectRatio(
          aspectRatio: 1.05,
          child: Stack(
            children: [
              Positioned.fill(
                child: CustomPaint(
                  painter: _TrianglePainter(nodeColors: [
                    for (final n in nodes) n.color,
                  ]),
                ),
              ),
              for (var i = 0; i < nodes.length; i++)
                Align(
                  alignment: _anchors[i],
                  child: _NodeChip(node: nodes[i]),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        ...relations.map((r) => _LegendRow(
              from: nodes[r.fromIndex],
              to: nodes[r.toIndex],
              description: r.description,
            )),
      ],
    );
  }
}

class _NodeChip extends StatelessWidget {
  final TriangleNode node;

  const _NodeChip({required this.node});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: node.color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: node.color.withOpacity(0.4),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(node.icon, color: Colors.white, size: 18),
          const SizedBox(width: 6),
          Text(
            node.label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class _LegendRow extends StatelessWidget {
  final TriangleNode from;
  final TriangleNode to;
  final String description;

  const _LegendRow({
    required this.from,
    required this.to,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 4),
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: from.color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(fontSize: 13, color: Color(0xFF333333), height: 1.3),
                children: [
                  TextSpan(
                    text: '${from.label} → ${to.label}：',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: description),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TrianglePainter extends CustomPainter {
  final List<Color> nodeColors;

  _TrianglePainter({required this.nodeColors});

  Offset _point(Alignment a, Size size) => Offset(
        (a.x + 1) / 2 * size.width,
        (a.y + 1) / 2 * size.height,
      );

  @override
  void paint(Canvas canvas, Size size) {
    final points = [
      for (final a in RelationTriangleDiagram._anchors) _point(a, size),
    ];

    // Blend each edge's color from its two endpoint node colors so the
    // legend dots visually match the line they describe.
    void drawEdge(int i, int j) {
      final paint = Paint()
        ..shader = LinearGradient(
          colors: [nodeColors[i].withOpacity(0.7), nodeColors[j].withOpacity(0.7)],
        ).createShader(Rect.fromPoints(points[i], points[j]))
        ..strokeWidth = 3
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(points[i], points[j], paint);
    }

    drawEdge(0, 1);
    drawEdge(1, 2);
    drawEdge(2, 0);
  }

  @override
  bool shouldRepaint(covariant _TrianglePainter oldDelegate) =>
      oldDelegate.nodeColors != nodeColors;
}
