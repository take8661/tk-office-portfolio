# Handoff: TK Office ポートフォリオサイト

> **Purpose:** 面接・採用の場で、自分の実績と実装力を証明するための **1ページ完結型ポートフォリオサイト** です。想定読者は「クライアント候補」ではなく **採用担当者・面接官** です。

---

## Overview

TK Office（竹村直人 / 札幌）の個人ポートフォリオサイト。

- **経営者としての実績**（自営業 10年以上）
- **エンタープライズITインフラの運用実務**（MECM / WSUS）
- **生成AI × 業務自動化の実装記録**（試作・実証プロジェクト 13件）

これら3層のキャリアを、1ページのランディング形式で **時系列＋領域別** に提示するサイトです。

**サイトの目的（重要 — 用途変更あり）：**

- ❌ 案件受注のためのランディングページ（旧用途）
- ✅ **採用面接で「これだけ作ってきた人」であることを示すポートフォリオ**（現在の用途）

そのため文言は営業トーン（〜を提供します／ご相談ください）ではなく、実績棚卸しトーン（〜を設計・構築してきました／実装経験があります）で統一しています。

主力アピールは:
- **SNS Factory**（Group A の Featured Work）— 収集 → 生成 → 承認 → 投稿 → 計測まで自動化する個人開発の統合ワークスペース
- **13件の試作・実証プロジェクト** を3グループに整理して提示
- **経営 → EC → SE → 生成AI** という一貫したキャリアストーリー

---

## About the Design Files

このバンドルに含まれる HTML/JSX ファイルは **デザインリファレンス（プロトタイプ）** です。
最終的なコードとしてそのままデプロイする想定ではなく、**「意図する見た目・情報構造・振る舞いのお手本」** として扱ってください。

タスクは、これらの HTML デザインを、対象コードベースの既存環境（React / Next.js / Astro / Vue / SvelteKit など）で **再現** することです。

既存の環境がまだ無い場合は、案件の目的に最適なフレームワークを選定して実装してください：

- **推奨1:** **Astro**（1ページ静的サイトに最適・JSほぼゼロで軽量）
- **推奨2:** **Next.js（SSG モード）**（既存の React エコシステムがある場合）
- **推奨3:** **素の HTML + CSS**（そのまま最小改変で運用したい場合）

Tweaks Panel（`reference/tweaks_panel.jsx`）は **開発中のデザインバリエーション切替 UI** であり、**本番デプロイ時は削除して構いません**。

---

## Fidelity

**High-fidelity（ハイファイ）** です。以下は完成度の高いモックとして扱ってください。

- ✅ 最終的な配色・タイポグラフィ・スペーシング決定済み
- ✅ 具体的なコピーライティング本番相当
- ✅ インタラクション（スクロールリビール・ナビ挙動）本番想定
- ✅ Google Fonts（Noto Sans JP / Noto Serif JP / Inter / JetBrains Mono）読み込み済み
- ✅ Featured Work（SNS Factory）のパイプライン図・モジュール表・トリガー表まで作り込み済み

ただし以下は「意図した最終形の再現」であり、コード実装は既存コードベースの規約（TypeScript / JSX 命名・スタイル方式）に合わせてください。

---

## Screens / Views

**1画面（Single Page）** で構成。全セクションは同一ページ内でアンカーリンク（`#about`、`#services` 等）でジャンプします。

### セクション一覧（上から順）

| # | セクション | ID | 目的 |
|---|---|---|---|
| 1 | Nav（グローバルヘッダー） | — | 常時固定のナビ。スクロールで下線が出る |
| 2 | Hero | `#top` | 第一印象・キャッチコピー・プロフィールカード |
| 3 | About | `#about` | 自己紹介本文と実績スタッツ（2カラム数字） |
| 4 | Capabilities（旧 Services） | `#services` | できること／専門領域 3種（AI導入設計 / AIワークフロー開発 / 生成AI制作実務） |
| 5 | Works | `#works` | 試作・実証プロジェクト13件（3グループ制） |
| 6 | Career | `#career` | タイムライン形式の経歴（2014〜現在） |
| 7 | Skills | `#skills` | 触れてきた技術スタック4カテゴリ |
| 8 | Contact | `#contact` | 面接補足の連絡先（軽トーン） |
| 9 | Footer | — | コピーライト |
| 10 | Tweaks Panel（開発用） | — | デザインバリエーション切替 UI（本番デプロイ時は削除） |

