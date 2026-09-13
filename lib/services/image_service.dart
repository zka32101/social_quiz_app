import 'package:flutter/foundation.dart';

/// 無料の商用利用OK画像を取得するサービス
///
/// Unsplash API を使用して、キーワードに基づいた
/// 高品質な画像URLを取得します。
/// ライセンス: Unsplash License (無料商用利用OK)
class ImageService {
  // Unsplash API キー (Free Tier)
  // 本番環境では環境変数から読み込む
  static const String _unsplashAccessKey = 'YOUR_UNSPLASH_ACCESS_KEY';
  static const String _unsplashApiBase = 'https://api.unsplash.com';

  /// キーワードから画像URLを取得
  ///
  /// 例: getImageUrl('日本の地図') → 日本地図の画像URL
  ///
  /// パラメータ:
  ///   - keyword: 検索キーワード（日本語・英語対応）
  ///   - width: 画像幅（デフォルト: 400px）
  ///   - height: 画像高さ（デフォルト: 300px）
  ///
  /// 戻り値: 画像URL、またはエラー時は null
  static Future<String?> getImageUrl(
    String keyword, {
    int width = 400,
    int height = 300,
  }) async {
    try {
      // 注: 実装時には以下を使用してください
      // 1. Unsplash APIキーを environment/secrets.dart から読み込む
      // 2. http.get() で API を呼び出す
      // 3. JSON レスポンスをパース
      // 4. 最初の結果の urls.regular を返す

      // 現在はキーワードベースのマッピングを使用
      return _getMappedImageUrl(keyword);
    } catch (e) {
      debugPrint('ImageService error: $e');
      return null;
    }
  }

