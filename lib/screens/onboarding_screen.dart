import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/avatar.dart';
import '../providers/avatar_provider.dart';
import '../screens/avatar_selection_screen.dart';
import '../utils/button_styles.dart';

/// オンボーディング画面（初回起動時のアバター選択）
///
/// ユーザーの最初のアプリ起動時に表示され、
/// アバター（プロフィール画像）を選択するよう促します。
/// 国語アプリと同じ親切なデザインを目指します。
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToProfileSelection() {
    // オンボーディング完了後、プロフィール選択画面へ
    context.go('/profile-selection');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) => setState(() => _currentPage = index),
        children: [
          // ページ1: ウェルカム
          _WelcomePage(
            onNext: () => _pageController.nextPage(
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeInOut,
            ),
          ),
          // ページ2: アバター選択
          _AvatarSelectionPage(
            onComplete: _goToProfileSelection,
            onSkip: _goToProfileSelection,
          ),
        ],
      ),
    );
  }
}

/// ページ1: ウェルカムページ
class _WelcomePage extends StatelessWidget {
  final VoidCallback onNext;

  const _WelcomePage({required this.onNext});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // ロゴ・タイトル
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // アイコン
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.blue.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '🗾',
                        style: TextStyle(fontSize: 60),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  // アプリ名
                  const Text(
                    '小学コレ！社会',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // サブタイトル
                  Text(
                    '日本の地理・歴史・政治・経済を\n楽しく学べるアプリ',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
            // ウェルカムメッセージ
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.blue.shade200,
                  width: 2,
                ),
              ),
              child: Column(
                children: [
                  const Text(
                    'ようこそ！👋',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '簡単な設定で、学習を始めましょう。',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // 次へボタン
            BottomButtonPadding(
              child: SizedBox(
                width: double.infinity,
                height: 64,
                child: ElevatedButton(
                  style: AppButtonStyles.primaryLarge(),
                  onPressed: onNext,
                  child: const Text(
                    '次へ',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ページ2: アバター選択ページ
class _AvatarSelectionPage extends ConsumerWidget {
  final VoidCallback onComplete;
  final VoidCallback onSkip;

  const _AvatarSelectionPage({
    required this.onComplete,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentAvatar = ref.watch(avatarProvider);
    final availableAvatars = ref.watch(availableAvatarsProvider);

    return SafeArea(
      child: Column(
        children: [
          // ヘッダー
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'アバターを選ぼう！',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '好きなキャラクターを選んでください\n（後からいつでも変更できます）',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                    height: 1.5,
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
                  },
                  child: Container(
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
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        // チェックマーク
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
                  ),
                );
              }),
            ),
          ),
          // ボタン領域
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                // 選択状態表示
                Text(
                  '選択中: ${currentAvatar.nameJa}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 16),
                // 完了ボタン
                SizedBox(
                  width: double.infinity,
                  height: 64,
                  child: ElevatedButton(
                    onPressed: onComplete,
                    child: const Text(
                      '学習をはじめる',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // スキップボタン
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: TextButton(
                    onPressed: onSkip,
                    child: const Text(
                      'スキップ',
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
