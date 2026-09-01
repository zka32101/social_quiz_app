import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/avatar.dart';
import '../models/profile.dart';
import '../providers/avatar_provider.dart';
import '../repositories/profile_repository.dart';
import '../services/user_profile_service.dart';
import 'avatar_selection_screen.dart';

/// プロフィール設定スクリーン
///
/// ユーザーが自分のアバター（プロフィール画像）を見て、変更できます。
class ProfileSettingsScreen extends ConsumerWidget {
  const ProfileSettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentAvatar = ref.watch(avatarProvider);
    final currentProfile = ref.watch(activeProfileProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('プロフィール設定'),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // アバター表示セクション
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24.0),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.blue.shade200,
                    width: 2,
                  ),
                ),
                child: Column(
                  children: [
                    // アバター画像
                    SizedBox(
                      width: 140,
                      height: 140,
                      child: Image.asset(
                        currentAvatar.imageAsset,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Center(
                              child: Icon(Icons.image_not_supported),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    // アバター名
                    Text(
                      currentAvatar.nameJa,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      currentAvatar.nameEn,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              // 変更ボタン
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () async {
                    final result = await Navigator.of(context).push<Avatar>(
                      MaterialPageRoute(
                        builder: (context) => const AvatarSelectionScreen(),
                      ),
                    );
                    if (result != null && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${result.nameJa}に変更しました'),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                  child: const Text('アバターを変更'),
                ),
              ),
              const SizedBox(height: 40),
              // ランキング設定セクション
              Text(
                'ランキング設定',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              // 名前公表トグル
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  title: const Text('ランキングに名前を表示'),
                  subtitle: Text(
                    currentProfile?.isNamePublic == true
                        ? 'あなたの名前はランキングに公開されます'
                        : 'ランキングでは匿名で表示されます',
                    style: const TextStyle(fontSize: 12),
                  ),
                  trailing: Switch(
                    value: currentProfile?.isNamePublic ?? false,
                    onChanged: (value) async {
                      if (currentProfile != null) {
                        final updatedProfile = UserProfile(
                          id: currentProfile.id,
                          name: currentProfile.name,
                          emoji: currentProfile.emoji,
                          createdAt: currentProfile.createdAt,
                          isNamePublic: value,
                        );
                        final repo = ref.read(profileRepositoryProvider);
                        repo.updateProfile(updatedProfile);

                        // Sync to Firestore
                        final profileService = UserProfileService();
                        await profileService.updateNamePublicSetting(value);

                        ref.refresh(activeProfileProvider);

                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                value
                                    ? '名前がランキングに表示されるようになりました'
                                    : 'ランキングで匿名表示されるようになりました',
                              ),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        }
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
