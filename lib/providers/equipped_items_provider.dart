import 'package:shared_core/shared_core.dart';

/// 社会コレ！ショップアイテム装着状態 Notifier。
///
/// shared_core の [BaseEquippedItemsNotifier] を継承し、
/// SharedPreferences の名前空間をアプリ固有にする
/// （[CharacterNotifier] と同じパターン。character_provider.dart 参照）。
class EquippedItemsNotifier extends BaseEquippedItemsNotifier {
  @override
  String get storageKey => 'shakai_equipped_items';
}
