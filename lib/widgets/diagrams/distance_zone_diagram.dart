import 'package:flutter/material.dart';

/// A single marker placed along a [DistanceZoneDiagram]'s gradient bar.
class DistanceZoneMarker {
  final String label;
  final String description;
  final IconData icon;

  /// Fractional position along the bar, 0.0 (near shore) .. 1.0 (far out).
  final double position;

  const DistanceZoneMarker({
    required this.label,
    required this.description,
    required this.icon,
    required this.position,
  });
}

/// Draws a horizontal "distance from shore" gradient bar (light near the
/// coast, dark far out to sea) with labeled markers along it — used for
/// concepts that are naturally organized by distance/depth, e.g. the four
/// types of Japanese fishing (沿岸・沖合・遠洋・養殖).
class DistanceZoneDiagram extends StatelessWidget {
  final String leftEdgeLabel;
  final String rightEdgeLabel;
  final List<DistanceZoneMarker> markers;
  final Color baseColor;

  const DistanceZoneDiagram({
    super.key,
    required this.leftEdgeLabel,
    required this.rightEdgeLabel,
    required this.markers,
    required this.baseColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(leftEdgeLabel,
                style: TextStyle(
                    fontSize: 11, color: baseColor.withOpacity(0.8))),
            Text(rightEdgeLabel,
                style: TextStyle(
                    fontSize: 11, color: baseColor.withOpacity(0.8))),
          ],
        ),
        const SizedBox(height: 4),
        LayoutBuilder(builder: (context, constraints) {
          final barWidth = constraints.maxWidth;
          const barHeight = 40.0;
          const markerWidth = 78.0;
          return SizedBox(
            // Extra height reserved above/below the bar for markers so
            // Positioned widgets never spill outside this box.
            height: 190,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  top: 75,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: barHeight,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(barHeight / 2),
                      gradient: LinearGradient(
                        colors: [
                          baseColor.withOpacity(0.25),
                          baseColor.withOpacity(0.95),
                        ],
                      ),
                    ),
                  ),
                ),
                for (var i = 0; i < markers.length; i++)
                  _buildMarker(
                    markers[i],
                    barWidth: barWidth,
                    markerWidth: markerWidth,
                    // Alternate above/below the bar so nearby markers
                    // (e.g. 沿岸 and 養殖, both close to shore) don't
                    // overlap each other's label text.
                    above: i.isEven,
                  ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildMarker(
    DistanceZoneMarker marker, {
    required double barWidth,
    required double markerWidth,
    required bool above,
  }) {
    final centerX = marker.position.clamp(0.0, 1.0) * barWidth;
    final left = (centerX - markerWidth / 2).clamp(0.0, barWidth - markerWidth);

    return Positioned(
      left: left,
      top: above ? 0 : 123,
      width: markerWidth,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: baseColor,
              shape: BoxShape.circle,
            ),
            child: Icon(marker.icon, color: Colors.white, size: 16),
          ),
          const SizedBox(height: 2),
          Text(
            marker.label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Color(0xFF333333),
            ),
          ),
          Text(
            marker.description,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 9, color: Color(0xFF666666)),
          ),
        ],
      ),
    );
  }
}
