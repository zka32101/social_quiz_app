import 'package:flutter/material.dart';
import 'package:shared_core/shared_core.dart' show buildAppTheme;

// ── 社会コレ！カラー定義 ──────────────────────────────────────────
/// メイングリーン（地図・自然をイメージ）
const kSocialPrimary = Color(0xFF2ECC71);

/// ダークグリーン（AppBar・ボタン強調）
const kSocialPrimaryDark = Color(0xFF27AE60);

/// 背景色
const kSocialBgLight = Color(0xFFF8F9FA);

// ── テーマ生成 ────────────────────────────────────────────────────
/// 社会コレ！アプリ用テーマ。
/// shared_core の buildAppTheme() に社会科カラーを渡して生成。
ThemeData buildSocialTheme() => buildAppTheme(
      primaryColor: kSocialPrimary,
      secondaryColor: kSocialPrimaryDark,
      bgColor: kSocialBgLight,
    );
