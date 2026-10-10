import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:social_quiz_app/features/prefecture/data/prefecture_specialty.dart';
import 'package:social_quiz_app/widgets/explanation_with_image_widget.dart';

void main() {
  test('first question always shows', () {
    expect(shouldShowSpecialtyImage(questionIndex: 0, question: '県庁所在地は？', explanation: '名古屋市'), true);
  });
  test('term question hidden', () {
    expect(shouldShowSpecialtyImage(questionIndex: 3, question: '県庁所在地は？', explanation: '名古屋市です'), false);
  });
  test('specialty keywords show', () {
    expect(shouldShowSpecialtyImage(questionIndex: 4, question: '名物はどれ？', explanation: 'x'), true);
    expect(shouldShowSpecialtyImage(questionIndex: 4, question: 'x', explanation: '世界遺産です'), true);
  });
  testWidgets('no overflow at 320px', (t) async {
    t.view.physicalSize = const Size(320, 640);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.reset);
    await t.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: ExplanationWithImage(
            explanation: 'あいちのとくさんひんはたくさんあります。ながいかいせつぶんがここにはいります。ながいかいせつぶんがここにはいります。ながいかいせつぶんがここにはいります。',
            imageOverride: 'assets/prefecture_specialty/none.webp',
          ),
        ),
      ),
    ));
    await t.pump();
    expect(t.takeException(), isNull);
  });
}
