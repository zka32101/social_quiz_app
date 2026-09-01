import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import '../../data/prefecture_data.dart';
import '../../repositories/progress_repository.dart';
import '../../repositories/profile_repository.dart';

class ParentReportScreen extends ConsumerWidget {
  const ParentReportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(progressProvider);
    final activeProfile = ref.watch(activeProfileProvider);

    // 都道府県集計
    const allPrefs = PrefectureDataList.all;
    final total = allPrefs.length; // 47
    final completed = progress.prefectureProgress.values
        .where((p) => p.isCompleted)
        .length;
    final studied = progress.prefectureProgress.values
        .where((p) => p.quizBestScore > 0 || p.completedSteps.isNotEmpty)
        .length;

    // 正解率（制覇済み都道府県の平均スコア）
    final scores = progress.prefectureProgress.values
        .where((p) => p.quizBestScore > 0)
        .map((p) => p.quizBestScore)
        .toList();
    final avgScore = scores.isEmpty
        ? 0.0
        : scores.reduce((a, b) => a + b) / scores.length;
    final correctRate = (avgScore / 10 * 100).round();

    // 最終学習日
    final lastStudied = progress.lastStudiedAt;
    final lastStr = lastStudied != null
        ? DateFormat('M月d日（E）', 'ja').format(lastStudied)
        : 'まだ学習していません';

    // 今日の日付
    final now = DateTime.now();
    final todayStr = DateFormat('yyyy年M月d日', 'ja').format(now);

