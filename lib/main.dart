import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_core/shared_core.dart'
    show
        characterStateProvider,
        coinProvider,
        equippedItemsProvider,
        feedbackProvider,
        screenTimeProvider,
        lessonProvider as sharedCoreLessonProvider,
        badgeProvider,
        unifiedBadges,
        BadgeNotifier,
        rankingProvider,
        friendProvider,
        missionProvider,
        dailyMissionProvider,
        premiumProvider,
        PremiumNotifier,
        PushNotificationService,
        adaptiveDifficultyNotifierProvider;
import 'app.dart';
import 'providers/character_provider.dart';
import 'providers/equipped_items_provider.dart';
import 'providers/screen_time_provider.dart';
import 'providers/lesson_provider.dart' show LessonNotifier, lessonProvider;
import 'services/firestore_friend_service.dart';
import 'services/firestore_ranking_service.dart';
import 'services/firestore_mission_service.dart';
import 'services/purchase_service.dart';
import 'services/ad_service.dart';
import 'services/character_id_migration.dart';
import 'services/feedback_service.dart';
import 'utils/constants.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 2026-08 キャラクターリニューアル: CharacterNotifier が旧キャラIDの
  // セーブデータを読み込む前に、新IDへ書き換えておく（該当データが無ければ
  // 何もしない冪等処理）。
  await CharacterIdMigration.migrateIfNeeded();

  // 日本語ロケール初期化
  await initializeDateFormatting('ja');

  // Hive 初期化（ローカルDB）
  await Hive.initFlutter();
  await Hive.openBox(AppConstants.contentBoxName);
  await Hive.openBox(AppConstants.settingsBoxName);
  await Hive.openBox(AppConstants.quizHistoryBoxName);
  await Hive.openBox('profiles');

  // アクティブプロフィールのボックスを先に開く（前回の続き）
  final profilesBox = Hive.box('profiles');
  final activeId = profilesBox.get('active_id') as String?;
  if (activeId != null) {
    final boxName = 'profile_$activeId';
    if (!Hive.isBoxOpen(boxName)) {
      await Hive.openBox(boxName);
    }
  }

  // Firebase 初期化（本番キー未設定時はスキップ）
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // ランキング機能等が userId を必要とするため匿名サインインしておく
    if (FirebaseAuth.instance.currentUser == null) {
      await FirebaseAuth.instance.signInAnonymously();
    }
  } catch (e) {
    debugPrint('[Firebase] 初期化スキップ: $e');
  }

  // Phase 4.18: プッシュ通知サービス初期化
  final pushService = PushNotificationService();
  try {
    await pushService.initialize(
      onMessageHandler: (RemoteMessage message) {
        debugPrint('Received message: ${message.notification?.title}');
      },
    );
  } catch (e) {
    // PushNotificationService initialization failed, continue anyway
  }

  // FCM トークンを取得・保存
  try {
    final fcmToken = await pushService.getFCMToken();
    if (fcmToken != null) {
      debugPrint('FCM Token obtained: ${fcmToken.substring(0, 20)}...');
      // 将来: await updateUserFCMToken(userId, fcmToken);
    }
  } catch (e) {
    // FCM token retrieval failed, continue anyway
  }

  // Phase 4.19: 適応難易度エンジン初期化
  // 注: ユーザーID取得後（プロフィール画面後）に各ユーザーごとに initializeAdaptiveDifficulty() を呼ぶこと
  debugPrint('Phase 4.19 Retention Optimization Engine: Initialized');

  // RevenueCat 初期化（ダミーキー時はスキップ）
  final purchaseService = PurchaseService();
  try {
    await purchaseService.initialize();
  } catch (e) {
    debugPrint('[RevenueCat] 初期化スキップ: $e');
  }

  // AdMob 初期化
  try {
    await AdService.initialize();
  } catch (e) {
    debugPrint('[AdMob] 初期化スキップ: $e');
  }

  final container = ProviderContainer(
    overrides: [
      // 社会コレ！のキャラクターノティファイアを注入
      characterStateProvider.overrideWith(CharacterNotifier.new),
      // Hive ベースのコイン管理を coinProvider に橋渡し
      coinProvider.overrideWith(SocialCoinNotifier.new),
      // ショップアイテム（テーマ・フレーム）の装着状態を注入
      equippedItemsProvider.overrideWith(EquippedItemsNotifier.new),
      // 統一バッジシステム（Phase 4.1）: 社会コレ用バッジを主題タグで初期化
      badgeProvider.overrideWith((ref) {
        final notifier = BadgeNotifier();
        notifier.setBadgeDefinitions(unifiedBadges, subject: 'shakai');
        return notifier;
      }),
      // 利用時間制限（スクリーンタイム管理）を注入。デフォルトは「制限なし」
      // （ScreenTimeSettings.enabled = false）
      screenTimeProvider.overrideWith(ScreenTimeNotifier.new),
      // 社会コレの解説記事管理（LessonProvider）ノティファイアを注入
      lessonProvider.overrideWith(LessonNotifier.new),
      // Phase 4.7: 統一サブスクリプション管理（PremiumProvider）
      premiumProvider.overrideWith(PremiumNotifier.new),
    ],
  );

  // バグ報告・改善要望フォームの送信処理（Firestore書き込み）を注入し、
  // オフラインキューに溜まっていた未送信分の再送信を試みる。
  container.read(feedbackProvider.notifier).setSubmitHandler(FeedbackService().submit);
  unawaited(container.read(feedbackProvider.notifier).retryPendingReports());

  // Phase 4.3: マルチアプリランキング・フレンド機能（Firestore連携）
  final rankingService = FirestoreRankingService();
  final friendService = FirestoreFriendService();
  final missionService = FirestoreMissionService();

  container.read(rankingProvider.notifier).setFetchHandler(rankingService.fetchRankings);
  container.read(globalRankingProvider.notifier).setFetchHandler(rankingService.fetchGlobalRankings);
  container.read(friendProvider.notifier)
    ..setFetchHandler(friendService.fetchFriends)
    ..setAddFriendHandler(friendService.addFriend)
    ..setRemoveFriendHandler(friendService.removeFriend);

  // Phase 4.7: 統一サブスクリプション初期化
  final currentUserId = missionService.getCurrentUserId();
  if (currentUserId != null) {
    container.read(premiumProvider.notifier)
      ..setCheckHandler((userId) => purchaseService.isSubscribed(userId))
      ..setExpiryHandler((userId) => purchaseService.getSubscriptionExpirationDate(userId));
    unawaited(container.read(premiumProvider.notifier).checkSubscription(currentUserId));
  }

  // Phase 4.5: デイリーミッション統一
  // ミッション初期化: 現在のユーザー ID で初期化
  if (currentUserId != null) {
    unawaited(container.read(missionProvider.notifier).initializeMissions(currentUserId));
  }

  // Phase 4.20: デイリーミッション統一実装
  // 日次ミッション初期化: 現在のユーザー ID とアプリ ID で初期化
  if (currentUserId != null) {
    unawaited(container.read(dailyMissionProvider.notifier).initializeDailyMissions(currentUserId, 'shakai'));
  }

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const SocialQuizApp(),
    ),
  );
}
