import 'package:hive/hive.dart';
import 'package:riverpod/riverpod.dart';
import 'package:social_quiz_app/models/quiz_attempt.dart';

/// クイズ試行履歴をHiveで管理
class QuizHistoryRepository {
  static const String boxName = 'quiz_history';
  static const int maxAttempts = 500; // 最大保持件数

  final Box<Map<String, dynamic>> _box;

  QuizHistoryRepository(this._box);

  /// 試行を追加
  Future<void> add(QuizAttempt attempt) async {
    await _box.put(attempt.id, attempt.toJson());

    // 容量制限を超えたら古いものから削除
    if (_box.length > maxAttempts) {
      _pruneOldest();
    }
  }

  /// 全試行を取得（降順：最新が先）
  List<QuizAttempt> getAll() {
    final attempts = _box.values
        .map((json) => QuizAttempt.fromJson(json))
        .toList();

    // 日時でソート（最新が先）
    attempts.sort((a, b) => b.attemptedAt.compareTo(a.attemptedAt));
    return attempts;
  }

  /// ステージ別の試行を取得
  List<QuizAttempt> getByStage(int stageNo) {
    final attempts = _box.values
        .where((json) => (json['stageNo'] as int?) == stageNo)
        .map((json) => QuizAttempt.fromJson(json))
        .toList();

    attempts.sort((a, b) => b.attemptedAt.compareTo(a.attemptedAt));
    return attempts;
  }

  /// 都道府県別の試行を取得
  List<QuizAttempt> getByPrefecture(String prefectureId) {
    final attempts = _box.values
        .where((json) => json['prefectureId'] == prefectureId)
        .map((json) => QuizAttempt.fromJson(json))
        .toList();

    attempts.sort((a, b) => b.attemptedAt.compareTo(a.attemptedAt));
    return attempts;
  }

  /// 最近N件を取得
  List<QuizAttempt> getRecent({int limit = 10}) {
    final attempts = getAll();
    return attempts.take(limit).toList();
  }

  /// 日付範囲内の試行を取得
  List<QuizAttempt> getByDateRange(DateTime start, DateTime end) {
    final attempts = _box.values
        .where((json) {
          final date = DateTime.tryParse(json['attemptedAt'] as String? ?? '') ?? DateTime.now();
          return date.isAfter(start) && date.isBefore(end);
        })
        .map((json) => QuizAttempt.fromJson(json))
        .toList();

    attempts.sort((a, b) => b.attemptedAt.compareTo(a.attemptedAt));
    return attempts;
  }

  /// 1つ削除
  Future<void> delete(String id) async {
    await _box.delete(id);
  }

  /// 全クリア
  Future<void> clear() async {
    await _box.clear();
  }

  /// 最も古い試行を削除（容量制限用）
  void _pruneOldest() {
    final attempts = getAll();
    if (attempts.isNotEmpty) {
      final oldest = attempts.last; // 最新が先なので、最後が最古
      _box.delete(oldest.id);
    }
  }

  /// 統計情報を計算
  QuizHistoryStats getStats({int stageNo = -1}) {
    List<QuizAttempt> attempts;

    if (stageNo > 0) {
      attempts = getByStage(stageNo);
    } else {
      attempts = getAll();
    }

    if (attempts.isEmpty) {
      return QuizHistoryStats.empty();
    }

    final totalAttempts = attempts.length;
    final totalCorrect = attempts.fold<int>(0, (sum, a) => sum + a.correctCount);
    final totalQuestions = attempts.fold<int>(0, (sum, a) => sum + a.totalCount);
    final averageAccuracy = totalQuestions > 0 ? (totalCorrect / totalQuestions) * 100 : 0.0;
    final averageTimePerQuestion = attempts.fold<int>(0, (sum, a) => sum + a.durationSeconds) /
        (totalQuestions > 0 ? totalQuestions : 1);
    final bestScore = attempts.isNotEmpty
        ? attempts.map((a) => a.totalScore).reduce((a, b) => a > b ? a : b)
        : 0;

    return QuizHistoryStats(
      totalAttempts: totalAttempts,
      totalCorrect: totalCorrect,
      totalQuestions: totalQuestions,
      averageAccuracy: averageAccuracy,
      averageTimePerQuestion: averageTimePerQuestion,
      bestScore: bestScore,
      perfectAttempts: attempts.where((a) => a.isPerfect).length,
    );
  }
}