    return Scaffold(
      appBar: AppBar(
        title: const Text('保護者レポート'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_rounded),
            tooltip: '共有',
            onPressed: () => _share(
              context,
              name: activeProfile?.name ?? 'お子さん',
              streak: progress.streak,
              completed: completed,
              total: total,
              correctRate: correctRate,
              points: progress.totalPoints,
              badges: progress.badges.length,
              wrongCount: progress.wrongAnswerIds.length,
              lastStr: lastStr,
              todayStr: todayStr,
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ─── ヘッダー ───────────────────────────────────────
          _HeaderCard(
            name: activeProfile?.name ?? 'お子さん',
            emoji: activeProfile?.emoji ?? '🧒',
            todayStr: todayStr,
            lastStr: lastStr,
          ),
          const SizedBox(height: 16),

          // ─── 主要統計グリッド ────────────────────────────────
          const _SectionTitle('学習の成果'),
          const SizedBox(height: 10),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1.8,
            children: [
              _StatCard(
                icon: Icons.local_fire_department_rounded,
                iconColor: Colors.orange,
                label: '連続学習日数',
                value: '${progress.streak}日',
              ),
              _StatCard(
                icon: Icons.flag_rounded,
                iconColor: Colors.green,
                label: '都道府県制覇',
                value: '$completed / $total県',
              ),
              _StatCard(
                icon: Icons.emoji_events_rounded,
                iconColor: Colors.amber,
                label: '総獲得ポイント',
                value: '${progress.totalPoints} pt',
              ),
              _StatCard(
                icon: Icons.workspace_premium_rounded,
                iconColor: Colors.purple,
                label: '獲得バッジ',
                value: '${progress.badges.length}個',
              ),
            ],
          ),
          const SizedBox(height: 20),

          // ─── ステージ完了進捗 ────────────────────────────────
          const _SectionTitle('ステージ進捗'),
          const SizedBox(height: 10),
          _StageProgressSection(stageProgress: progress.stageProgress),
          const SizedBox(height: 20),

          // ─── 学習時間トラッキング ──────────────────────────────
          const _SectionTitle('学習時間'),
          const SizedBox(height: 10),
          _LearningTimeCard(userProgress: progress),
          const SizedBox(height: 20),

          // ─── 正解率 ──────────────────────────────────────────
          const _SectionTitle('クイズ正解率'),
          const SizedBox(height: 10),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        scores.isEmpty ? '—' : '$correctRate%',
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: _rateColor(correctRate),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              scores.isEmpty
                                  ? 'まだクイズを解いていません'
                                  : _rateMessage(correctRate),
                              style: const TextStyle(fontSize: 13),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${scores.length}都道府県でクイズを実施',
                              style: TextStyle(
                                  fontSize: 12, color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (scores.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: correctRate / 100,
                        minHeight: 10,
                        backgroundColor: Colors.grey.shade200,
                        valueColor: AlwaysStoppedAnimation<Color>(
                            _rateColor(correctRate)),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // ─── 都道府県制覇進捗 ────────────────────────────────
          const _SectionTitle('都道府県の学習状況'),
          const SizedBox(height: 10),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _ProgressRow(
                    label: '制覇した都道府県',
                    value: completed,
                    total: total,
                    color: Colors.green,
                  ),
                  const SizedBox(height: 12),
                  _ProgressRow(
                    label: '学習を始めた都道府県',
                    value: studied,
                    total: total,
                    color: Colors.blue,
                  ),
                  const SizedBox(height: 12),
                  _ProgressRow(
                    label: 'まだ学習していない',
                    value: total - studied,
                    total: total,
                    color: Colors.grey,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // ─── まちがい復習ノート ──────────────────────────────
          const _SectionTitle('まちがい復習ノート'),
          const SizedBox(height: 10),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: progress.wrongAnswerIds.isEmpty
                          ? Colors.green.shade50
                          : Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      progress.wrongAnswerIds.isEmpty
                          ? Icons.check_circle_rounded
                          : Icons.edit_note_rounded,
                      color: progress.wrongAnswerIds.isEmpty
                          ? Colors.green
                          : Colors.orange,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          progress.wrongAnswerIds.isEmpty
                              ? 'まちがいはありません！'
                              : '${progress.wrongAnswerIds.length}問 残っています',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          progress.wrongAnswerIds.isEmpty
                              ? 'すべての問題を正解できています'
                              : 'アプリの「まちがい復習」から確認できます',
                          style: TextStyle(
                              fontSize: 12, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // ─── 最近のマイルストーン ──────────────────────────
          if (progress.stageProgress.values.isNotEmpty) ...[
            const _SectionTitle('最近のマイルストーン'),
            const SizedBox(height: 10),
            _RecentMilestonesCard(
              stageProgress: progress.stageProgress,
              badges: progress.badges,
            ),
            const SizedBox(height: 20),
          ],

          // ─── 保護者へのアドバイス ────────────────────────────
          const _SectionTitle('保護者の方へ'),
          const SizedBox(height: 10),
          _AdviceCard(
            streak: progress.streak,
            completed: completed,
            wrongCount: progress.wrongAnswerIds.length,
            stageCompleted: progress.completedStageCount,
          ),
          const SizedBox(height: 24),

          // ─── 共有ボタン ──────────────────────────────────────
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              icon: const Icon(Icons.share_rounded),
              label: const Text('レポートを共有する'),
              onPressed: () => _share(
                context,
                name: activeProfile?.name ?? 'お子さん',
                streak: progress.streak,
                completed: completed,
                total: total,
                correctRate: correctRate,
                points: progress.totalPoints,
                badges: progress.badges.length,
                wrongCount: progress.wrongAnswerIds.length,
                lastStr: lastStr,
                todayStr: todayStr,
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Color _rateColor(int rate) {
    if (rate >= 80) return Colors.green;
    if (rate >= 60) return Colors.orange;
    return Colors.red;
  }

  String _rateMessage(int rate) {
    if (rate >= 90) return 'とても優秀です！';
    if (rate >= 80) return 'よくできています！';
    if (rate >= 60) return '着実に学んでいます';
    return '復習をしてみましょう';
  }

  void _share(
    BuildContext context, {
    required String name,
    required int streak,
    required int completed,
    required int total,
    required int correctRate,
    required int points,
    required int badges,
    required int wrongCount,
    required String lastStr,
    required String todayStr,
  }) {
    final text = '''
📊 小学コレ！社会 学習レポート
$todayStr 現在

👤 $name さんの記録
━━━━━━━━━━━━━━━━━━
🔥 連続学習日数：$streak日
🗾 都道府県制覇：$completed / $total県
🏆 獲得ポイント：$points pt
🎖 バッジ：$badges個
✅ クイズ正解率：$correctRate%
📝 まちがいノート：$wrongCount問

最終学習日：$lastStr
━━━━━━━━━━━━━━━━━━
「小学コレ！社会」で楽しく学習中！
''';
    Share.share(text.trim());
  }
}

// ── ウィジェット部品 ──────────────────────────────────────────

class _StageProgressSection extends StatelessWidget {
  final Map<String, StageProgress> stageProgress;

  const _StageProgressSection({required this.stageProgress});

  @override
  Widget build(BuildContext context) {
    final total = 20;
    final completed = stageProgress.values
        .where((sp) => sp.isCompleted)
        .length;
    final unlocked = stageProgress.values
        .where((sp) => sp.isUnlocked)
        .length;

    // ステージを難易度別にグループ化
    final beginner = stageProgress.values
        .where((sp) => sp.stageNo >= 1 && sp.stageNo <= 2)
        .toList()
      ..sort((a, b) => a.stageNo.compareTo(b.stageNo));
    final intermediate = stageProgress.values
        .where((sp) => sp.stageNo >= 3 && sp.stageNo <= 5)
        .toList()
      ..sort((a, b) => a.stageNo.compareTo(b.stageNo));
    final advanced = stageProgress.values
        .where((sp) => sp.stageNo >= 6 && sp.stageNo <= 20)
        .toList()
      ..sort((a, b) => a.stageNo.compareTo(b.stageNo));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 全体進捗
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$completed / $total ステージ完了',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '開放済み: $unlocked',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '${(completed * 100 ~/ total).toString().padLeft(3)}%',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: completed / total,
                minHeight: 8,
                backgroundColor: Colors.grey.shade200,
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
              ),
            ),
            const SizedBox(height: 16),

            // 難易度別表示
            _DifficultyStageGroup(
              title: '初級（1-2）',
              stages: beginner,
              color: Colors.green,
            ),
            const SizedBox(height: 12),
            _DifficultyStageGroup(
              title: '中級（3-5）',
              stages: intermediate,
              color: Colors.orange,
            ),
            const SizedBox(height: 12),
            _DifficultyStageGroup(
              title: '上級（6-20）',
              stages: advanced,
              color: Colors.red,
            ),
          ],
        ),
      ),
    );
  }
}

class _DifficultyStageGroup extends StatelessWidget {
  final String title;
  final List<StageProgress> stages;
  final Color color;

