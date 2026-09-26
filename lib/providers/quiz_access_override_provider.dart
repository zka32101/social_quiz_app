import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repositories/progress_repository.dart';

/// クイズへのアクセス可否。
/// UserProgress.hasAccess（プレミアム or 無料期間中）をそのまま使う。
/// 以前は別の（そして未接続だった）サブスク状態プロバイダーに依存していたが、
/// 進捗データと二重管理になり不整合の原因になっていたため一本化した。
final canAccessSocialQuizzesProvider = Provider<bool>((ref) {
  return ref.watch(progressProvider).hasAccess;
});

/// ペイウォール表示が必要か
final shouldShowSocialPaywallProvider = Provider<bool>((ref) {
  return !ref.watch(canAccessSocialQuizzesProvider);
});

/// 無料期間の残り日数
final remainingSocialFreeDaysProvider = Provider<int>((ref) {
  return ref.watch(progressProvider).trialDaysRemaining;
});
