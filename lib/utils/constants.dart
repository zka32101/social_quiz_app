import 'package:flutter/material.dart';

/// アプリ全体で使用する定数
class AppConstants {
  // アプリ情報
  static const String appName = '小学コレ！社会';
  static const String appVersion = '1.0.0';

  // ─── 機能フラグ ──────────────────────────────────────────
  // 将来実装予定の機能を制御します。
  static const bool enableShop = true;                // ショップ機能（有効）
  static const bool enableSeasonalItems = true;      // 季節限定アイテム（有効）
  static const bool enableAvatarShop = true;         // アバター購入（有効）
  static const bool enableLimitedTimeEvents = false; // 期間限定イベント（実装予定）

  // RevenueCat
  static const String revenueCatAppleKey = 'appl_xxx'; // TODO: 本番キーに差し替え（iOS版）
  static const String revenueCatGoogleKey = 'goog_YtTtuJEjWUzMIqJuhFClqpyqosG';
  static const String premiumEntitlementId = 'premium';

  // プレミアム料金（RevenueCat で設定）
  static const String monthlyProductId = 'premium-monthly';    // 月額300円
  static const String yearlyProductId = 'premium-annualy';     // 年額料金

  // 無料ユーザーが使える都道府県（全47都道府県のうち5個 = 約10.6%）
  // 戦略: 日本の主要経済圏
  static const List<String> freePrefectureIds = [
    'hokkaido',      // 北日本の中心
    'tokyo',         // 首都・関東の中心
    'aichi',         // 中部の中心（名古屋）
    'osaka',         // 関西の中心
    'fukuoka',       // 九州の中心
  ];

  // ポイント
  static const int pointsPerCorrectAnswer = 10;
  static const int pointsAllCorrectBonus = 30;
  static const int pointsDailyMission = 50;
  static const int pointsPrefectureComplete = 100;

  // ストリーク
  static const int streakBadge3Days = 3;
  static const int streakBadge7Days = 7;
  static const int streakBadge30Days = 30;

  // クイズ
  static const int totalQuizCount = 10;
  static const int freeQuizLimit = 5; // 無料ユーザーは5問まで

  // Hive Box名
  static const String contentBoxName = 'content';
  static const String settingsBoxName = 'settings';
  static const String quizHistoryBoxName = 'quiz_history';

  // Hive キー
  static const String gradeKey = 'grade';
  static const String isPremiumKey = 'is_premium';
  static const String streakKey = 'streak';
  static const String lastStudiedAtKey = 'last_studied_at';
  static const String totalPointsKey = 'total_points';
  static const String badgesKey = 'badges';
  static const String parentEmailKey = 'parent_email';

  // Firebase コレクション名
  static const String prefecturesCollection = 'prefectures';
  static const String usersCollection = 'users';
  static const String dailyMissionsCollection = 'dailyMissions';
}

/// アプリのカラーパレット（小学コレ！社会 デザインシステム）
class AppColors {
  // メインカラー — 社会（グリーン系）
  static const int primaryValue   = 0xFF2ECC71; // メイングリーン
  static const int primaryDark    = 0xFF27AE60; // ダークグリーン
  static const int secondaryValue = 0xFF27AE60; // 旧名互換
  static const int accentValue    = 0xFFF39C12; // アンバー（ストリーク用）

  // Color オブジェクト（Flutter widget 用）
  static const Color primary = Color(0xFF2ECC71);
  static const Color primaryDarkColor = Color(0xFF27AE60);
  static const Color accent = Color(0xFFF39C12);

  // 背景
  static const int bgLight  = 0xFFF8F9FA;
  static const int bgWhite  = 0xFFFFFFFF;

  // ゲーミフィケーション
  static const int goldValue   = 0xFFFFD700;
  static const int silverValue = 0xFFC0C0C0;
  static const int bronzeValue = 0xFFCD7F32;

  // フィードバック
  static const int correctValue   = 0xFF27AE60; // 正解
  static const int incorrectValue = 0xFFE74C3C; // 不正解
  static const int warningValue   = 0xFFF39C12; // 警告

  // 正解/不正解 背景
  static const int correctBgValue   = 0xFFD5F4E6;
  static const int incorrectBgValue = 0xFFFADBD8;

  // プレミアム特典エリア
  static const int featureBgValue  = 0xFFE8F8F5; // 薄いグリーン
  static const int parentNoteBgValue = 0xFFFFF9E6; // 薄いアンバー
  static const int recommendedBgValue = 0xFFF0F9F7;
}

/// ルートパス定数
class AppRoutes {
  static const String splash = '/';
  static const String home = '/home';
  static const String prefectureList = '/prefectures';
  static const String study = '/study/:prefectureId';
  static const String quiz = '/quiz/:prefectureId';
  static const String result = '/result/:prefectureId';
  static const String settings = '/settings';
  static const String paywall = '/paywall';
}
