import 'package:flutter/material.dart';
import 'package:social_quiz_app/widgets/ukalab_emoji.dart';

/// 実績バッジの共通意匠（assets/badges/badge_<意匠>.webp）。画像が無いバッジは従来の絵文字で出す。
///
/// 意匠への対応は design/小学コレ！/共通/実績バッジ_意匠対応表_2026-10-07.md（社会）。
/// 県別マスター47件は全て compass のため、[label]（県名など）を画像の下部に重ねて区別する。
class BadgeEmblem extends StatelessWidget {
  const BadgeEmblem({
    super.key,
    required this.badgeId,
    required this.fallbackEmoji,
    this.size = 32,
    this.label,
  });

  final String badgeId;
  final String fallbackEmoji;
  final double size;

  /// 画像の下部に重ねる短いテキスト（任意）。画像表示時のみ。
  final String? label;

  static const Map<String, String> _emblemOf = {
    'first_correct': 'first_step',
    'combo_10': 'streak',
    'quiz_50': 'check',
    'stage_1_complete': 'challenge',
    'stage_2_complete': 'challenge',
    'stage_3_complete': 'challenge',
    'stage_4_complete': 'challenge',
    'stage_5_complete': 'challenge',
    'stage_6_complete': 'challenge',
    'stage_7_complete': 'challenge',
    'stage_8_complete': 'challenge',
    'stage_9_complete': 'challenge',
    'stage_10_complete': 'challenge',
    'all_stages': 'gradcap',
    'streak_3': 'streak',
    'streak_7': 'streak',
    'streak_30': 'streak',
    'region_hokkaido': 'compass',
    'region_tohoku': 'compass',
    'region_kanto': 'compass',
    'region_chubu': 'compass',
    'region_kinki': 'compass',
    'region_chugoku': 'compass',
    'region_shikoku': 'compass',
    'region_kyushu': 'compass',
    'hokkaido_master': 'compass',
    'aomori_master': 'compass',
    'iwate_master': 'compass',
    'miyagi_master': 'compass',
    'akita_master': 'compass',
    'yamagata_master': 'compass',
    'fukushima_master': 'compass',
    'ibaraki_master': 'compass',
    'tochigi_master': 'compass',
    'gunma_master': 'compass',
    'saitama_master': 'compass',
    'chiba_master': 'compass',
    'tokyo_master': 'compass',
    'kanagawa_master': 'compass',
    'niigata_master': 'compass',
    'toyama_master': 'compass',
    'ishikawa_master': 'compass',
    'fukui_master': 'compass',
    'yamanashi_master': 'compass',
    'nagano_master': 'compass',
    'gifu_master': 'compass',
    'shizuoka_master': 'compass',
    'aichi_master': 'compass',
    'mie_master': 'compass',
    'shiga_master': 'compass',
    'kyoto_master': 'compass',
    'osaka_master': 'compass',
    'hyogo_master': 'compass',
    'nara_master': 'compass',
    'wakayama_master': 'compass',
    'tottori_master': 'compass',
    'shimane_master': 'compass',
    'okayama_master': 'compass',
    'hiroshima_master': 'compass',
    'yamaguchi_master': 'compass',
    'tokushima_master': 'compass',
    'kagawa_master': 'compass',
    'ehime_master': 'compass',
    'kochi_master': 'compass',
    'fukuoka_master': 'compass',
    'saga_master': 'compass',
    'nagasaki_master': 'compass',
    'kumamoto_master': 'compass',
    'oita_master': 'compass',
    'miyazaki_master': 'compass',
    'kagoshima_master': 'compass',
    'okinawa_master': 'compass',
    'perfect_streak_5': 'streak',
    'perfect_streak_10': 'streak',
    'perfect_streak_20': 'streak',
    'quiz_master': 'master',
    'speed_champion': 'speed',
    'quiz_legend': 'check',
    'improvement_expert': 'levelup',
    'quest_master': 'challenge',
    'all_prefectures': 'collection',
    'social_master': 'gradcap',
  };

  /// バッジIDに対応する意匠名。なければ null。
  static String? emblemOf(String badgeId) => _emblemOf[badgeId];

  /// 県別マスター（`xxx_master` で compass 共通意匠になるもの）に重ねる県名ラベル。
  /// 該当しなければ null。[name] は「神奈川県マスター」形式。
  static String? prefectureLabel(String badgeId, String name) {
    if (!badgeId.endsWith('_master')) return null;
    if (const {'quiz_master', 'quest_master', 'social_master'}.contains(badgeId)) {
      return null;
    }
    return name.replaceAll('マスター', '');
  }

  @override
  Widget build(BuildContext context) {
    final name = _emblemOf[badgeId];
    if (name == null) return UkalabEmoji(fallbackEmoji, size: size);
    final image = Image.asset(
      'assets/badges/badge_$name.webp',
      width: size,
      height: size,
      fit: BoxFit.contain,
      excludeFromSemantics: true,
      errorBuilder: (context, error, stackTrace) =>
          UkalabEmoji(fallbackEmoji, size: size),
    );
    final text = label;
    if (text == null || text.isEmpty) return image;
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          image,
          Container(
            padding: EdgeInsets.symmetric(horizontal: size * 0.06),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.85),
              borderRadius: BorderRadius.circular(size * 0.12),
            ),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                text,
                maxLines: 1,
                style: TextStyle(
                  fontSize: size * 0.22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
