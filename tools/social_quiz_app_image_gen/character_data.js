// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 社会コレ！ マスコットキャラクター 画像生成用データ
// 男の子/女の子/動物/架空をミックスした16体構成（2026-08-17改訂）
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

// 共通ハウススタイル（全キャラ・全レベル共通で必ず末尾に付与）
const HOUSE_STYLE =
  'friendly semi-chibi elementary-school mascot character, warm rounded soft shapes, ' +
  'big sparkling expressive eyes, cheerful welcoming smile, Japanese kids-education-app illustration style, ' +
  'clean flat-cel shading with soft gradient highlights, thick clean outlines, vivid but soft colors, ' +
  'full body, front facing, centered composition, ' +
  'simple plain pastel background (single soft color, no scenery), ' +
  'no text, no logo, no watermark, no signature, no border';

const NEGATIVE_PROMPT = [
  'text, words, letters, numbers, watermark, signature, stamp, seal',
  'realistic photo, photorealistic, 3d render',
  'scary, horror, dark, creepy',
  'ugly, blurry, low quality, deformed, mutated, malformed',
  'extra limbs, bad anatomy, extra fingers, missing fingers',
  'adult body proportions, overly sexualized',
  'cropped, cut off, out of frame',
].join(', ');

// キャラクター定義: id / name / subject / appearance（外見の核となる要素・種族込み）
const CHARACTERS = [
  {
    id: 'mapple', name: 'マップル', subject: '地図記号',
    appearance:
      'a cheerful boy with fox-like ears and a fluffy tail, wearing a khaki explorer vest and a beret ' +
      'decorated with a compass rose pin, holding a rolled-up map, map-symbol motifs on his outfit',
  },
  {
    id: 'yukina', name: 'ユキナ', subject: '北海道・東北',
    appearance:
      'a small fluffy snow rabbit creature with round white-and-pale-blue fur, wearing a knitted scarf ' +
      'with a snowflake pattern, long floppy ears, rosy cheeks',
  },
  {
    id: 'haruka', name: 'はるか', subject: '関東・中部',
    appearance:
      'a girl with soft pink shoulder-length hair adorned with a cherry-blossom hairpin, ' +
      'wearing a light pink and white dress with a small Mt.Fuji-shaped brooch, holding a sakura branch',
  },
  {
    id: 'miyabi', name: 'みやび', subject: '近畿・中国・四国',
    appearance:
      'a graceful fox spirit (kitsune) wearing an elegant purple and gold kimono, with a small fox mask ' +
      'pushed up on her head and a golden castle-shaped hair ornament, holding a folding fan, fluffy fox tail',
  },
  {
    id: 'minori', name: 'みのり', subject: '農業',
    appearance:
      'a friendly scarecrow boy character made of straw and patched cloth, wearing a big straw hat, ' +
      'button eyes, holding a bundle of wheat ears, cheerful stitched smile',
  },
  {
    id: 'namika', name: 'なみか', subject: '水産業',
    appearance:
      'a cheerful dolphin creature standing upright, smooth turquoise-blue skin, wearing a sailor-style ' +
      'bandana, holding a small fishing net, playful bright eyes',
  },
  {
    id: 'geana', name: 'ギアナ', subject: '工業・工業地帯',
    appearance:
      'a small friendly robot child made of orange and gray metal panels, gear-shaped ears, safety-goggle ' +
      'eyes, wearing a tool belt, holding a small wrench, visible gears on chest',
  },
  {
    id: 'michiru', name: 'みちる', subject: '交通・情報化',
    appearance:
      'a sleek shinkansen-shaped spirit creature with a rounded white-and-blue nose-cone head, ' +
      'small wheel-like feet, red accent stripes, glowing signal-light eyes, holding a small smartphone',
  },
  {
    id: 'fumika', name: 'ふみか', subject: '古代・中世の歴史',
    appearance:
      'a girl with long dark brown hair tied with an ancient magatama-bead ornament, ' +
      'wearing a beige and brown ancient Japanese-inspired robe, holding an old scroll',
  },
  {
    id: 'tsubaki', name: 'つばき', subject: '江戸・幕末',
    appearance:
      'a young apprentice samurai boy with black hair tied up and a red hachimaki headband, ' +
      'wearing a navy-blue hakama-inspired outfit with a small wooden practice sword at his hip, determined confident look',
  },
  {
    id: 'haikara', name: 'はいから', subject: '明治・近代',
    appearance:
      'a stylish young gentleman boy wearing a Meiji-era western-inspired burgundy suit and a small top hat, ' +
      'holding a cane, round glasses, fashionable and cheerful',
  },
  {
    id: 'tera', name: 'テラ', subject: '国際・世界地理',
    appearance:
      'a tiny round spirit creature shaped like a friendly smiling globe, with continents drawn on its body ' +
      'like soft patchwork colors, small stubby arms and legs, tiny flag-pin antennae',
  },
  {
    id: 'seigi', name: 'せいぎ', subject: '憲法・三権分立',
    appearance:
      'a wise young owl character with neat navy-blue feathers, small round glasses, wearing a tiny judge-like ' +
      'collar, holding a small golden balance scale with both wings',
  },
  {
    id: 'takara', name: 'たから', subject: '税金・選挙',
    appearance:
      'a plump lucky tanuki (raccoon dog) character with a round belly, wearing a green vest, ' +
      'holding a cute piggy bank in one paw and a small ballot box in the other, mischievous friendly grin',
  },
  {
    id: 'michinori', name: 'みちのり', subject: '都道府県マスター',
    appearance:
      'a majestic young red-crowned crane character with elegant white-and-black feathers, wearing a small cape ' +
      'patterned with a stylized Japan map made of 47 colorful patches, confident traveler pose',
  },
  {
    id: 'shakai_star', name: 'シャカイスター', subject: '社会科完全マスター',
    appearance:
      'a legendary small star spirit with a radiant golden glowing body, flowing starlight trails, ' +
      'a tiny crown, faint constellation motifs drifting around it, the ultimate mascot form',
  },
];

// レベル別バリエーション定義（国語コレの5段階パターンを踏襲）
const LEVEL_VARIANTS = {
  lv1: {
    suffix: '',
    desc: (c) =>
      `A single character reference illustration of "${c.name}", ${c.appearance}. ` +
      'standing pose, warm gentle smile, welcoming introduction pose',
  },
  lv2: {
    suffix: '_lv2',
    desc: (c) =>
      `A joyful expression variant of "${c.name}" (same character design as base), ${c.appearance}. ` +
      'expression: huge delighted smile/expression, eyes sparkling with pure joy, celebrating a correct answer, same pose as base only happier',
  },
  lv3: {
    suffix: '_lv3',
    desc: (c) =>
      `A focused, thoughtful expression variant of "${c.name}" (same character design as base), ${c.appearance}. ` +
      'expression: focused with curiosity and concentration, thinking deeply about a quiz question, same body silhouette as base',
  },
  lv4: {
    suffix: '_lv4',
    desc: (c) =>
      `A dynamic action-pose variant of "${c.name}" (same character design as base), ${c.appearance}. ` +
      'pose: energetic action pose related to her/his/its subject, more dynamic body language than base',
  },
  lvmax: {
    suffix: '_lvmax',
    desc: (c) =>
      `A magical sparkling MAX-level variant of "${c.name}" (same character design as base), ${c.appearance}. ` +
      'surrounded by golden sparkles and a soft glowing aura, radiant confident proud expression, celebratory shining light effect, subject-themed light motifs floating around',
  },
};

module.exports = { CHARACTERS, LEVEL_VARIANTS, HOUSE_STYLE, NEGATIVE_PROMPT };
