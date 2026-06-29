import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import '../../data/prefecture_data.dart';
import '../../data/japan_prefecture_latlng.dart';
import '../../repositories/progress_repository.dart';

// ───────────────────────────────────────────────────
// 地方ごとの色設定
// ───────────────────────────────────────────────────

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

const _regionNames = <String, String>{
  'hokkaido': '北海道',
  'tohoku':   '東北',
  'kanto':    '関東',
  'chubu':    '中部',
  'kinki':    '近畿',
  'chugoku':  '中国',
  'shikoku':  '四国',
  'kyushu':   '九州・沖縄',
};

// ───────────────────────────────────────────────────
// JapanMapScreen
// ───────────────────────────────────────────────────

class JapanMapScreen extends ConsumerStatefulWidget {
  const JapanMapScreen({super.key});

  @override
  ConsumerState<JapanMapScreen> createState() => _JapanMapScreenState();
}

class _JapanMapScreenState extends ConsumerState<JapanMapScreen> {
  final _mapController = MapController();
  String? _tappedPrefId;

  @override
  Widget build(BuildContext context) {
    final progress = ref.watch(userProgressProvider);
    final learnedIds = progress.prefectureProgress.entries
        .where((e) => e.value.quizBestScore > 0 || e.value.completedSteps.isNotEmpty)
        .map((e) => e.key)
        .toSet();

    // 凡例の地方リスト（重複なし）
    final regions = _regionColors.keys.toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('日本の地理'),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${learnedIds.length}/47 学習済み',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        top: false, // AppBar が上部を担当
        child: Stack(
        children: [
          // ── メイン地図 ──────────────────────────────
          FlutterMap(
            mapController: _mapController,
            options: const MapOptions(
              initialCenter: LatLng(35.0, 136.5),
              initialZoom: 5.2,
              minZoom: 4.0,
              maxZoom: 12.0,
              interactionOptions: InteractionOptions(flags: InteractiveFlag.all),
            ),
            children: [
              // OpenStreetMap タイル
              TileLayer(
                urlTemplate:
                    'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName:
                    'com.petitStudio.socialQuizApp',
                maxNativeZoom: 19,
              ),

              // 都道府県ポリゴン（色分け）
              PolygonLayer(
                polygons: PrefectureDataList.all.map((pref) {
                  final data = prefLatlngMap[pref.id];
                  if (data == null) return null;
                  final color =
                      _regionColors[pref.region] ?? Colors.grey;
                  final isLearned = learnedIds.contains(pref.id);
                  final isTapped = _tappedPrefId == pref.id;
                  return Polygon(
                    points: data.border,
                    color: isTapped
                        ? color.withValues(alpha: 0.7)
                        : isLearned
                            ? color.withValues(alpha: 0.45)
                            : color.withValues(alpha: 0.22),
                    borderColor: color,
                    borderStrokeWidth: isTapped ? 3.0 : 1.8,
                  );
                }).whereType<Polygon>().toList(),
              ),

              // 都道府県マーカー（タップ可能）
              MarkerLayer(
                markers: PrefectureDataList.all.map((pref) {
                  final data = prefLatlngMap[pref.id];
                  if (data == null) return null;
                  final color =
                      _regionColors[pref.region] ?? Colors.grey;
                  final isLearned = learnedIds.contains(pref.id);
                  return Marker(
                    point: data.center,
                    width: 72,
                    height: 28,
                    child: GestureDetector(
                      onTap: () {
                        setState(() => _tappedPrefId = pref.id);
                        context.go('/prefecture/${pref.id}');
                      },
                      child: _PrefMarker(
                        prefecture: pref,
                        color: color,
                        isLearned: isLearned,
                      ),
                    ),
                  );
                }).whereType<Marker>().toList(),
              ),

              // OSM 帰属表示（義務）
              const RichAttributionWidget(
                attributions: [
                  TextSourceAttribution('© OpenStreetMap contributors'),
                ],
              ),
            ],
          ),

          // ── 沖縄インセットマップ（右下） ──────────────
          Positioned(
            right: 8,
            bottom: 48,
            child: Container(
              width: 120,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(
                  color: _regionColors['kyushu']!,
                  width: 1.5,
                ),
                borderRadius: BorderRadius.circular(6),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(5),
                child: Stack(
                  children: [
                    FlutterMap(
                      options: const MapOptions(
                        initialCenter: LatLng(26.2, 127.7),
                        initialZoom: 8.5,
                        interactionOptions: InteractionOptions(
                          flags: InteractiveFlag.none,
                        ),
                      ),
                      children: [
                        TileLayer(
                          urlTemplate:
                              'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName:
                              'com.petitStudio.socialQuizApp',
                          maxNativeZoom: 19,
                        ),
                        PolygonLayer(
                          polygons: PrefectureDataList.all
                              .where((p) => p.id == 'okinawa')
                              .map((pref) {
                            final data = prefLatlngMap[pref.id];
                            if (data == null) return null;
                            final color = _regionColors[pref.region] ??
                                Colors.grey;
                            return Polygon(
                              points: data.border,
                              color: color.withValues(alpha: 0.45),
                              borderColor: color,
                              borderStrokeWidth: 1.8,
                            );
                          }).whereType<Polygon>().toList(),
                        ),
                        MarkerLayer(
                          markers: PrefectureDataList.all
                              .where((p) => p.id == 'okinawa')
                              .map((pref) {
                            final data = prefLatlngMap[pref.id];
                            if (data == null) return null;
                            final color = _regionColors[pref.region] ??
                                Colors.grey;
                            final isLearned = learnedIds.contains(pref.id);
                            return Marker(
                              point: data.center,
                              width: 72,
                              height: 28,
                              child: GestureDetector(
                                onTap: () {
                                  setState(
                                      () => _tappedPrefId = pref.id);
                                  context.go('/prefecture/${pref.id}');
                                },
                                child: _PrefMarker(
                                  prefecture: pref,
                                  color: color,
                                  isLearned: isLearned,
                                ),
                              ),
                            );
                          }).whereType<Marker>().toList(),
                        ),
                      ],
                    ),
                    Positioned(
                      top: 2,
                      left: 4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 4, vertical: 1),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.85),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '沖縄県',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: _regionColors['kyushu'],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── 地方凡例（左下） ───────────────────────
          Positioned(
            left: 8,
            bottom: 48,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.92),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 6,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: regions.map((r) {
                  final color = _regionColors[r]!;
                  final name = _regionNames[r]!;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 1.5),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.7),
                            border: Border.all(color: color, width: 1),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          name,
                          style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // ── 操作ヒント（上部） ─────────────────────
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              color: Colors.blue.shade50.withValues(alpha: 0.9),
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.pinch, size: 13, color: Colors.blueGrey),
                  SizedBox(width: 4),
                  Text(
                    'ピンチでズーム・ドラッグで移動・都道府県名をタップ',
                    style: TextStyle(fontSize: 11, color: Colors.blueGrey),
                  ),
                ],
              ),
            ),
          ),
        ],
        ),
      ),
    );
  }
}

// ───────────────────────────────────────────────────
// 都道府県マーカー
// ───────────────────────────────────────────────────

class _PrefMarker extends StatelessWidget {
  const _PrefMarker({
    required this.prefecture,
    required this.color,
    required this.isLearned,
  });

  final PrefectureData prefecture;
  final Color color;
  final bool isLearned;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: isLearned ? color : Colors.white,
        border: Border.all(color: color, width: 1.5),
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 2, offset: Offset(0, 1)),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (isLearned)
            const Icon(Icons.check_circle, size: 9, color: Colors.white)
          else
            Text(prefecture.emoji,
                style: const TextStyle(fontSize: 9)),
          const SizedBox(width: 2),
          Flexible(
            child: Text(
              prefecture.name,
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.bold,
                color: isLearned ? Colors.white : color,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
