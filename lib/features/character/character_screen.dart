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
    return CharacterCollectionPage(
      characters: kShakaiCharacters,
      totalStagesCleared: completedCount,
    );
  }
}
