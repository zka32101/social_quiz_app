import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../repositories/progress_repository.dart';
import '../../repositories/profile_repository.dart';

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
}