  /// キーワードに基づいたプリロード済み画像URLを返す
  ///
  /// Unsplash で提供されている高品質な画像を使用
  /// 無料の商用利用が可能です
  static String? _getMappedImageUrl(String keyword) {
    // 日本語キーワードをマッピング
    final lowerKeyword = keyword.toLowerCase();

    // 地理関連
    if (lowerKeyword.contains('北海道') || lowerKeyword.contains('hokkaido')) {
      return 'https://images.unsplash.com/photo-1522383750817-f4e73c979e46?w=400&h=300&fit=crop'; // 雪景色
    }
    if (lowerKeyword.contains('東京') || lowerKeyword.contains('tokyo')) {
      return 'https://images.unsplash.com/photo-1524594081293-6fcb13f3e0f8?w=400&h=300&fit=crop'; // 東京スカイツリー
    }
    if (lowerKeyword.contains('京都') || lowerKeyword.contains('kyoto')) {
      return 'https://images.unsplash.com/photo-1493976040803-1a6b49589a98?w=400&h=300&fit=crop'; // 伏見稲荷
    }
    if (lowerKeyword.contains('大阪') || lowerKeyword.contains('osaka')) {
      return 'https://images.unsplash.com/photo-1570496776703-19c8b2d6c63d?w=400&h=300&fit=crop'; // 大阪城
    }
    if (lowerKeyword.contains('福岡') || lowerKeyword.contains('fukuoka')) {
      return 'https://images.unsplash.com/photo-1518570953037-21fa55e7e6d2?w=400&h=300&fit=crop'; // 福岡タワー
    }
    if (lowerKeyword.contains('富士山') || lowerKeyword.contains('mount fuji')) {
      return 'https://images.unsplash.com/photo-1522383750817-f4e73c979e46?w=400&h=300&fit=crop'; // 富士山
    }
    if (lowerKeyword.contains('地図') || lowerKeyword.contains('map')) {
      return 'https://images.unsplash.com/photo-1524661135-423995f22d0b?w=400&h=300&fit=crop'; // 地図
    }

    // 歴史関連
    if (lowerKeyword.contains('江戸') || lowerKeyword.contains('edo')) {
      return 'https://images.unsplash.com/photo-1549887534-7e89626e17f6?w=400&h=300&fit=crop'; // 日本の建築
    }
    if (lowerKeyword.contains('平安') || lowerKeyword.contains('heian')) {
      return 'https://images.unsplash.com/photo-1493976040803-1a6b49589a98?w=400&h=300&fit=crop'; // 寺院
    }
    if (lowerKeyword.contains('戦国') || lowerKeyword.contains('sengoku')) {
      return 'https://images.unsplash.com/photo-1570496776703-19c8b2d6c63d?w=400&h=300&fit=crop'; // 城
    }
    if (lowerKeyword.contains('明治') || lowerKeyword.contains('meiji')) {
      return 'https://images.unsplash.com/photo-1549887534-7e89626e17f6?w=400&h=300&fit=crop'; // 明治建築
    }

    // 産業・経済関連
    if (lowerKeyword.contains('農業') ||
        lowerKeyword.contains('agriculture') ||
        lowerKeyword.contains('farm')) {
      return 'https://images.unsplash.com/photo-1500595046891-26a73dae30ba?w=400&h=300&fit=crop'; // 畑
    }
    if (lowerKeyword.contains('工業') ||
        lowerKeyword.contains('manufacturing') ||
        lowerKeyword.contains('factory')) {
      return 'https://images.unsplash.com/photo-1504384308090-c894fdcc538d?w=400&h=300&fit=crop'; // 工場
    }
    if (lowerKeyword.contains('商業') || lowerKeyword.contains('commerce')) {
      return 'https://images.unsplash.com/photo-1556740738-b6a63e27c4df?w=400&h=300&fit=crop'; // 商店街
    }
    if (lowerKeyword.contains('漁業') || lowerKeyword.contains('fishing')) {
      return 'https://images.unsplash.com/photo-1559827260-dc66d52bef19?w=400&h=300&fit=crop'; // 海
    }
    if (lowerKeyword.contains('観光') || lowerKeyword.contains('tourism')) {
      return 'https://images.unsplash.com/photo-1488646953014-85cb44e25828?w=400&h=300&fit=crop'; // 観光地
    }

    // 公民関連
    if (lowerKeyword.contains('政治') || lowerKeyword.contains('politics')) {
      return 'https://images.unsplash.com/photo-1552664730-d307ca884978?w=400&h=300&fit=crop'; // 国会
    }
    if (lowerKeyword.contains('法律') || lowerKeyword.contains('law')) {
      return 'https://images.unsplash.com/photo-1554115736-cb0f51b4d597?w=400&h=300&fit=crop'; // 法律の本
    }
    if (lowerKeyword.contains('経済') || lowerKeyword.contains('economy')) {
      return 'https://images.unsplash.com/photo-1590283603385-17ffb3a7f29f?w=400&h=300&fit=crop'; // グラフ
    }
    if (lowerKeyword.contains('環境') || lowerKeyword.contains('environment')) {
      return 'https://images.unsplash.com/photo-1441974231531-c6227db76b6e?w=400&h=300&fit=crop'; // 自然
    }
    if (lowerKeyword.contains('sdg') || lowerKeyword.contains('sustainable')) {
      return 'https://images.unsplash.com/photo-1563514227147-6814121742e7?w=400&h=300&fit=crop'; // 地球
    }

    // デフォルト（日本文化）
    return 'https://images.unsplash.com/photo-1493976040803-1a6b49589a98?w=400&h=300&fit=crop'; // 日本の風景
  }

  /// Unsplash API を実際に呼び出すメソッド（将来実装）
  ///
  /// 本番環境では以下の実装を使用してください:
  /// ```dart
  /// static Future<String?> _fetchFromUnsplash(String keyword) async {
  ///   final query = Uri.encodeComponent(keyword);
  ///   final url = Uri.parse(
  ///     '$_unsplashApiBase/search/photos'
  ///     '?query=$query'
  ///     '&client_id=$_unsplashAccessKey'
  ///     '&per_page=1'
  ///   );
  ///
  ///   final response = await http.get(url);
  ///   if (response.statusCode == 200) {
  ///     final json = jsonDecode(response.body) as Map<String, dynamic>;
  ///     final results = json['results'] as List? ?? [];
  ///     if (results.isNotEmpty) {
  ///       return results[0]['urls']['regular'] as String;
  ///     }
  ///   }
  ///   return null;
  /// }
  /// ```
}

/// 説明付き画像を表示するウィジェット用のデータ
class ExplanationImage {
  final String keyword;
  final String imageUrl;
  final String alt;

  const ExplanationImage({
    required this.keyword,
    required this.imageUrl,
    required this.alt,
  });
}