---

### 1. Nav

- **要素:** ブランドロゴ（TK Office · Naoto Takemura · Sapporo）／ナビリンク（About・Services・Works・Career・Contact）／CTA ボタン「Contact →」
- **挙動:**
  - `position: fixed; top: 0;` で常時固定
  - スクロール量 40px 超で `.scrolled` クラス付与 → 下部に 1px ボーダー、パディング縮小
  - ナビリンクにホバー時、下線が左からスケールインするアンダーラインアニメーション（`::after` + `transform: scaleX()` + `transform-origin: left`）
  - 背景は `color-mix(in oklab, var(--bg) 85%, transparent)` + `backdrop-filter: blur(12px)`
- **レスポンシブ:** `max-width: 820px` でナビリンクを非表示（ブランドと CTA のみ表示）
- **注意:** CTA ボタンのラベルは **「Contact →」**（旧「お問い合わせ →」）— 面接向けの中立表現に変更済み

---

### 2. Hero (`#top`)

**目的:** ページを開いた瞬間、「この人は経営視点を持った生成AI実装者だ」と分かること。

- **レイアウト:** `grid-template-columns: 1.4fr 1fr;` の2カラム（左：見出しコピー、右：プロフィールカード）
- **左カラム内容:**
  - Eyebrow（モノスペース、パルスドット付き）: **`PORTFOLIO · 生成AI × 業務自動化 · 実装実績まとめ`**
  - H1（Serif, `clamp(40px, 6.2vw, 78px)`）: **「経営者の視点で、生成AI を使いこなす。」**
    - 「生成AI」に `.accent` クラス、下部に金色の下線ハイライト（`::after` 疑似要素 + `color-mix`）
  - Lede（本文リード、`font-size: 17px; line-height: 1.9`）:
    - 「10年以上の自営業経験と、エンタープライズITインフラの運用実務。」
    - 「そこに生成AIを掛け合わせ、業務自動化ツール・SNS運用パイプライン・」
    - 「画像／文章／リサーチ支援まで、自分で設計・実装してきた記録です。」
  - CTA ボタン2つ:
    - **Primary:** 「実装実績を見る」→ `#works`
    - **Outline:** 「経歴を見る」→ `#career`
- **右カラム（プロフィールカード）:**
  - 白背景カード、左上に `PROFILE` タグ（Mono, uppercase）
  - 5行のプロファイル表（KEY | VAL、点線区切り）:
    - `NAME` / **竹村 直人** Naoto Takemura
    - `ROLE` / AI活用ジェネラリスト（生成AIで業務課題を解く実装者）
    - `BASE` / 北海道 札幌市
    - `SINCE` / 2014 — 自営業歴 10年以上
    - `CERT` / 生成AIパスポート（2026年3月取得）／AIストラテジスト資格 学習中
- **背景装飾:** 右上に `radial-gradient` の柔らかいアクセントカラーグロー
- **重要な文言変更:**
  - Eyebrow: `AVAILABLE · 開発案件を受付中` → `PORTFOLIO · 実装実績まとめ`
  - CTA主: `相談してみる` → `実装実績を見る`
  - Lede: 営業訴求 → 実績棚卸しトーン

---

### 3. About (`#about`)

- **背景:** `var(--bg-alt)`（少し暗いアイボリー）で他セクションとの視覚的区切り
- **レイアウト:** `grid-template-columns: 1fr 1.3fr;` の2カラム
  - 左：Eyebrow「About」＋ 大見出し「経営者の視点と、／技術者の実装力を、／ひとつの窓口で。」
  - 右：本文4段落 + 数字スタッツ2つ
- **数字スタッツ:**
  - `10+` — 自営業歴（年）
  - `13` — 試作・実証プロジェクト
