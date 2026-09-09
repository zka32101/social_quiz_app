import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_core/shared_core.dart' show FeedbackReport;

/// shared_core の `FeedbackNotifier` に注入する送信ハンドラ。
///
/// バグ報告・改善要望を Firestore の `feedback` コレクションへ書き込む。
/// ドキュメントIDには [FeedbackReport.id]（送信時に採番されたUUID）を使用し、
/// オフラインキューからの再送信時に重複登録が起きないようにする。
class FeedbackService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> submit(FeedbackReport report) async {
    await _firestore.collection('feedback').doc(report.id).set(report.toJson());
  }
}
