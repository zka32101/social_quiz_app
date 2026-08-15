#!/usr/bin/env python3
"""
Prefecture Boundary Generator
Regenerates lib/data/japan_prefecture_latlng.dart from a real-world
GeoJSON boundary dataset for Japan's 47 prefectures.

Why this exists:
    The previous version of japan_prefecture_latlng.dart was hand-typed
    (eyeballed lat/lng points), which made prefecture shapes on the map
    inaccurate and inconsistent. This script instead:
      1. Downloads (or reuses a cached copy of) a real prefecture-boundary
         GeoJSON — see DATA SOURCE below.
      2. For each prefecture, keeps the main landmass plus any islands
         that are large enough to matter at map scale (drops thousands of
         tiny uninhabited islets that would just bloat the data).
      3. Simplifies each kept polygon ring with the Douglas-Peucker
         algorithm so the app ships a few thousand points total instead
         of tens of thousands, while still being far more accurate than
         a hand-drawn approximation.
      4. Writes the result as a Dart source file matching the existing
         `PrefLatlng` model (lib/data/japan_prefecture_latlng.dart).

DATA SOURCE / LICENSE:
    japan.geojson from https://github.com/dataofjapan/land, itself a
    derivative of 地球地図日本 (Global Map Japan) published by 国土地理院
    (GSI, Geospatial Information Authority of Japan).
    Per GSI's terms: non-commercial use requires attribution; commercial
    use additionally requires a usage report to GSI. This app already
    shows in-app attribution (see RichAttributionWidget in
    lib/features/japan_map/japan_map_screen.dart) — if the app is
    monetized, also file the usage report with GSI before shipping an
    update that uses this data.

Usage:
    python scripts/generate_prefecture_boundaries.py

    (re-run whenever the upstream boundary data changes; the script
    downloads a fresh copy unless --cache-file already exists)
"""

import argparse
import json
import math
import re
import urllib.request
from pathlib import Path

DEFAULT_SRC_URL = (
    "https://raw.githubusercontent.com/dataofjapan/land/master/japan.geojson"
)
REPO_ROOT = Path(__file__).resolve().parent.parent
PREFECTURE_DATA_DART = REPO_ROOT / "lib" / "data" / "prefecture_data.dart"
OUT_DART = REPO_ROOT / "lib" / "data" / "japan_prefecture_latlng.dart"

# Max number of separate polygons (main landmass + islands) kept per prefecture.
MAX_RINGS_PER_PREF = 8
# A ring is kept only if its area is at least this fraction of the prefecture's
# largest ring's area (filters out tiny uninhabited islets).
MIN_RELATIVE_AREA = 0.004


def shoelace_area(ring):
    """Unsigned polygon area in deg^2 (good enough for relative ranking)."""
    a = 0.0
    n = len(ring)
    for i in range(n):
        x1, y1 = ring[i]
        x2, y2 = ring[(i + 1) % n]
        a += x1 * y2 - x2 * y1
    return abs(a) / 2.0


def ring_centroid(ring):
    """Area-weighted centroid (planar approximation, fine at this scale)."""
    a = 0.0
    cx = 0.0
    cy = 0.0
    n = len(ring)
    for i in range(n):
        x1, y1 = ring[i]
        x2, y2 = ring[(i + 1) % n]
        cross = x1 * y2 - x2 * y1
        a += cross
        cx += (x1 + x2) * cross
        cy += (y1 + y2) * cross
    a *= 0.5
    if abs(a) < 1e-12:
        xs = [p[0] for p in ring]
        ys = [p[1] for p in ring]
        return (sum(xs) / len(xs), sum(ys) / len(ys))
    return (cx / (6 * a), cy / (6 * a))


def _perp_dist(pt, a, b):
    (x, y), (x1, y1), (x2, y2) = pt, a, b
    dx, dy = x2 - x1, y2 - y1
    if dx == 0 and dy == 0:
        return math.hypot(x - x1, y - y1)
    t = ((x - x1) * dx + (y - y1) * dy) / (dx * dx + dy * dy)
    px, py = x1 + t * dx, y1 + t * dy
    return math.hypot(x - px, y - py)


def _rdp(points, epsilon):
    """Douglas-Peucker polyline simplification."""
    if len(points) < 3:
        return points[:]
    dmax = 0.0
    index = 0
    for i in range(1, len(points) - 1):
        d = _perp_dist(points[i], points[0], points[-1])
        if d > dmax:
            index, dmax = i, d
    if dmax > epsilon:
        left = _rdp(points[: index + 1], epsilon)
        right = _rdp(points[index:], epsilon)
        return left[:-1] + right
    return [points[0], points[-1]]


