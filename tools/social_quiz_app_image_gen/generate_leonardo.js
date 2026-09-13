#!/usr/bin/env node
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 社会コレ！ マスコットキャラクター画像 一括生成（Leonardo.ai版）
// 16体 × 5レベル(lv1/lv2/lv3/lv4/lvmax) = 80枚
//
// コスト最小設定: alchemy:false, photoReal:false, num_images:1, 512x512
// 既存ファイルは自動スキップ（--allを何度実行しても未生成分だけ課金）
//
// 使い方（PowerShellで先に $env:LEONARDO_API_KEY をセットしてから）:
//   node generate_leonardo.js --sample                 # 先頭1体・lv1のみ（画風確認用、1枚だけ課金）
//   node generate_leonardo.js --ids mapple,yukina       # 指定キャラのみ（全レベル）
//   node generate_leonardo.js --ids mapple --levels lv1 # キャラ×レベルを絞る
//   node generate_leonardo.js --all                     # 残り全部（未生成分のみ）
//   node generate_leonardo.js --all --force             # 全部作り直す
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

const fs = require('fs');
const path = require('path');
const { CHARACTERS, LEVEL_VARIANTS, HOUSE_STYLE, NEGATIVE_PROMPT } = require('./character_data');

const LEONARDO_API_KEY = process.env.LEONARDO_API_KEY;
const LEONARDO_MODEL_ID = process.env.LEONARDO_MODEL_ID || 'de7d3faf-762f-48e0-b3b7-9d0ac3a3fcf3'; // Phoenix 1.0
const OUTPUT_DIR = 'H:\\マイドライブ\\images\\小学コレ！\\社会\\キャラクター';
const API_BASE = 'https://cloud.leonardo.ai/api/rest/v1';

function buildPrompt(character, levelKey) {
  const level = LEVEL_VARIANTS[levelKey];
  const prompt = [level.desc(character), HOUSE_STYLE].join(', ');
  return { prompt, negativePrompt: NEGATIVE_PROMPT };
}

async function generateImage(prompt, negativePrompt) {
  const createRes = await fetch(`${API_BASE}/generations`, {
    method: 'POST',
    headers: {
      Authorization: `Bearer ${LEONARDO_API_KEY}`,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      prompt,
      negative_prompt: negativePrompt,
      modelId: LEONARDO_MODEL_ID,
      width: 512,
      height: 512,
      num_images: 1,
      alchemy: false, // 高品質モード（コスト数倍）はオフ
      photoReal: false,
    }),
  });

  if (!createRes.ok) {
    throw new Error(`Leonardo API error (create): ${createRes.status} ${await createRes.text()}`);
  }

  const created = await createRes.json();
  const genId = created?.sdGenerationJob?.generationId;
  if (!genId) {
    throw new Error(`generationId が取得できませんでした: ${JSON.stringify(created)}`);
  }

  let attempts = 0;
  let images = null;
  while (attempts < 30) {
    await new Promise((r) => setTimeout(r, 2000));
    const poll = await fetch(`${API_BASE}/generations/${genId}`, {
      headers: { Authorization: `Bearer ${LEONARDO_API_KEY}` },
    });
    if (!poll.ok) {
      throw new Error(`Leonardo API error (poll): ${poll.status} ${await poll.text()}`);
    }
    const data = await poll.json();
    const gen = data.generations_by_pk;
    if (gen?.status === 'COMPLETE') {
      images = gen.generated_images;
      break;
    }
    if (gen?.status === 'FAILED') {
      throw new Error(`generation failed: ${JSON.stringify(gen)}`);
    }
    attempts++;
  }

  if (!images || !images[0]?.url) {
    throw new Error('画像生成がタイムアウトしました');
  }

  return images[0].url;
}

async function downloadTo(url, filePath) {
  const res = await fetch(url);
  if (!res.ok) throw new Error(`download failed: ${res.status}`);
  const buf = Buffer.from(await res.arrayBuffer());
  fs.writeFileSync(filePath, buf);
}

