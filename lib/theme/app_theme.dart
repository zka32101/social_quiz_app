import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_core/shared_core.dart' as sc;

// ── 社会コレ！カラー定義（ライトモード） ──────────────────────────
/// メイングリーン（地図・自然をイメージ）
const kSocialPrimary = Color(0xFF2ECC71);

/// ダークグリーン（AppBar・ボタン強調）
const kSocialPrimaryDark = Color(0xFF27AE60);

/// 背景色
const kSocialBgLight = Color(0xFFF8F9FA);

/// テキスト色（ライト）
const kSocialTextDark = Color(0xFF1F1F1F);

/// セカンダリテキスト色（ライト）
const kSocialTextSecondary = Color(0xFF757575);

// ── ダークモードカラー定義 ───────────────────────────────────────
/// ダークモード: プライマリ（明るいグリーン）
const kSocialPrimaryDark2 = Color(0xFF4ECB82);

/// ダークモード: 背景色
const kSocialBgDark = Color(0xFF121212);

/// ダークモード: サーフェス色
const kSocialSurfaceDark = Color(0xFF1E1E1E);

/// テキスト色（ダーク）
const kSocialTextWhite = Color(0xFFFFFFFF);

// ── テーマ生成 ────────────────────────────────────────────────────
/// 社会コレ！アプリ用ライトテーマ。
/// Material Design 3対応
ThemeData buildSocialTheme() {
  final baseTheme = sc.buildAppTheme(
    primaryColor: kSocialPrimary,
    secondaryColor: kSocialPrimaryDark,
    bgColor: kSocialBgLight,
  );

  return baseTheme.copyWith(
    textTheme: GoogleFonts.notoSansJpTextTheme(baseTheme.textTheme).copyWith(
      displayLarge: GoogleFonts.notoSansJp(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: kSocialTextDark,
      ),
      displayMedium: GoogleFonts.notoSansJp(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: kSocialTextDark,
      ),
      displaySmall: GoogleFonts.notoSansJp(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: kSocialTextDark,
      ),
      headlineMedium: GoogleFonts.notoSansJp(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: kSocialTextDark,
      ),
      headlineSmall: GoogleFonts.notoSansJp(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: kSocialTextDark,
      ),
      titleLarge: GoogleFonts.notoSansJp(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: kSocialTextDark,
      ),
      titleMedium: GoogleFonts.notoSansJp(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: kSocialTextDark,
      ),
      bodyLarge: GoogleFonts.notoSansJp(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: kSocialTextDark,
      ),
      bodyMedium: GoogleFonts.notoSansJp(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: kSocialTextDark,
      ),
      bodySmall: GoogleFonts.notoSansJp(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: kSocialTextSecondary,
      ),
      labelLarge: GoogleFonts.notoSansJp(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: kSocialTextDark,
      ),
    ),
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
  cardTheme: CardThemeData(
    color: kSocialSurfaceDark,
  ),
  textTheme: TextTheme(
    displayLarge: GoogleFonts.notoSansJp(
      fontSize: 32,
      fontWeight: FontWeight.bold,
      color: kSocialTextWhite,
    ),
    displayMedium: GoogleFonts.notoSansJp(
      fontSize: 28,
      fontWeight: FontWeight.bold,
      color: kSocialTextWhite,
    ),
    displaySmall: GoogleFonts.notoSansJp(
      fontSize: 24,
      fontWeight: FontWeight.bold,
      color: kSocialTextWhite,
    ),
    headlineMedium: GoogleFonts.notoSansJp(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: kSocialTextWhite,
    ),
    headlineSmall: GoogleFonts.notoSansJp(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: kSocialTextWhite,
    ),
    titleLarge: GoogleFonts.notoSansJp(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: kSocialTextWhite,
    ),
    titleMedium: GoogleFonts.notoSansJp(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: kSocialTextWhite.withOpacity(0.87),
    ),
    bodyLarge: GoogleFonts.notoSansJp(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: kSocialTextWhite,
    ),
    bodyMedium: GoogleFonts.notoSansJp(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: kSocialTextWhite.withOpacity(0.7),
    ),
    bodySmall: GoogleFonts.notoSansJp(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      color: kSocialTextWhite.withOpacity(0.6),
    ),
    labelLarge: GoogleFonts.notoSansJp(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      color: kSocialTextWhite,
    ),
  ),
);
