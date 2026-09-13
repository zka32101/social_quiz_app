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

/// デフォルトアバターを取得するプロバイダー
final defaultAvatarProvider = Provider<Avatar>((ref) {
  return kDefaultAvatars.first;
});

/// 利用可能なアバター一覧（現在のデフォルト4つ）
final availableAvatarsProvider = Provider<List<Avatar>>((ref) {
  return getDefaultAvatars();
});
