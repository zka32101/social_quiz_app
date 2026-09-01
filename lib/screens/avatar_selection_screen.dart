import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/avatar.dart';
import '../providers/avatar_provider.dart';

/// アバター選択スクリーン
///
/// ユーザーがプロフィール画像（アバター）を選択します。
/// デフォルト4つのアバターから選択可能です。
/// 国語アプリと同じデザインを目指します。
class AvatarSelectionScreen extends ConsumerWidget {
  final VoidCallback? onSelected;

  const AvatarSelectionScreen({
    Key? key,
    this.onSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentAvatar = ref.watch(avatarProvider);
    final availableAvatars = ref.watch(availableAvatarsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('アバター選択'),
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // タイトルセクション
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'あなたのアバターを選ぼう！',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '国語のように、好きなキャラクターを選んでください',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            // アバターグリッド
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: List.generate(availableAvatars.length, (index) {
                  final avatar = availableAvatars[index];
                  final isSelected = currentAvatar.id == avatar.id;

                  return GestureDetector(
                    onTap: () async {
                      await ref.read(avatarProvider.notifier).selectAvatar(avatar);
                      onSelected?.call();
                    },
                    child: _AvatarCard(
                      avatar: avatar,
                      isSelected: isSelected,
                    ),
                  );
                }),
              ),
            ),
            // 選択状態表示＋確認ボタン
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  Text(
                    '選択中: ${currentAvatar.nameJa}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop(currentAvatar);
                      },
                      child: const Text('決定'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// アバターカードウィジェット
class _AvatarCard extends StatelessWidget {
  final Avatar avatar;
  final bool isSelected;

  const _AvatarCard({
    required this.avatar,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: isSelected ? Colors.blue : Colors.grey.shade300,
          width: isSelected ? 3 : 1,
        ),
        borderRadius: BorderRadius.circular(12),
        color: isSelected ? Colors.blue.shade50 : Colors.white,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // アバター画像
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Image.asset(
                avatar.imageAsset,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                      child: Icon(Icons.image_not_supported),
                    ),
                  );
                },
              ),
            ),
          ),
          // アバター名
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              avatar.nameJa,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          // チェックマーク（選択時）
          if (isSelected)
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// アバター選択ダイアログ
Future<Avatar?> showAvatarSelectionDialog(BuildContext context) {
  return showDialog<Avatar>(
    context: context,
    builder: (context) => Dialog(
      insetPadding: const EdgeInsets.all(16),
      child: AvatarSelectionScreen(
        onSelected: () => Navigator.pop(context),
      ),
    ),
  );
}