  const _DifficultyStageGroup({
    required this.title,
    required this.stages,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 16,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: stages.map((sp) {
            return _StageIndicator(
              stageNo: sp.stageNo,
              isUnlocked: sp.isUnlocked,
              isCompleted: sp.isCompleted,
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _StageIndicator extends StatelessWidget {
  final int stageNo;
  final bool isUnlocked;
  final bool isCompleted;

  const _StageIndicator({
    required this.stageNo,
    required this.isUnlocked,
    required this.isCompleted,
  });

  @override
  Widget build(BuildContext context) {
    late Color bgColor;
    late Color textColor;
    late String label;

    if (isCompleted) {
      bgColor = Colors.green;
      textColor = Colors.white;
      label = '✓';
    } else if (isUnlocked) {
      bgColor = Colors.blue.shade100;
      textColor = Colors.blue;
      label = stageNo.toString();
    } else {
      bgColor = Colors.grey.shade300;
      textColor = Colors.grey;
      label = '🔒';
    }

    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  final String name;
  final String emoji;
  final String todayStr;
  final String lastStr;

  const _HeaderCard({
    required this.name,
    required this.emoji,
    required this.todayStr,
    required this.lastStr,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1976D2), Color(0xFF1565C0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 40)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$name さんの学習レポート',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  todayStr,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
                Text(
                  '最終学習日：$lastStr',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.bold,
        color: Colors.grey,
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 26),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(label,
                      style: TextStyle(
                          fontSize: 11, color: Colors.grey.shade600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  Text(value,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgressRow extends StatelessWidget {
  final String label;
  final int value;
  final int total;
  final Color color;

  const _ProgressRow({
    required this.label,
    required this.value,
    required this.total,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final ratio = total > 0 ? value / total : 0.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(label, style: const TextStyle(fontSize: 13)),
            ),
            Text(
              '$value / $total',
              style: TextStyle(
                  fontSize: 13, fontWeight: FontWeight.bold, color: color),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: ratio,
            minHeight: 6,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}

class _LearningTimeCard extends StatelessWidget {
  final UserProgress userProgress;

  const _LearningTimeCard({required this.userProgress});

  @override
  Widget build(BuildContext context) {
    final todaysMinutes = userProgress.todaysLearningMinutes;
    final weeklyMinutes = userProgress.weeklyLearningMinutes;
    final weeklyAverage = userProgress.weeklyAverageLearningMinutes;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.schedule_rounded, color: Colors.blue, size: 24),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '今日の学習時間',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      Text(
                        '$todaysMinutes分',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      Text(
                        '今週',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$weeklyMinutes分',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Container(width: 1, height: 40, color: Colors.grey.shade300),
                  Column(
                    children: [
                      Text(
                        '1日平均',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$weeklyAverage分',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Text(
                    '総学習時間: ${userProgress.totalLearningMinutes}分',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
                if (weeklyAverage >= 30)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('⭐', style: TextStyle(fontSize: 12)),
                        const SizedBox(width: 4),
                        Text(
                          '目標達成',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _RecentMilestonesCard extends StatelessWidget {
  final Map<String, StageProgress> stageProgress;
  final List<String> badges;

  const _RecentMilestonesCard({
    required this.stageProgress,
    required this.badges,
  });

  @override
  Widget build(BuildContext context) {
    // 最近完了したステージを取得（3つまで）
    final recentStages = stageProgress.values
        .where((sp) => sp.isCompleted && sp.completedAt != null)
        .toList()
      ..sort((a, b) => (b.completedAt ?? DateTime(2000))
          .compareTo(a.completedAt ?? DateTime(2000)));

    if (recentStages.isEmpty && badges.isEmpty) {
      return Card(
        color: Colors.blue.shade50,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(Icons.emoji_events_rounded, color: Colors.blue, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'これからのマイルストーンをお楽しみに！',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.blue.shade700,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (recentStages.isNotEmpty) ...[
              Text(
                '完了したステージ',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 8),
              ...recentStages.take(3).map((stage) {
                final date = stage.completedAt != null
                    ? DateFormat('M月d日', 'ja').format(stage.completedAt!)
                    : '?';
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: Colors.green.shade100,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Center(
                          child: Text(
                            '${stage.stageNo}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: Colors.green,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'ステージ ${stage.stageNo} 完了',
                          style: const TextStyle(fontSize: 13),
                        ),
                      ),
                      Text(
                        date,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              if (badges.isNotEmpty) const SizedBox(height: 12),
            ],
            if (badges.isNotEmpty) ...[
              Text(
                '獲得したバッジ',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: badges.take(5).map((badgeId) {
                  return _BadgeMiniDisplay(badgeId: badgeId);
                }).toList(),
              ),
              if (badges.length > 5)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    '他 ${badges.length - 5} 個',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _BadgeMiniDisplay extends StatelessWidget {
  final String badgeId;

  const _BadgeMiniDisplay({required this.badgeId});

  @override
  Widget build(BuildContext context) {
    final emoji = _getBadgeEmoji(badgeId);
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        border: Border.all(color: Colors.amber.shade200),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(emoji, style: const TextStyle(fontSize: 20)),
      ),
    );
  }

  String _getBadgeEmoji(String badgeId) {
    if (badgeId.contains('stage')) return '🎯';
    if (badgeId.contains('master')) return '👑';
    if (badgeId.contains('speed')) return '⚡';
    if (badgeId.contains('social')) return '🏆';
    return '🎖️';
  }
}

class _AdviceCard extends StatelessWidget {
  final int streak;
  final int completed;
  final int wrongCount;
  final int stageCompleted;

  const _AdviceCard({
    required this.streak,
    required this.completed,
    required this.wrongCount,
    this.stageCompleted = 0,
  });

  @override
  Widget build(BuildContext context) {
    final advices = <String>[];

    if (streak >= 7) {
      advices.add('7日以上連続学習中です。この調子で続けましょう！');
    } else if (streak == 0) {
      advices.add('毎日少しずつ学習する習慣をつけると効果的です。');
    } else {
      advices.add('連続$streak日学習中！目標は7日連続です。');
    }

    if (wrongCount > 5) {
      advices.add('まちがいノートに$wrongCount問たまっています。「まちがい復習」機能で見直しましょう。');
    }

    if (stageCompleted >= 5) {
      advices.add('$stageCompleted個のステージを完了しました！難しいステージにも挑戦してみましょう。');
    } else if (stageCompleted > 0) {
      advices.add('ステージ学習を進めると、難しい内容にも対応できるようになります。');
    }

    if (completed >= 10) {
      advices.add('$completed都道府県を制覇しました。全47県を目指してみましょう！');
    } else {
      advices.add('デイリーミッションを使うと毎日1つずつ制覇が進みます。');
    }

    return Card(
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: advices.map((a) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('💡', style: TextStyle(fontSize: 16)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(a, style: const TextStyle(fontSize: 13, height: 1.5)),
                ),
              ],
            ),
          )).toList(),
        ),
      ),
    );
  }
}