- **文言のトーン:** 最終段は「一緒に始めさせてください」ではなく **「〜自分の手で作ってきた記録です」** で締める

---

### 4. Capabilities / できること・専門領域 (`#services`)

**セクション見出し変更あり:**
- 旧: 「Services / 提供サービス」（営業トーン）
- 新: **「Capabilities / できること／専門領域」**（実績棚卸しトーン）

セクション導入文も変更:
- 旧: 「〜業務フローに組み込み、実運用まで伴走します。札幌の中小企業様〜」
- 新: **「これまでに自分で手を動かして設計・構築してきた領域を、3つに整理して掲載しています。」**

- **レイアウト:** 3カラムグリッド（`grid-template-columns: repeat(3, 1fr)`、`gap: 24px`）
- **カード共通構成（`.svc-card`）:**
  - 上部ビジュアル `aspect-ratio: 16/5`（グレースケール画像 + ネイビーオーバーレイ + 斜線パターン）
  - ナンバリング `01 / SERVICE`（Mono, letter-spacing 0.2em）
  - アイコン（44×44、`border: 1px solid var(--accent)`、SVG stroke アイコン）
  - タイトル（Serif, 22px, weight 600）
  - 説明文（14px, `line-height: 1.9`）
  - タグ群（`.tag`、モノスペース11px、アクセントソフト背景）
- **カード3枚のタイトルと文言:**

| # | Title | Description（要旨） | Tags |
|---|---|---|---|
| 01 | **AI導入設計・PoC構築** | 業務ヒアリング → 課題整理 → ツール選定 → PoC の順で設計・検証してきた実績。複数事業と副業案件で要件定義から運用設計まで一貫担当。 | 要件定義 / PoC / 運用設計 |
| 02 | **AIワークフロー／ツール開発** | Claude / GPT-4o / Gemini API × Node.js / Python / React / n8n で業務自動化ツール・Webアプリを実装。SNS運用パイプライン、LINE Bot、ローカルダッシュボード等の実装経験。 | Node.js / Python / n8n / LINE API |
| 03 | **生成AIによる制作・リサーチ実務** | ロゴ・バナー・アイキャッチの画像生成、多言語翻訳、記事執筆、市場／技術リサーチ。単発制作から継続運用、複数モデルの使い分けを含む実務経験。 | ロゴ / 翻訳 / SEO記事 / リサーチ |

---

### 5. Works (`#works`)

**目的:** 「これだけ作ってきた」という証拠として、13件の試作・実証プロジェクトを **3グループ** に整理して提示。

- **背景:** `var(--bg-alt)`
- **レイアウト:** `grid-template-columns: repeat(2, 1fr); gap: 32px;`（Featured のみ `grid-column: 1/-1;` で全幅）
- **導入文:** 2025年〜現在の実証プロジェクト群であること、商用リリース済成果物ではなく **実装力の証拠** として掲載していることを明記

#### グループ構成

| Group | タイトル | 件数 | Featured |
|---|---|---|---|
| GROUP A | 運用・自動化の基盤づくり | 3 projects | **A-01 SNS Factory** |
| GROUP B | 発信・ナレッジ運用 | 3 projects | — |
| GROUP C | ツール・制作物 | 7 projects | — |

グループ見出しは `.works-group` クラス（`grid-column: 1/-1;`、baseline align の3要素 flex：GROUP番号・タイトル・件数）。

#### A-01 · Featured Work: SNS Factory（要注意 — 主力コンテンツ）

サイト全体の **主力アピール** となる大型カード。実装量が多いので個別セクションで詳細記述します。

