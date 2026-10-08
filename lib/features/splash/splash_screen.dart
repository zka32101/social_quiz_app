import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_core/shared_core.dart' show premiumProvider;
import '../../repositories/profile_repository.dart';
import '../../utils/constants.dart';
import '../../widgets/branded_splash.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;

    final profileRepo = ref.read(profileRepositoryProvider);
    final profiles = profileRepo.getAllProfiles();

    if (profiles.isEmpty) {
      // 初回起動：オンボーディングへ（アバター選択）
      if (mounted) context.go('/onboarding');
    } else {
      final activeId = profileRepo.getActiveProfileId();
      if (activeId != null && profiles.any((p) => p.id == activeId)) {
        // アクティブプロフィールのボックスを開いてホームへ
        await openProfileBox(activeId);
        ref.read(activeProfileIdProvider.notifier).state = activeId;
        unawaited(
            ref.read(premiumProvider.notifier).checkSubscription(activeId));
        if (mounted) context.go(AppRoutes.home);
      } else {
        // プロフィール選択へ
        context.go('/profile-selection');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // 起動画面（StartupSplash）と同じ見た目。アニメを再生し直さない。
    return const BrandedSplash();
  }
}
