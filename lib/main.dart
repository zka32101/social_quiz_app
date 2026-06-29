import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_core/shared_core.dart' show characterStateProvider, coinProvider;
import 'app.dart';
import 'providers/character_provider.dart';
import 'services/purchase_service.dart';
import 'services/ad_service.dart';
import 'utils/constants.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

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
  } catch (e) {
    debugPrint('[Firebase] 初期化スキップ: $e');
  }

  // RevenueCat 初期化（ダミーキー時はスキップ）
  try {
    await PurchaseService.initialize();
  } catch (e) {
    debugPrint('[RevenueCat] 初期化スキップ: $e');
  }

  // AdMob 初期化
  try {
    await AdService.initialize();
  } catch (e) {
    debugPrint('[AdMob] 初期化スキップ: $e');
  }

  runApp(
    ProviderScope(
      overrides: [
        // 社会コレ！のキャラクターノティファイアを注入
        characterStateProvider.overrideWith(CharacterNotifier.new),
        // Hive ベースのコイン管理を coinProvider に橋渡し
        coinProvider.overrideWith(SocialCoinNotifier.new),
      ],
      child: const SocialQuizApp(),
    ),
  );
}
