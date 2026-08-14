import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/prefecture.dart';
import '../models/quiz.dart';
import '../utils/constants.dart';
import '../data/prefecture_data.dart';
import '../data/quiz_generator.dart';

/// コンテンツリポジトリ（JSON アセット → Hive キャッシュ → Firestore の順）
///
/// コンテンツの更新は assets/data/<prefectureId>.json を編集するだけ。
/// Dart コードの変更・再ビルドは不要。
class ContentRepository {
  final Box _contentBox = Hive.box(AppConstants.contentBoxName);

  /// 都道府県一覧取得（Hive キャッシュ → 静的マスターデータ・全47都道府県）
  Future<List<Prefecture>> getPrefectures() async {
    final cached = _contentBox.get('prefectures_list');
    if (cached != null) {
      final list = (cached as List).cast<Map<dynamic, dynamic>>();
      return list
          .map((m) => Prefecture.fromJson(Map<String, dynamic>.from(m)))
          .toList();
    }

    // TODO: Firestore から取得（Firebase 設定後に有効化）
    // final snapshot = await FirebaseFirestore.instance
    //     .collection(AppConstants.prefecturesCollection)
    //     .get();
    // ...

    // 全47都道府県マスターデータから生成
    // （学習ステップ・クイズは getStudySteps/getQuizzes 側で
    //   都道府県ごとに JSON アセット→自動生成のフォールバックを持つ）
    return PrefectureDataList.all
        .map((p) => Prefecture(
              id: p.id,
              name: p.name,
              region: p.region,
              imageUrl: '',
              steps: const [],
              badgeId: '${p.id}_master',
            ))
        .toList();
  }

  /// 特定都道府県の学習ステップ取得（JSON アセット → Hive キャッシュ → Firestore）
  Future<List<StudyStep>> getStudySteps(String prefectureId) async {
    final data = await _loadPrefectureJson(prefectureId);
    if (data == null) return _fallbackSteps(prefectureId);

    final stepsList = data['steps'] as List<dynamic>?;
    if (stepsList == null || stepsList.isEmpty) {
      return _fallbackSteps(prefectureId);
    }

    return stepsList
        .map((s) => StudyStep.fromJson(Map<String, dynamic>.from(s)))
        .toList();
  }

  /// 特定都道府県のクイズ取得（JSON アセット → Hive キャッシュ → Firestore）
  Future<List<Quiz>> getQuizzes(String prefectureId) async {
    // Hive キャッシュ確認（Firestore から取得済みの場合）
    final cacheKey = 'quizzes_$prefectureId';
    final cached = _contentBox.get(cacheKey);
    if (cached != null) {
      final list = (cached as List).cast<Map<dynamic, dynamic>>();
      return list
          .map((m) => Quiz.fromJson(Map<String, dynamic>.from(m)))
          .toList();
    }

    // JSON アセットから読み込み
    final data = await _loadPrefectureJson(prefectureId);
    if (data != null) {
      final quizList = data['quizzes'] as List<dynamic>?;
      if (quizList != null && quizList.isNotEmpty) {
        return quizList
            .map((q) => Quiz.fromJson(Map<String, dynamic>.from(q)))
            .toList();
      }
    }

    // フォールバック: 汎用ダミークイズ
    return _genericQuizzes(prefectureId);
  }

  /// キャッシュクリア
  Future<void> clearCache() async {
    await _contentBox.clear();
  }

  // ─── 内部ヘルパー ─────────────────────────────────────────────────

  /// assets/data/<prefectureId>.json を読み込む
  Future<Map<String, dynamic>?> _loadPrefectureJson(
      String prefectureId) async {
    try {
      final jsonStr = await rootBundle
          .loadString('assets/data/$prefectureId.json');
      return json.decode(jsonStr) as Map<String, dynamic>;
    } catch (_) {
      // ファイルが存在しない or JSON パースエラー → null を返す
      return null;
    }
  }

  /// JSON がない場合のフォールバックステップ
  List<StudyStep> _fallbackSteps(String prefId) {
    return [
      StudyStep(stepNo: 1, title: '基本情報', cards: [
        ContentCard(
            type: CardType.text,
            content: '$prefId の基本情報\n\nコンテンツ準備中です。'),
      ]),
      StudyStep(stepNo: 2, title: '産業', cards: [
        ContentCard(
            type: CardType.text,
            content: '$prefId の産業情報\n\nコンテンツ準備中です。'),
      ]),
      StudyStep(stepNo: 3, title: '文化・観光・先人', cards: [
        ContentCard(
            type: CardType.text,
            content: '$prefId の文化情報\n\nコンテンツ準備中です。'),
      ]),
    ];
  }

  /// JSON がない場合のフォールバック：都道府県データから自動生成
  List<Quiz> _genericQuizzes(String prefId) {
    final generated = QuizGenerator.forPrefecture(prefId);
    if (generated.isNotEmpty) return generated;
    // 念のための最終フォールバック
    return List.generate(
      10,
      (i) => Quiz(
        id: '${prefId}_q${i + 1}',
        stepNo: i < 3 ? 1 : i < 7 ? 2 : 3,
        question: 'クイズ ${i + 1}（$prefId）',
        choices: ['選択肢A', '選択肢B', '選択肢C', '選択肢D'],
        correctIndex: 0,
        explanation: 'この問題の解説です。',
      ),
    );
  }
}

/// ContentRepository プロバイダー
final contentRepositoryProvider = Provider<ContentRepository>((ref) {
  return ContentRepository();
});

/// 都道府県一覧プロバイダー
final prefecturesProvider = FutureProvider<List<Prefecture>>((ref) async {
  return ref.read(contentRepositoryProvider).getPrefectures();
});

/// 特定都道府県クイズプロバイダー
final quizzesProvider =
    FutureProvider.family<List<Quiz>, String>((ref, prefectureId) async {
  return ref.read(contentRepositoryProvider).getQuizzes(prefectureId);
});

/// 特定都道府県学習ステッププロバイダー
final studyStepsProvider =
    FutureProvider.family<List<StudyStep>, String>((ref, prefectureId) async {
  return ref.read(contentRepositoryProvider).getStudySteps(prefectureId);
});
