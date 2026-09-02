import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../data/badge_definitions.dart';
import '../data/stage_quests_data.dart';
import '../models/user_progress.dart';
import '../utils/constants.dart';
import 'profile_repository.dart';

export '../models/user_progress.dart';

/// ユーザー進捗リポジトリ（Hive ローカルストレージ）
class ProgressRepository {
  final Box _box;

  ProgressRepository(this._box);

  // ─── ロード ───────────────────────────────────────────────
  UserProgress loadLocal() {
    final badges = List<String>.from(
      _box.get(AppConstants.badgesKey, defaultValue: <String>[]) as List,
    );
    final prefProgressRaw = _box.get('prefecture_progress') as Map? ?? {};
    final stageProgressRaw = _box.get('stage_progress') as Map? ?? {};

    final prefProgress = <String, PrefectureProgress>{};
    prefProgressRaw.forEach((k, v) {
      if (v is Map) {
        prefProgress[k as String] = PrefectureProgress.fromJson(Map<String, dynamic>.from(v));
      }
    });

    final stageProgress = <String, StageProgress>{};
    stageProgressRaw.forEach((k, v) {
      if (v is Map) {
        stageProgress[k as String] = StageProgress.fromJson(Map<String, dynamic>.from(v));
      }
    });

    final trialStartDate = _box.get('trial_start_date') as String?;
    final wrongAnswerIds = List<String>.from(
      _box.get('wrong_answers', defaultValue: <String>[]) as List,
    );

    return UserProgress(
      userId: _box.get('user_id', defaultValue: 'local') as String,
      grade: _box.get(AppConstants.gradeKey, defaultValue: 4) as int,
      isPremium: _box.get(AppConstants.isPremiumKey, defaultValue: false) as bool,
      totalPoints: _box.get(AppConstants.totalPointsKey, defaultValue: 0) as int,
      streak: _box.get(AppConstants.streakKey, defaultValue: 0) as int,
      lastStudiedAt: _box.get('last_studied_at') != null
          ? DateTime.tryParse(_box.get('last_studied_at') as String)
          : null,
      parentEmail: _box.get(AppConstants.parentEmailKey, defaultValue: '') as String,
      badges: badges,
      prefectureProgress: prefProgress,
      stageProgress: stageProgress.isEmpty
          ? {'stage_1': StageProgress.empty('stage_1', 1)}
          : stageProgress,
      coins: _box.get('coins', defaultValue: 0) as int,
      trialStartDate: trialStartDate,
      wrongAnswerIds: wrongAnswerIds,
    );
  }

  // ─── 保存 ───────────────────────────────────────────────
  Future<void> saveAll(UserProgress progress) async {
    await _box.put(AppConstants.gradeKey, progress.grade);
    await _box.put(AppConstants.isPremiumKey, progress.isPremium);
    await _box.put(AppConstants.totalPointsKey, progress.totalPoints);
    await _box.put(AppConstants.streakKey, progress.streak);
    await _box.put(AppConstants.badgesKey, progress.badges);
    await _box.put(AppConstants.parentEmailKey, progress.parentEmail ?? '');
    await _box.put('coins', progress.coins);
    if (progress.trialStartDate != null) {
      await _box.put('trial_start_date', progress.trialStartDate);
    }
    await _box.put('wrong_answers', progress.wrongAnswerIds);
    if (progress.lastStudiedAt != null) {
      await _box.put('last_studied_at', progress.lastStudiedAt!.toIso8601String());
    }
    // 都道府県進捗
    final prefMap = <String, dynamic>{};
    progress.prefectureProgress.forEach((k, v) => prefMap[k] = v.toJson());
    await _box.put('prefecture_progress', prefMap);
    // ステージ進捗
    final stageMap = <String, dynamic>{};
    progress.stageProgress.forEach((k, v) => stageMap[k] = v.toJson());
    await _box.put('stage_progress', stageMap);
  }

  // ─── ポイント・コイン ─────────────────────────────────────
  Future<void> addPoints(int points) async {
    final current = _box.get(AppConstants.totalPointsKey, defaultValue: 0) as int;
    await _box.put(AppConstants.totalPointsKey, current + points);
  }

  Future<void> addCoins(int amount) async {
    final current = _box.get('coins', defaultValue: 0) as int;
    await _box.put('coins', current + amount);
  }

  Future<bool> spendCoins(int amount) async {
    final current = _box.get('coins', defaultValue: 0) as int;
    if (current < amount) return false;
    await _box.put('coins', current - amount);
    return true;
  }

  // ─── ストリーク ───────────────────────────────────────────
  Future<void> updateStreak(int streak) async {
    await _box.put(AppConstants.streakKey, streak);
    await _box.put('last_studied_at', DateTime.now().toIso8601String());
  }

