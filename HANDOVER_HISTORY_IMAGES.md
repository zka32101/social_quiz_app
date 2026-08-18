# 社会コレ！歴史クイズ 資料画像 — 引き継ぎ書

**作成日**: 2026-08-18
**対象**: `social_quiz_app`（小学コレ！社会）の歴史クイズ（`lib/features/history/history_era_screen.dart`）
**状態**: アプリ側の受け皿（データ定義・表示ウィジェット・画面組み込み）は実装済み。**画像そのものの調達（検索・ライセンス確認・ダウンロード）だけが未着手**。

このセッションはネットワークポリシー上、一般の外部サイト（Wikimedia Commons・ColBase等）へのアクセスがブロックされており、画像の検索結果は得られてもページの閲覧・ダウンロードができない。そのため、インターネットに自由にアクセスできる環境（Windows版Claude Code等）での作業が必要で、この引き継ぎ書を作成した。

---

## 1. アプリ側はすでに実装済み（コード変更は不要）

- `lib/data/history_reference_images.dart` — 時代ID（`jomon`, `kofun`... など）ごとに、画像の**予定パス・キャプション・出典表記欄**を定義済み
- `lib/widgets/history_reference_gallery.dart` — 画像を横スクロールギャラリーで表示するウィジェット。**画像ファイルがまだ存在しない場合は自動的に何も表示しない**（クラッシュしない・壊れた画像アイコンも出ない）よう作ってある
- `lib/features/history/history_era_screen.dart` — 各時代の解説画面に上記ギャラリーを組み込み済み

→ **つまり、下記の画像ファイルを指定のパスに置くだけで、コードの変更なしに表示される。** 全部揃わなくてもよい。1枚も無ければ何も表示されないだけで、揃った時代から順に表示されていく。

---

## 2. 必要な画像一覧

保存先はすべて `social_quiz_app/assets/history/`。ファイル名は下表の通り**厳密に一致させること**（`lib/data/history_reference_images.dart` にハードコードされているため）。

| 時代ID | ファイル名 | キャプション | 検索キーワード例 | 推奨ソース |
|---|---|---|---|---|
| jomon | `jomon_pottery.jpg` | 縄文土器 | `縄文土器 深鉢形土器` | ColBase／Wikimedia Commons |
| jomon | `jomon_dwelling.jpg` | 竪穴住居（復元） | `竪穴住居 復元` | Wikimedia Commons |
| kofun | `kofun_haniwa.jpg` | 埴輪（はにわ） | `埴輪 円筒埴輪 人物埴輪` | ColBase（東京国立博物館蔵） |
| kofun | `kofun_aerial.jpg` | 前方後円墳（航空写真） | `大仙古墳 仁徳天皇陵 航空写真` | Wikimedia Commons |
| asuka | `asuka_horyuji.jpg` | 法隆寺（世界最古の木造建築） | `法隆寺 五重塔` | Wikimedia Commons |
| asuka | `asuka_shotoku.jpg` | 聖徳太子の肖像画 | `聖徳太子 唐本御影` | Wikimedia Commons（古美術・PD） |
| nara | `nara_daibutsu.jpg` | 東大寺の大仏 | `東大寺 大仏 盧舎那仏` | Wikimedia Commons |
| heian | `heian_genji_scroll.jpg` | 源氏物語絵巻 | `源氏物語絵巻 国宝` | Wikimedia Commons（PD） |
| kamakura | `kamakura_mongol_scroll.jpg` | 蒙古襲来絵詞（元寇の様子） | `蒙古襲来絵詞` | Wikimedia Commons（PD） |
| muromachi | `muromachi_kinkakuji.jpg` | 金閣寺 | `金閣寺 鹿苑寺` | Wikimedia Commons |
| azuchi | `azuchi_matchlock.jpg` | 火縄銃（種子島銃） | `火縄銃 種子島銃` | ColBase |
| edo | `edo_daimyo_procession.jpg` | 大名行列（参勤交代）の浮世絵 | `大名行列 浮世絵` | Wikimedia Commons（PD） |
| edo | `edo_ieyasu.jpg` | 徳川家康の肖像画 | `徳川家康 肖像画` | Wikimedia Commons（PD） |
| meiji | `meiji_ginza_bricktown.jpg` | 文明開化の頃の銀座煉瓦街 | `文明開化 銀座煉瓦街` | Wikimedia Commons（PD、100年超） |
| showa | `showa_atomic_dome.jpg` | 原爆ドーム | `原爆ドーム` | Wikimedia Commons（現代の風景写真、CC明記のもの） |

**意図的に対象外にした時代**: `yayoi`（卑弥呼は同時代の肖像が存在しない）、`taisho`、`heisei_reiwa`（抽象的な出来事・制度が中心で、単一の実在イメージが無い、または直近すぎて著作権リスクが高い）。無理に画像を探す必要はない。

**画像化を避けたもの（著作権・内容面でリスクが高い）**:
- 1964年東京五輪・東日本大震災の報道写真 → 撮影者の著作権が現存している可能性が高い
- 原爆ドームは「現代の建物としての風景写真」に限定し、被害の様子を写した歴史的写真は使わないこと（子ども向け教材としての配慮、かつ著作権的にも安全ではない）

---

## 3. ライセンスの確認方法（重要）

商用アプリ（課金・広告あり）なので、**下記のライセンスのものだけ**を使うこと：

- ✅ **CC0 / パブリックドメイン（PD）** — 帰属表示不要、自由に使える
- ✅ **CC BY / CC BY-SA** — 使えるが**帰属表示が必須**（下記参照）
- ❌ **CC BY-NC（非営利限定）** — 使用不可（このアプリは商用のため）
- ❌ **出典不明・「フリー素材」とだけ書かれたサイト** — 実際のライセンスを確認できない場合は使わない
- ❌ **Adobe Stock / PIXTA / アフロ等の有料ストックフォト** — 購入していない画像は使用不可

Wikimedia Commonsの各画像ページには必ずライセンスが明記されている（ページ下部の "Licensing" セクション）。ColBaseは基本的にCC BY 4.0（要帰属表示）。

### 帰属表示が必要な場合（CC BY / CC BY-SA）

`lib/data/history_reference_images.dart` の該当エントリに `credit:` を追記する。例：

```dart
HistoryImageRef(
  assetPath: 'assets/history/kofun_haniwa.jpg',
  caption: '埴輪（はにわ）',
  credit: '出典: ColBase（東京国立博物館）CC BY 4.0',
),
```

（`credit` が無い場合はCC0/PDとして帰属表示なしで表示される）

---

## 4. 作業手順まとめ

1. 上記キーワードでColBase／Wikimedia Commonsを検索し、CC0/PD/CC BY(-SA)の画像を選ぶ
2. `social_quiz_app/assets/history/` に、表の通りのファイル名で保存（揃わない時代があってもOK、後から追加できる）
3. CC BY/CC BY-SAの画像は `lib/data/history_reference_images.dart` の該当エントリに `credit:` を追記
4. `pubspec.yaml` の `flutter: assets:` に `- assets/history/` を追加
5. `flutter pub get` → `flutter analyze` → `flutter test` で確認
6. コミット・プッシュ（またはGitHub連携のあるセッションに引き継ぎ）

---

## 5. 動作確認のポイント

- 画像を1枚も置かなくてもアプリは正常に動く（ギャラリーが自動的に非表示になるだけ）
- 一部の時代だけ画像を置いた状態でも問題ない（置いた時代だけギャラリーが表示される）
- `test/widgets/history_reference_gallery_test.dart` に、画像あり/なし両方のケースのテストが既にある
