import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:social_quiz_app/data/badge_definitions.dart';
import 'package:social_quiz_app/widgets/badge_emblem.dart';

void main() {
  test('社会の全バッジに共通意匠の対応があり、画像ファイルが存在する', () {
    expect(BadgeDefinitions.all.length, 82);
    for (final b in BadgeDefinitions.all) {
      final name = BadgeEmblem.emblemOf(b.id);
      expect(name, isNotNull, reason: b.id);
      expect(File('assets/badges/badge_$name.webp').existsSync(), true,
          reason: '${b.id} -> $name');
    }
  });

  test('県別マスターだけに県名ラベルが付く', () {
    expect(BadgeEmblem.prefectureLabel('aomori_master', '青森県マスター'), '青森県');
    expect(BadgeEmblem.prefectureLabel('quiz_master', 'クイズマスター'), isNull);
    expect(BadgeEmblem.prefectureLabel('region_kanto', '関東マスター'), isNull);
    final n = BadgeDefinitions.all
        .where((b) => BadgeEmblem.prefectureLabel(b.id, b.name) != null)
        .length;
    expect(n, 47);
  });

  testWidgets('対応のあるバッジは画像、ないバッジは絵文字で出る', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: Column(children: [
          BadgeEmblem(badgeId: 'streak_3', fallbackEmoji: '🔥'),
          BadgeEmblem(
              badgeId: 'aomori_master', fallbackEmoji: '🍎', label: '青森県'),
          BadgeEmblem(badgeId: 'unknown_badge', fallbackEmoji: '🔥'),
        ]),
      ),
    ));
    await tester.pump();
    expect(find.byType(Image), findsWidgets);
    expect(find.text('青森県'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
