import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../repositories/progress_repository.dart';
import '../../utils/constants.dart';

// ─── Era data model ──────────────────────────────────────────────────────────

enum EraGroup { ancient, medieval, modern }

class HistoricalEra {
  final String id;
  final String name;
  final String reading;
  final String emoji;
  final String period;
  final String keyword;
  final EraGroup group;

  const HistoricalEra({
    required this.id,
    required this.name,
    required this.reading,
    required this.emoji,
    required this.period,
    required this.keyword,
    required this.group,
  });
}

const _eras = <HistoricalEra>[
  HistoricalEra(
    id: 'jomon',
    name: '縄文時代',
    reading: 'じょうもんじだい',
    emoji: '🪨',
    period: '約14000〜300年前（BC）',
    keyword: '土器・縄文式の生活',
    group: EraGroup.ancient,
  ),
  HistoricalEra(
    id: 'yayoi',
    name: '弥生時代',
    reading: 'やよいじだい',
    emoji: '🌾',
    period: '約300BCE〜300CE',
    keyword: '稲作が広まった',
    group: EraGroup.ancient,
  ),
  HistoricalEra(
    id: 'kofun',
    name: '古墳時代',
    reading: 'こふんじだい',
    emoji: '🏔️',
    period: '約300〜593年',
    keyword: '大きな古墳を作った',
    group: EraGroup.ancient,
  ),
  HistoricalEra(
    id: 'asuka',
    name: '飛鳥時代',
    reading: 'あすかじだい',
    emoji: '🕊️',
    period: '593〜710年',
    keyword: '聖徳太子・大化の改新',
    group: EraGroup.ancient,
  ),
  HistoricalEra(
    id: 'nara',
    name: '奈良時代',
    reading: 'ならじだい',
    emoji: '🦌',
    period: '710〜794年',
    keyword: '奈良が都・東大寺建設',
    group: EraGroup.ancient,
  ),
  HistoricalEra(
    id: 'heian',
    name: '平安時代',
    reading: 'へいあんじだい',
    emoji: '🌸',
    period: '794〜1185年',
    keyword: '京都が都・藤原氏',
    group: EraGroup.ancient,
  ),
  HistoricalEra(
    id: 'kamakura',
    name: '鎌倉時代',
    reading: 'かまくらじだい',
    emoji: '⚔️',
    period: '1185〜1336年',
    keyword: '源頼朝・初の武家政権',
    group: EraGroup.medieval,
  ),
  HistoricalEra(
    id: 'muromachi',
    name: '室町時代',
    reading: 'むろまちじだい',
    emoji: '🎭',
    period: '1336〜1573年',
    keyword: '足利氏・金閣寺・銀閣寺',
    group: EraGroup.medieval,
  ),
  HistoricalEra(
    id: 'azuchi',
    name: '安土桃山時代',
    reading: 'あづちももやまじだい',
    emoji: '🏯',
    period: '1573〜1603年',
    keyword: '織田信長・豊臣秀吉',
    group: EraGroup.medieval,
  ),
  HistoricalEra(
    id: 'edo',
    name: '江戸時代',
    reading: 'えどじだい',
    emoji: '🗾',
    period: '1603〜1868年',
    keyword: '徳川幕府・265年の平和',
    group: EraGroup.medieval,
  ),
  HistoricalEra(
    id: 'meiji',
    name: '明治時代',
    reading: 'めいじじだい',
    emoji: '🚂',
    period: '1868〜1912年',
    keyword: '近代化・文明開化',
    group: EraGroup.modern,
  ),
  HistoricalEra(
    id: 'taisho',
    name: '大正時代',
    reading: 'たいしょうじだい',
    emoji: '📻',
    period: '1912〜1926年',
    keyword: '大正デモクラシー',
    group: EraGroup.modern,
  ),
  HistoricalEra(
    id: 'showa',
    name: '昭和時代',
    reading: 'しょうわじだい',
    emoji: '🕊️',
    period: '1926〜1989年',
    keyword: '戦争と復興・高度成長',
    group: EraGroup.modern,
  ),
  HistoricalEra(
    id: 'heisei_reiwa',
    name: '平成・令和時代',
    reading: 'へいせい・れいわじだい',
    emoji: '💻',
    period: '1989年〜',
    keyword: '情報化社会',
    group: EraGroup.modern,
  ),
];

// ─── Era group colors ────────────────────────────────────────────────────────

Color _groupColor(EraGroup group) {
  switch (group) {
    case EraGroup.ancient:
      return const Color(0xFF8D6E63); // brown
    case EraGroup.medieval:
      return const Color(0xFF1565C0); // blue
    case EraGroup.modern:
      return const Color(0xFF2E7D32); // green
  }
}

Color _groupBgColor(EraGroup group) {
  switch (group) {
    case EraGroup.ancient:
      return const Color(0xFFF5F0EC);
    case EraGroup.medieval:
      return const Color(0xFFE8EEF8);
    case EraGroup.modern:
      return const Color(0xFFE8F5E9);
  }
}