- **ラッパー:** `.featured-work`（`grid-column: 1/-1;`、右上に `FEATURED` タグを疑似要素で固定）
- **構成:**
  1. **Hero バナー** — `aspect-ratio: 32/9`、`sns-factory-hero.jpg` にグレースケール＋ネイビーオーバーレイ、左下にモノスペースラベル
  2. **Header** — カテゴリ `A-01 · SNS運用 × 収益自動化`、番号 `2025 — 継続開発中 · 主力案件`、Serif 大見出し「SNS Factory — マルチアカウント統合パイプライン」、Tagline 段落
  3. **Body 01 · CONCEPT + 02 · PIPELINE**（`.featured-grid` — 1.15fr : 1fr の2カラム）
     - CONCEPT: 3層構造・`accounts/<名前>/` 分離思想・「公開の最終判断は必ず人間」設計哲学の説明
     - **REPO リンク**（重要）: モノスペース `REPO` ラベル + `github.com/take8661/sns-factory-showcase ↗`（アクセントカラー、外部リンク、`target="_blank" rel="noopener"`）
     - PIPELINE: モノスペースのパイプライン図（`.pipeline-viz`）— ノードは3種（通常・AI処理・人間判断）で色分け、凡例付き
  4. **Body 03 · MODULES** — 6件のモジュール表（`.modules-grid`、2カラム、左ボーダー3pxアクセント）
     - 予約投稿ダッシュボード / Threadsスケジューラ / トレンドフィード ／…など
  5. **Body 04 · TRIGGERS**（サーバー不要の定期実行）— 3件のスケジュール表 + `.trigger-note`（highlight 色のアクセント）
  6. **Ops highlights** — フッター相当の3カラム数字ハイライト（`.ops-grid`、`.ops-num` は Serif 32px）

#### GROUP A 残り (A-02, A-03) と GROUP B / C の Work Cards

- 共通クラス `.work-card`（`aspect-ratio: 16/9` 画像 + `.work-body` 内テキスト）
- 各カード構成:
  - 画像（グレースケール + ネイビーオーバーレイ + 斜線パターン処理）
  - ラベル（左下、モノスペース、半透明ネイビー背景）
  - Meta: カテゴリ番号（例 `A-02 · 品質ゲート`）と年（例 `2025`）
  - Serif タイトル
  - 説明文（14px, line-height 1.85）
  - `.work-result`（左ボーダー3pxアクセント、成果を1行で要約するハイライト枠）
  - `.work-stack` タグ列

**各Workカードの詳細な文言は `reference/index.html` の `#works` セクション本文を参照してください。**

---

### 6. Career (`#career`)

- **レイアウト:** 縦タイムライン（`.career-timeline`、`max-width: 920px`、左に1pxのライン、各アイテムに丸ドット）
- **アイテム構成:**
  - 現職には `.current` クラス → ドットが highlight 色（金）
  - 年（Mono, アクセント色）／役職（Serif 20px）／所属（グレー小）／説明（15px）
- **時系列（新しい順）:**
  - **2025 — 現在:** 生成AI事業（TK Office）
  - **2022 — 現在:** システムエンジニア（業務委託 / MECM / WSUS）
  - **2018 — 現在:** 共済事業
  - **2018 — 2022:** Eコマース事業（代表）
  - **2014 — 2018:** 遊戯事業（代表）

---

### 7. Skills (`#skills`)

- **見出し:** 「触れてきたもの」（実績棚卸しトーン）
- **背景:** `var(--bg-alt)`
- **レイアウト:** `grid-template-columns: repeat(4, 1fr);` の4カテゴリカード
- **カテゴリ:**
  1. `LANGUAGE` — JavaScript / TypeScript / Python / SQL 等
  2. `DATABASE` — PostgreSQL / SQLite / Redis 等
  3. `INFRA · OPS` — MECM / WSUS / Windows Server / Docker 等
  4. `AI · AUTOMATION` — Claude / GPT-4o / Gemini / Grok / n8n / Dify / Cursor / Apify / Playwright / Claude Code 並列運用 / RAG / Obsidian Vault

各カードは白背景 + 1pxライン、タイトルはモノスペース11px letter-spacing 0.2em、項目は縦並び。

---

### 8. Contact (`#contact`)

**目的の変更に伴い、営業CTAではなく面接補足の連絡導線に変更済み。**

- 旧見出し: 「まずは、お気軽にご相談ください。」
- 新見出し: **「技術的な詳細は、／お気軽にお問い合わせください。」**

- 旧本文: 「AIで何かできないか？というふわっとした段階でも歓迎です。」
- 新本文: **「掲載している実装の中身・ソースコード・設計判断など、面談で入りきらない部分でご質問があれば、メールでご連絡いただければ個別にお答えします。」**

