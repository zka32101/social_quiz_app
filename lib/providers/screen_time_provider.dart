import 'package:shared_core/shared_core.dart';

/// 社会コレ！利用時間制限（スクリーンタイム管理）Notifier。
///
/// shared_core の [BaseScreenTimeNotifier] を継承し、ストレージキーの
/// プレフィックスのみアプリ固有の値をオーバーライドする
/// （[CharacterNotifier] と同じパターン。`lib/providers/character_provider.dart` 参照）。
///
/// `main.dart` の `ProviderContainer` で
/// `screenTimeProvider.overrideWith(ScreenTimeNotifier.new)` として登録する。
class ScreenTimeNotifier extends BaseScreenTimeNotifier {
  @override
  String get storageKey => 'shakai_screen_time';
}
