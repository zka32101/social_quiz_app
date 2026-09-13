import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/image_service.dart';

/// キーワードから画像URLを取得するプロバイダー
///
/// 例: ref.watch(imageProvider('日本の地図'))
final imageProvider = FutureProvider.family<String?, String>((ref, keyword) async {
  return await ImageService.getImageUrl(keyword);
});

/// キャッシュ付き画像URL取得プロバイダー
///
/// 同じキーワードで複数回呼び出された場合、
/// キャッシュされた結果を返します
final cachedImageProvider =
    FutureProvider.family<String?, String>((ref, keyword) async {
  // キャッシング機能付きで画像を取得
  // Riverpod の FutureProvider は自動的にキャッシュします
  return await ImageService.getImageUrl(keyword);
});