String _groupLabel(EraGroup group) {
  switch (group) {
    case EraGroup.ancient:
      return '古代・古典';
    case EraGroup.medieval:
      return '中世・近世';
    case EraGroup.modern:
      return '近代・現代';
  }
}

// ─── Badge IDs used for tracking studied eras ────────────────────────────────

String _eraBadgeId(String eraId) => 'history_era_$eraId';

// ─── Screen ──────────────────────────────────────────────────────────────────

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userProgress = ref.watch(userProgressProvider);
    final studiedCount = _eras
        .where((e) => userProgress.badges.contains(_eraBadgeId(e.id)))
        .length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('歴史'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 12),
        children: [
          // ─── Progress banner ───────────────────────────────────
          _ProgressBanner(studiedCount: studiedCount, totalCount: _eras.length),
          const SizedBox(height: 16),

          // ─── Timeline legend ───────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _LegendDot(color: _groupColor(EraGroup.ancient), label: _groupLabel(EraGroup.ancient)),
                const SizedBox(width: 12),
                _LegendDot(color: _groupColor(EraGroup.medieval), label: _groupLabel(EraGroup.medieval)),
                const SizedBox(width: 12),
                _LegendDot(color: _groupColor(EraGroup.modern), label: _groupLabel(EraGroup.modern)),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ─── Timeline cards ────────────────────────────────────
          for (int i = 0; i < _eras.length; i++)
            _EraTimelineCard(
              era: _eras[i],
              index: i,
              isStudied: userProgress.badges.contains(_eraBadgeId(_eras[i].id)),
              isLast: i == _eras.length - 1,
            ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// ─── Progress banner ─────────────────────────────────────────────────────────

class _ProgressBanner extends StatelessWidget {
  final int studiedCount;
  final int totalCount;

  const _ProgressBanner({required this.studiedCount, required this.totalCount});

  @override
  Widget build(BuildContext context) {
    final ratio = studiedCount / totalCount;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(AppColors.primaryValue).withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('📚 ', style: TextStyle(fontSize: 20)),
                Text(
                  '$studiedCount / $totalCount 学習済み',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333333),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: ratio,
                minHeight: 8,
                backgroundColor: const Color(0xFFE0E0E0),
                valueColor: const AlwaysStoppedAnimation<Color>(
                  Color(AppColors.primaryValue),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              studiedCount == totalCount
                  ? '全時代コンプリート！おめでとう！'
                  : '各時代をタップして学ぼう！',
              style: TextStyle(
                fontSize: 12,
                color: studiedCount == totalCount
                    ? const Color(AppColors.primaryValue)
                    : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Legend dot ──────────────────────────────────────────────────────────────

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600)),
      ],
    );
  }
}

// ─── Timeline card ───────────────────────────────────────────────────────────

class _EraTimelineCard extends StatelessWidget {
  final HistoricalEra era;
  final int index;
  final bool isStudied;
  final bool isLast;

  const _EraTimelineCard({
    required this.era,
    required this.index,
    required this.isStudied,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    final color = _groupColor(era.group);
    final bgColor = _groupBgColor(era.group);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ─── Timeline connector ──────────────────────────────
          SizedBox(
            width: 60,
            child: Column(
              children: [
                // Dot
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: isStudied ? color : color.withOpacity(0.25),
                    shape: BoxShape.circle,
                    border: Border.all(color: color, width: 2),
                  ),
                  child: Center(
                    child: isStudied
                        ? const Icon(Icons.check, size: 16, color: Colors.white)
                        : Text(
                            '${index + 1}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: color,
                            ),
                          ),
                  ),
                ),
                // Line to next
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: color.withOpacity(0.25),
                    ),
                  ),
              ],
            ),
          ),

          // ─── Era card ─────────────────────────────────────────
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: 16, bottom: isLast ? 8 : 12),
              child: GestureDetector(
                onTap: () => context.push('/history-era/${era.id}'),
                child: Container(
                  decoration: BoxDecoration(
                    color: isStudied ? bgColor : Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isStudied ? color.withOpacity(0.4) : Colors.grey.shade200,
                      width: 1.5,
                    ),
                  ),
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      // Emoji
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: bgColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(era.emoji, style: const TextStyle(fontSize: 24)),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Text
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              era.name,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: color,
                              ),
                            ),
                            Text(
                              era.reading,
                              style: TextStyle(
                                fontSize: 10,
                                color: color.withOpacity(0.7),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              era.period,
                              style: const TextStyle(fontSize: 11, color: Color(0xFF888888)),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              era.keyword,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF555555),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Arrow / studied badge
                      if (isStudied)
                        Icon(Icons.star_rounded, color: const Color(AppColors.accentValue), size: 22)
                      else
                        Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey[400]),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