  // ─── バッジ ────────────────────────────────────────────────
  Future<void> addBadge(String badgeId) async {
    final badges = List<String>.from(
      _box.get(AppConstants.badgesKey, defaultValue: <String>[]) as List,
    );
    if (!badges.contains(badgeId)) {
      badges.add(badgeId);
      await _box.put(AppConstants.badgesKey, badges);
    }
  }

  // ─── プレミアム ───────────────────────────────────────────
  Future<void> setPremium(bool value) async {
    await _box.put(AppConstants.isPremiumKey, value);
  }

  Future<void> initTrialIfNeeded() async {
    if (_box.get('trial_start_date') == null) {
      await _box.put('trial_start_date', DateTime.now().toIso8601String());
    }
  }

  // ─── 都道府県進捗 ─────────────────────────────────────────
  Future<void> completeStep(String prefectureId, int stepNo) async {
    final progress = loadLocal();
    final current = progress.prefectureProgress[prefectureId]
        ?? PrefectureProgress.empty(prefectureId);
    if (!current.completedSteps.contains(stepNo)) {
      final updated = current.copyWith(
        completedSteps: [...current.completedSteps, stepNo],
      );
      final newPrefProgress = Map<String, PrefectureProgress>.from(progress.prefectureProgress);
      newPrefProgress[prefectureId] = updated;
      await saveAll(progress.copyWith(prefectureProgress: newPrefProgress));
    }
  }

  Future<void> saveQuizResult(
    String prefectureId,
    int score, {
    String? newBadgeId,
  }) async {
    final progress = loadLocal();
    final current = progress.prefectureProgress[prefectureId]
        ?? PrefectureProgress.empty(prefectureId);
    final newPrefProgress = Map<String, PrefectureProgress>.from(progress.prefectureProgress);
    // isCompleted は一度 true になったら再挑戦で下がった点数でも false に戻さない
    // （score >= 7 は「今回のスコアで新たに制覇したか」の判定のみに使う）
    final justCompleted = score >= 7;
    newPrefProgress[prefectureId] = current.copyWith(
      quizBestScore: score > current.quizBestScore ? score : current.quizBestScore,
      isCompleted: current.isCompleted || justCompleted,
      completedAt: justCompleted ? DateTime.now() : current.completedAt,
    );
    var updated = progress.copyWith(prefectureProgress: newPrefProgress);
    if (newBadgeId != null && !updated.badges.contains(newBadgeId)) {
      updated = updated.copyWith(badges: [...updated.badges, newBadgeId]);
    }
    await saveAll(updated);
  }

  // ─── ステージ・クエスト進捗 ───────────────────────────────
  Future<void> completeQuest(String stageId, int questNo) async {
    final progress = loadLocal();
    final current = progress.stageProgress[stageId]
        ?? StageProgress.empty(stageId, int.tryParse(stageId.replaceAll('stage_', '')) ?? 1);
    if (!current.completedQuests.contains(questNo)) {
      final newStageProgress = Map<String, StageProgress>.from(progress.stageProgress);
      newStageProgress[stageId] = current.copyWith(
        completedQuests: [...current.completedQuests, questNo],
      );
      await saveAll(progress.copyWith(stageProgress: newStageProgress));
    }
  }

  // ─── メール ───────────────────────────────────────────────
  Future<void> setParentEmail(String email) async {
    await _box.put(AppConstants.parentEmailKey, email);
  }

  // ━━━ 間違いノート ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Future<void> addWrongAnswer(String quizId) async {
    final ids = List<String>.from(
      _box.get('wrong_answers', defaultValue: <String>[]) as List,
    );
    if (!ids.contains(quizId)) {
      ids.add(quizId);
      await _box.put('wrong_answers', ids);
    }
  }

  Future<void> removeWrongAnswer(String quizId) async {
    final ids = List<String>.from(
      _box.get('wrong_answers', defaultValue: <String>[]) as List,
    );
    ids.remove(quizId);
    await _box.put('wrong_answers', ids);
  }

  List<String> loadWrongAnswerIds() {
    return List<String>.from(
      _box.get('wrong_answers', defaultValue: <String>[]) as List,
    );
  }

  // ━━━ ストリーク計算 ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  /// 日付ベースのストリーク計算
  /// 昨日学習済み → streak + 1
  /// 今日すでに学習済み → streak変わらず
  /// それ以外 → streak = 1 (リセット)
  int calculateNewStreak(int currentStreak, DateTime? lastStudiedAt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    if (lastStudiedAt == null) return 1;
    final lastDay = DateTime(lastStudiedAt.year, lastStudiedAt.month, lastStudiedAt.day);
    final diff = today.difference(lastDay).inDays;
    if (diff == 0) return currentStreak; // 今日すでに学習
    if (diff == 1) return currentStreak + 1; // 昨日学習 → 継続
    return 1; // 空白日あり → リセット
  }
}

