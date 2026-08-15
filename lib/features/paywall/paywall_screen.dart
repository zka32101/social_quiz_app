import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../../providers/purchase_provider.dart';
import '../../utils/constants.dart';

class PaywallScreen extends ConsumerWidget {
  const PaywallScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final offeringsAsync = ref.watch(offeringsProvider);
    final purchaseState = ref.watch(purchaseNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('プレミアムプラン'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => context.pop(),
          ),
        ],
      ),
      body: SafeArea(
        child: offeringsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => _buildFallbackPaywall(context, ref, purchaseState),
          data: (offerings) => offerings == null || offerings.current == null
              ? _buildFallbackPaywall(context, ref, purchaseState)
              : _buildPaywallWithOfferings(
                  context, ref, offerings.current!, purchaseState),
        ),
      ),
    );
  }

  Widget _buildPaywallWithOfferings(
    BuildContext context,
    WidgetRef ref,
    Offering offering,
    PurchaseState purchaseState,
  ) {
    final monthly = offering.monthly;
    final annual = offering.annual;

    return _PaywallBody(
      monthlyPackage: monthly,
      annualPackage: annual,
      purchaseState: purchaseState,
      onPurchase: (package) => _handlePurchase(context, ref, package),
      onRestore: () => _handleRestore(context, ref),
    );
  }

  Widget _buildFallbackPaywall(
    BuildContext context,
    WidgetRef ref,
    PurchaseState purchaseState,
  ) {
    return _PaywallBody(
      monthlyPackage: null,
      annualPackage: null,
      purchaseState: purchaseState,
      // 商品情報（offerings）の取得に失敗しているため購入不可。
      // ボタンを押しても何も起きない「無反応」を避け、理由を伝える。
      onPurchase: (_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('現在プランを読み込めませんでした。時間をおいて再度お試しください'),
            backgroundColor: Colors.orange,
          ),
        );
      },
      onRestore: () => _handleRestore(context, ref),
    );
  }

  Future<void> _handlePurchase(
      BuildContext context, WidgetRef ref, Package? package) async {
    if (package == null) return;

    final success =
        await ref.read(purchaseNotifierProvider.notifier).purchase(package);

    if (success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🎉 プレミアムプランへようこそ！'),
          backgroundColor: Colors.green,
        ),
      );
      context.pop();
    }
  }

  Future<void> _handleRestore(BuildContext context, WidgetRef ref) async {
    final isPremium =
        await ref.read(purchaseNotifierProvider.notifier).restore();

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isPremium ? '✅ 購入を復元しました' : '復元できる購入が見つかりませんでした'),
          backgroundColor: isPremium ? Colors.green : Colors.orange,
        ),
      );
      if (isPremium) context.pop();
    }
  }
}

class _PaywallBody extends StatefulWidget {
  final Package? monthlyPackage;
  final Package? annualPackage;
  final PurchaseState purchaseState;
  final void Function(Package?) onPurchase;
  final VoidCallback onRestore;

  const _PaywallBody({
    required this.monthlyPackage,
    required this.annualPackage,
    required this.purchaseState,
    required this.onPurchase,
    required this.onRestore,
  });

  @override
  State<_PaywallBody> createState() => _PaywallBodyState();
}

class _PaywallBodyState extends State<_PaywallBody> {
  bool _selectedYearly = true;

  @override
  Widget build(BuildContext context) {
    final monthlyPrice = widget.monthlyPackage?.storeProduct.priceString ?? '¥300/月';
    final annualPrice = widget.annualPackage?.storeProduct.priceString ?? '¥2,400/年';
    final isLoading =
        widget.purchaseState.status == PurchaseStatus.loading;
    // ストアが実際に無料トライアルを提供している場合のみバッジを表示する
    final hasFreeTrial =
        widget.monthlyPackage?.storeProduct.introductoryPrice != null;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 8),
          const Text('👑', style: TextStyle(fontSize: 64)),
          const SizedBox(height: 16),
          const Text(
            '全機能を解放しよう！',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),

          // 特典リスト
          _buildBenefitsList(),
          const SizedBox(height: 24),

          // プランカード
          _PlanCard(
            title: '年額プラン',
            price: annualPrice,
            badge: '¥200/月 — 2ヶ月分お得',
            isSelected: _selectedYearly,
            isBestValue: true,
            onTap: () => setState(() => _selectedYearly = true),
          ),
          const SizedBox(height: 12),
          _PlanCard(
            title: '月額プラン',
            price: monthlyPrice,
            // ストア側で無料トライアルが実際に設定されている場合のみ表示する
            // （固定文言だと未対応ユーザー・トライアル済みユーザーにも
            //   「14日間無料」と誤って約束してしまうため）
            badge: hasFreeTrial
                ? '14日間無料！その後 $monthlyPrice'
                : monthlyPrice,
            isSelected: !_selectedYearly,
            isBestValue: false,
            onTap: () => setState(() => _selectedYearly = false),
          ),
          const SizedBox(height: 32),

          // 購入ボタン
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isLoading
                  ? null
                  : () => widget.onPurchase(
                        _selectedYearly
                            ? widget.annualPackage
                            : widget.monthlyPackage,
                      ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text(
                      '今すぐはじめる',
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
            ),
          ),

          // エラー表示
          if (widget.purchaseState.status == PurchaseStatus.error)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                widget.purchaseState.errorMessage ?? '',
                style: const TextStyle(color: Colors.red, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ),

          const SizedBox(height: 16),
          TextButton(
            onPressed: widget.onRestore,
            child: const Text('購入を復元する',
                style: TextStyle(color: Colors.grey)),
          ),
          const SizedBox(height: 4),
          const Text(
            '大人の方へ: アプリ内課金が発生します',
            style: TextStyle(fontSize: 12, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitsList() {
    const benefits = [
      ('🗾', '全47都道府県を学習'),
      ('📚', '歴史・経済・公民・産業すべてのカテゴリ'),
      ('⚔️', 'マルチプレイ対戦が無制限'),
      ('🏆', 'ランキング参加・バッジ収集'),
      ('📊', '学習レポート・復習ノート'),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: benefits
            .map((b) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Text(b.$1, style: const TextStyle(fontSize: 18)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(b.$2,
                            style: const TextStyle(fontSize: 14)),
                      ),
                    ],
                  ),
                ))
            .toList(),
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  final String title;
  final String price;
  final String badge;
  final bool isSelected;
  final bool isBestValue;
  final VoidCallback onTap;

  const _PlanCard({
    required this.title,
    required this.price,
    required this.badge,
    required this.isSelected,
    required this.isBestValue,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color:
                isSelected ? colorScheme.primary : Colors.grey.shade300,
            width: isSelected ? 2.5 : 1.5,
          ),
          borderRadius: BorderRadius.circular(12),
          color: isSelected
              ? colorScheme.primary.withOpacity(0.05)
              : Colors.white,
        ),
        child: Stack(
          children: [
            Row(
              children: [
                Icon(
                  isSelected
                      ? Icons.radio_button_checked
                      : Icons.radio_button_off,
                  color: isSelected ? colorScheme.primary : Colors.grey,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600)),
                      const SizedBox(height: 4),
                      Text(badge,
                          style: TextStyle(
                            fontSize: 13,
                            color: isSelected
                                ? colorScheme.primary
                                : Colors.grey.shade600,
                          )),
                    ],
                  ),
                ),
                Text(price,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? colorScheme.primary
                          : Colors.black87,
                    )),
              ],
            ),
            if (isBestValue)
              Positioned(
                right: 0,
                top: -8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text('おすすめ',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
