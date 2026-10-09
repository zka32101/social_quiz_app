import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_core/shared_core.dart' show inventoryProvider;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:social_quiz_app/features/home/widgets/home_app_bar_title.dart';
import 'package:social_quiz_app/features/shop/decor/decor_screen.dart';
import 'package:social_quiz_app/features/shop/title/title_items.dart';
import 'package:social_quiz_app/features/shop/title/title_plate.dart';
import 'package:social_quiz_app/features/shop/title/title_provider.dart';

Future<ProviderContainer> _container({
  Map<String, Object> prefs = const {},
  Set<String> owned = const {},
  TitleProgress progress = const TitleProgress(),
}) async {
  SharedPreferences.setMockInitialValues(prefs);
  final c = ProviderContainer(overrides: [titleProgressProvider.overrideWithValue(progress)]);
  addTearDown(c.dispose);
  c.read(inventoryProvider);
  c.read(titleProvider);
  await Future<void>.delayed(const Duration(milliseconds: 20));
  for (final id in owned) {
    c.read(inventoryProvider.notifier).state = {...c.read(inventoryProvider), id};
  }
  return c;
}

void main() {
  group('称号の定義', () {
    test('8個・ID重複なし・購入5個(100〜500コイン)と達成3個', () {
      expect(kTitleDefs.length, 8);
      expect({for (final t in kTitleDefs) t.id}.length, 8);
      final buy = kTitleDefs.where((t) => t.isPurchasable).toList();
      expect(buy.length, 5);
      expect(buy.every((t) => t.coinCost! >= 100 && t.coinCost! <= 500), true);
      expect(kTitleDefs.where((t) => t.unlock != null).length, 3);
      expect(titleExchangeItems().length, 5);
      expect(titleExchangeItems().every((e) => e.category == '称号'), true);
    });

    test('達成型は進捗値がしきい値以上で解放', () {
      final d = titleDefById('title_ganbari')!;
      expect(isTitleUnlocked(d, owned: {}, progress: const TitleProgress(streak: 6)), false);
      expect(isTitleUnlocked(d, owned: {}, progress: const TitleProgress(streak: 7)), true);
      final k = titleDefById('title_ken')!;
      expect(isTitleUnlocked(k, owned: {}, progress: const TitleProgress(prefectures: 9)), false);
      expect(isTitleUnlocked(k, owned: {}, progress: const TitleProgress(prefectures: 10)), true);
      final b = titleDefById('title_badge')!;
      expect(isTitleUnlocked(b, owned: {}, progress: const TitleProgress(badges: 5)), true);
    });

    test('購入型は所持しているときだけ解放。条件文は未解放のときだけ出る', () {
      final d = titleDefById('title_chizu')!;
      expect(isTitleUnlocked(d, owned: {}, progress: const TitleProgress(streak: 99)), false);
      expect(isTitleUnlocked(d, owned: {'title_chizu'}, progress: const TitleProgress()), true);
      expect(titleLockHint(d, owned: {}, progress: const TitleProgress()), contains('100'));
      expect(titleLockHint(d, owned: {'title_chizu'}, progress: const TitleProgress()), isNull);
      expect(titleLockHint(titleDefById('title_ganbari')!, owned: {}, progress: const TitleProgress()), contains('7'));
    });

    test('プレート画像が存在する', () {
      expect(File(TitlePlate.asset).existsSync(), true);
    });
  });

  group('装着の状態', () {
    test('未解放はつけられず、解放済みはつけられて保存・解除できる', () async {
      final c = await _container(owned: {'title_chizu'});
      final n = c.read(titleProvider.notifier);
      expect(await n.equip(titleDefById('title_rekishi')!), false);
      expect(c.read(activeTitleProvider), isNull);
      expect(await n.equip(titleDefById('title_chizu')!), true);
      expect(c.read(activeTitleProvider)?.name, 'ちずはかせ');
      final p = await SharedPreferences.getInstance();
      expect(p.getString('shakai_title_equipped'), 'title_chizu');
      await n.unequip();
      expect(c.read(activeTitleProvider), isNull);
      expect(p.getString('shakai_title_equipped'), isNull);
    });

    test('保存済みでも、未解放・知らないIDは無視される', () async {
      final c1 = await _container(prefs: {'shakai_title_equipped': 'title_nihon'});
      expect(c1.read(activeTitleProvider), isNull);
      final c2 = await _container(prefs: {'shakai_title_equipped': 'unknown'});
      expect(c2.read(activeTitleProvider), isNull);
      final c3 = await _container(prefs: {'shakai_title_equipped': 'title_badge'}, progress: const TitleProgress(badges: 5));
      expect(c3.read(activeTitleProvider)?.id, 'title_badge');
    });
  });

  group('表示', () {
    testWidgets('プレート: 画像の上に称号名。長い名前でもあふれない', (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(body: Center(child: TitlePlate(name: 'とてもとてもながいしょうごうのなまえです', width: 96))),
      ));
      expect(find.byType(Image), findsOneWidget);
      expect(find.text('とてもとてもながいしょうごうのなまえです'), findsOneWidget);
      expect(find.byType(FittedBox), findsOneWidget);
      expect(tester.getSize(find.byKey(const ValueKey('title_plate'))).width, 96);
      expect(tester.takeException(), isNull);
    });

    testWidgets('ヘッダー: 未選択なら何も出さず、選択すると名前の下にプレートが出る', (tester) async {
      Widget app(String? t) => MaterialApp(
            home: Scaffold(
              appBar: AppBar(
                toolbarHeight: t == null ? null : 80,
                title: HomeAppBarTitle(avatar: const SizedBox(width: 28, height: 28), name: 'はなこ', titleName: t),
              ),
            ),
          );
      await tester.pumpWidget(app(null));
      expect(find.byKey(const ValueKey('title_plate')), findsNothing);
      await tester.pumpWidget(app('ちずはかせ'));
      expect(find.text('ちずはかせ'), findsOneWidget);
      final nameY = tester.getBottomLeft(find.text('はなこ')).dy;
      final plateY = tester.getTopLeft(find.byKey(const ValueKey('title_plate'))).dy;
      expect(plateY >= nameY - 0.5, true);
      expect(tester.takeException(), isNull);
    });

    testWidgets('ヘッダー: 狭い幅(320dp)でもあふれない', (tester) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          appBar: AppBar(
            toolbarHeight: 80,
            title: const HomeAppBarTitle(avatar: SizedBox(width: 28, height: 28), name: 'なまえがながいこ', titleName: 'にっぽんめいじん'),
            actions: [for (var i = 0; i < 5; i++) const IconButton(onPressed: null, icon: Icon(Icons.star))],
          ),
        ),
      ));
      expect(tester.takeException(), isNull);
    });

    testWidgets('きせかえ画面: 未解放は鍵つきで条件を出し、解放済みはえらんでつけられる', (tester) async {
      final c = (await tester.runAsync(() => _container(owned: {'title_chizu'}, progress: const TitleProgress(streak: 7))))!;
      tester.view.physicalSize = const Size(800, 2400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(UncontrolledProviderScope(container: c, child: const MaterialApp(home: DecorScreen())));
      await tester.pump();
      expect(find.text('称号'), findsOneWidget);
      expect(find.text('🔒 にっぽんめいじん'), findsOneWidget);
      expect(find.textContaining('500コイン'), findsOneWidget);
      expect(find.textContaining('個のけんをクリア'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('title_tile_title_nihon')));
      await tester.pump();
      expect(c.read(activeTitleProvider), isNull);
      await tester.tap(find.byKey(const ValueKey('title_tile_title_ganbari')));
      await tester.pump();
      expect(c.read(activeTitleProvider)?.id, 'title_ganbari');
      expect(find.text('✓ がんばりやさん'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
