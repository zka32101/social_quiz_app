# 実装設計書① 日本一周マップ踏破システム

**優先度**: 🥇 最優先  
**推定工期**: 4-5日  
**実装モデル**: Haiku で十分  
**難易度**: 中程度（SVG + 状態管理）

---

## 1. 機能概要

### ユーザーストーリー
```
ユーザーがクイズに正解するたびに、
対応する都道府県がマップ上で色づいていく。
すべての都道府県をクリアすることが「ゲームの完全クリア」
```

### ゴール・メリット
| 観点 | 効果 |
|------|------|
| **学習効果** | 都道府県の位置が自動的に頭に入る |
| **継続性** | 「あと○県！」という視覚的進捗で次をやりたくなる |
| **差別化** | 桃鉄レベルの「地図×ゲーム」の快感が実装可能 |
| **UI映え** | Google Play スクリーンショットで最強視認性 |

---

## 2. データモデル設計

### 2.1 Quiz モデル拡張

```dart
@freezed
class Quiz with _$Quiz {
  const factory Quiz({
    required int id,
    required String question,
    required List<String> options,
    required int correctIndex,
    required String explanation,
    required String category,
    required int difficulty,
    
    // ========== NEW: マップ連動データ ==========
    required String? prefectureId,  // 都道府県コード（例："hokkaido"）
    required String? prefectureName, // 都道府県名（例："北海道"）
    // ==========================================
  }) = _Quiz;
}
```

**prefectureId の命名規則**:
```dart
"hokkaido"      // 北海道
"aomori"        // 青森県
"tokyo"         // 東京都
"osaka"         // 大阪府
// ... 47都道府県すべて
```

---

### 2.2 Prefecture（都道府県）モデル新規作成

```dart
@freezed
class Prefecture with _$Prefecture {
  const factory Prefecture({
    required String id,              // "hokkaido" など
    required String name,            // "北海道"
    required String region,          // "hokkaido", "tohoku", "kanto", ...
    required int cleared,            // 0=未クリア, 1=クリア
    required int questionCount,      // この県の出題数
    required int correctCount,       // この県で正解した数
    required DateTime? clearedAt,    // クリア日時
  }) = _Prefecture;
}
```

**地方区分**（バッジシステムに対応）:
```dart
enum Region {
  hokkaido,      // 北海道（1県）
  tohoku,        // 東北（6県）
  kanto,         // 関東（7県）
  chubu,         // 中部（9県）
  kansai,        // 関西（6県）
  chugoku,       // 中国（5県）
  shikoku,       // 四国（4県）
  kyushu,        // 九州・沖縄（8県）
}
```

---

### 2.3 SharedPreferences 保存スキーマ

```dart
// マップの状態をJSON保存
'app_pref_states'  // JSON: Map<String, int>
// 例: {"hokkaido": 1, "aomori": 0, "iwate": 1, ...}

// 地方別クリア状態
'app_region_cleared_[region]'
// 例: 'app_region_cleared_tohoku' -> int (0-6/6県)

// クリア日時
'app_pref_cleared_[id]'
// 例: 'app_pref_cleared_hokkaido' -> DateTime ISO文字列

// 全国クリア済みか（最終目標達成）
'app_all_prefectures_cleared'  // bool
```

---

## 3. UI/UX 設計

### 3.1 マップ画面レイアウト

```
┌─────────────────────────────────────┐
│  📍 日本全国制覇！                  │
│  ████████░░░░░░░░░░  25/47 都道府県│
└─────────────────────────────────────┘
│                                     │
│     【日本地図SVG表示エリア】        │
│                                     │
│  ┌──────────────────────────────┐  │
│  │                              │  │
│  │  北海道 (✓ 金色に輝く)      │  │
│  │  ┌────────────────┐         │  │
│  │  │                │ ← タップ可│  │
│  │  │  東北地方      │         │  │
│  │  │  ┌─────────────┐         │  │
│  │  │  │ 青森（✓）   │ ← 色付  │  │
│  │  │  │ 岩手（○）   │ ← グレー│  │
│  │  │  │ 秋田（✓）   │ ← 色付  │  │
│  │  │  │ 宮城（✓）   │ ← 色付  │  │
│  │  │  │ 山形（○）   │ ← グレー│  │
│  │  │  │ 福島（○）   │ ← グレー│  │
│  │  │  └─────────────┘         │  │
│  │  │                          │  │
│  │  │  ... 他の地方 ...         │  │
│  │  │                          │  │
│  │  └────────────────────────┘  │  │
│  └──────────────────────────────┘  │
│                                     │
└─────────────────────────────────────┘
```