// ─────────────────────────────────────────────────────────────
// Riverpod プロバイダー
// ─────────────────────────────────────────────────────────────

final progressRepositoryProvider = Provider<ProgressRepository>((ref) {
  // profile_repository.dart の activeProfileIdProvider を使用（null の場合は 'default'）
  final profileId = ref.watch(activeProfileIdProvider) ?? 'default';
  final boxName = 'profile_$profileId';
  final box = Hive.isBoxOpen(boxName)
      ? Hive.box(boxName)
      : Hive.box(AppConstants.settingsBoxName);
  return ProgressRepository(box);
});

/// ユーザー進捗ノティファイアー
class UserProgressNotifier extends StateNotifier<UserProgress> {
  final ProgressRepository _repo;

  UserProgressNotifier(this._repo) : super(_repo.loadLocal()) {
    _repo.initTrialIfNeeded();
  }

  Future<void> refresh() async {
    state = _repo.loadLocal();
  }

  Future<void> addPoints(int points) async {
    await _repo.addPoints(points);
    state = state.copyWith(totalPoints: state.totalPoints + points);
  }

  Future<void> addCoins(int amount) async {
    await _repo.addCoins(amount);
    state = state.copyWith(coins: state.coins + amount);
  }

  Future<bool> spendCoins(int amount) async {
    final success = await _repo.spendCoins(amount);
    if (success) state = state.copyWith(coins: state.coins - amount);
    return success;
  }

  Future<void> updateStreak(int streak) async {
    await _repo.updateStreak(streak);
    state = state.copyWith(streak: streak);
  }

  /// バッジを付与 + バッジのコイン報酬を自動加算
  /// 全バッジ獲得時には social_master バッジも自動付与
  Future<void> addBadge(String badgeId) async {
    if (state.badges.contains(badgeId)) return; // 重複スキップ
    await _repo.addBadge(badgeId);
    // await をまたぐ間に別の呼び出しが同じバッジを追加している可能性があるため再チェック
    if (!state.badges.contains(badgeId)) {
      state = state.copyWith(badges: [...state.badges, badgeId]);
    }
    // バッジコイン報酬を自動付与
    final def = BadgeDefinitions.findById(badgeId);
    if (def != null && def.coinReward > 0) {
      await _repo.addCoins(def.coinReward);
      state = state.copyWith(coins: state.coins + def.coinReward);
    }

    // 全バッジ獲得をチェック（social_master バッジ獲得判定）
    await _checkAndAwardSocialMaster();
  }

  /// 全バッジ獲得時に social_master バッジを付与
  Future<void> _checkAndAwardSocialMaster() async {
    if (state.badges.contains('social_master')) return; // 既に獲得済み

    // 全バッジ数から social_master を除く
    final totalBadges = BadgeDefinitions.all.length - 1; // social_master を除外
    final earnedCount = state.badges.length;

    // 全バッジを獲得したか確認（社会博士以外の全バッジ）
    if (earnedCount >= totalBadges) {
      final allOtherBadgesEarned = BadgeDefinitions.all
          .where((b) => b.id != 'social_master')
          .every((b) => state.badges.contains(b.id));

      if (allOtherBadgesEarned) {
        await _repo.addBadge('social_master');
        if (!state.badges.contains('social_master')) {
          state = state.copyWith(badges: [...state.badges, 'social_master']);
        }
        // 社会博士バッジのコイン報酬を付与
        final socialMasterDef = BadgeDefinitions.findById('social_master');
        if (socialMasterDef != null && socialMasterDef.coinReward > 0) {
          await _repo.addCoins(socialMasterDef.coinReward);
          state = state.copyWith(coins: state.coins + socialMasterDef.coinReward);
        }
      }
    }
  }

  Future<void> setPremium(bool value) async {
    await _repo.setPremium(value);
    state = state.copyWith(isPremium: value);
  }

  Future<void> setParentEmail(String email) async {
    await _repo.setParentEmail(email);
    state = state.copyWith(parentEmail: email);
  }

