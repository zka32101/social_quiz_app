import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_core/shared_core.dart'
    show
        CollectionProgressCard,
        ReviewTodayCard,
        kPrefectureCollection,
        onboardingProvider,
        weeklyChallengeProvider;

import '../../../theme/app_theme.dart' show kSocialPrimary;

/// ホーム画面に出す定着率施策（初回7日間の報酬・今日の復習・週次チャレンジ・
/// 都道府県コンプリート）。出すものがなければ何も表示しない。
class RetentionSection extends ConsumerWidget {
  const RetentionSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final onboarding = ref.watch(onboardingProvider);
    final weekly = ref.watch(weeklyChallengeProvider);
    final claimable = onboarding.claimable;

    return Column(
      children: [
        if (claimable.isNotEmpty) ...[
          Card(
            color: Colors.amber.shade50,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('🎁 はじめての7日間ごほうび（${onboarding.claimedDays.length}/7）',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  for (final r in claimable)
                    ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      title: Text('${r.day}日目: ${r.title}'),
                      subtitle: Text(r.description),
                      trailing: FilledButton(
                        onPressed: () async {
                          final messenger = ScaffoldMessenger.of(context);
                          final got = await ref
                              .read(onboardingProvider.notifier)
                              .claim(r.day);
                          if (got != null) {
                            messenger.showSnackBar(SnackBar(
                                content: Text('🪙 ${got.coins} コインをもらったよ！')));
                          }
                        },
                        child: Text('🪙 ${r.coins}'),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
        ReviewTodayCard(
          color: kSocialPrimary,
          onStart: () => context.push('/wrong-answer-review'),
        ),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  weekly.isComplete
                      ? '🎉 今週のチャレンジ達成！'
                      : '🎯 今週のチャレンジ：あと${weekly.remaining}問正解',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(value: weekly.progress, color: kSocialPrimary),
              ],
            ),
          ),
        ),
        const SizedBox(height: 4),
        CollectionProgressCard(set: kPrefectureCollection, color: kSocialPrimary),
        const SizedBox(height: 16),
      ],
    );
  }
}
