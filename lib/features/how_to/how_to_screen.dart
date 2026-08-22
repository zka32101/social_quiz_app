import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HowToScreen extends StatelessWidget {
  const HowToScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F9FF),
      appBar: AppBar(
        title: const Text('アプリの使い方'),
        centerTitle: true,
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
        children: const [
          // ── ようこそ ──────────────────────────────────────────
          _WelcomeCard(),
          SizedBox(height: 24),

          // ── 学習の流れ ────────────────────────────────────────
          _SectionTitle(title: '📚 学習の流れ', color: Color(0xFF1565C0)),
          SizedBox(height: 10),
          _StepsCard(),
          SizedBox(height: 24),

          // ── カテゴリ紹介 ──────────────────────────────────────
          _SectionTitle(title: '🎯 カテゴリ紹介', color: Color(0xFF2E7D32)),
          SizedBox(height: 10),
          _CategoryCard(
            emoji: '🗾',
            title: '都道府県クイズ',
            color: Color(0xFF1976D2),
            points: [
              '47都道府県の場所・特色・県庁所在地・特産品を学ぼう',
              'まずスタディカードで特徴を覚えてから4択クイズに挑戦！',
              '正解率90%以上で★★★（3スター）獲得！',
              '★3を集めると「都道府県マスター」バッジがもらえる',
              '全47都道府県を制覇するとレアキャラクターがアンロック！',
            ],
          ),
          SizedBox(height: 10),
          _CategoryCard(
            emoji: '📍',
            title: '小3 社会科',
            color: Color(0xFF0288D1),
            points: [
              '小学3年生の社会科教科書に対応したクイズ',
              '「地図記号」「方角・方位」「昔の道具・生活」の3テーマ',
              '消防署・警察・スーパーマーケットなど身近なしくみも学べる',
              '地図の読み方はテスト頻出！しっかり覚えよう',
            ],
          ),
          SizedBox(height: 10),
          _CategoryCard(
            emoji: '📖',
            title: '小4 社会科',
            color: Color(0xFF00897B),
            points: [
              '小学4年生の教科書に完全対応！',
              '「都道府県」「地方区分（8地方）」「山・川・湖」「気候・季節」',
              '「水道・下水道のしくみ」「災害・防災」の6テーマ',
              '地方マップで8つの地方と都道府県の位置関係を視覚的に学習',
              'テスト直前の総復習にもぴったり',
            ],
          ),
          SizedBox(height: 10),
          _CategoryCard(
            emoji: '🏭',
            title: '産業・農業',
            color: Color(0xFF558B2F),
            points: [
              '日本の農業・漁業・林業・工業のしくみを学ぼう',
              '食料自給率・主な農産物の産地・漁港の場所も出題',
              '自動車・電化製品などの工業製品と産地の関係も学べる',
              '公害問題・環境と産業のバランスについても解説',
            ],
          ),
          SizedBox(height: 10),
          _CategoryCard(
            emoji: '💴',
            title: '経済・政治',
            color: Color(0xFFAD1457),
            points: [
              '日本の税金のしくみ・社会保障・福祉について学ぼう',
              '円高・円安・貿易など経済の基礎知識も出題',
              '国会・内閣・裁判所の役割と三権分立のしくみ',
              '選挙のしくみ・憲法の条文についても詳しく解説',
            ],
          ),
          SizedBox(height: 10),
          _CategoryCard(
            emoji: '⚖️',
            title: '公民・政治',
            color: Color(0xFFC62828),
            points: [
              '日本国憲法の三大原則（国民主権・基本的人権・平和主義）',
              '国会のしくみ（衆議院・参議院）と主な仕事を覚えよう',
              '内閣・総理大臣の役割と内閣の組織',
              '裁判所の役割・司法・違憲立法審査権について',
              '選挙の種類・投票のしくみ・選挙権年齢も出題！',
            ],
          ),
          SizedBox(height: 10),
          _CategoryCard(
            emoji: '🏛️',
            title: '歴史',
            color: Color(0xFF6A1B9A),
            points: [
              '縄文・弥生時代から令和まで、時代ごとに体系的に学べる',
              '各時代の重要人物・出来事・文化・建物を詳しく解説',
              '年号の暗記に役立つ語呂合わせポイントも収録',
              '鎌倉幕府・江戸幕府・明治維新など節目の出来事も徹底カバー',
              '近現代史（戦争・高度成長・現代）まで対応！',
            ],
          ),
          SizedBox(height: 10),
          _CategoryCard(
            emoji: '🌐',
            title: '国際・世界との関係',
            color: Color(0xFF01579B),
            points: [
              '日本と関係の深い国々（アメリカ・中国・韓国・EU等）を学ぼう',
              '国連・UNICEF・WHOなど国際機関の役割も出題',
              '日本のODA（政府開発援助）・国際協力のしくみ',
              '世界の食料問題・貧困問題・難民問題についても解説',
            ],
          ),
          SizedBox(height: 10),
          _CategoryCard(
            emoji: '🌍',
            title: '世界の地理',
            color: Color(0xFF0277BD),
            points: [
              '六大陸（アジア・ヨーロッパ・アフリカ・北アメリカ・南アメリカ・オセアニア）を覚えよう',
              '三大洋（太平洋・大西洋・インド洋）の位置も出題',
              '世界40か国以上の国旗・首都・特色・文化を紹介',
              '「エベレスト山」「ナイル川」「サハラ砂漠」など世界の地形も！',
              '「🌏 クイズに挑戦！」ボタンで世界地理20問に挑戦できる',
            ],
          ),
          SizedBox(height: 10),
          _CategoryCard(
            emoji: '🌱',
            title: '環境・SDGs',
            color: Color(0xFF388E3C),
            points: [
              '地球温暖化のしくみ・原因・対策を詳しく学ぼう',
              '公害問題（四大公害病・水俣病・イタイイタイ病等）も出題',
              '3R（リデュース・リユース・リサイクル）のしくみと実践',
              'SDGs（持続可能な開発目標）17項目の内容を覚えよう',
              '再生可能エネルギー（太陽光・風力・水力）の種類と特徴',
              '森林保護・生物多様性・海洋プラスチック問題も解説',
            ],
          ),
          SizedBox(height: 24),

          // ── デイリーミッション ────────────────────────────────
          _SectionTitle(title: '📅 デイリーミッション', color: Color(0xFF00838F)),
          SizedBox(height: 10),
          _DailyMissionCard(),
          SizedBox(height: 24),

          // ── プロフィール ──────────────────────────────────────
          _SectionTitle(title: '👤 プロフィール機能', color: Color(0xFF4527A0)),
          SizedBox(height: 10),
          _ProfileCard(),
          SizedBox(height: 24),

          // ── ショップ & キャラクター ───────────────────────────
          _SectionTitle(title: '🛒 ショップ & キャラクター', color: Color(0xFFE65100)),
          SizedBox(height: 10),
          _ShopCard(),
          SizedBox(height: 24),

          // ── コインとバッジ ────────────────────────────────────
          _SectionTitle(title: '🪙 コイン・バッジ・スター', color: Color(0xFFF57F17)),
          SizedBox(height: 10),
          _CoinBadgeCard(),
          SizedBox(height: 24),

          // ── フレンド対戦 ──────────────────────────────────────
          _SectionTitle(title: '👥 フレンド対戦', color: Color(0xFF6A1B9A)),
          SizedBox(height: 10),
          _MultiplayerCard(),
          SizedBox(height: 24),

          // ── まちがい復習 ──────────────────────────────────────
          _SectionTitle(title: '📝 まちがい復習ノート', color: Color(0xFFE53935)),
          SizedBox(height: 10),
          _ReviewCard(),
          SizedBox(height: 24),

          // ── 学習のコツ ────────────────────────────────────────
          _SectionTitle(title: '💡 学習のコツ', color: Color(0xFF01579B)),
          SizedBox(height: 10),
          _TipsCard(),
          SizedBox(height: 24),

          // ── よくある質問 ──────────────────────────────────────
          _SectionTitle(title: '❓ よくある質問', color: Color(0xFF37474F)),
          SizedBox(height: 10),
          _FAQCard(),
          SizedBox(height: 24),

          // ── 保護者の方へ ──────────────────────────────────────
          _SectionTitle(title: '👪 保護者の方へ', color: Color(0xFF2E7D32)),
          SizedBox(height: 10),
          _ParentCard(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.pop(),
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.play_arrow_rounded),
        label: const Text(
          'さっそく始める！',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Parts
// ─────────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  final String title;
  final Color color;

  const _SectionTitle({required this.title, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 22,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────

class _WelcomeCard extends StatelessWidget {
  const _WelcomeCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1565C0), Color(0xFF1976D2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1565C0).withValues(alpha: 0.35),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '🗾 小学コレ！社会へようこそ！',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 12),
          Text(
            '社会科をゲーム感覚で楽しく学べるアプリです。\n'
            '都道府県・世界の国々・日本の歴史・産業・環境・政治など、'
            '小学3〜6年生の社会科を全て網羅しています！',
            style: TextStyle(fontSize: 13, color: Colors.white, height: 1.6),
          ),
          SizedBox(height: 16),
          _FeatureGrid(),
        ],
      ),
    );
  }
}