### 3.2 地図の色分け

```dart
// 都道府県ごとの色設定
enum PrefectureStatus {
  locked,      // 未クリア → グレー（#CCCCCC）
  cleared,     // クリア → 青系（#2196F3）
  completed,   // 完全クリア（全問正解）→ 金色（#FFD700）
}

// 地方ごとのハイライト
bool isRegionComplete(String region) {
  // その地方の全県がクリアされた場合、
  // リージョン全体をボーダーで囲む
}
```

### 3.3 クリック・タップ動作

```dart
// SVG上の都道府県をタップ
onTap(prefectureId) {
  // ① 詳細ダイアログを表示
  showPrefectureDetail(prefectureId);
  
  // ② ダイアログ内容：
  // - 県名
  // - クリア状態（✓ or ○）
  // - この県で出題された問題数 / 正解数
  // - 「この県の問題をプレイ」ボタン
}
```

---

## 4. SVG 設計

### 4.1 地図ファイル

```
android/assets/maps/
├── japan_map.svg       # メイン地図（都道府県47分割）
├── hokkaido.svg        # 北海道（詳細地図・将来用）
└── regions/
    ├── tohoku.svg
    ├── kanto.svg
    ├── ...
```

### 4.2 SVG 構造例

```xml
<svg viewBox="0 0 1000 1400" xmlns="http://www.w3.org/2000/svg">
  <!-- 北海道 -->
  <path id="hokkaido" 
        d="M 500,50 L 600,80 L 580,150 ..."
        fill="#CCCCCC"
        stroke="#999"
        stroke-width="1"
        data-pref-id="hokkaido"
        data-pref-name="北海道"
  />
  
  <!-- 青森県 -->
  <path id="aomori"
        d="M 520,160 L 580,180 L 560,220 ..."
        fill="#CCCCCC"
        stroke="#999"
        stroke-width="1"
        data-pref-id="aomori"
        data-pref-name="青森県"
  />
  
  <!-- ... 他45県 ... -->
</svg>
```

### 4.3 SVG の色更新（Dart 側）

```dart
// SVG のパス要素の fill を動的に変更
void updatePrefectureColor(String prefId, Color color) {
  // 方法 A: SvgPicture + GestureDetector の組み合わせ
  // （簡易版）
  
  // 方法 B: WebView + JavaScript （複雑だがリッチ）
  
  // 推奨: flutter_svg パッケージ + ColorFilter
  SvgPicture.asset(
    'assets/maps/japan_map.svg',
    colorFilter: ColorFilter.mode(
      _getPrefectureColor(prefId),
      BlendMode.srcIn,
    ),
  );
}
```

**推奨実装: カスタム SvgPainter**

```dart
class JapanMapPainter extends CustomPainter {
  final Map<String, int> prefStatuses;  // prefId -> cleared (0/1)
  
  @override
  void paint(Canvas canvas, Size size) {
    // SVG をパース → 47県の Path を描画
    // 各パスの fill色は prefStatuses を参照
    
    for (String prefId in japanPrefectures) {
      Path path = japanMapPaths[prefId];
      Paint paint = Paint()
        ..color = prefStatuses[prefId] == 1 
            ? Colors.blue 
            : Colors.grey;
      canvas.drawPath(path, paint);
    }
  }
  
  @override
  bool shouldRepaint(JapanMapPainter oldDelegate) {
    return oldDelegate.prefStatuses != prefStatuses;
  }
}
```

---

## 5. 実装ステップ

### Phase 1: データ層（Day 1-2）

**Task 1.1: Quiz モデル拡張**
```dart
// lib/models/quiz.dart に prefectureId, prefectureName を追加
// 既存の4択問題すべてに都道府県タグを付与
```

**Task 1.2: Prefecture モデル作成**
```dart
// lib/models/prefecture.dart を新規作成
// Freezed で自動生成
```

