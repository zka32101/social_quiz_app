import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_core/shared_core.dart' show LessonMenuPage;
import '../../data/lesson_data.dart';
import '../../providers/lesson_provider.dart';

/// 社会コレ！「解説メニュー」画面。
/// 表示ロジックは shared_core の LessonMenuPage に委譲し、
/// 画面表示時にアプリ側の記事一覧（kLessons）を読み込む。
class LessonScreen extends ConsumerStatefulWidget {
  const LessonScreen({super.key});

  @override
  ConsumerState<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends ConsumerState<LessonScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(lessonProvider.notifier).load(kLessons);
    });
  }

  @override
  Widget build(BuildContext context) {
    return const LessonMenuPage(lessons: kLessons);
  }
}
