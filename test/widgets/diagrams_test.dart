import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:social_quiz_app/data/civics_diagrams.dart';
import 'package:social_quiz_app/data/industry_diagrams.dart';
import 'package:social_quiz_app/widgets/diagrams/diagram_panel.dart';

/// Pumps [child] inside a minimal MaterialApp/Scaffold at a given width and
/// asserts nothing threw (e.g. no RenderFlex overflow) during layout.
Future<void> _pumpAndCheck(
  WidgetTester tester,
  Widget child, {
  double width = 375,
}) async {
  await tester.binding.setSurfaceSize(Size(width, 800));
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: child,
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  expect(tester.takeException(), isNull);
}

void main() {
  group('civicsDiagramFor', () {
    for (final width in [320.0, 375.0, 428.0]) {
      testWidgets('separation_of_powers renders without overflow at $width',
          (tester) async {
        final diagram = civicsDiagramFor('separation_of_powers');
        expect(diagram, isNotNull);
        await _pumpAndCheck(tester, diagram!, width: width);
        expect(find.text('国会'), findsOneWidget);
        expect(find.text('内閣'), findsOneWidget);
        expect(find.text('裁判所'), findsOneWidget);
      });

      testWidgets('national_assembly renders without overflow at $width',
          (tester) async {
        final diagram = civicsDiagramFor('national_assembly');
        expect(diagram, isNotNull);
        await _pumpAndCheck(tester, diagram!, width: width);
        expect(find.text('衆議院'), findsOneWidget);
        expect(find.text('参議院'), findsOneWidget);
      });
    }

    testWidgets('returns null for sections without a diagram', (tester) async {
      expect(civicsDiagramFor('constitution'), isNull);
      expect(civicsDiagramFor('taxes'), isNull);
      expect(civicsDiagramFor('unknown_section'), isNull);
    });
  });

  group('industryDiagramFor', () {
    for (final width in [320.0, 375.0, 428.0]) {
      testWidgets('fishery renders without overflow at $width', (tester) async {
        final diagram = industryDiagramFor('fishery');
        expect(diagram, isNotNull);
        await _pumpAndCheck(tester, diagram!, width: width);
        expect(find.text('養殖業'), findsOneWidget);
        expect(find.text('遠洋漁業'), findsOneWidget);
      });

      testWidgets('agriculture renders without overflow at $width',
          (tester) async {
        final diagram = industryDiagramFor('agriculture');
        expect(diagram, isNotNull);
        await _pumpAndCheck(tester, diagram!, width: width);
        expect(find.text('田おこし'), findsOneWidget);
      });
    }

    testWidgets('returns null for sections without a diagram', (tester) async {
      expect(industryDiagramFor('pollution'), isNull);
      expect(industryDiagramFor('information_society'), isNull);
    });
  });

  group('DiagramPanel', () {
    testWidgets('collapses and expands on tap', (tester) async {
      await _pumpAndCheck(
        tester,
        DiagramPanel(
          title: 'テスト図解',
          color: Colors.purple,
          diagram: const Text('中身のダイアグラム'),
          initiallyExpanded: false,
        ),
      );
      expect(find.text('中身のダイアグラム'), findsNothing);

      await tester.tap(find.text('テスト図解'));
      await tester.pumpAndSettle();
      expect(find.text('中身のダイアグラム'), findsOneWidget);

      await tester.tap(find.text('テスト図解'));
      await tester.pumpAndSettle();
      expect(find.text('中身のダイアグラム'), findsNothing);
    });
  });
}