- **要素:**
  - Eyebrow「Contact」（センター揃え）
  - Serif 大見出し
  - `.contact-email`（大きく、メールアドレスをリンク表示 / Cloudflare Email Obfuscation で難読化）
  - 3項目メタ情報:
    - `EMAIL` / obfuscated address
    - `LOCATION` / 北海道 札幌市
    - `RESPONSE` / 1〜2営業日以内に返信
  - CTA ボタン: 「メールで連絡する →」（旧「メールで問い合わせる →」）

- **注意:** Cloudflare の `email-protection` を使っているため、実装先のインフラで同等の仕組みを用意するか、または平文メール記述に切り替える判断が必要。ご相談・お問い合わせ用途ではないので静的なメール表示でも可。

---

### 9. Footer

- ブランドロゴ + 「© 2026 TK Office · Sapporo, Hokkaido」のみのシンプル構成
- ページ最下部、`padding: 40px`、上部に薄いボーダー

---

### 10. Tweaks Panel（開発用・本番削除可）

- `reference/tweaks_panel.jsx` を React + Babel Standalone で読み込む開発用パネル
- 現状の切り替え項目:
  - `variant`: `classic`（デフォルト・ライトネイビー基調）／`modern`（ダーク＋青系グラデーション）
  - `accent`: クラシック時のアクセントカラー切替（ネイビー / モスグリーン / ブラウン）
- **本番デプロイ時は以下を削除:**
  - `<div id="tweaks-root"></div>`
  - React / ReactDOM / Babel Standalone の `<script>` タグ3本
  - `tweaks_panel.jsx` の `<script type="text/babel">`
  - 末尾の `<script type="text/babel">` の TweaksApp 実装

---

## Interactions & Behavior

### スクロール系
- **Nav ボーダー切替:** `window.scrollY > 40` で `.scrolled` クラス付与（プレーンJS、`transition: border-color .3s, padding .3s;`）
- **Reveal on scroll:** `.reveal` → `.on` の Fade + slight translate。IntersectionObserver で `rootMargin: '0px 0px -10% 0px'`
  - 初期ビューポート内要素は即座に `.on` を付与（`rect.top < vh * 0.95`）
  - `.work-card` / `.featured-work` / `.works-group` は **絶対に隠さない**（主コンテンツのため）
  - フォールバック: 1.5秒後に強制で全 `.reveal` を `.on` に

### ホバー系
- `.svc-card`, `.work-card`: `transform: translateY(-4px)` + shadow
- `.btn`: `translateY(-2px)` + shadow
- Nav リンク: 下線アニメーション（`scaleX 0 → 1`, `transform-origin: left`）

### アニメーション
- Hero eyebrow dot: `@keyframes pulse` で 2s ループ（opacity 1 ⇄ 0.4）
- スクロールは `scroll-behavior: smooth`

### レスポンシブブレイクポイント
- `max-width: 900px`: Hero grid → 1カラム、About → 1カラム、Services grid → 1カラム、Featured grid → 1カラム、Trigger grid → 1カラム
- `max-width: 820px`: Nav リンク非表示、Works grid → 1カラム、Skills grid → 2カラム、Modules grid → 1カラム
- `max-width: 640px`: Works group heading の折り返し、Featured hero label 縮小

---

## State Management

このサイトは **ほぼ静的** です。以下のみ動的:

- **Nav スクロール状態** — 単一クラス切替のみ、状態管理ライブラリ不要
- **Reveal 状態** — IntersectionObserver で DOM class 直接操作
- **Tweaks Panel（開発用）** — React ローカル state + `postMessage` で親フレームへ永続化通知（本番では削除するため無視可）

**データフェッチは無し。**外部 API 呼び出しもありません。フォームや動的入力もありません（メールは `mailto:` リンクのみ）。

---

## Design Tokens

### Colors — Classic（デフォルト・ライト）