function parseArgs() {
  const args = process.argv.slice(2);
  const opts = { sample: false, ids: null, levels: null, all: false, force: false };
  for (let i = 0; i < args.length; i++) {
    if (args[i] === '--sample') opts.sample = true;
    else if (args[i] === '--ids') opts.ids = args[++i].split(',').map((s) => s.trim());
    else if (args[i] === '--levels') opts.levels = args[++i].split(',').map((s) => s.trim());
    else if (args[i] === '--all') opts.all = true;
    else if (args[i] === '--force') opts.force = true;
  }
  return opts;
}

async function main() {
  if (!LEONARDO_API_KEY) {
    console.error('❌ LEONARDO_API_KEY が設定されていません。');
    console.error('   例: $env:LEONARDO_API_KEY="xxxx"; node generate_leonardo.js --sample');
    process.exit(1);
  }

  const opts = parseArgs();
  const allLevelKeys = Object.keys(LEVEL_VARIANTS);

  let targetChars = opts.ids ? CHARACTERS.filter((c) => opts.ids.includes(c.id)) : CHARACTERS;
  let targetLevels = opts.levels ? opts.levels.filter((l) => allLevelKeys.includes(l)) : allLevelKeys;

  if (opts.sample) {
    targetChars = CHARACTERS.slice(0, 1);
    targetLevels = ['lv1'];
  }

  if (targetChars.length === 0) {
    console.error('❌ 対象キャラが見つかりません');
    process.exit(1);
  }

  // 生成対象一覧（キャラ×レベル）を組み立て
  const jobs = [];
  for (const c of targetChars) {
    for (const levelKey of targetLevels) {
      const suffix = LEVEL_VARIANTS[levelKey].suffix;
      const fileName = `${c.id}${suffix}.png`;
      jobs.push({ character: c, levelKey, fileName });
    }
  }

  fs.mkdirSync(OUTPUT_DIR, { recursive: true });
  const manifestPath = path.join(OUTPUT_DIR, 'manifest.json');
  const manifest = fs.existsSync(manifestPath) ? JSON.parse(fs.readFileSync(manifestPath, 'utf8')) : {};

  let skipped = 0;
  const toGenerate = opts.force
    ? jobs
    : jobs.filter((job) => {
        const exists = fs.existsSync(path.join(OUTPUT_DIR, job.fileName));
        if (exists) skipped++;
        return !exists;
      });

  if (skipped > 0) {
    console.log(`⏭️  既存の${skipped}枚をスキップ（再生成するには --force を付けてください）`);
  }
  console.log(
    `🎨 ${toGenerate.length} 枚を生成します（Leonardo.ai / modelId=${LEONARDO_MODEL_ID} / alchemy=off / 512x512）`
  );
  console.log(`📁 出力先: ${OUTPUT_DIR}\n`);

  for (const job of toGenerate) {
    const { character, levelKey, fileName } = job;
    process.stdout.write(`  ${character.id} (${character.name} / ${levelKey}) ... `);
    try {
      const { prompt, negativePrompt } = buildPrompt(character, levelKey);
      const imageUrl = await generateImage(prompt, negativePrompt);
      const outFile = path.join(OUTPUT_DIR, fileName);
      await downloadTo(imageUrl, outFile);
      manifest[fileName] = {
        characterId: character.id,
        name: character.name,
        subject: character.subject,
        level: levelKey,
        file: fileName,
        prompt,
        provider: 'leonardo',
        modelId: LEONARDO_MODEL_ID,
        generatedAt: new Date().toISOString(),
      };
      fs.writeFileSync(manifestPath, JSON.stringify(manifest, null, 2));
      console.log('✅');
    } catch (e) {
      console.log(`❌ ${e.message}`);
    }
  }

  console.log(`\n完了（生成${toGenerate.length}枚 / スキップ${skipped}枚）。出力先: ${OUTPUT_DIR}`);
}

main().catch((e) => {
  console.error(`❌ 予期しないエラー: ${e.message}`);
  process.exit(1);
});
