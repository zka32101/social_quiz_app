import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/avatar.dart';
import '../providers/avatar_provider.dart';
import '../screens/profile_settings_screen.dart';

/// アバター表示ウィジェット（大サイズ）
///
/// ホーム画面やプロフィール画面での表示用。
/// タップするとプロフィール設定画面に移動します。
class AvatarDisplayLarge extends ConsumerWidget {
  final VoidCallback? onTap;
  final bool showLabel;

  const AvatarDisplayLarge({
    Key? key,
    this.onTap,
    this.showLabel = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final avatar = ref.watch(avatarProvider);

    return GestureDetector(
      onTap: onTap ??
          () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const ProfileSettingsScreen(),
              ),
            );
          },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // アバター画像
          Container(
            width: 120,
            height: 120,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade100,
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.blue.shade300,
                width: 3,
              ),
            ),
            child: Image.asset(
              avatar.imageAsset,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return Icon(
                  Icons.person,
                  size: 60,
                  color: Colors.blue.shade300,
                );
              },
            ),
          ),
          if (showLabel) ...[
            const SizedBox(height: 12),
            Text(
              avatar.nameJa,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// アバター表示ウィジェット（小サイズ）
///
/// ヘッダーやリスト内での表示用。
/// タップするとプロフィール設定画面に移動します。
class AvatarDisplaySmall extends ConsumerWidget {
  final VoidCallback? onTap;
  final double size;

  const AvatarDisplaySmall({
    Key? key,
    this.onTap,
    this.size = 48,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final avatar = ref.watch(avatarProvider);

    return GestureDetector(
      onTap: onTap ??
          () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const ProfileSettingsScreen(),
              ),
            );
          },
      child: Container(
        width: size,
        height: size,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.blue.shade100,
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.blue.shade300,
            width: 2,
          ),
        ),
        child: Image.asset(
          avatar.imageAsset,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return Icon(
              Icons.person,
              size: size * 0.5,
              color: Colors.blue.shade300,
            );
          },
        ),
      ),
    );
  }
}

/// アバター表示ウィジェット（超小サイズ）
///
/// AppBar やタイルの右側での表示用。
class AvatarDisplayTiny extends ConsumerWidget {
  final VoidCallback? onTap;

  const AvatarDisplayTiny({
    Key? key,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final avatar = ref.watch(avatarProvider);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: Colors.blue.shade100,
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.blue.shade300,
            width: 1.5,
          ),
        ),
        child: Image.asset(
          avatar.imageAsset,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return Icon(
              Icons.person,
              size: 16,
              color: Colors.blue.shade300,
            );
          },
        ),
      ),
    );
  }
}
