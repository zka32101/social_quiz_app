import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ─────────────────────────────────────────────────────────────
// World Map Visual Widget — GeoJSON country polygons
// Simplified Mercator projection:
//   nx = (longitude + 180) / 360   (0 = 180°W, 1 = 180°E)
//   ny = (75 - latitude)  / 150    (0 = 75°N,  1 = 75°S)
// ─────────────────────────────────────────────────────────────

// ── GeoJSON 解析クラス ─────────────────────────────────────
class _WorldCountry {
  final String name;
  final String nameJa;
  final String continent;
  final List<List<List<double>>> rings; // [ring][point][lon, lat]

  const _WorldCountry({
    required this.name,
    required this.nameJa,
    required this.continent,
    required this.rings,
  });
}

List<_WorldCountry> _parseWorldGeoJson(String jsonStr) {
  final data = json.decode(jsonStr) as Map<String, dynamic>;
  final features = data['features'] as List<dynamic>;
  final result = <_WorldCountry>[];

  for (final f in features) {
    final props = f['properties'] as Map<String, dynamic>;
    final name = (props['NAME'] ?? props['ADMIN'] ?? '') as String;
    final nameJa = (props['NAME_JA'] ?? '') as String;
    final continent = (props['CONTINENT'] ?? '') as String;
    final geo = f['geometry'] as Map<String, dynamic>?;
    if (geo == null) continue;

    final rings = _extractRings(geo);
    if (rings.isNotEmpty) {
      result.add(_WorldCountry(
        name: name,
        nameJa: nameJa.isEmpty ? name : nameJa,
        continent: continent,
        rings: rings,
      ));
    }
  }
  return result;
}

List<List<List<double>>> _extractRings(Map<String, dynamic> geo) {
  final type = geo['type'] as String;
  final coords = geo['coordinates'];
  final rings = <List<List<double>>>[];

  if (type == 'Polygon') {
    rings.add(_toRing(coords[0] as List));
  } else if (type == 'MultiPolygon') {
    for (final poly in coords as List) {
      rings.add(_toRing((poly as List)[0] as List));
    }
  }
  return rings;
}

List<List<double>> _toRing(List coords) {
  return coords.map<List<double>>((pt) {
    final list = pt as List;
    return [(list[0] as num).toDouble(), (list[1] as num).toDouble()];
  }).toList();
}

// ── 大陸カラー ────────────────────────────────────────────
const Map<String, Color> _continentFill = {
  'Asia': Color(0xFFE65100),
  'Europe': Color(0xFF1565C0),
  'Africa': Color(0xFF2E7D32),
  'North America': Color(0xFF7B1FA2),
  'South America': Color(0xFFC62828),
  'Oceania': Color(0xFF00695C),
  'Antarctica': Color(0xFFB0BEC5),
};

// ─────────────────────────────────────────────────────────────

class WorldMapWidget extends StatefulWidget {
  const WorldMapWidget({super.key});

  @override
  State<WorldMapWidget> createState() => _WorldMapWidgetState();
}

class _WorldMapWidgetState extends State<WorldMapWidget> {
  _CountryPin? _selected;
  List<_WorldCountry>? _countries;

  @override
  void initState() {
    super.initState();
    _loadGeoJson();
  }