  /// クエスト完了 + 自動バッジ付与
  /// ステージ完了時は stage_completion バッジを付与
  /// 全ステージ完了時は all_stages バッジを付与
  Future<void> completeQuest(String stageId, int questNo) async {
    await _repo.completeQuest(stageId, questNo);
    state = _repo.loadLocal();

    // ステージ完了をチェック
    final stageProgress = state.stageProgress[stageId];
    if (stageProgress != null && !stageProgress.isCompleted) {
      // ステージの総クエスト数を仮定（StageQuestsData から取得可能）
      // 一般的に 5 クエストまたは個別のクエスト数
      final expectedQuestCount = _getExpectedQuestCount(stageId);

      if (stageProgress.completedQuests.length >= expectedQuestCount) {
        // ステージ完了 → バッジ付与
        await _markStageCompleted(stageId);

        // 全ステージ完了をチェック
        if (state.stageProgress.values.every((sp) => sp.isCompleted)) {
          // all_stages バッジ付与
          if (!state.badges.contains('all_stages')) {
            await addBadge('all_stages');
          }
        }
      }
    }
  }

  /// ステージをマーク完了 + バッジ付与
  Future<void> _markStageCompleted(String stageId) async {
    final stageProgress = state.stageProgress[stageId];
    if (stageProgress != null && !stageProgress.isCompleted) {
      final newStageProgress = Map<String, StageProgress>.from(state.stageProgress);
      newStageProgress[stageId] = stageProgress.copyWith(
        isCompleted: true,
        completedAt: DateTime.now(),
      );

      // 進捗を保存
      final updated = state.copyWith(stageProgress: newStageProgress);
      await _repo.saveAll(updated);
      state = updated;

      // ステージ完了バッジを付与（stage_X_complete）
      final stageNumber = int.tryParse(stageId.replaceAll('stage_', '')) ?? 1;
      final stageBadgeId = 'stage_${stageNumber}_complete';
      if (!state.badges.contains(stageBadgeId)) {
        await addBadge(stageBadgeId);
      }
    }
  }

  /// ステージの期待クエスト数を取得
  /// StageQuestsData から該当ステージのクエスト数を取得
  int _getExpectedQuestCount(String stageId) {
    // StageQuestsData.questsByStage から取得
    final quests = StageQuestsData.questsByStage[stageId] ?? [];
    return quests.isEmpty ? 5 : quests.length; // デフォルト 5
  }

  /// 都道府県の学習ステップ（STEP1〜3）を完了として記録し、Stateを再読み込み
  Future<void> completeStep(String prefectureId, int stepNo) async {
    await _repo.completeStep(prefectureId, stepNo);
    state = _repo.loadLocal();
  }

  /// クイズ結果を保存し、Stateを再読み込み
  Future<void> saveQuizResult(String prefectureId, int score, {String? newBadgeId}) async {
    await _repo.saveQuizResult(prefectureId, score, newBadgeId: newBadgeId);
    state = _repo.loadLocal();
  }

  /// プロファイル切り替え: 指定プロファイルのボックスから状態を再読み込み
  Future<void> switchProfile(String profileId) async {
    final boxName = 'profile_$profileId';
    final box = Hive.isBoxOpen(boxName)
        ? Hive.box(boxName)
        : Hive.box(AppConstants.settingsBoxName);
    final newRepo = ProgressRepository(box);
    await newRepo.initTrialIfNeeded();
    state = newRepo.loadLocal();
  }

  /// ストリーク更新 + バッジ自動付与（3/7/30日）
  Future<String?> updateStreakWithBadge(int streak) async {
    await updateStreak(streak);
    String? earnedBadgeId;
    if (streak == 3 && !state.badges.contains('streak_3')) {
      await addBadge('streak_3');
      earnedBadgeId = 'streak_3';
    } else if (streak == 7 && !state.badges.contains('streak_7')) {
      await addBadge('streak_7');
      earnedBadgeId = 'streak_7';
    } else if (streak == 30 && !state.badges.contains('streak_30')) {
      await addBadge('streak_30');
      earnedBadgeId = 'streak_30';
    }
    return earnedBadgeId;
  }

  Future<void> addWrongAnswer(String quizId) async {
    await _repo.addWrongAnswer(quizId);
    final ids = _repo.loadWrongAnswerIds();
    state = state.copyWith(wrongAnswerIds: ids);
  }

  Future<void> removeWrongAnswer(String quizId) async {
    await _repo.removeWrongAnswer(quizId);
    final ids = _repo.loadWrongAnswerIds();
    state = state.copyWith(wrongAnswerIds: ids);
  }
}

/// メインプロバイダー（StateNotifier）
final userProgressProvider =
    StateNotifierProvider<UserProgressNotifier, UserProgress>((ref) {
  final repo = ref.watch(progressRepositoryProvider);
  return UserProgressNotifier(repo);
});

/// 旧名互換エイリアス
final progressProvider = userProgressProvider;

/// コイン残高プロバイダー（派生）
final coinsProvider = Provider<int>((ref) {
  return ref.watch(userProgressProvider).coins;
});
