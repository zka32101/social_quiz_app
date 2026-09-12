import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_core/shared_core.dart'
    show requireParentalGate, ScreenTimeSettingsWidget, NotificationSettingsPage, RetentionDashboard, AddFriendDialog;
import '../../repositories/progress_repository.dart';
import '../../repositories/profile_repository.dart';
import '../../theme/app_theme.dart' show kSocialPrimary;

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(progressProvider);
    final activeProfile = ref.watch(activeProfileProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('設定')),
      body: Builder(builder: (context) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // ── プロフィール管理 ──────────────────────────
              const Text(
                'プロフィール管理',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Current profile row
                      Row(
                        children: [
                          Text(
                            activeProfile?.emoji ?? '👤',
                            style: const TextStyle(fontSize: 32),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              activeProfile?.name ?? 'プロフィールなし',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          OutlinedButton(
                            onPressed: () => context.push('/profile-selection'),
                            child: const Text('切替'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () => context.push('/profile-create'),
                          icon: const Icon(Icons.add),
                          label: const Text('新しいプロフィールを追加'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // ── 保護者レポート ─────────────────────────────
              Card(
                child: ListTile(
                  leading: const Icon(Icons.bar_chart_rounded, color: Colors.blue),
                  title: const Text('保護者レポート'),
                  subtitle: const Text('学習状況の確認・共有'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push('/parent-report'),
                ),
              ),
              const SizedBox(height: 16),
              // ── ソーシャル ─────────────────────────────────
              Card(
                child: ListTile(
                  leading: const Icon(Icons.person_add, color: Colors.orange),
                  title: const Text('フレンドを探す'),
                  subtitle: const Text('ユーザーを検索してフレンド申請する'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _openAddFriendDialog(context),
                ),
              ),
              const SizedBox(height: 16),
              // ── 利用時間制限 ───────────────────────────────
              // 設定変更は保護者向けの操作のため requireParentalGate を通す
              // （課金操作と同じパターン。paywall_screen.dart 参照）
              Card(
                child: ListTile(
                  leading: const Icon(Icons.hourglass_bottom_rounded, color: Colors.deepPurple),
                  title: const Text('利用時間制限'),
                  subtitle: const Text('1日の利用時間の上限を設定できます'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _openScreenTimeSettings(context),
                ),
              ),
              const SizedBox(height: 16),
              // ── 既存の設定 ────────────────────────────────
              // プレミアム状態によって表示を切り替える
              // （非プレミアムに「全コンテンツ無料」と表示するとpaywallと矛盾するため）
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: progress.isPremium
                      ? const Row(
                          children: [
                            Text('🎉', style: TextStyle(fontSize: 20)),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'プレミアム会員：全コンテンツを無料でお楽しみいただけます！',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        )
                      : Row(
                          children: [
                            const Text('🔓', style: TextStyle(fontSize: 20)),
                            const SizedBox(width: 10),
                            const Expanded(
                              child: Text(
                                '一部コンテンツは無料でお楽しみいただけます。プレミアムで全都道府県が解放されます。',
                                style: TextStyle(fontSize: 13),
                              ),
                            ),
                            TextButton(
                              onPressed: () => context.push('/paywall'),
                              child: const Text('詳しく見る'),
                            ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 16),
              // ── 分析 ───────────────────────────────────────
              Card(
                child: ListTile(
                  leading: const Icon(Icons.assessment_outlined, color: Colors.teal),
                  title: const Text('ユーザーリテンション分析'),
                  subtitle: const Text('あなたの活動パターンと継続性を分析'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const RetentionDashboard(),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 保護者メール — 4 kanji → add furigana
                      RichText(
                        text: const TextSpan(
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                          children: [
                            TextSpan(text: '保護者メール'),
                            TextSpan(
                              text: ' (ほごしゃめーる)',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.normal,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        progress.parentEmail?.isNotEmpty == true
                            ? progress.parentEmail!
                            : '未設定',
                        style: const TextStyle(fontSize: 15),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () {
                            context.push('/settings/parent-email');
                          },
                          child: const Text('保護者メールを変更'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  /// フレンド検索ダイアログを開く
  void _openAddFriendDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const AddFriendDialog(),
    );
  }

  /// 保護者ゲートを通したうえで、利用時間制限の設定画面を開く。
  Future<void> _openScreenTimeSettings(BuildContext context) async {
    final passedGate = await requireParentalGate(
      context,
      title: '保護者の方へ確認',
      description: 'これは利用時間の上限を設定する操作です。\n下の計算の答えを入力してください。',
    );
    if (!passedGate || !context.mounted) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => Scaffold(
          appBar: AppBar(title: const Text('利用時間制限')),
          body: const ScreenTimeSettingsWidget(primaryColor: kSocialPrimary),
        ),
      ),
    );
  }
}