| Token | Hex | 用途 |
|---|---|---|
| `--bg` | `#f6f5f1` | 全体背景（アイボリー） |
| `--bg-alt` | `#ecebe5` | セクション交互背景（About / Works / Skills） |
| `--ink` | `#0f1a34` | 本文文字色（ネイビーブラック） |
| `--ink-soft` | `#384156` | 補助文字色 |
| `--ink-mute` | `#6b7280` | ミュートテキスト・ラベル |
| `--line` | `#d9d6cc` | ボーダー・区切り線 |
| `--card` | `#ffffff` | カード背景 |
| `--accent` | `#1a3a6b` | メインアクセント（ネイビー） |
| `--accent-soft` | `#e7ecf4` | アクセント淡色（タグ背景等） |
| `--highlight` | `#b8946a` | 金アクセント（ハイライト・現職ドット） |

### Colors — Modern（ダーク・オプション）

| Token | Hex | 用途 |
|---|---|---|
| `--bg` | `#0b1220` | ダーク背景 |
| `--bg-alt` | `#111a2e` | ダーク交互背景 |
| `--ink` | `#eef2f9` | ダーク時本文 |
| `--ink-soft` | `#b8c2d6` | ダーク時補助 |
| `--ink-mute` | `#7683a0` | ダーク時ミュート |
| `--line` | `#1e2942` | ダーク時ボーダー |
| `--card` | `#131c33` | ダーク時カード |
| `--accent` | `#6fb5ff` | ダーク時アクセント（ブライトブルー） |
| `--accent-soft` | `#1a2745` | ダーク時アクセント淡 |
| `--highlight` | `#7fe6d3` | ダーク時ハイライト（ミント） |

### Typography

| Family | 用途 |
|---|---|
| `Noto Serif JP`（500/600/700） | 見出し・数字・タイトル系 |
| `Noto Sans JP`（300/400/500/600/700/800） | 本文・UI・日本語コピー |
| `Inter`（300/400/500/600/700/800） | 予備（Modern バリアント時の見出し） |
| `JetBrains Mono`（400/500） | ラベル・番号・パイプライン図・タグ |

- Base font-size: `16px`
- Base line-height: `1.75`
- 見出しサイズ: `clamp(28px, 4vw, 44px)`（section-title）、`clamp(40px, 6.2vw, 78px)`（hero h1）
- letter-spacing: 見出し `.02em`、ラベル `.15em〜.25em`
- `font-feature-settings: "palt"` を全体に適用（日本語の詰め）

### Spacing

- **Section padding:** `120px 40px`（≤820px で `80px 20px`）
- **Container max-width:** `1200px`
- **Grid gap:** カード間 `24px`〜`32px`、大セクション `48px`〜`80px`
- **Card padding:** `.svc-card` `40px 32px`、`.work-body` `32px`、`.featured-body` `40px`

### Border Radius

- `--radius: 4px`（デフォルト値・ほぼ使用せず、意図的に **角ばったクラシック印象**）
- カードにはほぼ radius を適用しない設計（信頼型トーン）

### Shadows

- `--shadow: 0 1px 2px rgba(15,26,52,.04), 0 4px 24px rgba(15,26,52,.04)`
- Modern variant: `0 1px 2px rgba(0,0,0,.2), 0 8px 40px rgba(0,0,0,.25)`
- Hover 時のみ強調（`0 8px 24px rgba(15,26,52,.15)`）

---

## Assets

### `/assets/img/` 内の画像（全17枚 · JPEG）

| File | 用途 | Size |
|---|---|---|
| `sns-factory-hero.jpg` | Featured Work（A-01）のヒーローバナー | 513 KB |
| `svc-01-consulting.jpg` | Capabilities Card 01 上部ビジュアル | 60 KB |
| `svc-02-development.jpg` | Capabilities Card 02 上部ビジュアル | 55 KB |
| `svc-03-creative.jpg` | Capabilities Card 03 上部ビジュアル | 119 KB |
| `a02-quality.jpg` | Works A-02（品質ゲート） | 318 KB |
| `a03-panel-hub.jpg` | Works A-03（Panel Hub） | 130 KB |
| `b01-wiki.jpg` | Works B-01（Wiki） | 402 KB |
| `b02-summary.jpg` | Works B-02（Summary） | 61 KB |
| `b03-timeline.jpg` | Works B-03（Timeline） | 54 KB |
| `c01-receipt.jpg` | Works C-01（Receipt） | 315 KB |
| `c02-automation.jpg` | Works C-02（Automation） | 321 KB |
| `c03-media.jpg` | Works C-03（Media） | 39 KB |
| `c04-database.jpg` | Works C-04（Database） | 82 KB |
| `c05-video.jpg` | Works C-05（Video） | 155 KB |
| `c06-table.jpg` | Works C-06（Table） | 123 KB |
| `c07-spreadsheet.jpg` | Works C-07（Spreadsheet） | 237 KB |

