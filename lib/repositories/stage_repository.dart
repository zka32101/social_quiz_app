import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/stage.dart';
import '../models/quiz_data.dart';
import '../utils/constants.dart';
import '../data/stage_quests_data.dart';
import '../data/quiz_mock_data.dart';

/// ステージリポジトリ（MVP データ → Hive キャッシュ → Firestore）
///
/// 各ステージの定義と進捗を管理します。
/// 現在は MVP 10 ステージのマスターデータを使用。
class StageRepository {
  final Box _stageBox = Hive.box(AppConstants.contentBoxName);

  /// 全ステージ一覧取得（Hive キャッシュ → MVP データ + クエストデータ注入）
  Future<List<Stage>> getAllStages() async {
    // キャッシュはクリアして最新クエストを常に反映
    // （コンテンツ更新時にキャッシュが古くなるのを防ぐ）
    final cached = _stageBox.get('stages_list_v2');
    if (cached != null) {
      final list = (cached as List).cast<Map<dynamic, dynamic>>();
      return list
          .map((m) => Stage.fromJson(Map<String, dynamic>.from(m)))
          .toList();
    }

    // MVP データにクエストを注入して生成
    final stages = StageData.mvpList.map((m) {
      final stageMap = Map<String, dynamic>.from(m);
      final stageId = stageMap['id'] as String;

      // StageQuestsData からクエストを注入
      final quests = StageQuestsData.questsByStage[stageId];
      if (quests != null) {
        stageMap['quests'] = quests;
      }

      return Stage.fromJson(stageMap);
    }).toList();

    // キャッシュに保存（v2キーで新形式）
    await _stageBox.put('stages_list_v2', stages.map((s) => s.toJson()).toList());

    return stages;
  }

  /// 特定ステージを取得
  Future<Stage?> getStage(String stageId) async {
    final stages = await getAllStages();
    try {
      return stages.firstWhere((s) => s.id == stageId);
    } catch (_) {
      return null;
    }
  }

  /// 特定ステージ番号のステージを取得
  Future<Stage?> getStageByNo(int stageNo) async {
    final stages = await getAllStages();
    try {
      return stages.firstWhere((s) => s.stageNo == stageNo);
    } catch (_) {
      return null;
    }
  }

  /// 学年に応じたステージ一覧を取得
  Future<List<Stage>> getStagesByGrade(int grade) async {
    final stages = await getAllStages();
    String gradeRange;

    if (grade <= 2) {
      gradeRange = '1-2';
    } else if (grade <= 4) {
      gradeRange = '3-4';
    } else {
      gradeRange = '5-6';
    }

    return stages
        .where((s) => s.gradeRange == gradeRange || s.gradeRange == 'all')
        .toList();
  }

  /// ステージの初期クエストセットを生成
  /// （実装: Firestore から取得するか、マスターデータから生成）
  Future<List<Quest>> getQuestsByStage(String stageId) async {
    final stage = await getStage(stageId);
    if (stage == null) return [];

    // TODO: Firestore から実際のクエストを取得する場合はここに実装
    // 現在は、ステージに含まれる quests フィールドを使用
    return stage.quests;
  }

  /// クイズデータを取得（Hive キャッシュ → Firestore → Mock データ）
  Future<QuizData> getQuizData(String quizDataId) async {
    // 1. Hive キャッシュを確認
    final cached = _stageBox.get('quizData_$quizDataId');
    if (cached != null) {
      final data = Map<String, dynamic>.from(cached as Map);
      return QuizData.fromFirestore(data);
    }

    // 2. Firestore から取得
    try {
      final firestore = FirebaseFirestore.instance;
      final doc = await firestore.collection('quizData').doc(quizDataId).get();

      if (!doc.exists) {
        throw Exception('Quiz data not found: $quizDataId');
      }

      final data = doc.data() ?? {};

      // 3. Hive にキャッシュ保存
      await _stageBox.put('quizData_$quizDataId', data);

      // 4. デシリアライズして返却
      return QuizData.fromFirestore(data);
    } catch (e) {
      // Firebase が未初期化または接続できない場合、Mock データを返す（開発用）
      final mockData = _getMockQuizData(quizDataId);
      if (mockData != null) {
        return mockData;
      }
      rethrow;
    }
  }

  /// Mock クイズデータ（開発用・Firebase 未設定時のフォールバック）
  /// QuizMockData クラスから全80問+のデータを取得
  QuizData? _getMockQuizData(String quizDataId) {
    final mockData = QuizMockData.allQuizzes[quizDataId];
    if (mockData != null) {
      return QuizData.fromFirestore(Map<String, dynamic>.from(mockData));
    }
    return null;
  }

  /// キャッシュクリア（コンテンツ更新時に呼ぶ）
  Future<void> clearCache() async {
    await _stageBox.delete('stages_list');
    await _stageBox.delete('stages_list_v2');
  }
}

/// StageRepository プロバイダー
final stageRepositoryProvider = Provider<StageRepository>((ref) {
  return StageRepository();
});

/// 全ステージ一覧プロバイダー
final allStagesProvider = FutureProvider<List<Stage>>((ref) async {
  return ref.read(stageRepositoryProvider).getAllStages();
});

/// 学年別ステージプロバイダー
final stagesByGradeProvider = FutureProvider.family<List<Stage>, int>((ref, grade) async {
  return ref.read(stageRepositoryProvider).getStagesByGrade(grade);
});

/// 特定ステージプロバイダー
final stageProvider = FutureProvider.family<Stage?, String>((ref, stageId) async {
  return ref.read(stageRepositoryProvider).getStage(stageId);
});

/// 特定ステージのクエストプロバイダー
final questsByStageProvider = FutureProvider.family<List<Quest>, String>((ref, stageId) async {
  return ref.read(stageRepositoryProvider).getQuestsByStage(stageId);
});

/// クイズデータプロバイダー（Firestore + Hive キャッシュ）
final quizDataProvider = FutureProvider.family<QuizData, String>((ref, quizDataId) async {
  return ref.read(stageRepositoryProvider).getQuizData(quizDataId);
});