/// クイズ統計情報
class QuizHistoryStats {
  final int totalAttempts;
  final int totalCorrect;
  final int totalQuestions;
  final double averageAccuracy;   // パーセント
  final double averageTimePerQuestion; // 秒
  final int bestScore;
  final int perfectAttempts;      // 満点の回数

  const QuizHistoryStats({
    required this.totalAttempts,
    required this.totalCorrect,
    required this.totalQuestions,
    required this.averageAccuracy,
    required this.averageTimePerQuestion,
    required this.bestScore,
    required this.perfectAttempts,
  });

  factory QuizHistoryStats.empty() {
    return const QuizHistoryStats(
      totalAttempts: 0,
      totalCorrect: 0,
      totalQuestions: 0,
      averageAccuracy: 0.0,
      averageTimePerQuestion: 0.0,
      bestScore: 0,
      perfectAttempts: 0,
    );
  }
}

/// Riverpod プロバイダ
final quizHistoryRepositoryProvider = Provider((ref) {
  final box = Hive.box<Map<String, dynamic>>(QuizHistoryRepository.boxName);
  return QuizHistoryRepository(box);
});

/// 全試行を取得
final allQuizAttemptsProvider = StateNotifierProvider<QuizAttemptsNotifier, List<QuizAttempt>>((ref) {
  final repo = ref.watch(quizHistoryRepositoryProvider);
  return QuizAttemptsNotifier(repo, repo.getAll());
});

/// ステージ別試行を取得
final stageQuizAttemptsProvider =
    StateNotifierProvider.family<StageQuizAttemptsNotifier, List<QuizAttempt>, int>((ref, stageNo) {
  final repo = ref.watch(quizHistoryRepositoryProvider);
  return StageQuizAttemptsNotifier(repo, stageNo, repo.getByStage(stageNo));
});

/// 最近の試行を取得
final recentQuizAttemptsProvider =
    StateNotifierProvider.family<RecentQuizAttemptsNotifier, List<QuizAttempt>, int>((ref, limit) {
  final repo = ref.watch(quizHistoryRepositoryProvider);
  return RecentQuizAttemptsNotifier(repo, limit, repo.getRecent(limit: limit));
});

/// 統計情報を取得
final quizStatsProvider = StateNotifierProvider.family<QuizStatsNotifier, QuizHistoryStats, int>((ref, stageNo) {
  final repo = ref.watch(quizHistoryRepositoryProvider);
  return QuizStatsNotifier(repo, stageNo, repo.getStats(stageNo: stageNo));
});

class QuizAttemptsNotifier extends StateNotifier<List<QuizAttempt>> {
  final QuizHistoryRepository _repo;

  QuizAttemptsNotifier(this._repo, List<QuizAttempt> initialState) : super(initialState);

  Future<void> addAttempt(QuizAttempt attempt) async {
    await _repo.add(attempt);
    state = _repo.getAll();
  }

  void refresh() {
    state = _repo.getAll();
  }
}

class StageQuizAttemptsNotifier extends StateNotifier<List<QuizAttempt>> {
  final QuizHistoryRepository _repo;
  final int stageNo;

  StageQuizAttemptsNotifier(this._repo, this.stageNo, List<QuizAttempt> initialState) : super(initialState);

  Future<void> addAttempt(QuizAttempt attempt) async {
    await _repo.add(attempt);
    state = _repo.getByStage(stageNo);
  }

  void refresh() {
    state = _repo.getByStage(stageNo);
  }
}

class RecentQuizAttemptsNotifier extends StateNotifier<List<QuizAttempt>> {
  final QuizHistoryRepository _repo;
  final int limit;

  RecentQuizAttemptsNotifier(this._repo, this.limit, List<QuizAttempt> initialState) : super(initialState);

  Future<void> addAttempt(QuizAttempt attempt) async {
    await _repo.add(attempt);
    state = _repo.getRecent(limit: limit);
  }

  void refresh() {
    state = _repo.getRecent(limit: limit);
  }
}

class QuizStatsNotifier extends StateNotifier<QuizHistoryStats> {
  final QuizHistoryRepository _repo;
  final int stageNo;

  QuizStatsNotifier(this._repo, this.stageNo, QuizHistoryStats initialState) : super(initialState);

  Future<void> addAttempt(QuizAttempt attempt) async {
    await _repo.add(attempt);
    state = _repo.getStats(stageNo: stageNo);
  }

  void refresh() {
    state = _repo.getStats(stageNo: stageNo);
  }
}