**取得元:** すべて生成AIによる制作物（本人の実際の実装のスクリーンショットではなく、コンセプトを表現したイメージビジュアル）。実装先で差し替える場合は、**同じアスペクト比**（`16/9` for work、`16/5` for service、`32/9` for featured hero）を維持してください。

### 画像のスタイル処理

**重要:** 画像は生の色ではなくフィルター処理された状態で表示されます:

```css
/* Work / Service / Featured 共通 */
filter: grayscale(1) brightness(.55) contrast(1.2);
/* + オーバーレイ疑似要素 */
background: linear-gradient(135deg, rgba(26,58,107,.75), rgba(15,26,52,.55));
mix-blend-mode: multiply;
/* + 斜線パターン */
background: repeating-linear-gradient(135deg, transparent 0 8px, rgba(255,255,255,.02) 8px 9px);
```

これにより **画像の中身に関係なくブランドトーン（ネイビー）で統一** されます。実装時はこの処理を維持してください。

### Google Fonts

外部読み込み。CSP や CDN 制約がある場合は self-host に切り替えてください。

```
https://fonts.googleapis.com/css2?family=Noto+Sans+JP:wght@300;400;500;600;700;800&family=Noto+Serif+JP:wght@500;600;700&family=Inter:wght@300;400;500;600;700;800&family=JetBrains+Mono:wght@400;500&display=swap
```

### アイコン

すべて **インライン SVG**（stroke ベース、24×24）。外部アイコンライブラリ（Lucide 等）依存なし。実装先で置き換える場合は `stroke="currentColor"; stroke-width="1.5"` を維持。

### 外部リンク

- **SNS Factory リポジトリ:** `https://github.com/take8661/sns-factory-showcase`（`target="_blank" rel="noopener"`）

### Cloudflare Email Obfuscation について

現状の HTML は Cloudflare の `email-protection` スクリプト（`/cdn-cgi/scripts/5c5dd728/cloudflare-static/email-decode.min.js`）に依存しています。Cloudflare を通さないインフラにデプロイする場合は:

- **選択肢A:** メールアドレスを平文で HTML に直書き（採用向けサイトなので許容範囲）
- **選択肢B:** 独自の難読化（JS で `data-*` 属性から組み立てる等）
- **選択肢C:** お問い合わせフォーム経由に切替

---

## Files

このパッケージに同梱している参照ファイル:

```
design_handoff_tk_office_portfolio/
├── README.md                        ← このファイル
└── reference/
    ├── index.html                   ← メインプロトタイプ（最新版・採用ポートフォリオ用途反映済み）
    └── tweaks_panel.jsx             ← 開発用 Tweaks Panel（本番デプロイ時は不要）
```

**同梱していないもの（プロジェクト側で別途参照）:**

- `/assets/img/*.jpg` — 上記 Assets 節に一覧あり。実装時は同じファイル名・同じアスペクト比で配置するか、独自の画像に差し替え。

---

## Implementation Notes（実装先への申し送り）

### 用途変更に伴う重要な観点

このサイトは **旧「営業ランディングページ」から「採用ポートフォリオ」へ用途変更済み** です。以下の観点を実装で維持してください:

1. **文言のトーン** — 営業的な誘導表現（〜します／お気軽にご相談ください／案件受付中）は使わない。実績・スキル棚卸しトーン（〜してきました／実装経験があります）で統一。
2. **CTA の位置づけ** — ナビ / Hero / Contact のいずれも「案件を取る」導線ではなく「面接補足として連絡する」導線として扱う。
3. **サイトの核** — Works（試作・実証プロジェクト13件）とその Featured である **SNS Factory** が最重要。ここは絶対にレイアウト・情報密度を削らない。

