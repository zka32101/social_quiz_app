import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_core/shared_core.dart';
import '../data/shakai_characters.dart';
import '../repositories/progress_repository.dart';

// ─── Phase 4.1: CharacterProfile統合版 ────────────────────────────────────

/// 社会コレ！キャラクター管理（Phase 4.1: CharacterProfile対応）
class CharacterNotifier extends BaseCharacterProfileNotifier {
  @override
  List<BaseCharacter> get characterList => kShakaiCharacters;

  @override
  String get storageKey => 'shakai_character_profiles';

  @override
  Subject get appSubject => Subject.shakai;
}

/// 統一キャラクタープロバイダー（Phase 4.1）
final characterProvider = NotifierProvider<CharacterNotifier, CharacterProfileMap>(
  CharacterNotifier.new,
);

/// 社会コレ！コイン橋渡しノティファイア。
/// shared_core の coinProvider を Hive ベースの UserProgress に橋渡しする。
/// CoinShopPage / CoinBalanceWidget は coinProvider を見るため、
/// このクラスで UserProgress.coins と同期させる。
class SocialCoinNotifier extends CoinNotifier {
  @override
  CoinState build() {
    // userProgressProvider の coins を reactively に watch して同期する
    final coins = ref.watch(userProgressProvider.select((p) => p.coins));
    return CoinState(totalCoins: coins);
  }

  @override
  Future<void> load() async {
    // userProgressProvider から読み込み済みなので no-op
  }

  @override
  Future<void> addCoins(int amount) async {
    await ref.read(userProgressProvider.notifier).addCoins(amount);
    // state は build() で自動更新される
  }

  @override
  Future<bool> spendCoins(int amount) async {
    if (state.totalCoins < amount) return false;
    return ref.read(userProgressProvider.notifier).spendCoins(amount);
  }
}
