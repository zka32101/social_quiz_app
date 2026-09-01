/// 商用利用OK画像統合ガイド
///
/// このガイドでは、アプリ内でExplanationWithImageウィジェットを
/// 使用して、educational content に画像を追加する方法を説明します。

/*

## 使用例

### 1. 基本的な使い方（クイズ解説に画像を追加）

```dart
import 'package:flutter/material.dart';
import '../widgets/explanation_with_image_widget.dart';

class MyExplanationScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // テキストとその下に関連画像を表示
            ExplanationWithImage(
              explanation: '北海道は日本最北端の都道府県です。'
                  '雪が多く、冬は非常に寒いのが特徴です。',
              imageKeyword: '北海道',
              imageHeight: 250,
            ),
          ],
        ),
      ),
    );
  }
}
```

### 2. 横並びレイアウト（左に画像、右にテキスト）

```dart
ExplanationWithImageHorizontal(
  explanation: '農業は日本経済の基盤です。'
      '特に米や野菜の栽培が重要な役割を果たしています。',
  imageKeyword: '農業',
  imageWidth: 120,
)
```

### 3. テキストのみ（フォールバック）

```dart
// 画像が不要な場合
ExplanationCard(
  explanation: '解説テキスト',
  padding: const EdgeInsets.all(16),
)
```

## 対応キーワード

### 地理
- '北海道', 'hokkaido'
- '東京', 'tokyo'
- '京都', 'kyoto'
- '大阪', 'osaka'
- '福岡', 'fukuoka'
- '富士山', 'mount fuji'
- '地図', 'map'

### 歴史
- '江戸', 'edo'
- '平安', 'heian'
- '戦国', 'sengoku'
- '明治', 'meiji'

### 産業
- '農業', 'agriculture', 'farm'
- '工業', 'manufacturing', 'factory'
- '商業', 'commerce'
- '漁業', 'fishing'
- '観光', 'tourism'

### 公民
- '政治', 'politics'
- '法律', 'law'
- '経済', 'economy'
- '環境', 'environment'
- 'sdg', 'sustainable'

## 他のスクリーンへの統合例

### 都道府県学習ページ

```dart
class PrefectureStudyScreen extends StatelessWidget {
  final String prefectureId;

  @override
  Widget build(BuildContext context) {
    final pref = PrefectureDataList.findById(prefectureId);

    return SingleChildScrollView(
      child: Column(
        children: [
          // 地理情報
          ExplanationWithImage(
            explanation: pref.description,
            imageKeyword: pref.name,
          ),

          // 特産物
          ExplanationWithImage(
            explanation: '特産品: \${pref.specialties}',
            imageKeyword: '${pref.name}特産',
          ),
        ],
      ),
    );
  }
}
```

### 歴史ページ

```dart
class HistoryEraScreen extends StatelessWidget {
  final String eraId;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          ExplanationWithImage(
            explanation: eraData.description,
            imageKeyword: eraData.eraName,
          ),
        ],
      ),
    );
  }
}
```

### 産業・経済ページ

```dart
class IndustryScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        ExplanationWithImage(
          explanation: '日本の農業について...',
          imageKeyword: '農業',
        ),
        ExplanationWithImage(
          explanation: '製造業の重要性...',
          imageKeyword: '工業',
        ),
        ExplanationWithImage(
          explanation: '商業の役割...',
          imageKeyword: '商業',
        ),
      ],
    );
  }
}
```

## 将来の拡張

### 1. Unsplash API 直接統合

```dart
// ImageService で実装予定:
// - Unsplash API キーを environment/secrets.dart から読み込む
// - http.get() で API を呼び出す
// - 動的にキーワード検索結果から画像を取得

static Future<String?> _fetchFromUnsplash(String keyword) async {
  final query = Uri.encodeComponent(keyword);
  final url = Uri.parse(
    'https://api.unsplash.com/search/photos'
    '?query=\$query'
    '&client_id=\${_unsplashAccessKey}'
    '&per_page=1'
  );

  final response = await http.get(url);
  if (response.statusCode == 200) {
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final results = json['results'] as List? ?? [];
    if (results.isNotEmpty) {
      return results[0]['urls']['regular'] as String;
    }
  }
  return null;
}
```

### 2. キャッシング

```dart
// Riverpod の FutureProvider は自動的にキャッシュしますが、
// 追加でローカルファイルキャッシュを実装可能:

static final _imageCache = <String, String>{};

static Future<String?> getImageUrl(String keyword) async {
  if (_imageCache.containsKey(keyword)) {
    return _imageCache[keyword];
  }

  final url = await _fetchFromUnsplash(keyword);
  if (url != null) {
    _imageCache[keyword] = url;
  }
  return url;
}
```

### 3. ローカル画像フォールバック

```dart
// キーワードに対応したローカル画像がある場合、
// ネットワーク画像の前にローカル画像を使用:

static String? _getLocalImagePath(String keyword) {
  final mapping = {
    'hokkaido': 'assets/images/hokkaido.jpg',
    'tokyo': 'assets/images/tokyo.jpg',
    // ...
  };
  return mapping[keyword];
}
```

## ライセンス

- **Unsplash License**: 無料、クレジット表記不要、商用利用OK
- すべての画像は高品質で教育用途に適しています

## トラブルシューティング

### 画像が表示されない
1. キーワードが正しいか確認
2. ネットワーク接続を確認
3. Unsplash API（将来統合時）のキーが有効か確認

### パフォーマンスの問題
1. 画像高さを小さくする: `imageHeight: 150`
2. キャッシュを使用: `cachedImageProvider` を使用
3. 遅延ロード: ScrollView with lazy loading

*/

// このファイルは説明用です。
// 実際のコード例は上記コメントセクションを参照してください。