  Future<void> _loadGeoJson() async {
    try {
      final str = await rootBundle
          .loadString('assets/data/world_countries.geojson');
      // Isolate で解析してUIスレッドをブロックしない
      final parsed = await compute(_parseWorldGeoJson, str);
      if (mounted) setState(() => _countries = parsed);
    } catch (_) {
      // フォールバック: 空リストでもPainterが背景だけ描画
      if (mounted) setState(() => _countries = []);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
          child: _buildLegend(),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                final height = (constraints.maxHeight.isFinite &&
                        constraints.maxHeight > width / 2.0)
                    ? constraints.maxHeight.clamp(width / 2.0, width / 1.35)
                    : width / 1.6;
                return SizedBox(
                  width: width,
                  height: height,
                  child: Stack(
                    children: [
                      CustomPaint(
                        size: Size(width, height),
                        painter: _WorldMapPainter(_countries),
                      ),
                      if (_countries == null)
                        const Center(
                          child: CircularProgressIndicator(
                            color: Colors.white54,
                            strokeWidth: 2,
                          ),
                        ),
                      ..._countryPins
                          .map((pin) => _buildPin(pin, width, height)),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
        if (_selected != null)
          _buildCountryInfo(_selected!)
        else
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              '国旗（こっき）をタップして国の情報を見よう！',
              style:
                  TextStyle(color: Colors.grey.shade600, fontSize: 13),
              textAlign: TextAlign.center,
            ),
          ),
      ],
    );
  }

