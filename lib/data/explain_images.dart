/// 解説・学習画面に表示するAI生成の説明イラストのパス解決。
///
/// 画像は assets/images/explain/ 配下（quiz / learn / history / world）。
/// 画像が無い組み合わせは null を返し、呼び出し側は何も表示しない。
const Set<String> _kQuizKeys = {
  'civics_constitution',
  'civics_elections',
  'civics_local_government',
  'civics_national_assembly',
  'civics_separation_of_powers',
  'civics_taxes',
  'env_climate',
  'env_energy',
  'env_forest',
  'env_pollution',
  'env_recycle',
  'env_sdgs',
  'grade3_directions',
  'grade3_factory',
  'grade3_farming',
  'grade3_garbage',
  'grade3_old_life',
  'grade3_public_services',
  'grade3_supermarket',
  'grade4_disaster',
  'grade4_garbage_disposal',
  'grade4_geography',
  'grade4_local_features',
  'grade4_prefectures',
  'grade4_regions',
  'grade4_seasons',
  'grade4_water',
  'grade4_welfare',
  'industry_agriculture',
  'industry_fishery',
  'industry_food_self_sufficiency',
  'industry_industrial_zones',
  'industry_information_society',
  'industry_manufacturing',
  'industry_pollution',
  'world_capitals',
  'world_continents',
  'world_countries',
  'world_geography',
  'world_oceans',
};

const Set<String> _kLearnKeys = {
  'sdgs', 'seiji', 'senkyo', 'zeikin', 'sangyo', 'boeki', 'kankyo',
  'un', 'contribution', 'world_issues', 'culture',
};

const Set<String> _kHistoryKeys = {'yayoi', 'taisho', 'heisei_reiwa'};

/// クイズの category / subcategory から解説画像のアセットパスを返す。
String? quizExplainImage(String? category, String? subcategory) {
  if (category == null || subcategory == null) return null;
  final prefix = category == 'environment' ? 'env' : category;
  final key = '${prefix}_$subcategory';
  return _kQuizKeys.contains(key) ? 'assets/images/explain/quiz/$key.jpg' : null;
}

/// 学習セクション（sdgs, seiji, un など）の説明画像。
String? learnExplainImage(String id) =>
    _kLearnKeys.contains(id) ? 'assets/images/explain/learn/$id.jpg' : null;

/// 歴史の時代（yayoi, taisho, heisei_reiwa）の説明画像。
String? historyExplainImage(String eraId) => _kHistoryKeys.contains(eraId)
    ? 'assets/images/explain/history/$eraId.jpg'
    : null;

/// 世界の大陸（英語名: 'North America' 等）の説明画像。
String? worldExplainImage(String englishName) {
  final id = englishName.toLowerCase().replaceAll(' ', '_');
  const ids = {
    'asia', 'europe', 'africa', 'north_america', 'south_america', 'oceania'
  };
  return ids.contains(id) ? 'assets/images/explain/world/$id.jpg' : null;
}
