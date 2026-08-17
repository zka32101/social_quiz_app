import 'package:flutter/material.dart';
import '../widgets/diagrams/distance_zone_diagram.dart';
import '../widgets/diagrams/process_flow_diagram.dart';

/// Maps an industry quiz sectionId (== JSON subcategory) to a diagram
/// widget that helps visualize the concept, where one is available.
Widget? industryDiagramFor(String sectionId) {
  switch (sectionId) {
    case 'fishery':
      return const DistanceZoneDiagram(
        baseColor: Color(0xFF00838F),
        leftEdgeLabel: '陸に近い',
        rightEdgeLabel: '陸から遠い',
        markers: [
          DistanceZoneMarker(
            label: '養殖業',
            description: 'いけすなどで育てて増やす',
            icon: Icons.set_meal,
            position: 0.06,
          ),
          DistanceZoneMarker(
            label: '沿岸漁業',
            description: '日帰りでできる近くの海',
            icon: Icons.sailing,
            position: 0.32,
          ),
          DistanceZoneMarker(
            label: '沖合漁業',
            description: '数日かけて漁を行う',
            icon: Icons.directions_boat,
            position: 0.64,
          ),
          DistanceZoneMarker(
            label: '遠洋漁業',
            description: '数か月かけて遠くの海へ',
            icon: Icons.anchor,
            position: 0.94,
          ),
        ],
      );
    case 'agriculture':
      return const ProcessFlowDiagram(
        color: Color(0xFF2E7D32),
        steps: [
          ProcessStep(
            label: '3月',
            detail: '種もみの準備',
            icon: Icons.grain,
          ),
          ProcessStep(
            label: '4月',
            detail: '田おこし',
            icon: Icons.agriculture,
          ),
          ProcessStep(
            label: '5月',
            detail: '代かき・田植え',
            icon: Icons.grass,
          ),
          ProcessStep(
            label: '夏',
            detail: '水の管理・草取り',
            icon: Icons.water_drop,
          ),
          ProcessStep(
            label: '9〜10月',
            detail: '稲刈り・乾燥',
            icon: Icons.content_cut,
          ),
          ProcessStep(
            label: '出荷',
            detail: 'お米として出荷',
            icon: Icons.local_shipping,
          ),
        ],
      );
    default:
      return null;
  }
}