**Task 1.3: SharedPreferences スキーマ実装**
```dart
// lib/services/map_service.dart を新規作成
// 都道府県ごとのクリア状態を保存・読込

class MapService {
  // クリア状態を取得
  Future<Map<String, int>> getPrefectureStates() async {
    final json = await _prefs.getString('app_pref_states');
    return json != null ? jsonDecode(json) : {};
  }
  
  // クリア状態を更新
  Future<void> setPrefectureCleared(String prefId) async {
    final states = await getPrefectureStates();
    states[prefId] = 1;
    await _prefs.setString('app_pref_states', jsonEncode(states));
  }
}
```

---

### Phase 2: UI 層（Day 2-3）

**Task 2.1: MapScreen 作成**
```dart
// lib/screens/map_screen.dart
class MapScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefectures = ref.watch(prefectureProvider);
    
    return Scaffold(
      appBar: AppBar(title: Text('日本全国制覇！')),
      body: Column(
        children: [
          // 進捗バー
          _buildProgressBar(prefectures),
          
          // 日本地図
          Expanded(
            child: InteractiveViewer(
              child: JapanMapWidget(
                prefectures: prefectures,
                onPrefectureTap: _showPrefectureDetail,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
```

**Task 2.2: JapanMapWidget（SVG描画）**
```dart
// lib/widgets/japan_map_widget.dart
class JapanMapWidget extends StatelessWidget {
  final List<Prefecture> prefectures;
  final Function(String) onPrefectureTap;
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (details) => _handleTap(details, context),
      child: CustomPaint(
        painter: JapanMapPainter(
          prefectures: prefectures,
        ),
        child: Container(),
      ),
    );
  }
}
```

**Task 2.3: PrefectureDetailDialog**
```dart
// lib/widgets/prefecture_detail_dialog.dart
class PrefectureDetailDialog extends StatelessWidget {
  final Prefecture prefecture;
  
  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(prefecture.name, style: Theme.of(context).textTheme.headlineSmall),
          Text('${prefecture.correctCount} / ${prefecture.questionCount} 正解'),
          ElevatedButton(
            onPressed: () => _playQuestionsByPrefecture(prefecture.id),
            child: Text('この県の問題をプレイ'),
          ),
        ],
      ),
    );
  }
}
```

---

### Phase 3: 問題データ付与（Day 3-4）

**Task 3.1: 既存問題に都道府県タグを付与**

```dart
// 例：既存の4択問題を修正

// Before
Quiz(
  id: 1,
  question: "日本の首都は？",
  options: ["東京", "大阪", "京都", "横浜"],
  correctIndex: 0,
  // ...
)

// After
Quiz(
  id: 1,
  question: "東京都の県庁所在地は？",
  options: ["東京", "横浜", "川崎", "さいたま"],
  correctIndex: 0,
  prefectureId: "tokyo",      // ← NEW
  prefectureName: "東京都",   // ← NEW
  // ...
)
```

**Task 3.2: 都道府県ごとの問題数を確認**
```
目標: 各県につき最低3問以上のクイズを用意

北海道: 5問
青森県: 3問
岩手県: 3問
...

問題が少ない県は新規問題を作成
```

---

### Phase 4: Riverpod Provider（Day 4）

**Task 4.1: PrefectureProvider 実装**

```dart
// lib/providers/prefecture_provider.dart

final mapServiceProvider = Provider((_) => MapService());

// 全都道府県の状態を取得
final prefecturesProvider = FutureProvider<List<Prefecture>>((ref) async {
  final mapService = ref.watch(mapServiceProvider);
  return await mapService.getAllPrefectures();
});

// 単一都道府県の状態を取得
final prefectureProvider = FutureProvider.family<Prefecture, String>((ref, prefId) async {
  final mapService = ref.watch(mapServiceProvider);
  return await mapService.getPrefecture(prefId);
});

// クリア進捗を取得
final mapProgressProvider = FutureProvider<int>((ref) async {
  final prefs = ref.watch(prefecturesProvider);
  return prefs.whenData((list) => list.where((p) => p.cleared == 1).length);
});
```

**Task 4.2: クイズ正解時のマップ更新**

