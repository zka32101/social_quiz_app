import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_core/shared_core.dart';
import '../../data/shakai_characters.dart';
import '../../repositories/progress_repository.dart';

/// 社会コレ！キャラクター図鑑画面。
/// 表示ロジックはすべて CharacterCollectionPage に委譲。
class CharacterScreen extends ConsumerWidget {
  const CharacterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 都道府県制覇数をステージクリア数として使用
    final completedCount = ref.watch(
      userProgressProvider.select((p) => p.completedPrefectureCount),
    );
    // CharacterCollectionPage（shared_core）は独自の AppBar を
    // automaticallyImplyLeading: false で持つため戻るボタンが出ない。
    // shared_core 側を変更できないため、戻るボタンを上に重ねて表示する。
    return Stack(
      children: [
        CharacterCollectionPage(
          characters: kShakaiCharacters,
          totalStagesCleared: completedCount,
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              tooltip: '戻る',
              onPressed: () => Navigator.of(context).maybePop(),
            ),
          ),
        ),
      ],
    );
  }
}
