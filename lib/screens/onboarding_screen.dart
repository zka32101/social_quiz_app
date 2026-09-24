import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../utils/button_styles.dart';

/// オンボーディング画面（初回起動時のウェルカム画面）
///
/// ユーザーの最初のアプリ起動時に表示されます。
/// アバター選択は次のプロフィール作成画面で行うため、ここでは行いません
/// （以前はここでも選択できたが、プロフィール作成と重複するため削除）。
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  void _goToProfileSelection() {
    // オンボーディング完了後、プロフィール選択画面へ
    context.go('/profile-selection');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _WelcomePage(onNext: _goToProfileSelection),
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
                    'はじめる',
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
