import 'package:flutter/material.dart';
import '../widgets/diagrams/relation_triangle_diagram.dart';
import '../widgets/diagrams/comparison_columns_diagram.dart';

/// Maps a civics quiz sectionId (== JSON subcategory) to a diagram widget
/// that helps visualize the concept, where one is available. Sections with
/// no natural diagram (e.g. 憲法の三大原則, 税金) return null.
Widget? civicsDiagramFor(String sectionId) {
  switch (sectionId) {
    case 'separation_of_powers':
      return const RelationTriangleDiagram(
        nodes: [
          TriangleNode(label: '国会', icon: Icons.account_balance, color: Color(0xFF3949AB)),
          TriangleNode(label: '内閣', icon: Icons.groups, color: Color(0xFFEF6C00)),
          TriangleNode(label: '裁判所', icon: Icons.gavel, color: Color(0xFF2E7D32)),
        ],
        relations: [
          TriangleRelation(
            fromIndex: 0,
            toIndex: 1,
            description: '内閣総理大臣を指名する',
          ),
          TriangleRelation(
            fromIndex: 1,
            toIndex: 0,
            description: '衆議院を解散できる',
          ),
          TriangleRelation(
            fromIndex: 0,
            toIndex: 2,
            description: '弾劾裁判所を設けて裁判官をやめさせるか判断する',
          ),
          TriangleRelation(
            fromIndex: 2,
            toIndex: 0,
            description: '法律が憲法に違反していないか調べる（違憲審査）',
          ),
          TriangleRelation(
            fromIndex: 1,
            toIndex: 2,
            description: '裁判官を任命する',
          ),
          TriangleRelation(
            fromIndex: 2,
            toIndex: 1,
            description: '内閣の命令・処分が憲法に違反していないか調べる',
          ),
        ],
      );
    case 'national_assembly':
      return const ComparisonColumnsDiagram(
        leftTitle: '衆議院',
        rightTitle: '参議院',
        leftColor: Color(0xFF3949AB),
        rightColor: Color(0xFF00838F),
        rows: [
          ComparisonRow(label: '定数', leftValue: '465人', rightValue: '248人'),
          ComparisonRow(label: '任期', leftValue: '4年', rightValue: '6年（3年ごとに半数改選）'),
          ComparisonRow(label: '解散', leftValue: 'ある', rightValue: 'ない'),
          ComparisonRow(label: '議決の優越', leftValue: '衆議院の優越がある', rightValue: '—'),
        ],
      );
    default:
      return null;
  }
}
