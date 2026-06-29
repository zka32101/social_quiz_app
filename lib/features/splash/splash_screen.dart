import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../repositories/profile_repository.dart';
import '../../utils/constants.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );
    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );
    _controller.forward();
    _initialize();
  }

  Future<void> _initialize() async {
    await Future.delayed(const Duration(milliseconds: 1800));
    if (!mounted) return;

    final profileRepo = ref.read(profileRepositoryProvider);
    final profiles = profileRepo.getAllProfiles();

    if (profiles.isEmpty) {
      // 初回起動：プロフィール作成へ
      context.go('/profile-selection');
    } else {
      final activeId = profileRepo.getActiveProfileId();
      if (activeId != null && profiles.any((p) => p.id == activeId)) {
        // アクティブプロフィールのボックスを開いてホームへ
        await openProfileBox(activeId);
        ref.read(activeProfileIdProvider.notifier).state = activeId;
        if (mounted) context.go(AppRoutes.home);
      } else {
        // プロフィール選択へ
        context.go('/profile-selection');
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF2ECC71), Color(0xFF27AE60)],
          ),
        ),
        child: Stack(
          children: [
            // 浮かぶ星の装飾
            const _FloatingStar(top: 80, left: 30, delay: 0),
            const _FloatingStar(top: 160, right: 40, delay: 500),
            const _FloatingStar(top: 320, left: 50, delay: 1000),
            const _FloatingStar(bottom: 200, right: 30, delay: 1500),

            // メインコンテンツ
            SafeArea(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(flex: 2),

                    // ロゴ
                    ScaleTransition(
                      scale: _scaleAnimation,
                      child: const Text('📚', style: TextStyle(fontSize: 80)),
                    ),
                    const SizedBox(height: 20),

                    // アプリ名
                    const Text(
                      '小学コレ！社会',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '小学生の学習を楽しく',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // 教科タグ
                    const Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      alignment: WrapAlignment.center,
                      children: [
                        _SubjectTag('社会'),
                        _SubjectTag('算数'),
                        _SubjectTag('国語'),
                        _SubjectTag('理科'),
                      ],
                    ),

                    const Spacer(flex: 3),

                    // ローディング
                    const SizedBox(
                      width: 28,
                      height: 28,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 3,
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SubjectTag extends StatelessWidget {
  final String label;
  const _SubjectTag(this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.25),
        border: Border.all(color: Colors.white.withOpacity(0.5)),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _FloatingStar extends StatefulWidget {
  final double? top, bottom, left, right;
  final int delay;
  const _FloatingStar({this.top, this.bottom, this.left, this.right, required this.delay});

  @override
  State<_FloatingStar> createState() => _FloatingStarState();
}

class _FloatingStarState extends State<_FloatingStar>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );
    _anim = Tween<double>(begin: 0, end: -20).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _ctrl.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: widget.top,
      bottom: widget.bottom,
      left: widget.left,
      right: widget.right,
      child: AnimatedBuilder(
        animation: _anim,
        builder: (_, __) => Transform.translate(
          offset: Offset(0, _anim.value),
          child: const Text('⭐', style: TextStyle(fontSize: 24, color: Colors.white60)),
        ),
      ),
    );
  }
}
