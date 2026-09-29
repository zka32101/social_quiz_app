import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/avatar.dart';
import '../repositories/profile_repository.dart';

/// アバター選択プロバイダー
///
/// ユーザーが選択したアバター（プロフィール画像）をローカルで管理します。
/// デフォルトは id=1 (茶色クマ) です。
class AvatarNotifier extends StateNotifier<Avatar> {
  final Box _box;
  final String _profileId;

  AvatarNotifier(this._box, this._profileId)
      : super(kDefaultAvatars.first);

  /// 選択されたアバターを読み込む
  void load() {
    final avatarId = _box.get('avatar_id_$_profileId', defaultValue: 1) as int;
    final avatar = getAvatarById(avatarId);
    if (avatar != null) {
      state = avatar;
    }
  }

  /// アバターを選択
  Future<void> selectAvatar(Avatar avatar) async {
    await _box.put('avatar_id_$_profileId', avatar.id);
    state = avatar;
  }

  /// 選択済みアバターのIDを取得
  int getSelectedAvatarId() {
    return _box.get('avatar_id_$_profileId', defaultValue: 1) as int;
  }
}

/// アバター選択プロバイダー（StateNotifier）
///
/// 現在のプロフィールに対するアバター選択を管理します。
/// プロフィール切替時に自動的に再読み込みされます。
final avatarProvider = StateNotifierProvider.autoDispose<AvatarNotifier, Avatar>((ref) {
  final activeProfile = ref.watch(activeProfileProvider);

  // プロフィールボックスを取得
  final boxName = 'profile_${activeProfile?.id ?? 'default'}';
  final box = Hive.isBoxOpen(boxName) ? Hive.box(boxName) : Hive.box('profiles');

  final profileId = activeProfile?.id ?? 'default';
  final notifier = AvatarNotifier(box, profileId);

  // 読み込み
  notifier.load();

  return notifier;
});

/// 指定したプロフィールIDにアバターを直接保存する（Hive box への書き込みのみ）。
///
/// プロフィール新規作成直後など、`activeProfileIdProvider` の変更で
/// `avatarProvider`（autoDispose）が破棄・再構築されるタイミングと重なると、
/// `ref.read(avatarProvider.notifier).selectAvatar(...)` の await 中に
/// 元の AvatarNotifier が dispose され「Tried to use AvatarNotifier after
/// `dispose` was called」で例外になることがある。box への書き込みだけなら
/// この競合を避けられるため、作成直後の保存はこちらを使う。
Future<void> setAvatarForProfile(String profileId, Avatar avatar) async {
  final boxName = 'profile_$profileId';
  final box =
      Hive.isBoxOpen(boxName) ? Hive.box(boxName) : Hive.box('profiles');
  await box.put('avatar_id_$profileId', avatar.id);
}

/// 指定したプロフィールIDに紐づくアバターを同期的に取得する。
/// プロフィール一覧画面など、複数プロフィールのアバターをまとめて表示する場合に使用。
/// (Item 6/8: emoji 表示から Avatar 画像モデルへ統一するためのヘルパー)
Avatar getAvatarForProfile(String profileId) {
  final boxName = 'profile_$profileId';
  final box = Hive.isBoxOpen(boxName)
      ? Hive.box(boxName)
      : (Hive.isBoxOpen('profiles') ? Hive.box('profiles') : null);
  if (box == null) return kDefaultAvatars.first;
  final avatarId = box.get('avatar_id_$profileId', defaultValue: 1) as int;
  return getAvatarById(avatarId) ?? kDefaultAvatars.first;
}

/// デフォルトアバターを取得するプロバイダー
final defaultAvatarProvider = Provider<Avatar>((ref) {
  return kDefaultAvatars.first;
});

/// 利用可能なアバター一覧（現在のデフォルト4つ）
final availableAvatarsProvider = Provider<List<Avatar>>((ref) {
  return getDefaultAvatars();
});
