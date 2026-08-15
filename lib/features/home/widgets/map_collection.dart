import 'package:flutter/material.dart';
import '../../../data/prefecture_data.dart';
import '../../../models/user_progress.dart';
import '../../../utils/constants.dart';

/// 都道府県コレクション（全47都道府県・地方ごとにグループ表示）
class MapCollection extends StatelessWidget {
  final Map<String, PrefectureProgress> prefectureProgress;
  final bool isPremium;
  final void Function(String prefId) onPrefectureTap;

  const MapCollection({
    super.key,
    required this.prefectureProgress,
    required this.onPrefectureTap,
    this.isPremium = false,
  });

  @override
  Widget build(BuildContext context) {
    final total = PrefectureDataList.all.length;
    final completedCount =
        prefectureProgress.values.where((p) => p.isCompleted).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              '都道府県コレクション',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF333333),
              ),
            ),
            Text(
              '$completedCount / $total',
              style: const TextStyle(
                color: Color(AppColors.primaryValue),
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // 地方ごとにグループ表示
        ...PrefectureDataList.regionLabels.entries.map(
          (regionEntry) => _buildRegionSection(context, regionEntry),
        ),
      ],
    );
  }

  Widget _buildRegionSection(
      BuildContext context, MapEntry<String, String> regionEntry) {
    final regionId = regionEntry.key;
    final regionLabel = regionEntry.value;
    final prefs = PrefectureDataList.byRegion(regionId);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 6),
          child: Text(
            regionLabel,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
        ),
        Wrap(
          spacing: 4,
          runSpacing: 4,
          children: prefs.map((pref) {
            final prefId = pref.id;
            final prefName = pref.name;
            final progress = prefectureProgress[prefId];
            final isCompleted = progress?.isCompleted ?? false;
            final isStarted =
                (progress?.completedSteps.isNotEmpty ?? false) && !isCompleted;
            // プレミアム会員はすべての都道府県が解放される
            final isLocked = !isPremium &&
                !AppConstants.freePrefectureIds.contains(prefId);

            return SizedBox(
              width: 76,
              child: _buildPrefectureChip(
                context,
                prefId: prefId,
                prefName: prefName,
                isCompleted: isCompleted,
                isStarted: isStarted,
                isLocked: isLocked,
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 4),
      ],
    );
  }

  Widget _buildPrefectureChip(
    BuildContext context, {
    required String prefId,
    required String prefName,
    required bool isCompleted,
    required bool isStarted,
    required bool isLocked,
  }) {
    Color bgColor;
    Color borderColor;
    Widget icon;

    if (isCompleted) {
      bgColor = const Color(AppColors.primaryValue).withOpacity(0.12);
      borderColor = const Color(AppColors.primaryValue);
      icon = const Text('⭐', style: TextStyle(fontSize: 10));
    } else if (isStarted) {
      bgColor = const Color(0xFFFFF3E0);
      borderColor = const Color(0xFFF39C12);
      icon = const Text('✏️', style: TextStyle(fontSize: 9));
    } else if (isLocked) {
      bgColor = const Color(0xFFF5F5F5);
      borderColor = const Color(0xFFE0E0E0);
      icon = const Icon(Icons.lock_outline, size: 10, color: Color(0xFFBBBBBB));
    } else {
      bgColor = Colors.white;
      borderColor = const Color(0xFFE0E0E0);
      icon = const SizedBox.shrink();
    }

    return GestureDetector(
      onTap: () => onPrefectureTap(prefId),
      child: Container(
        margin: const EdgeInsets.only(right: 4, bottom: 4),
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        decoration: BoxDecoration(
          color: bgColor,
          border: Border.all(color: borderColor, width: 1.5),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            icon,
            const SizedBox(height: 2),
            Text(
              prefName.replaceAll('県', '').replaceAll('府', '').replaceAll('都', '').replaceAll('道', ''),
              style: TextStyle(
                fontSize: 10,
                fontWeight: isCompleted ? FontWeight.bold : FontWeight.normal,
                color: isLocked ? Colors.grey[400] : Colors.black87,
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