def simplify_ring_to_target(ring, target_min, target_max):
    """Binary-search an epsilon so the simplified ring lands in
    [target_min, target_max] points."""
    pts = ring[:-1] if ring[0] == ring[-1] else ring[:]
    lo, hi = 0.0001, 2.0
    best = pts
    for _ in range(22):
        mid = (lo + hi) / 2
        simplified = _rdp(pts, mid)
        n = len(simplified)
        if n > target_max:
            lo = mid
        elif n < target_min:
            hi = mid
        else:
            best = simplified
            break
        best = simplified
    if len(best) < 3:
        step = max(1, len(pts) // target_min)
        best = pts[::step]
    return best


def extract_rings(geometry):
    """Exterior rings only (holes are ignored — not meaningful at this
    simplification level, same approach used elsewhere in this app for
    the world map, see world_map_widget.dart)."""
    t = geometry["type"]
    coords = geometry["coordinates"]
    if t == "Polygon":
        return [coords[0]]
    if t == "MultiPolygon":
        return [poly[0] for poly in coords]
    return []


def load_source_geojson(url, cache_file):
    if cache_file and Path(cache_file).exists():
        return json.loads(Path(cache_file).read_text(encoding="utf-8"))
    with urllib.request.urlopen(url, timeout=60) as resp:
        raw = resp.read()
    if cache_file:
        Path(cache_file).write_bytes(raw)
    return json.loads(raw)


def load_canonical_prefectures():
    """(id, name) pairs in the exact order used by PrefectureDataList.all,
    parsed straight from prefecture_data.dart so this script never drifts
    from the app's own source of truth."""
    content = PREFECTURE_DATA_DART.read_text(encoding="utf-8")
    blocks = re.split(r"\n    PrefectureData\(\n", content)
    canon = []
    for b in blocks:
        m = re.search(r"id: '(\w+)', name: '([^']+)'", b)
        if m:
            canon.append((m.group(1), m.group(2)))
    assert len(canon) == 47, f"expected 47 prefectures, found {len(canon)}"
    return canon


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--source-url", default=DEFAULT_SRC_URL)
    parser.add_argument(
        "--cache-file",
        default=str(REPO_ROOT / "scripts" / ".japan_geojson_cache.json"),
        help="Local cache of the downloaded GeoJSON (skip re-download if present). "
        "Delete this file to force a fresh download.",
    )
    args = parser.parse_args()

    canon = load_canonical_prefectures()
    data = load_source_geojson(args.source_url, args.cache_file)
    features_by_jis_id = {f["properties"]["id"]: f for f in data["features"]}
    features_sorted = [features_by_jis_id[i] for i in range(1, 48)]

    out = []
    out.append("// japan_prefecture_latlng.dart")
    out.append("// 都道府県の中心座標と境界ポリゴン（WGS84 緯度経度）")
    out.append("// v4.0 — 実測の都道府県境界データを Douglas-Peucker 法で簡略化。")
    out.append("//        主要な島（本土・有人島など）は個別ポリゴンとして保持。")
    out.append("//")
    out.append("// 出典（データソース）:")
    out.append("//   「地球地図日本」国土地理院（GSI）")
    out.append("//   https://github.com/dataofjapan/land （japan.geojson, 非公式ミラー）")
    out.append("//   地球地図日本の利用条件により、非営利利用は出典明記、")
    out.append("//   営利利用は出典明記に加え著作権者（国土地理院）への利用報告が必要。")
    out.append("//   → 本アプリはアプリ内で出典表示を行うこと（japan_map_screen.dart の")
    out.append("//      RichAttributionWidget 参照）。営利利用の利用報告は別途対応要。")
    out.append("//")
    out.append("// 再生成: python scripts/generate_prefecture_boundaries.py")
    out.append("")
    out.append("import 'package:latlong2/latlong.dart';")
    out.append("")
    out.append("class PrefLatlng {")
    out.append("  final LatLng center;")
    out.append("  final List<List<LatLng>> borders; // 1県あたり複数ポリゴン（本土＋主要な島）")
    out.append("  const PrefLatlng(this.center, this.borders);")
    out.append("}")
    out.append("")
    out.append("// ignore_for_file: prefer_const_constructors")
    out.append("final Map<String, PrefLatlng> prefLatlngMap = {")

    total_rings = 0
    total_pts_after = 0

    for (pid, name), feat in zip(canon, features_sorted):
        assert feat["properties"]["nam_ja"] == name, (
            f"name mismatch for {pid}: expected {name}, "
            f"got {feat['properties']['nam_ja']}"
        )
        rings = extract_rings(feat["geometry"])
        ring_areas = sorted(
            ((shoelace_area(r), r) for r in rings), key=lambda t: t[0], reverse=True
        )
        largest_area = ring_areas[0][0] if ring_areas else 0.0

        kept = []
        for area, ring in ring_areas:
            if not kept:
                kept.append((area, ring))
                continue
            if len(kept) >= MAX_RINGS_PER_PREF:
                break
            if area >= largest_area * MIN_RELATIVE_AREA:
                kept.append((area, ring))

        cx, cy = ring_centroid(ring_areas[0][1])  # (lon, lat)

        out.append(f"  // ━━━━ {name} ━━━━")
        out.append(f"  '{pid}': PrefLatlng(")
        out.append(f"    const LatLng({cy:.4f}, {cx:.4f}),")
        out.append("    [")
        for area, ring in kept:
            frac = area / largest_area if largest_area > 0 else 0
            if frac > 0.5:
                tmin, tmax = 24, 70
            elif frac > 0.05:
                tmin, tmax = 10, 34
            else:
                tmin, tmax = 5, 14
            simp = simplify_ring_to_target(ring, tmin, tmax)
            total_pts_after += len(simp)
            total_rings += 1

            out.append("      [")
            items = [f"LatLng({lat:.4f}, {lon:.4f})" for lon, lat in simp]
            for i in range(0, len(items), 4):
                out.append("        " + ", ".join(items[i : i + 4]) + ",")
            out.append("      ],")
        out.append("    ],")
        out.append("  ),")
        out.append("")

    out.append("};")

    OUT_DART.write_text("\n".join(out) + "\n", encoding="utf-8")
    print(f"Wrote {OUT_DART} — {total_rings} rings, {total_pts_after} points total")


if __name__ == "__main__":
    main()
