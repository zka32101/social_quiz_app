import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../data/badge_definitions.dart';
import '../../data/prefecture_data.dart' show PrefectureDataList;
import '../../utils/constants.dart';

class ResultScreen extends StatelessWidget {
  final String prefectureId;
  final int totalPoints;
  final int correctCount;
  final int totalCount;
  final String? newBadgeId;
  final int coinsEarned;

  const ResultScreen({
    super.key,
    required this.prefectureId,
    required this.totalPoints,
    required this.correctCount,
    required this.totalCount,
    this.newBadgeId,
    this.coinsEarned = 0,
  });

  @override
  Widget build(BuildContext context) {
    // 都道府県名: 47都道府県データから取得 → 見つからなければIDそのまま
    final prefName =
        PrefectureDataList.findById(prefectureId)?.name ?? prefectureId;
    final percentage =
        totalCount > 0 ? (correctCount / totalCount * 100).round() : 0;
    final badge = newBadgeId != null ? BadgeDefinitions.findById(newBadgeId!) : null;

    return Scaffold(
      backgroundColor: const Color(AppColors.bgLight),
      body: Column(
        children: [
          // グリーンステータスバー
          Container(
            color: const Color(AppColors.primaryValue),
            height: MediaQuery.of(context).padding.top,
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 結果ヘッダー
                  Column(
                    children: [
                      const Text('🎉', style: TextStyle(fontSize: 64)),
                      const SizedBox(height: 12),
                      const Text(
                        'クイズ完了！',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF333333),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'お疲れさまでした',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // スコアボックス（グリーングラデーション）
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF2ECC71), Color(0xFF27AE60)],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(AppColors.primaryValue)
                              .withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        const Text(
                          '最終スコア',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '$correctCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 52,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '$totalCount問中',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 詳細（グリーン左ボーダー）
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: const Border(
                        left: BorderSide(
                            color: Color(AppColors.primaryValue), width: 4),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _buildDetailRow(
                          '✓', '正解数', '$correctCount問',
                          valueColor: const Color(AppColors.correctValue),
                        ),
                        const Divider(height: 1, indent: 16),
                        _buildDetailRow(
                          '✗', '不正解数',
                          '${totalCount - correctCount}問',
                          valueColor: const Color(AppColors.incorrectValue),
                        ),
                        const Divider(height: 1, indent: 16),
                        _buildDetailRow(
                          '📊', '正解率', '$percentage%',
                        ),
                        const Divider(height: 1, indent: 16),
                        _buildDetailRow(
                          '⭐', '獲得ポイント', '+$totalPoints pt',
                          valueColor: const Color(AppColors.primaryValue),
                        ),
                        if (coinsEarned > 0) ...[
                          const Divider(height: 1, indent: 16),
                          _buildDetailRow(
                            '🪙', '獲得コイン', '+$coinsEarned',
                            valueColor: const Color(AppColors.accentValue),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // コメント
                  Center(
                    child: Text(
                      percentage >= 80
                          ? '素晴らしい！$prefNameマスターに近づいてる！'
                          : percentage >= 50
                              ? 'よくできました！復習してさらに上を目指そう'
                              : 'もう一度チャレンジしてみよう！',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  // バッジ獲得
                  if (badge != null) ...[
                    const SizedBox(height: 20),
                    _buildBadgeCard(badge),
                  ],

                  const SizedBox(height: 28),

                  // ボタン群
                  GestureDetector(
                    onTap: () => context.push(AppRoutes.prefectureList),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: const Color(AppColors.primaryValue),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(AppColors.primaryValue)
                                .withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text(
                          '次の章へ進む',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: () => context.go(AppRoutes.home),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: const Color(0xFFE0E0E0), width: 2),
                      ),
                      child: const Center(
                        child: Text(
                          'ホームに戻る',
                          style: TextStyle(
                            color: Color(0xFF333333),
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String icon, String label, String value,
      {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(icon, style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 8),
              Text(label,
                  style: const TextStyle(
                      fontSize: 14, color: Color(0xFF666666))),
            ],
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: valueColor ?? const Color(0xFF333333),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadgeCard(BadgeDef badge) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF9E6),
        borderRadius: BorderRadius.circular(16),
        border: const Border(
          left: BorderSide(color: Color(0xFFF39C12), width: 4),
        ),
      ),
      child: Row(
        children: [
          Text(badge.emoji, style: const TextStyle(fontSize: 40)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      '🏅 新しいバッジ獲得！',
                      style: TextStyle(
                        color: Color(0xFFF39C12),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (badge.coinReward > 0) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.amber.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '+${badge.coinReward}🪙',
                          style: const TextStyle(fontSize: 11, color: Color(0xFFB7770A)),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  badge.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333333),
                  ),
                ),
                Text(
                  badge.description,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF666666),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