### 推奨実装スタック

- **フレームワーク:** Astro（1ページ完結・JS 最小・SEO 有利）
- **コンポーネント分割:**
  - `Nav.astro`
  - `Hero.astro`
  - `About.astro`
  - `Capabilities.astro`（旧 Services）
  - `Works.astro`（内部で `WorkCard.astro` / `FeaturedWork.astro` / `WorksGroupHeading.astro` を持つ）
  - `Career.astro`
  - `Skills.astro`
  - `Contact.astro`
  - `Footer.astro`
- **スタイル:** `<style>` はコンポーネントスコープに分割。CSS Custom Properties（`:root` の tokens）はグローバル `styles/tokens.css` に切り出し推奨
- **Reveal アニメーション:** `client:visible` ディレクティブや軽量 vanilla JS に置換
- **Tweaks Panel:** 本番では削除。開発中のみ有効化する場合は Astro の環境変数で切替

### アクセシビリティ

- 画像すべてに空 `alt=""`（装飾扱い）。ポートフォリオ本文としてスクリーンリーダーで読み上げる必要は無いが、Work タイトル・Career 記述は十分な情報密度でテキスト提供済み。
- ナビは `<nav>` セマンティックタグ使用済み。
- リンクはすべて `<a>` タグ。ボタンとして扱っているものも `<a>` のまま（`<button>` にしない — 遷移のためのリンク）。

### パフォーマンス

- 画像は最大 513KB（`sns-factory-hero.jpg`）。実装時は WebP 変換 + `loading="lazy"` 済みなのでそのまま維持推奨。
- Google Fonts は `preconnect` 済み。ただし self-host に切り替えるとさらに高速化可能。

---

## 変更履歴（用途転換）

このハンドオフパッケージは **採用ポートフォリオ用途への転換後** の状態です。旧営業ページから以下が変更されています:

| 場所 | Before（営業） | After（採用ポートフォリオ） |
|---|---|---|
| Nav CTA | 「お問い合わせ →」 | 「Contact →」 |
| Hero Eyebrow | 「AVAILABLE · 開発案件を受付中」 | 「PORTFOLIO · 実装実績まとめ」 |
| Hero H1 副文 | 「困りごとを一緒にほどきます」 | 「自分で設計・実装してきた記録です」 |
| Hero Primary CTA | 「相談してみる」 | 「実装実績を見る」 |
| Hero Secondary CTA | 「実績を見る」 | 「経歴を見る」 |
| Profile ROLE | 「〜業務課題を解くひと」 | 「〜業務課題を解く実装者」 |
| About 締め | 「札幌の中小企業さまの小さな自動化から一緒に始めさせてください」 | 「〜自分の手で作ってきた記録です」 |
| Services 見出し | 「提供サービス」 | 「できること／専門領域」 |
| Services 導入 | 「〜運用まで伴走します。お気軽にご相談ください」 | 「これまで手を動かして構築してきた領域を3つに整理」 |
| Card 01 タイトル | AI導入コンサルティング | AI導入設計・PoC構築 |
| Card 02 タイトル | AIツール・システム開発 | AIワークフロー／ツール開発 |
| Card 03 タイトル | 画像生成 / 翻訳 / 記事執筆 | 生成AIによる制作 · リサーチ実務 |
| Contact 見出し | 「まずは、お気軽にご相談ください」 | 「技術的な詳細は、お気軽にお問い合わせください」 |
| Contact 本文 | 「ふわっとした段階でも歓迎」 | 「面接で入りきらない部分があれば個別回答」 |
| Contact CTA | 「メールで問い合わせる →」 | 「メールで連絡する →」 |

**追加コンテンツ:**
- SNS Factory の CONCEPT 段落下に、公開リポジトリへのリンク `REPO github.com/take8661/sns-factory-showcase ↗` を追加

---

*Last updated: 2026-08-02*
