/// A single historical reference photo/illustration shown on an era's
/// detail screen, e.g. a photo of Jomon pottery for the 縄文時代 era.
class HistoryImageRef {
  /// Asset path. The file does not need to exist yet — see
  /// [HistoryReferenceGallery] in
  /// `lib/widgets/history_reference_gallery.dart`, which checks
  /// availability at runtime and silently skips missing images (and hides
  /// itself entirely if none of an era's images are available yet).
  final String assetPath;

  /// Short caption shown under the image, e.g. '縄文土器'.
  final String caption;

  /// Attribution text for CC-BY / CC-BY-SA licensed images (required by
  /// those licenses). Null for CC0 / public-domain images where no
  /// attribution is legally required.
  final String? credit;

  const HistoryImageRef({
    required this.assetPath,
    required this.caption,
    this.credit,
  });
}

/// Reference images awaiting sourcing, keyed by era id (matches
/// `_eraData` keys in `history_era_screen.dart`). Populate
/// `assets/history/` with files at these exact paths — see
/// `HANDOVER_HISTORY_IMAGES.md` for sourcing guidance (search keywords,
/// license requirements, recommended sources) and the license/credit
/// each entry should carry once sourced.
///
/// Eras not listed here (yayoi, taisho, heisei_reiwa) were judged to have
/// no single concrete, safely-licensable subject worth photographing —
/// see the handover doc for the reasoning.
Map<String, List<HistoryImageRef>> get kHistoryReferenceImages => {
      'jomon': const [
        HistoryImageRef(
          assetPath: 'assets/history/jomon_pottery.jpg',
          caption: '縄文土器',
        ),
        HistoryImageRef(
          assetPath: 'assets/history/jomon_dwelling.jpg',
          caption: '竪穴住居（復元）',
        ),
      ],
      'kofun': const [
        HistoryImageRef(
          assetPath: 'assets/history/kofun_haniwa.jpg',
          caption: '埴輪（はにわ）',
        ),
        HistoryImageRef(
          assetPath: 'assets/history/kofun_aerial.jpg',
          caption: '前方後円墳（航空写真）',
        ),
      ],
      'asuka': const [
        HistoryImageRef(
          assetPath: 'assets/history/asuka_horyuji.jpg',
          caption: '法隆寺（世界最古の木造建築）',
        ),
        HistoryImageRef(
          assetPath: 'assets/history/asuka_shotoku.jpg',
          caption: '聖徳太子の肖像画',
        ),
      ],
      'nara': const [
        HistoryImageRef(
          assetPath: 'assets/history/nara_daibutsu.jpg',
          caption: '東大寺の大仏',
        ),
      ],
      'heian': const [
        HistoryImageRef(
          assetPath: 'assets/history/heian_genji_scroll.jpg',
          caption: '源氏物語絵巻',
        ),
      ],
      'kamakura': const [
        HistoryImageRef(
          assetPath: 'assets/history/kamakura_mongol_scroll.jpg',
          caption: '蒙古襲来絵詞（元寇の様子）',
        ),
      ],
      'muromachi': const [
        HistoryImageRef(
          assetPath: 'assets/history/muromachi_kinkakuji.jpg',
          caption: '金閣寺',
        ),
      ],
      'azuchi': const [
        HistoryImageRef(
          assetPath: 'assets/history/azuchi_matchlock.jpg',
          caption: '火縄銃（種子島銃）',
        ),
      ],
      'edo': const [
        HistoryImageRef(
          assetPath: 'assets/history/edo_daimyo_procession.jpg',
          caption: '大名行列（参勤交代）の浮世絵',
        ),
        HistoryImageRef(
          assetPath: 'assets/history/edo_ieyasu.jpg',
          caption: '徳川家康の肖像画',
        ),
      ],
      'meiji': const [
        HistoryImageRef(
          assetPath: 'assets/history/meiji_ginza_bricktown.jpg',
          caption: '文明開化の頃の銀座煉瓦街',
        ),
      ],
      'showa': const [
        HistoryImageRef(
          assetPath: 'assets/history/showa_atomic_dome.jpg',
          caption: '原爆ドーム',
        ),
      ],
    };

/// Reference images for the given era id, or an empty list if none are
/// defined for that era.
List<HistoryImageRef> historyImagesFor(String eraId) =>
    kHistoryReferenceImages[eraId] ?? const [];
