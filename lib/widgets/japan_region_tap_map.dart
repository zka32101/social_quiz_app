import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../data/prefecture_data.dart';
import '../data/japan_prefecture_latlng.dart';

const _regionColors = <String, Color>{
  'hokkaido': Color(0xFF00897B),
  'tohoku':   Color(0xFF1565C0),
  'kanto':    Color(0xFF283593),
  'chubu':    Color(0xFF2E7D32),
  'kinki':    Color(0xFFE65100),
  'chugoku':  Color(0xFF6A1B9A),
  'shikoku':  Color(0xFF00838F),
  'kyushu':   Color(0xFFC62828),
};

/// 日本地方タップ地図ウィジェット（クイズ用）
class JapanRegionTapMap extends StatefulWidget {
  final List<String> availableRegions;
  final Map<String, String> regionLabels;
  final String correctAnswer;
  final String? selectedRegion;
  final bool isAnswered;
  final bool isCorrect;
  final void Function(String region) onRegionTapped;

  const JapanRegionTapMap({
    super.key,
    required this.availableRegions,
    required this.regionLabels,
    required this.correctAnswer,
    required this.selectedRegion,
    required this.isAnswered,
    required this.isCorrect,
    required this.onRegionTapped,
  });

  @override
  State<JapanRegionTapMap> createState() => _JapanRegionTapMapState();
}

class _JapanRegionTapMapState extends State<JapanRegionTapMap> {
  // region → prefecture polygons (borders)
  late final Map<String, List<List<LatLng>>> _regionBoundaries;
  // region → label position (centroid of all pref centers)
  late final Map<String, LatLng> _regionCentroids;

  @override
  void initState() {
    super.initState();
    _buildRegionData();
  }

  void _buildRegionData() {
    final boundaries = <String, List<List<LatLng>>>{};
    final latSums  = <String, double>{};
    final lngSums  = <String, double>{};
    final counts   = <String, int>{};

    for (final pref in PrefectureDataList.all) {
      final data = prefLatlngMap[pref.id];
      if (data == null) continue;
      final r = pref.region;
      boundaries.putIfAbsent(r, () => []).addAll(data.borders);
      latSums[r] = (latSums[r] ?? 0) + data.center.latitude;
      lngSums[r] = (lngSums[r] ?? 0) + data.center.longitude;
      counts[r]  = (counts[r]  ?? 0) + 1;
    }

    _regionBoundaries = boundaries;
    _regionCentroids  = {
      for (final r in boundaries.keys)
        r: LatLng(latSums[r]! / counts[r]!, lngSums[r]! / counts[r]!),
    };
  }

  // 点がポリゴン内にあるか判定（ray-casting）
  bool _containsPoint(List<LatLng> polygon, LatLng point) {
    bool inside = false;
    final n = polygon.length;
    final px = point.longitude;
    final py = point.latitude;
    for (int i = 0, j = n - 1; i < n; j = i++) {
      final xi = polygon[i].longitude, yi = polygon[i].latitude;
      final xj = polygon[j].longitude, yj = polygon[j].latitude;
      if ((yi > py) != (yj > py) &&
          px < (xj - xi) * (py - yi) / (yj - yi) + xi) {
        inside = !inside;
      }
    }
    return inside;
  }

  void _onMapTap(TapPosition _, LatLng latLng) {
    if (widget.isAnswered) return;
    for (final region in widget.availableRegions) {
      for (final polygon in (_regionBoundaries[region] ?? [])) {
        if (_containsPoint(polygon, latLng)) {
          widget.onRegionTapped(region);
          return;
        }
      }
    }
  }

  Color _polygonFillColor(String region) {
    final base = _regionColors[region] ?? Colors.grey;
    if (!widget.isAnswered) {
      return widget.availableRegions.contains(region)
          ? base.withValues(alpha: 0.55)
          : Colors.grey.withValues(alpha: 0.15);
    }
    if (region == widget.correctAnswer) return Colors.green.withValues(alpha: 0.75);
    if (region == widget.selectedRegion) return Colors.red.withValues(alpha: 0.65);
    return base.withValues(alpha: 0.25);
  }

  Color _polygonBorderColor(String region) {
    if (!widget.isAnswered) {
      return (_regionColors[region] ?? Colors.grey).withValues(alpha: 0.85);
    }
    if (region == widget.correctAnswer) return Colors.green;
    if (region == widget.selectedRegion) return Colors.red;
    return (_regionColors[region] ?? Colors.grey).withValues(alpha: 0.4);
  }

  double _polygonBorderWidth(String region) {
    if (!widget.isAnswered) return 1.5;
    if (region == widget.correctAnswer || region == widget.selectedRegion) return 2.5;
    return 1.0;
  }

  @override
  Widget build(BuildContext context) {
    final polygons = <Polygon>[];
    for (final pref in PrefectureDataList.all) {
      final data = prefLatlngMap[pref.id];
      if (data == null) continue;
      final r = pref.region;
      for (final ring in data.borders) {
        polygons.add(Polygon(
          points: ring,
          color: _polygonFillColor(r),
          borderColor: _polygonBorderColor(r),
          borderStrokeWidth: _polygonBorderWidth(r),
        ));
      }
    }

    final markers = <Marker>[];
    for (final region in widget.availableRegions) {
      final centroid = _regionCentroids[region];
      if (centroid == null) continue;
      final label    = widget.regionLabels[region] ?? region;
      final color    = _regionColors[region] ?? Colors.grey;
      Color labelBg  = Colors.white.withValues(alpha: 0.9);
      Color labelFg  = color;
      if (widget.isAnswered) {
        if (region == widget.correctAnswer) {
          labelBg = Colors.green;
          labelFg = Colors.white;
        } else if (region == widget.selectedRegion) {
          labelBg = Colors.red;
          labelFg = Colors.white;
        }
      }
      markers.add(Marker(
        point: centroid,
        width: 72,
        height: 26,
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: labelBg,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: color, width: 1.2),
            boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 2, offset: Offset(1, 1))],
          ),
          child: Text(
            label,
            style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: labelFg),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ));
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: ColoredBox(
        color: const Color(0xFFD6EAF8), // 海の色（薄青）
        child: FlutterMap(
          options: MapOptions(
            initialCenter: const LatLng(36.0, 136.8),
            initialZoom: 4.6,
            interactionOptions: const InteractionOptions(flags: InteractiveFlag.none),
            onTap: _onMapTap,
          ),
          children: [
            PolygonLayer(polygons: polygons),
            MarkerLayer(markers: markers),
          ],
        ),
      ),
    );
  }
}
