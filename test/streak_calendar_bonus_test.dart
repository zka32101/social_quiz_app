import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:social_quiz_app/reward_assets.dart';
import 'package:social_quiz_app/utils/study_dates.dart';
import 'package:social_quiz_app/widgets/bonus_stickers.dart';
import 'package:social_quiz_app/widgets/streak_calendar.dart';

void main() {
  test('appendStudyDate dedupes and sorts', () {
    final t = DateTime(2026, 10, 10, 15);
    var l = appendStudyDate(existing: ['2026-10-09'], today: t);
    expect(l, ['2026-10-09', '2026-10-10']);
    l = appendStudyDate(existing: l, today: t);
    expect(l, ['2026-10-09', '2026-10-10']);
  });

  test('appendStudyDate backfills for existing users', () {
    final l = appendStudyDate(
      existing: [],
      today: DateTime(2026, 10, 10),
      previousStreak: 3,
      previousLastStudied: DateTime(2026, 10, 9, 20),
    );
    expect(l, ['2026-10-07', '2026-10-08', '2026-10-09', '2026-10-10']);
  });

  test('appendStudyDate keeps only last 180 days', () {
    final l = appendStudyDate(
        existing: ['2026-01-01', '2026-06-01'], today: DateTime(2026, 10, 10));
    expect(l.contains('2026-01-01'), isFalse);
    expect(l.contains('2026-06-01'), isTrue);
  });

  test('milestones', () {
    final days = {for (var i = 1; i <= 8; i++) DateTime(2026, 10, i)};
    final p = streakRunPositions(days);
    expect(p[DateTime(2026, 10, 7)], 7);
    expect(isStreakMilestone(7), isTrue);
    expect(isStreakMilestone(14), isTrue);
    expect(isStreakMilestone(30), isTrue);
    expect(isStreakMilestone(8), isFalse);
    expect(streakRunPositions({DateTime(2026, 10, 1), DateTime(2026, 10, 3)})[DateTime(2026, 10, 3)], 1);
  });

  test('bonusStickerAssets and evaluateBonus', () {
    expect(bonusStickerAssets(firstAttempt: false, personalBest: false, firstPerfect: false), isEmpty);
    expect(bonusStickerAssets(firstAttempt: true, personalBest: false, firstPerfect: false).single, contains('rocket'));
    expect(bonusStickerAssets(firstAttempt: false, personalBest: true, firstPerfect: false).single, contains('trophy_blue'));
    expect(bonusStickerAssets(firstAttempt: false, personalBest: false, firstPerfect: true).single, contains('rainbow_star'));
    expect(bonusStickerAssets(firstAttempt: true, personalBest: true, firstPerfect: true).length, 2);
    var f = evaluateBonus(prevBest: null, correct: 10, total: 10);
    expect(f.firstAttempt && f.firstPerfect && !f.personalBest, isTrue);
    f = evaluateBonus(prevBest: 7, correct: 8, total: 10);
    expect(f.personalBest && !f.firstAttempt && !f.firstPerfect, isTrue);
    f = evaluateBonus(prevBest: 8, correct: 8, total: 10);
    expect(f.personalBest, isFalse);
    f = evaluateBonus(prevBest: 9, correct: 10, total: 10);
    expect(f.personalBest && f.firstPerfect, isTrue);
    f = evaluateBonus(prevBest: 10, correct: 10, total: 10);
    expect(f.firstPerfect, isFalse);
  });

  testWidgets('assets exist', (tester) async {
    for (final a in [
      'assets/reward/calendar_frame.webp',
      'assets/reward/stamp_ring_rainbow.webp',
      'assets/reward/stamp_coin.webp',
      'assets/reward/sticker_rocket.webp',
      'assets/reward/sticker_trophy_blue.webp',
      'assets/reward/sticker_rainbow_star.webp',
    ]) {
      expect((await rootBundle.load(a)).lengthInBytes, greaterThan(0));
    }
  });

  testWidgets('StreakCalendar no overflow at 320px', (tester) async {
    await tester.binding.setSurfaceSize(const Size(320, 640));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final days = {for (var i = 1; i <= 16; i++) DateTime(2026, 10, i)};
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: StreakCalendar(studiedDays: days, month: DateTime(2026, 10)),
          ),
        ),
      ),
    ));
    await tester.pump();
    expect(tester.takeException(), isNull);
    expect(find.text('2026年10月'), findsOneWidget);
    expect(find.byKey(const Key('stamp_coin_7')), findsOneWidget);
    expect(find.byKey(const Key('stamp_coin_14')), findsOneWidget);
    expect(find.byKey(const Key('stamp_3')), findsOneWidget);
  });

  testWidgets('BonusStickers max 2 and no overflow', (tester) async {
    await tester.binding.setSurfaceSize(const Size(320, 640));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: Center(
          child: BonusStickers(
              flags: BonusFlags(firstAttempt: true, personalBest: true, firstPerfect: true)),
        ),
      ),
    ));
    await tester.pump();
    expect(tester.takeException(), isNull);
    expect(find.byType(Image), findsNWidgets(2));
  });
}