```dart
// lib/providers/quiz_provider.dart に追加

final scoreNotifierProvider = StateNotifierProvider<ScoreNotifier, int>((ref) {
  return ScoreNotifier(ref);
});

class ScoreNotifier extends StateNotifier<int> {
  final Ref ref;
  
  ScoreNotifier(this.ref) : super(0);
  
  void addScore(int points, Quiz quiz) {
    state += points;
    
    // 都道府県をマーク
    if (quiz.prefectureId != null) {
      ref.read(mapServiceProvider).setPrefectureCleared(quiz.prefectureId!);
      
      // ProviderをリフレッシュしてUIを更新
      ref.refresh(prefecturesProvider);
    }
  }
}
```

---

## 6. バッジシステム統合（shared_core）

### 6.1 バッジ定義

```dart
// 地方別バッジ
"hokkaido_master"      // 北海道制覇
"tohoku_master"        // 東北制覇（6県すべてクリア）
"kanto_master"         // 関東制覇
"chubu_master"         // 中部制覇
"kansai_master"        // 関西制覇
"chugoku_master"       // 中国制覇
"shikoku_master"       // 四国制覇
"kyushu_master"        // 九州・沖縄制覇

// グローバルバッジ
"japan_complete"       // 日本全国制覇（全47都道府県）
```

### 6.2 バッジ獲得ロジック

```dart
void checkRegionCompletion(String region) {
  final regionPrefectures = prefecturesInRegion[region];
  final allCleared = regionPrefectures.every((p) => p.cleared == 1);
  
  if (allCleared) {
    badgeService.unlockBadge("${region}_master");
  }
}

void checkJapanCompletion() {
  if (prefectures.every((p) => p.cleared == 1)) {
    badgeService.unlockBadge("japan_complete");
    // 金色ウェーブアニメーション表示
  }
}
```

---

## 7. テスト計画

### 7.1 ユニットテスト
```dart
test('Prefecture model serialization', () {
  final pref = Prefecture(
    id: 'tokyo',
    name: '東京都',
    cleared: 1,
    // ...
  );
  expect(pref.id, 'tokyo');
});

test('MapService.setPrefectureCleared updates state', () async {
  final service = MapService();
  await service.setPrefectureCleared('tokyo');
  final states = await service.getPrefectureStates();
  expect(states['tokyo'], 1);
});
```

### 7.2 ウィジェットテスト
```dart
testWidgets('MapScreen shows progress bar', (WidgetTester tester) async {
  await tester.pumpWidget(testApp);
  expect(find.byType(LinearProgressIndicator), findsOneWidget);
});

testWidgets('Tapping prefecture shows dialog', (WidgetTester tester) async {
  await tester.pumpWidget(testApp);
  await tester.tap(find.byKey(Key('pref_tokyo')));
  await tester.pumpAndSettle();
  expect(find.byType(AlertDialog), findsOneWidget);
});
```

---

## 8. 実装チェックリスト

- [ ] Quiz モデルに prefectureId, prefectureName 追加
- [ ] Prefecture モデル作成・Freezed生成
- [ ] MapService 実装（SharedPreferences連携）
- [ ] MapScreen UI実装
- [ ] JapanMapWidget（SVG）実装
- [ ] PrefectureDetailDialog 実装
- [ ] 全問題に都道府県タグ付与（問題データレビュー）
- [ ] PrefectureProvider 実装
- [ ] クイズ正解時のマップ更新ロジック
- [ ] 地方別バッジシステム統合
- [ ] ユニットテスト実装
- [ ] ウィジェットテスト実装
- [ ] UI/UX ポーリッシング（色・アニメーション）
- [ ] Google Play スクリーンショット撮影

---

## 9. デザイン参考

### 色パレット
```
未クリア: #CCCCCC (Light Gray)
クリア: #2196F3 (Material Blue)
完全クリア: #FFD700 (Gold)
ホバー: #1976D2 (Darker Blue)
```

### アニメーション
```
県がクリアされた時: 
  1. フラッシュ（0.3秒）
  2. 色が徐々に濃くなる（0.5秒）
  3. 小さくスケール（1.05倍）

地方完全クリア時:
  1. 地方全体がゴールドに輝く（1秒）
  2. パーティクル効果（✨）
  3. バッジアンロック演出
```

---

**次ステップ**: Task #2 「③ きょうは何の日」設計書へ

