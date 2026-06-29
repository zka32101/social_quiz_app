import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/player_stats.dart';
import '../../providers/matchmaking_provider.dart';

class MatchingWaitingScreen extends ConsumerStatefulWidget {
  final PlayerStats myStats;

  const MatchingWaitingScreen({required this.myStats, super.key});

  @override
  ConsumerState<MatchingWaitingScreen> createState() =>
      _MatchingWaitingScreenState();
}

class _MatchingWaitingScreenState
    extends ConsumerState<MatchingWaitingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // マッチング開始
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(matchmakingProvider.notifier)
          .startSearching(widget.myStats);
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final matchmakingState = ref.watch(matchmakingProvider);

    // マッチング確定 → 対戦画面へ遷移
    ref.listen(matchmakingProvider, (prev, next) {
      if (next.status == MatchmakingStatus.matched && next.matchId != null) {
        context.go(
          '/multiplayer-quiz/${next.matchId}?userId=${widget.myStats.userId}',
        );
        ref.read(matchmakingProvider.notifier).reset();
      }
    });

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (!didPop) {
          final cancel = await _showCancelDialog(context);
          if (cancel == true) {
            await ref
                .read(matchmakingProvider.notifier)
                .cancelSearch(widget.myStats.userId);
            if (context.mounted) context.go('/multiplayer');
          }
        }
      },
      child: Scaffold(
        backgroundColor: Colors.blue.shade700,
        body: SafeArea(
          child: _buildBody(context, matchmakingState),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, MatchmakingState state) {
    if (state.status == MatchmakingStatus.error) {
      return _buildErrorView(context, state.errorMessage);
    }

    return Column(
      children: [
        const Spacer(),
        _buildSearchingAnimation(),
        const SizedBox(height: 32),
        _buildStatusText(),
        const SizedBox(height: 16),
        _buildRatingInfo(),
        const Spacer(),
        _buildCancelButton(context),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildSearchingAnimation() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // 外側のリング（パルス）
        AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (_, __) => Transform.scale(
            scale: _pulseAnimation.value,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.1),
                border: Border.all(color: Colors.white24, width: 2),
              ),
            ),
          ),
        ),
        // プレイヤーアバター
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: Text(
              widget.myStats.userEmoji,
              style: const TextStyle(fontSize: 48),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusText() {
    return Column(
      children: [
        Text(
          widget.myStats.userName,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          '対戦相手を探しています...',
          style: TextStyle(color: Colors.white70, fontSize: 16),
        ),
        const SizedBox(height: 8),
        // ドット アニメーション
        _DotsAnimation(),
      ],
    );
  }

  Widget _buildRatingInfo() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white12,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star, color: Colors.amber, size: 18),
          const SizedBox(width: 6),
          Text(
            'レート: ${widget.myStats.ratingScore.toStringAsFixed(0)}  (±300範囲で検索中)',
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildCancelButton(BuildContext context) {
    return TextButton(
      onPressed: () async {
        final cancel = await _showCancelDialog(context);
        if (cancel == true) {
          await ref
              .read(matchmakingProvider.notifier)
              .cancelSearch(widget.myStats.userId);
          if (context.mounted) context.go('/multiplayer');
        }
      },
      child: const Text(
        'キャンセル',
        style: TextStyle(color: Colors.white60, fontSize: 16),
      ),
    );
  }

  Widget _buildErrorView(BuildContext context, String? message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.wifi_off, color: Colors.white60, size: 64),
            const SizedBox(height: 24),
            Text(
              message ?? '対戦相手が見つかりませんでした',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.blue.shade700,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              onPressed: () {
                ref.read(matchmakingProvider.notifier).reset();
                ref
                    .read(matchmakingProvider.notifier)
                    .startSearching(widget.myStats);
              },
              child: const Text('もう一度探す',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () {
                ref.read(matchmakingProvider.notifier).reset();
                context.go('/multiplayer');
              },
              child: const Text('戻る',
                  style: TextStyle(color: Colors.white60)),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool?> _showCancelDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('検索をキャンセルしますか？'),
        content: const Text('対戦相手の検索を中止して戻ります。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('続ける'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('キャンセル',
                style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

// ドットアニメーションウィジェット
class _DotsAnimation extends StatefulWidget {
  @override
  State<_DotsAnimation> createState() => _DotsAnimationState();
}

class _DotsAnimationState extends State<_DotsAnimation> {
  int _dotCount = 1;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 500), _tick);
  }

  void _tick() {
    if (!mounted) return;
    setState(() => _dotCount = (_dotCount % 3) + 1);
    Future.delayed(const Duration(milliseconds: 500), _tick);
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      '●' * _dotCount + '○' * (3 - _dotCount),
      style: const TextStyle(color: Colors.white38, fontSize: 14),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
