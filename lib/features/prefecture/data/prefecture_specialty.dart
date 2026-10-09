/// 都道府県ID -> 名物イラストのファイル名(拡張子なし)。
/// 絵の名物名は表示しない(名称と絵が一致しない場合があるため)。
/// 富士山(fuji)は山梨/静岡共通のため使用しない。
const Map<String, String> kPrefectureSpecialtyFiles = {
  'aichi': 'aichi_tebasaki',
  'akita': 'akita_inu',
  'aomori': 'aomori_apple',
  'chiba': 'chiba_peanut',
  'ehime': 'ehime_mikan',
  'fukui': 'fukui_dinosaur',
  'fukuoka': 'fukuoka_ramen',
  'fukushima': 'fukushima_akabeko',
  'gifu': 'gifu_gassho',
  'gunma': 'gunma_daruma',
  'hiroshima': 'hiroshima_torii',
  'hokkaido': 'hokkaido_crab',
  'hyogo': 'hyogo_himeji',
  'ibaraki': 'ibaraki_melon',
  'ishikawa': 'ishikawa_wajima',
  'iwate': 'iwate_tetsubin',
  'kagawa': 'kagawa_udon',
  'kagoshima': 'kagoshima_sakurajima',
  'kanagawa': 'kanagawa_daibutsu',
  'kochi': 'kochi_katsuo',
  'kumamoto': 'kumamoto_suika',
  'kyoto': 'kyoto_pagoda',
  'mie': 'mie_pearl',
  'miyagi': 'miyagi_kokeshi',
  'miyazaki': 'miyazaki_mango',
  'nagano': 'nagano_snowmonkey',
  'nagasaki': 'nagasaki_castella',
  'nara': 'nara_deer',
  'niigata': 'niigata_rice',
  'oita': 'oita_onsen',
  'okayama': 'okayama_momo',
  'okinawa': 'okinawa_shisa',
  'osaka': 'osaka_takoyaki',
  'saga': 'saga_arita',
  'saitama': 'saitama_negi',
  'shiga': 'shiga_biwa',
  'shimane': 'shimane_shimenawa',
  'shizuoka': 'shizuoka_tea',
  'tochigi': 'tochigi_strawberry',
  'tokushima': 'tokushima_sudachi',
  'tokyo': 'tokyo_tower',
  'tottori': 'tottori_nashi',
  'toyama': 'toyama_tulip',
  'wakayama': 'wakayama_ume',
  'yamagata': 'yamagata_cherry',
  'yamaguchi': 'yamaguchi_fugu',
  'yamanashi': 'yamanashi_grape',
};

const String kPrefectureSpecialtyDir = 'assets/prefecture_specialty';

/// 名物イラストのアセットパス。無ければ null。
String? prefectureSpecialtyAsset(String prefectureId) {
  final f = kPrefectureSpecialtyFiles[prefectureId];
  return f == null ? null : '$kPrefectureSpecialtyDir/$f.webp';
}