class _FeatureGrid extends StatelessWidget {
  const _FeatureGrid();

  @override
  Widget build(BuildContext context) {
    const items = [
      ('🎯', '600問以上収録'),
      ('🏆', 'バッジ・キャラクター収集'),
      ('👥', 'フレンドとリアルタイム対戦'),
      ('📝', 'まちがい復習ノート'),
      ('📅', 'デイリーミッション'),
      ('🌍', '世界地理も学べる'),
    ];
    return Wrap(
      spacing: 8,
      runSpacing: 6,
      children: items
          .map((item) => Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(item.$1, style: const TextStyle(fontSize: 13)),
                    const SizedBox(width: 4),
                    Text(
                      item.$2,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ))
          .toList(),
    );
  }
}

// ─────────────────────────────────────────────────────────────

class _StepsCard extends StatelessWidget {
  const _StepsCard();

  @override
  Widget build(BuildContext context) {
    const steps = [
      (
        num: '1',
        emoji: '👤',
        title: 'プロフィールを作る',
        desc: '初回起動時にニックネームと絵文字を設定。家族で使う場合は複数プロフィールを作れます！',
        color: Color(0xFF546E7A),
      ),
      (
        num: '2',
        emoji: '🗂️',
        title: 'カテゴリを選ぶ',
        desc: '「学習をはじめる」→カテゴリ一覧から都道府県・歴史・世界地理など好きなテーマを選ぼう',
        color: Color(0xFF1565C0),
      ),
      (
        num: '3',
        emoji: '📖',
        title: 'スタディカードで覚える',
        desc: 'クイズの前にスタディカードで重要ポイントをチェック！見るだけでどんどん知識が身につく',
        color: Color(0xFF00897B),
      ),
      (
        num: '4',
        emoji: '🎯',
        title: 'クイズに挑戦！',
        desc: '4択クイズに答えよう。正解・不正解どちらでも詳しい解説が表示されるから、間違えても学べる！',
        color: Color(0xFFF57F17),
      ),
      (
        num: '5',
        emoji: '⭐',
        title: 'スターで実力チェック',
        desc: '正解率で★1〜3が表示される。90%以上で★★★！まずは★2（60%）を目標にしよう',
        color: Color(0xFFFB8C00),
      ),
      (
        num: '6',
        emoji: '🪙',
        title: 'コイン & バッジを集めよう',
        desc: '正解するたびにコインがもらえる。条件を達成するとバッジも獲得！コインはショップで使おう',
        color: Color(0xFFE53935),
      ),
      (
        num: '7',
        emoji: '🔥',
        title: '毎日続けてストリーク！',
        desc: '毎日学習を続けると連続日数が増え、ボーナスコインがもらえる。デイリーミッションも忘れずに！',
        color: Color(0xFF6A1B9A),
      ),
    ];

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: steps.asMap().entries.map((entry) {
            final i = entry.key;
            final s = entry.value;
            return Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: s.color,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          s.num,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                s.emoji,
                                style: const TextStyle(fontSize: 18),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  s.title,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            s.desc,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF666666),
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (i < steps.length - 1) ...[
                  const SizedBox(height: 8),
                  const Padding(
                    padding: EdgeInsets.only(left: 15),
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      color: Color(0xFFCCCCCC),
                      size: 20,
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────

class _CategoryCard extends StatelessWidget {
  final String emoji;
  final String title;
  final Color color;
  final List<String> points;

  const _CategoryCard({
    required this.emoji,
    required this.title,
    required this.color,
    required this.points,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(14),
              ),
            ),
            child: Row(
              children: [
                Text(emoji, style: const TextStyle(fontSize: 26)),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
            child: Column(
              children: points
                  .map(
                    (p) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.check_circle_outline,
                            size: 16,
                            color: color,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              p,
                              style: const TextStyle(
                                fontSize: 13,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────

class _DailyMissionCard extends StatelessWidget {
  const _DailyMissionCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: const Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            _InfoRow(
              emoji: '📅',
              title: '今日の都道府県チャレンジ',
              desc:
                  'ホーム画面に毎日1つの都道府県が出題されます。'
                  'その日のうちにクイズをクリアすると「ミッション達成！」になり、'
                  'ボーナスコインがもらえます。翌日になると新しい都道府県が出題されます。',
            ),
            SizedBox(height: 12),
            _InfoRow(
              emoji: '🔥',
              title: 'ストリーク（連続日数）',
              desc:
                  '毎日学習するとストリークカウンターが増えます。'
                  '3日・7日・30日などの節目でボーナスコインが大量にもらえます！'
                  '1日でも学習をスキップするとストリークがリセットされるので注意。',
            ),
            SizedBox(height: 12),
            _InfoRow(
              emoji: '💡',
              title: '効率的な使い方',
              desc:
                  'デイリーミッションは毎日3〜5分で終わります。'
                  '朝起きたとき・学校から帰ったとき・寝る前など、'
                  'ルーティンに組み込むとストリークが続きやすくなります。',
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────

class _ProfileCard extends StatelessWidget {
  const _ProfileCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: const Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            _InfoRow(
              emoji: '👤',
              title: 'プロフィールを作る',
              desc:
                  '初回起動時にニックネームと好きな絵文字を選んでプロフィールを作ります。'
                  'ニックネームとアイコン絵文字はいつでも変更できます。',
            ),
            SizedBox(height: 12),
            _InfoRow(
              emoji: '👨‍👩‍👧‍👦',
              title: '複数プロフィール（家族で使える！）',
              desc:
                  '1台のスマートフォンで最大4人分のプロフィールを作れます。'
                  '兄弟・家族それぞれが別々のプロフィールで学習できるので、'
                  'コインやバッジが混ざりません。切り替えはホーム右上のアイコンから。',
            ),
            SizedBox(height: 12),
            _InfoRow(
              emoji: '🔄',
              title: 'プロフィール切り替え',
              desc:
                  'ホーム画面の右上にある人物アイコン（👤）をタップすると'
                  'プロフィール切替画面に移ります。'
                  '使いたいプロフィールを選ぶだけで即座に切り替わります。',
            ),
            SizedBox(height: 12),
            _InfoRow(
              emoji: '💾',
              title: 'データの保存',
              desc:
                  'プロフィールごとにコイン・バッジ・クイズ進捗・'
                  'まちがいノートが別々に保存されます。'
                  'スマートフォンを変える場合はFirebaseアカウントでデータを引き継げます。',
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────

class _ShopCard extends StatelessWidget {
  const _ShopCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: const Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            _InfoRow(
              emoji: '🛒',
              title: 'ショップの開き方',
              desc:
                  'ホーム画面右上のショッピングカートアイコン（🛒）をタップすると'
                  'ショップが開きます。コインで様々なアイテムを購入できます！',
            ),
            SizedBox(height: 12),
            _InfoRow(
              emoji: '🎩',
              title: 'キャラクターアイテム（帽子・アクセサリー）',
              desc:
                  'キャラクターにかぶせる帽子やアクセサリーをコインで購入できます。'
                  'レアなアイテムほど多くのコインが必要。まずは基本アイテムから集めよう！',
            ),
            SizedBox(height: 12),
            _InfoRow(
              emoji: '🖼️',
              title: '背景・フレーム',
              desc:
                  'プロフィール画面の背景やカードのフレームを変更できます。'
                  '季節ごとの限定背景なども登場します。',
            ),
            SizedBox(height: 12),
            _InfoRow(
              emoji: '🎵',
              title: 'BGM・効果音',
              desc:
                  'クイズ中のBGMを変更できます。'
                  '集中できる静かなBGMや、テンションが上がるBGMなど種類が豊富！',
            ),
            SizedBox(height: 12),
            _InfoRow(
              emoji: '🦸',
              title: 'キャラクターのアンロック',
              desc:
                  '都道府県クイズを全47都道府県でクリアしたり、'
                  '特定のバッジを取得すると新しいキャラクターがアンロックされます。'
                  'キャラクター画面（顔アイコン）で収集状況を確認しよう！',
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────

class _CoinBadgeCard extends StatelessWidget {
  const _CoinBadgeCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: const Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            _InfoRow(
              emoji: '🪙',
              title: 'コインのもらい方',
              desc:
                  'クイズで正解するたびにコインがもらえます。'
                  '連続正解や高得点（★3）ではボーナスコインがつきます。'
                  'デイリーミッション達成やストリーク更新でも大量にもらえます！',
            ),
            SizedBox(height: 12),
            _InfoRow(
              emoji: '🏅',
              title: 'バッジの種類',
              desc:
                  '「地理」「クイズ」「ストリーク」「コレクション」「マスター」など'
                  '6カテゴリに分けて多数のバッジが用意されています。'
                  '「都道府県マスター」「歴史博士」など称号バッジも多数！',
            ),
            SizedBox(height: 12),
            _InfoRow(
              emoji: '⭐',
              title: 'スター判定のしくみ',
              desc:
                  'クイズの正解率で★1〜3が決まります。\n'
                  '★★★（3つ星）: 正解率90%以上\n'
                  '★★（2つ星）: 正解率60〜89%\n'
                  '★（1つ星）: 正解率30〜59%\n'
                  '何度でも挑戦して記録を更新できます。',
            ),
            SizedBox(height: 12),
            _InfoRow(
              emoji: '🔥',
              title: '連続学習ストリーク',
              desc:
                  '毎日アプリを開いてクイズに挑戦すると連続日数（ストリーク）が増えます。'
                  '3日・7日・14日・30日・100日の節目でスペシャルボーナスがもらえます。'
                  '1日でも休むとリセットされるので注意しましょう！',
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────

class _MultiplayerCard extends StatelessWidget {
  const _MultiplayerCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: const Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            _InfoRow(
              emoji: '🔍',
              title: '対戦相手の探し方',
              desc:
                  'ホーム画面の「フレンドと対戦」ボタンをタップするとマッチメイキング画面に移ります。'
                  'オンライン中のプレイヤー一覧が表示されるので、対戦したい相手を選んで「申し込む」を押そう。',
            ),
            SizedBox(height: 12),
            _InfoRow(
              emoji: '⚔️',
              title: '対戦のルール',
              desc:
                  '同じクイズを同時に10問解いて正解数を競います。'
                  '制限時間内に多く正解した方が勝ち！'
                  '同点の場合は回答速度で決まります。',
            ),
            SizedBox(height: 12),
            _InfoRow(
              emoji: '📊',
              title: 'Eloレーティング',
              desc:
                  '対戦するたびにレーティングポイントが変わります。'
                  '勝てばポイントアップ、負けると減少。'
                  '強い相手に勝つほど大きく上昇し、弱い相手に負けるほど大きく下がります。',
            ),
            SizedBox(height: 12),
            _InfoRow(
              emoji: '🏆',
              title: 'ランキング',
              desc:
                  'ホーム画面の「ランキングを見る」から全国ランキングを確認できます。'
                  '総獲得ポイント・勝率・レーティングで競い合おう！'
                  'トップ10に入ると特別なバッジがもらえます。',
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────

class _ReviewCard extends StatelessWidget {
  const _ReviewCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: const Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            _InfoRow(
              emoji: '📝',
              title: 'まちがい復習ノートとは？',
              desc:
                  'クイズで間違えた問題が自動的に「まちがい復習ノート」に保存されます。'
                  'ホーム画面に赤いカードが表示されたら復習のサインです。'
                  '復習した問題を正解すると、ノートから削除されます。',
            ),
            SizedBox(height: 12),
            _InfoRow(
              emoji: '🔁',
              title: '何度でも繰り返し復習',
              desc:
                  'まちがい復習ノートには同じ問題が何度でも追加されます。'
                  '苦手な問題ほどノートに蓄積されるので、'
                  '定期的に復習して弱点を潰していこう！',
            ),
            SizedBox(height: 12),
            _InfoRow(
              emoji: '💡',
              title: '解説を活用しよう',
              desc:
                  'クイズに答えると、正解・不正解に関わらず詳しい解説が表示されます。'
                  '解説にはテストに出やすいポイントがまとめてあります。'
                  '読むだけで記憶に定着しやすくなります！',
            ),
            SizedBox(height: 12),
            _InfoRow(
              emoji: '📈',
              title: '効果的な復習タイミング',
              desc:
                  '間違えたその日のうちに1回復習し、翌日・3日後・7日後に'
                  '再び確認すると記憶に残りやすいです（間隔反復学習法）。'
                  'まちがい復習ノートを毎日チェックする習慣をつけよう！',
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────

class _TipsCard extends StatelessWidget {
  const _TipsCard();

  @override
  Widget build(BuildContext context) {
    const tips = [
      (emoji: '📅', text: '毎日5〜10分でOK！短い時間でもコツコツ続けることが大切'),
      (emoji: '🗺️', text: '都道府県は地方マップで場所から覚えると効率的。まず8つの地方を覚えよう'),
      (emoji: '📖', text: 'クイズ前にスタディカードをしっかり読もう。正解率が格段に上がる'),
      (emoji: '❌', text: '間違えた問題はすぐに復習！「なぜ間違えたのか」を理解することが大事'),
      (emoji: '⭐', text: 'まず★2（60%）を目標に。慣れてきたら★3（90%）にチャレンジ！'),
      (emoji: '🔥', text: 'ストリークを途切れさせないよう、毎日少しでもアプリを開こう'),
      (emoji: '👫', text: 'フレンドと対戦すると競争意識が生まれて楽しく続けられる'),
      (emoji: '🏆', text: 'バッジ・キャラクター集めをモチベーションに！全コンプを目指そう'),
      (emoji: '📊', text: 'ランキングを定期的にチェック。順位の変動で自分の成長がわかる'),
      (emoji: '🌍', text: '世界地理は世界ニュースを見るときの理解力もアップする！'),
    ];

    return Card(
      elevation: 1,
      color: const Color(0xFFFFF8E1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'ポイント',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Color(0xFFF57F17),
              ),
            ),
            const SizedBox(height: 8),
            ...tips.map(
              (t) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(t.emoji, style: const TextStyle(fontSize: 16)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        t.text,
                        style: const TextStyle(fontSize: 13, height: 1.4),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────

class _FAQCard extends StatelessWidget {
  const _FAQCard();

  @override
  Widget build(BuildContext context) {
    const faqs = [
      (
        q: 'コインがなくなった場合は？',
        a: 'クイズに正解し続けることでコインは増えていきます。'
            'デイリーミッション達成やストリーク継続でボーナスコインも獲得できます。'
            '無課金でも十分なコインを集められます！',
      ),
      (
        q: 'バッジの条件がわからない',
        a: 'バッジ画面（🏅アイコン）を開くと、各バッジの取得条件が表示されています。'
            '「?」のバッジは条件を達成すると内容が明らかになるシークレットバッジです。',
      ),
      (
        q: 'スタディカードをスキップしてクイズだけやりたい',
        a: 'スタディカード画面で「スキップ」ボタンを押すとすぐにクイズに進めます。'
            'ただし初めて学ぶカテゴリはカードを読んでからの方がスコアが上がりやすいです。',
      ),
      (
        q: '間違えたのにノートに保存されない',
        a: 'まちがい復習ノートは4択クイズのみ対応しています。'
            '一部のミニゲーム形式の問題は対象外の場合があります。',
      ),
      (
        q: 'アプリの音を消したい',
        a: '設定画面（⚙️アイコン）からBGMと効果音をそれぞれOFF/ONにできます。'
            '学校や図書館で使う場合はマナーモードにするか、設定でOFFにしましょう。',
      ),
      (
        q: '友達と対戦できない',
        a: '対戦するには双方がオンライン状態である必要があります。'
            'Wi-Fi環境で使うと安定した対戦ができます。'
            'また相手が別の画面を開いている場合はマッチメイキングに表示されません。',
      ),
    ];

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: faqs
              .map(
                (faq) => _FAQItem(q: faq.q, a: faq.a),
              )
              .toList(),
        ),
      ),
    );
  }
}

class _FAQItem extends StatefulWidget {
  final String q;
  final String a;

  const _FAQItem({required this.q, required this.a});

  @override
  State<_FAQItem> createState() => _FAQItemState();
}

class _FAQItemState extends State<_FAQItem> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: () => setState(() => _open = !_open),
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              children: [
                const Text(
                  'Q.',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1565C0),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    widget.q,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Icon(
                  _open ? Icons.expand_less : Icons.expand_more,
                  color: Colors.grey.shade500,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
        if (_open)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 0, 10),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F9FF),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                widget.a,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF555555),
                  height: 1.6,
                ),
              ),
            ),
          ),
        const Divider(height: 1),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────

class _ParentCard extends StatelessWidget {
  const _ParentCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      color: const Color(0xFFF1F8E9),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: const Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '保護者の方へ',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2E7D32),
              ),
            ),
            SizedBox(height: 12),
            _InfoRow(
              emoji: '📚',
              title: '学習内容について',
              desc:
                  '本アプリは小学校の学習指導要領に沿った内容で構成されています。'
                  '小学3〜6年生の社会科（地理・歴史・公民・産業・環境・世界）を'
                  '網羅しており、学校のテスト対策・予習・復習に活用できます。',
            ),
            SizedBox(height: 12),
            _InfoRow(
              emoji: '🔒',
              title: 'プライバシーとデータ',
              desc:
                  '氏名・住所・電話番号など個人を特定する情報は一切収集しません。'
                  '学習データはFirebase（Googleのサービス）に暗号化して保存されます。'
                  'お子様の安全のため、個人情報を入力しないよう指導をお願いします。',
            ),
            SizedBox(height: 12),
            _InfoRow(
              emoji: '💰',
              title: 'アプリ内課金について',
              desc:
                  '基本機能は無料でご利用いただけます。'
                  '広告非表示・追加コンテンツのためのプレミアムプラン（有料）があります。'
                  'お子様が誤って購入しないよう、端末の購入制限設定をご利用ください。',
            ),
            SizedBox(height: 12),
            _InfoRow(
              emoji: '⏱️',
              title: '利用時間の目安',
              desc:
                  'デイリーミッションは1日5〜10分程度で完了します。'
                  '学習効果を高めるには毎日短時間継続することをおすすめします。'
                  '長時間連続使用よりも、複数回に分けた利用が記憶の定着に効果的です。',
            ),
            SizedBox(height: 12),
            _InfoRow(
              emoji: '📧',
              title: 'お問い合わせ',
              desc:
                  'ご不明な点・不具合・ご要望は\n'
                  'yourwishdev@gmail.com\nまでご連絡ください。',
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────

class _InfoRow extends StatelessWidget {
  final String emoji;
  final String title;
  final String desc;

  const _InfoRow({
    required this.emoji,
    required this.title,
    required this.desc,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(emoji, style: const TextStyle(fontSize: 22)),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                desc,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF555555),
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
