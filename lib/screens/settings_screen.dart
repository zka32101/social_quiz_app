import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_core/shared_core.dart';

import '../providers/profile_provider.dart';
import '../providers/settings_provider.dart';
import '../theme/app_theme.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(profileProvider);
    final settings = ref.watch(settingsProvider);

    // AnalyticsDashboard 用のサンプルデータ
    final totalQuestions = profile.totalQuestionsAttempted ?? 0;
    final averageAccuracy = profile.averageAccuracy ?? 0.0;
    final totalTimeSpent = profile.totalTimeSpent ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('設定'),
        backgroundColor: AppTheme.primaryColor,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '設定'),
            Tab(text: '学習分析'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab 1: 設定
          _SettingsTabContent(
            profile: profile,
            settings: settings,
            ref: ref,
          ),
          // Tab 2: 学習分析
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: AnalyticsDashboardWidget(
              userName: profile.userName.isEmpty ? 'ユーザー' : profile.userName,
              totalQuestions: totalQuestions,
              averageAccuracy: averageAccuracy,
              totalTimeSpent: totalTimeSpent,
              dailyActivity: _generateDailyActivity(profile),
              accuracyTrend: _generateAccuracyTrend(profile),
            ),
          ),
        ],
      ),
    );
  }

  List<DailyActivityData> _generateDailyActivity(UserProfile profile) {
    return [
      DailyActivityData(day: '月', count: profile.mondayAttempts ?? 0),
      DailyActivityData(day: '火', count: profile.tuesdayAttempts ?? 0),
      DailyActivityData(day: '水', count: profile.wednesdayAttempts ?? 0),
      DailyActivityData(day: '木', count: profile.thursdayAttempts ?? 0),
      DailyActivityData(day: '金', count: profile.fridayAttempts ?? 0),
      DailyActivityData(day: '土', count: profile.saturdayAttempts ?? 0),
      DailyActivityData(day: '日', count: profile.sundayAttempts ?? 0),
    ];
  }

  List<AccuracyTrendData> _generateAccuracyTrend(UserProfile profile) {
    return [
      AccuracyTrendData(week: 'W1', accuracy: profile.week1Accuracy ?? 0.0),
      AccuracyTrendData(week: 'W2', accuracy: profile.week2Accuracy ?? 0.0),
      AccuracyTrendData(week: 'W3', accuracy: profile.week3Accuracy ?? 0.0),
      AccuracyTrendData(week: 'W4', accuracy: profile.week4Accuracy ?? 0.0),
    ];
  }
}

class _SettingsTabContent extends StatelessWidget {
  final UserProfile profile;
  final AppSettings settings;
  final WidgetRef ref;

  const _SettingsTabContent({
    required this.profile,
    required this.settings,
    required this.ref,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // プロフィール情報
        Card(
          child: ListTile(
            leading: const Icon(Icons.person, color: AppTheme.primaryColor),
            title: const Text('プロフィール'),
            subtitle: Text(profile.userName.isEmpty ? '未設定' : profile.userName),
            trailing: const Icon(Icons.edit, color: AppTheme.textMuted),
            onTap: () => _showNameDialog(context),
          ),
        ),
        const SizedBox(height: 16),

        // 音声設定
        _SectionHeader('サウンド設定'),
        Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: SwitchListTile(
            secondary: const Icon(Icons.volume_up, color: AppTheme.primaryColor),
            title: const Text('サウンド'),
            subtitle: const Text('効果音を有効にする'),
            value: settings.soundEnabled,
            onChanged: (v) => ref.read(settingsProvider.notifier).setSoundEnabled(v),
            activeThumbColor: AppTheme.primaryColor,
          ),
        ),
        const SizedBox(height: 16),

        // 通知設定
        _SectionHeader('通知設定'),
        Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: SwitchListTile(
            secondary: const Icon(Icons.notifications, color: AppTheme.accentOrange),
            title: const Text('毎日リマインダー'),
            subtitle: const Text('毎日の学習を通知でサポート'),
            value: settings.notificationEnabled,
            onChanged: (v) => ref.read(settingsProvider.notifier).setNotificationEnabled(v),
            activeThumbColor: AppTheme.accentOrange,
          ),
        ),
        const SizedBox(height: 16),

        // その他
        _SectionHeader('その他'),
        Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: const Icon(Icons.privacy_tip, color: AppTheme.textMuted),
            title: const Text('プライバシーポリシー'),
            trailing: const Icon(Icons.chevron_right, color: AppTheme.textMuted),
            onTap: () => Navigator.of(context).pushNamed('/privacy'),
          ),
        ),
        Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: const Icon(Icons.feedback, color: AppTheme.textMuted),
            title: const Text('バグ報告・ご意見'),
            subtitle: const Text('不具合や改善要望を送る'),
            trailing: const Icon(Icons.chevron_right, color: AppTheme.textMuted),
            onTap: () => Navigator.of(context).pushNamed('/feedback'),
          ),
        ),
        Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: const Icon(Icons.info, color: AppTheme.textMuted),
            title: const Text('アプリについて'),
            subtitle: const Text('バージョン 1.0.0'),
            trailing: const Icon(Icons.chevron_right, color: AppTheme.textMuted),
            onTap: () => showAboutDialog(
              context: context,
              applicationName: '社会コレ！',
              applicationVersion: '1.0.0',
              applicationLegalese: '© 2026 ',
            ),
          ),
        ),

        const SizedBox(height: 32),
      ],
    );
  }

  void _showNameDialog(BuildContext context) {
    final ctrl = TextEditingController(text: profile.userName);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('プロフィール名を設定'),
        content: TextField(
          controller: ctrl,
          decoration: const InputDecoration(
            hintText: '例: たろう',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('キャンセル')),
          ElevatedButton(
            onPressed: () {
              ref.read(profileProvider.notifier).setUserName(ctrl.text.trim());
              Navigator.pop(ctx);
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 8, top: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppTheme.textMuted,
        ),
      ),
    );
  }
}
