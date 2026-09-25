import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_core/shared_core.dart'
    show requireParentalGate, ScreenTimeSettingsWidget, NotificationSettingsPage, RetentionDashboard, AddFriendDialog;
import 'package:shared_core/models/push_notification_model.dart' show RetentionMetrics;
import 'package:shared_core/providers/push_notification_provider.dart' show userRetentionMetricsProvider;
import '../../repositories/progress_repository.dart';
import '../../repositories/profile_repository.dart';
import '../../services/quiz_history_service.dart';
import '../../theme/app_theme.dart' show kSocialPrimary;
import '../../widgets/avatar_display_widget.dart';

/// ローカルの進捗データ（ストリーク・クイズ履歴）から簡易的な
/// リテンション指標を計算する。サーバー側のセッション計測は行っていないため
/// セッション数・平均時間はクイズ履歴から推定した値を使う。
RetentionMetrics _buildLocalRetentionMetrics(WidgetRef ref, String userId) {
  final progress = ref.read(progressProvider);
  final quizStats = ref.read(quizOverallStatsProvider);

  final lastActiveAt = progress.lastStudiedAt ?? DateTime.now();
  final daysWithoutActivity =
      DateTime.now().difference(lastActiveAt).inDays.clamp(0, 9999);

  final String riskLevel;
  if (daysWithoutActivity >= 14) {
    riskLevel = 'critical';
  } else if (daysWithoutActivity >= 7) {
    riskLevel = 'high';
  } else if (daysWithoutActivity >= 3) {
    riskLevel = 'medium';
  } else {
    riskLevel = 'low';
  }

  final churnIndicators = <String>[
    if (daysWithoutActivity >= 3) '$daysWithoutActivity日間 学習していません',
    if (progress.streak == 0) '連続学習ストリークが途切れています',
  ];
  final recommendedActions = <String>[
    if (riskLevel == 'high' || riskLevel == 'critical')
      'リマインダー通知で学習を促しましょう',
    if (progress.streak > 0) 'ストリークを継続できるよう応援しましょう',
    if (churnIndicators.isEmpty) '順調に学習が続いています',
  ];

  return RetentionMetrics(
    userId: userId,
    consecutiveActiveDays: progress.streak,
    totalActiveDays: progress.streak,
    daysWithoutActivity: daysWithoutActivity,
    dailyActiveRate: (progress.streak / 7).clamp(0.0, 1.0),
    weeklyRetentionRate: (progress.streak / 7).clamp(0.0, 1.0),
    monthlyRetentionRate: (progress.streak / 30).clamp(0.0, 1.0),
    riskLevel: riskLevel,
    sessionCount: quizStats.totalAttempts,
    averageSessionDurationMinutes: quizStats.averageTimePerQuestion / 60,
    lastActiveAt: lastActiveAt,
    analyzedAt: DateTime.now(),
    churnIndicators: churnIndicators,
    recommendedActions: recommendedActions,
  );
}

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
                          // Item 6/8: emoji ではなく Avatar 画像モデルを表示
                          const AvatarDisplaySmall(size: 40),
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
                  onTap: () {
                    // このアプリは Firebase Auth ではなくローカルプロフィール
                    // （activeProfileIdProvider）でユーザーを識別しているため、
                    // Firebase Auth の uid ではなくこちらを使う
                    // （以前は uid が常に null で画面が開かなかった）。
                    final userId = ref.read(activeProfileIdProvider);
                    if (userId == null) return;
                    // userRetentionMetricsProvider は記録用の provider のため、
                    // ローカルの進捗データから指標を計算して記録してから開く
                    // （以前は誰も記録していなかったため永久にローディング表示のままだった）。
                    final metrics = _buildLocalRetentionMetrics(ref, userId);
                    ref
                        .read(userRetentionMetricsProvider.notifier)
                        .recordRetentionMetrics(metrics);
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => RetentionDashboard(userId: userId),
                      ),
                    );
                  },
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
                          onPressed: () => _showParentEmailDialog(
                            context,
                            ref,
                            progress.parentEmail ?? '',
                          ),
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

  /// 保護者メールを入力・保存するダイアログを開く
  void _showParentEmailDialog(
    BuildContext context,
    WidgetRef ref,
    String currentEmail,
  ) {
    final controller = TextEditingController(text: currentEmail);
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('保護者メール'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
            hintText: 'example@email.com',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () {
              ref
                  .read(progressProvider.notifier)
                  .setParentEmail(controller.text.trim());
              Navigator.of(dialogContext).pop();
            },
            child: const Text('保存'),
          ),
        ],
      ),
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