import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 問題ごとの正解回数を記録し、一定回数以上正解した問題を
/// 出題対象から除外できるようにするサービス。
///
/// 「同じ問題が永遠と出続ける」対策：問題IDごとの正解回数を
/// SharedPreferences に保存し、閾値（[masteredThreshold]）以上
/// 正解した問題は、次回以降の出題候補から外せるようにする。
class QuestionMasteryService {
  static const String _storageKey = 'question_mastery_correct_counts';
  static const int masteredThreshold = 2;

  Future<Map<String, int>> _loadAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw == null || raw.isEmpty) return {};
    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      return decoded.map((k, v) => MapEntry(k, v as int));
    } catch (_) {
      return {};
    }
  }

  Future<void> _saveAll(Map<String, int> counts) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, jsonEncode(counts));
  }

  /// 全問題の正解回数マップを取得
  Future<Map<String, int>> getAllCorrectCounts() => _loadAll();

  /// 正解した問題IDの回数を1増やす
  Future<void> recordCorrect(String questionId) async {
    final counts = await _loadAll();
    counts[questionId] = (counts[questionId] ?? 0) + 1;
    await _saveAll(counts);
  }

  /// 指定の問題が「マスター済み」（閾値以上正解）かどうか
  bool isMastered(Map<String, int> counts, String questionId) {
    return (counts[questionId] ?? 0) >= masteredThreshold;
  }
}

final questionMasteryServiceProvider = Provider<QuestionMasteryService>((ref) {
  return QuestionMasteryService();
});

/// 全問題の正解回数マップ（画面側でクイズの出題フィルタに使う）
final questionMasteryCountsProvider = FutureProvider<Map<String, int>>((ref) async {
  final service = ref.watch(questionMasteryServiceProvider);
  return service.getAllCorrectCounts();
});