  Widget _buildLegend() {
    const items = [
      ('アジア', Color(0xFFE65100)),
      ('ヨーロッパ', Color(0xFF1565C0)),
      ('アフリカ', Color(0xFF2E7D32)),
      ('北アメリカ', Color(0xFF7B1FA2)),
      ('南アメリカ', Color(0xFFC62828)),
      ('オセアニア', Color(0xFF00695C)),
    ];
    return Wrap(
      spacing: 10,
      runSpacing: 4,
      children: items
          .map((item) => Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                        color: item.$2,
                        borderRadius: BorderRadius.circular(2)),
                  ),
                  const SizedBox(width: 4),
                  Text(item.$1,
                      style: const TextStyle(
                          fontSize: 11, fontWeight: FontWeight.w500)),
                ],
              ))
          .toList(),
    );
  }

  Widget _buildPin(_CountryPin pin, double w, double h) {
    // タップ領域は子ども向けに最低40x40論理ピクセルを確保しつつ、
    // 見た目の国旗の位置（中心）は従来どおりに保つ。
    const tapSize = 40.0;
    final x = pin.nx * w - tapSize / 2;
    final y = pin.ny * h - tapSize / 2;
    return Positioned(
      left: x,
      top: y,
      child: GestureDetector(
        onTap: () => setState(() {
          _selected = _selected?.flag == pin.flag ? null : pin;
        }),
        child: SizedBox(
          width: tapSize,
          height: tapSize,
          child: Center(
            child: Text(
              pin.flag,
              style: TextStyle(
                fontSize: _selected?.flag == pin.flag ? 22 : 16,
                shadows: const [
                  Shadow(
                      color: Colors.black54,
                      blurRadius: 4,
                      offset: Offset(1, 1))
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCountryInfo(_CountryPin pin) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Row(
        children: [
          Text(pin.flag, style: const TextStyle(fontSize: 30)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${pin.name}（${pin.furigana}）',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 3),
                Text('首都（しゅと）: ${pin.capital}',
                    style: const TextStyle(fontSize: 12)),
                Text(pin.fact,
                    style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade700,
                        height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// CustomPainter — GeoJSON country polygons
// ─────────────────────────────────────────────────────────────

class _WorldMapPainter extends CustomPainter {
  final List<_WorldCountry>? countries;

  _WorldMapPainter(this.countries);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // 海（背景）
    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, h),
      Paint()..color = const Color(0xFF0D47A1),
    );

    if (countries == null || countries!.isEmpty) return;

    // 国ポリゴンを大陸色で描画
    for (final country in countries!) {
      final fillColor =
          _continentFill[country.continent] ?? Colors.grey.shade600;
      for (final ring in country.rings) {
        final path = _buildPath(ring, w, h);
        // 塗り
        canvas.drawPath(
            path, Paint()..color = fillColor..style = PaintingStyle.fill);
        // 境界線
        canvas.drawPath(
          path,
          Paint()
            ..color = Colors.white.withValues(alpha: 0.30)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 0.5,
        );
      }
    }

    // グリッドライン（赤道・北極圏・南極圏）
    _drawGridLines(canvas, w, h);
  }

  void _drawGridLines(Canvas canvas, double w, double h) {
    final paint = Paint()..strokeWidth = 0.8;

    // 赤道 (0°)
    paint.color = Colors.white.withValues(alpha: 0.25);
    canvas.drawLine(Offset(0, h * 0.50), Offset(w, h * 0.50), paint);

    // 北回帰線 (23.5°N → ny = (75-23.5)/150 = 0.343)
    paint.color = Colors.white.withValues(alpha: 0.12);
    paint.strokeWidth = 0.5;
    canvas.drawLine(Offset(0, h * 0.343), Offset(w, h * 0.343), paint);

    // 南回帰線 (23.5°S → ny = (75+23.5)/150 = 0.657)
    canvas.drawLine(Offset(0, h * 0.657), Offset(w, h * 0.657), paint);

    // 北極圏 (66.5°N → ny = 0.057)
    paint.color = Colors.white.withValues(alpha: 0.08);
    canvas.drawLine(Offset(0, h * 0.057), Offset(w, h * 0.057), paint);
  }

  Path _buildPath(List<List<double>> ring, double w, double h) {
    final path = Path();
    bool first = true;
    double prevNx = 0;

    for (final pt in ring) {
      final lon = pt[0];
      final lat = pt[1];
      final nx = (lon + 180) / 360;
      final ny = (75 - lat) / 150;
      final x = nx * w;
      final y = ny * h;

      if (first) {
        path.moveTo(x, y);
        first = false;
      } else {
        // 180°子午線をまたぐ場合は線を引かない（パス切断）
        if ((nx - prevNx).abs() > 0.5) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      prevNx = nx;
    }
    path.close();
    return path;
  }

  @override
  bool shouldRepaint(_WorldMapPainter old) => old.countries != countries;
}

// ─────────────────────────────────────────────────────────────
// Country pin data (国旗ピン)
// ─────────────────────────────────────────────────────────────

class _CountryPin {
  final String flag;
  final String name;
  final String furigana;
  final String capital;
  final String fact;
  final double nx;
  final double ny;

  const _CountryPin({
    required this.flag,
    required this.name,
    required this.furigana,
    required this.capital,
    required this.fact,
    required this.nx,
    required this.ny,
  });
}

const List<_CountryPin> _countryPins = [
  _CountryPin(
    flag: '🇯🇵',
    name: '日本',
    furigana: 'にほん',
    capital: '東京（とうきょう）',
    fact: '太平洋にある島国。47都道府県からなる。自動車・電化製品の輸出大国。',
    nx: 0.889,
    ny: 0.267,
  ),
  _CountryPin(
    flag: '🇨🇳',
    name: '中国',
    furigana: 'ちゅうごく',
    capital: '北京（ペキン）',
    fact: '世界最多人口（14億人超）の国。万里の長城・三峡ダムが有名。',
    nx: 0.808,
    ny: 0.267,
  ),
  _CountryPin(
    flag: '🇮🇳',
    name: 'インド',
    furigana: 'インド',
    capital: 'ニューデリー',
    fact: '世界第2位の人口大国（14億人超）。ヒンディー語・英語が公用語。',
    nx: 0.703,
    ny: 0.440,
  ),
  _CountryPin(
    flag: '🇷🇺',
    name: 'ロシア',
    furigana: 'ロシア',
    capital: 'モスクワ',
    fact: '世界最大の国土面積（1710万km²）。ユーラシア大陸の北部を占める。',
    nx: 0.722,
    ny: 0.120,
  ),
  _CountryPin(
    flag: '🇺🇸',
    name: 'アメリカ',
    furigana: 'アメリカ',
    capital: 'ワシントンD.C.',
    fact: '世界最大の経済大国（GDP第1位）。宇宙開発・IT産業をリードする。',
    nx: 0.200,
    ny: 0.253,
  ),
  _CountryPin(
    flag: '🇨🇦',
    name: 'カナダ',
    furigana: 'カナダ',
    capital: 'オタワ',
    fact: '世界第2位の面積（998万km²）。メープルシロップ・小麦が名産。',
    nx: 0.200,
    ny: 0.133,
  ),
  _CountryPin(
    flag: '🇧🇷',
    name: 'ブラジル',
    furigana: 'ブラジル',
    capital: 'ブラジリア',
    fact: '南アメリカ最大の国。アマゾン川流域の熱帯雨林が広がる。サッカーが盛ん。',
    nx: 0.347,
    ny: 0.600,
  ),
  _CountryPin(
    flag: '🇫🇷',
    name: 'フランス',
    furigana: 'フランス',
    capital: 'パリ',
    fact: 'エッフェル塔・ルーブル美術館が有名。観光客数が世界で最も多い国。',
    nx: 0.492,
    ny: 0.193,
  ),
  _CountryPin(
    flag: '🇩🇪',
    name: 'ドイツ',
    furigana: 'ドイツ',
    capital: 'ベルリン',
    fact: 'ヨーロッパ最大の経済大国。自動車（BMW・メルセデス）で有名。',
    nx: 0.511,
    ny: 0.167,
  ),
  _CountryPin(
    flag: '🇬🇧',
    name: 'イギリス',
    furigana: 'イギリス',
    capital: 'ロンドン',
    fact: '産業革命発祥の国。英語が世界に広まったのはイギリスの影響。',
    nx: 0.483,
    ny: 0.153,
  ),
  _CountryPin(
    flag: '🇿🇦',
    name: '南アフリカ',
    furigana: 'みなみアフリカ',
    capital: 'プレトリア',
    fact: 'アフリカで最も経済力のある国。ダイヤモンド・金の産地として有名。',
    nx: 0.542,
    ny: 0.747,
  ),
  _CountryPin(
    flag: '🇪🇬',
    name: 'エジプト',
    furigana: 'エジプト',
    capital: 'カイロ',
    fact: 'ピラミッド・スフィンクスなど古代文明の遺産が多く残る。ナイル川が流れる。',
    nx: 0.556,
    ny: 0.327,
  ),
  _CountryPin(
    flag: '🇦🇺',
    name: 'オーストラリア',
    furigana: 'オーストラリア',
    capital: 'キャンベラ',
    fact: '大陸であり国でもある。カンガルー・コアラなど固有の動物が多く生息。',
    nx: 0.861,
    ny: 0.660,
  ),
  _CountryPin(
    flag: '🇸🇦',
    name: 'サウジアラビア',
    furigana: 'サウジアラビア',
    capital: 'リヤド',
    fact: '石油（原油）の埋蔵量・輸出量が世界トップクラスのイスラム教の国。',
    nx: 0.614,
    ny: 0.360,
  ),
  _CountryPin(
    flag: '🇲🇽',
    name: 'メキシコ',
    furigana: 'メキシコ',
    capital: 'メキシコシティ',
    fact: '古代マヤ・アステカ文明の遺跡が残る。トウモロコシ料理が豊富。',
    nx: 0.194,
    ny: 0.380,
  ),
  _CountryPin(
    flag: '🇰🇷',
    name: '韓国',
    furigana: 'かんこく',
    capital: 'ソウル',
    fact: '日本の隣国。K-POP・韓国料理が世界中で人気。半導体・造船が主要産業。',
    nx: 0.878,
    ny: 0.273,
  ),
  _CountryPin(
    flag: '🇮🇹',
    name: 'イタリア',
    furigana: 'イタリア',
    capital: 'ローマ',
    fact:
        'ブーツの形をした国。コロッセオ・バチカン市国が有名。ピザ・パスタの発祥地。',
    nx: 0.528,
    ny: 0.253,
  ),
];
