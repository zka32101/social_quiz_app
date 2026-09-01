import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/image_provider.dart';

/// 説明テキストと関連画像を表示するカード
///
/// クイズの解説や学習ページで使用します。
/// 自動的に関連画像を取得して表示します。
class ExplanationWithImage extends ConsumerWidget {
  final String explanation;
  final String? imageKeyword;
  final double imageHeight;
  final EdgeInsets padding;

  const ExplanationWithImage({
    Key? key,
    required this.explanation,
    this.imageKeyword,
    this.imageHeight = 250,
    this.padding = const EdgeInsets.all(16),
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final imageKeywordForSearch = imageKeyword ?? explanation;
    final imageAsync = ref.watch(imageProvider(imageKeywordForSearch));

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 画像セクション
          if (imageAsync.when(
            data: (url) => url != null,
            loading: () => true,
            error: (_, __) => false,
          ))
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: imageAsync.when(
                  data: (imageUrl) {
                    if (imageUrl == null) {
                      return const SizedBox.shrink();
                    }
                    return Image.network(
                      imageUrl,
                      height: imageHeight,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: imageHeight,
                          color: Colors.grey.shade200,
                          child: const Center(
                            child: Icon(Icons.image_not_supported),
                          ),
                        );
                      },
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          height: imageHeight,
                          color: Colors.grey.shade200,
                          child: const Center(
                            child: SizedBox(
                              width: 40,
                              height: 40,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                  loading: () => Container(
                    height: imageHeight,
                    color: Colors.grey.shade200,
                    child: const Center(
                      child: SizedBox(
                        width: 40,
                        height: 40,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  ),
                  error: (error, stackTrace) => Container(
                    height: imageHeight,
                    color: Colors.grey.shade200,
                    child: const Center(
                      child: Icon(Icons.error_outline),
                    ),
                  ),
                ),
              ),
            ),
          // テキストセクション
          const Text(
            '解説',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            explanation,
            style: const TextStyle(
              fontSize: 15,
              height: 1.6,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}

/// シンプルな説明カード（画像なし）
class ExplanationCard extends StatelessWidget {
  final String explanation;
  final EdgeInsets padding;

  const ExplanationCard({
    Key? key,
    required this.explanation,
    this.padding = const EdgeInsets.all(16),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '解説',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            explanation,
            style: const TextStyle(
              fontSize: 15,
              height: 1.6,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}

/// 画像とテキストを横並びで表示するカード
class ExplanationWithImageHorizontal extends ConsumerWidget {
  final String explanation;
  final String? imageKeyword;
  final double imageWidth;
  final EdgeInsets padding;

  const ExplanationWithImageHorizontal({
    Key? key,
    required this.explanation,
    this.imageKeyword,
    this.imageWidth = 120,
    this.padding = const EdgeInsets.all(16),
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final imageKeywordForSearch = imageKeyword ?? explanation;
    final imageAsync = ref.watch(imageProvider(imageKeywordForSearch));

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 画像
          if (imageAsync.when(
            data: (url) => url != null,
            loading: () => true,
            error: (_, __) => false,
          ))
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: imageAsync.when(
                  data: (imageUrl) {
                    if (imageUrl == null) {
                      return const SizedBox.shrink();
                    }
                    return Image.network(
                      imageUrl,
                      width: imageWidth,
                      height: imageWidth,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: imageWidth,
                          height: imageWidth,
                          color: Colors.grey.shade200,
                          child: const Center(
                            child: Icon(Icons.image_not_supported, size: 20),
                          ),
                        );
                      },
                    );
                  },
                  loading: () => Container(
                    width: imageWidth,
                    height: imageWidth,
                    color: Colors.grey.shade200,
                    child: const Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  ),
                  error: (_, __) => Container(
                    width: imageWidth,
                    height: imageWidth,
                    color: Colors.grey.shade200,
                    child: const Icon(Icons.error_outline, size: 20),
                  ),
                ),
              ),
            ),
          // テキスト
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '解説',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  explanation,
                  style: const TextStyle(
                    fontSize: 13,
                    height: 1.5,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
