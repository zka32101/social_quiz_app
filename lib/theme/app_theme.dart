import 'package:flutter/material.dart';
import 'package:shared_core/shared_core.dart' show buildAppTheme;

// ── 社会コレ！カラー定義（ライトモード） ──────────────────────────
/// メイングリーン（地図・自然をイメージ）
const kSocialPrimary = Color(0xFF2ECC71);

/// ダークグリーン（AppBar・ボタン強調）
const kSocialPrimaryDark = Color(0xFF27AE60);

/// 背景色
const kSocialBgLight = Color(0xFFF8F9FA);

// ── ダークモードカラー定義 ───────────────────────────────────────
/// ダークモード: プライマリ（明るいグリーン）
const kSocialPrimaryDark2 = Color(0xFF4ECB82);

/// ダークモード: 背景色
const kSocialBgDark = Color(0xFF121212);

/// ダークモード: サーフェス色
const kSocialSurfaceDark = Color(0xFF1E1E1E);

// ── テーマ生成 ────────────────────────────────────────────────────
/// 社会コレ！アプリ用ライトテーマ。
/// Material Design 3対応
ThemeData buildSocialTheme() {
  final baseTheme = buildAppTheme(
    primaryColor: kSocialPrimary,
    secondaryColor: kSocialPrimaryDark,
    bgColor: kSocialBgLight,
  );

  return baseTheme.copyWith(
    useMaterial3: true,
  );
}

/// 社会コレ！アプリ用ダークテーマ。
/// Material Design 3対応
ThemeData buildSocialDarkTheme() => ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: kSocialPrimaryDark2,
      scaffoldBackgroundColor: kSocialBgDark,
      appBarTheme: AppBarTheme(
        backgroundColor: kSocialSurfaceDark,
        elevation: 0,
      ),
      cardTheme: CardTheme(
        color: kSocialSurfaceDark,
      ),
    );
