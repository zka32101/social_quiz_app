import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import '../data/history_reference_images.dart';

/// A horizontal gallery of historical reference photos for an era detail
/// screen (縄文土器, 法隆寺, etc.) — see `history_reference_images.dart`.
///
/// Images are sourced by hand (see `HANDOVER_HISTORY_IMAGES.md`) and may
/// not exist yet. This widget checks each [images] entry's asset
/// availability at runtime via [rootBundle.load] and silently drops any
/// that fail to load, rather than showing a broken-image icon. If none of
/// the given images are available, the whole gallery renders nothing
/// (`SizedBox.shrink()`) so an empty "参考画像" card never appears before
/// the images have been added.
class HistoryReferenceGallery extends StatefulWidget {
  final List<HistoryImageRef> images;
  final Color accentColor;

  const HistoryReferenceGallery({
    super.key,
    required this.images,
    required this.accentColor,
  });

  @override
  State<HistoryReferenceGallery> createState() =>
      _HistoryReferenceGalleryState();
}

class _HistoryReferenceGalleryState extends State<HistoryReferenceGallery> {
  late Future<List<HistoryImageRef>> _availableFuture;

  @override
  void initState() {
    super.initState();
    _availableFuture = _resolveAvailable(widget.images);
  }

  @override
  void didUpdateWidget(HistoryReferenceGallery old) {
    super.didUpdateWidget(old);
    if (old.images != widget.images) {
      _availableFuture = _resolveAvailable(widget.images);
    }
  }

  static Future<List<HistoryImageRef>> _resolveAvailable(
    List<HistoryImageRef> refs,
  ) async {
    final available = <HistoryImageRef>[];
    for (final ref in refs) {
      try {
        await rootBundle.load(ref.assetPath);
        available.add(ref);
      } catch (_) {
        // まだ画像が用意されていない参照は静かにスキップする。
      }
    }
    return available;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.images.isEmpty) return const SizedBox.shrink();

    return FutureBuilder<List<HistoryImageRef>>(
      future: _availableFuture,
      builder: (context, snapshot) {
        final available = snapshot.data;
        if (available == null || available.isEmpty) {
          return const SizedBox.shrink();
        }
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.photo_library_outlined,
                        color: widget.accentColor, size: 20),
                    const SizedBox(width: 8),
                    const Text(
                      '参考画像',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const Divider(height: 16),
                SizedBox(
                  height: 150,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: available.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (context, i) => _ImageTile(ref: available[i]),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ImageTile extends StatelessWidget {
  final HistoryImageRef ref;
  const _ImageTile({required this.ref});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 130,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(
              ref.assetPath,
              width: 130,
              height: 100,
              fit: BoxFit.cover,
              // 直前に rootBundle.load() で存在確認済みだが、念のため
              // ここでも壊れた画像に対して安全側に倒す。
              errorBuilder: (context, error, stackTrace) =>
                  const SizedBox.shrink(),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            ref.caption,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (ref.credit != null)
            Text(
              ref.credit!,
              style: const TextStyle(fontSize: 8, color: Colors.grey),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
        ],
      ),
    );
  }
}
