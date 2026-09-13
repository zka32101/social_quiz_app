import 'package:flutter/material.dart';

/// モバイルフレンドリーなボタンスタイルセット
///
/// 小学生ユーザーと保護者にとって操作しやすいボタンサイズを提供します。
/// - 最小高さ: 56px（Flutter Material の推奨値）
/// - 推奨高さ: 64px（タブレットでの操作性向上）
/// - 下部パディング: 20px（ホームボタンやジェスチャーへの干渉を避ける）
class AppButtonStyles {
  /// メインアクション用（primary）
  /// 最もよく使うボタン（答える、進むなど）
  static ButtonStyle primaryLarge() => ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 20),
        minimumSize: const Size.fromHeight(64),
      );

  /// セカンダリアクション用
  /// 補助的なアクション（スキップ、もう一度など）
  static ButtonStyle secondaryLarge() => OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 20),
        minimumSize: const Size.fromHeight(64),
      );

  /// テキストボタン用（低強度）
  /// キャンセルや詳細情報など
  static ButtonStyle textLarge() => TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 20),
        minimumSize: const Size.fromHeight(64),
      );

  /// 小さめボタン用
  /// リスト内のボタンやダイアログのボタン
  static ButtonStyle primarySmall() => ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        minimumSize: const Size.fromHeight(56),
      );

  /// アイコンボタン用
  /// FAB（FloatingActionButton）の代わりに使用可能
  static ButtonStyle iconLarge() => ElevatedButton.styleFrom(
        padding: const EdgeInsets.all(20),
        minimumSize: const Size(64, 64),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      );
}

/// ボタン配置の共通パターン
class ButtonLayoutPatterns {
  /// 画面下部の全幅ボタン（20px下部パディング付き）
  static Widget primaryButtonWithBottomPadding({
    required Widget button,
    required BuildContext context,
  }) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: 20 + bottomPadding),
      child: button,
    );
  }

  /// 横並びボタン（2列）
  static Widget twoHorizontalButtons({
    required Widget leftButton,
    required Widget rightButton,
    double spacing = 12,
    double bottomPadding = 20,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: bottomPadding),
      child: Row(
        children: [
          Expanded(child: leftButton),
          SizedBox(width: spacing),
          Expanded(child: rightButton),
        ],
      ),
    );
  }

  /// 横並びボタン（3列）
  static Widget threeHorizontalButtons({
    required Widget leftButton,
    required Widget centerButton,
    required Widget rightButton,
    double spacing = 8,
    double bottomPadding = 20,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: bottomPadding),
      child: Row(
        children: [
          Expanded(child: leftButton),
          SizedBox(width: spacing),
          Expanded(child: centerButton),
          SizedBox(width: spacing),
          Expanded(child: rightButton),
        ],
      ),
    );
  }
}

/// 推奨される画面下部ボタン配置用の Padding ヘルパー
///
/// 使い方:
/// ```dart
/// Column(
///   children: [
///     Expanded(child: content),
///     BottomButtonPadding(
///       child: SizedBox(
///         width: double.infinity,
///         height: 64,
///         child: ElevatedButton(onPressed: onPressed, child: Text('決定')),
///       ),
///     ),
///   ],
/// )
/// ```
class BottomButtonPadding extends StatelessWidget {
  final Widget child;
  final double padding;

  const BottomButtonPadding({
    Key? key,
    required this.child,
    this.padding = 20,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bottomViewInsets = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        bottom: padding + bottomViewInsets,
        top: 16,
      ),
      child: child,
    );
  }
}
