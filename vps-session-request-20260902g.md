# VPS側セッションへの依頼（2026-09-02・緊急対応3件＋項目27の反映状況再確認）

## 最優先：api-health-degradation-demoの復旧

竹村さんより「公開デモが落ちたまま何もできない、リセットボタンが無い」との報告。
このデモには最初からリセット機能が実装されておらず、決済API連携をわざと壊す
操作をした後、訪問者側には復旧手段が無い状態だった可能性がある。

`review-files/api-health-degradation-demo/`側でリセット機能
（`POST /api/demo-reset`＋画面のリセットボタン）を追加・テスト済み（詳細は
`VPS-DEPLOY-PENDING.md`項目29参照）。**まずこのデモを最優先で反映してほしい**。
反映後、以下で復旧を確認してほしい。

```
curl -s https://api-health-degradation-demo.demos.himitsuno-heya123.com/__status
# → "overall":"operational" になっていること
```

もし反映前の時点で`"overall":"degraded"`や`"open"`になっている場合、反映後に
画面の「今すぐこのデモをリセットする」ボタンを押して復旧することを確認してほしい。

## 2. gov-spec-checklist-extractor-demoのサンプルPDF文字化け修正

`apps/api/src/sampleSpecPdf.ts`の`subset: true`→`subset: false`変更を反映
（詳細はVPS-DEPLOY-PENDING.md項目29）。**`apps/web/dist/`の再ビルドは不要**
（このデモ自体はサーバー側のPDF生成コードのみの変更、フロントエンドは無変更）。

確認方法：公開URLで「同梱サンプルPDFを試す」を押し、画面右側のPDFプレビューで
「架空自治体情報システム調達仕様書（サンプル）」等の日本語が正しく表示され、
文字化け（欠落・別記号への置き換わり）が無いことを確認。

## 3. simple-waf-demoにサンプル比較ボタンを追加

`public/index.html`・`public/app.js`を反映（詳細はVPS-DEPLOY-PENDING.md項目29）。
バックエンド・WAFロジックは無変更。

確認方法：公開URLを開き、「同梱サンプル攻撃をWAF経由／直叩きの両方に送って
比較する」ボタンを押すと、結果欄にWAF経由（403）と直叩き（200・SQL漏洩）の
両方が表示されることを確認。

## 4. 【要再確認】項目27（状態リセット機能・5デモ）の反映状況

`vps-session-request-20260902d.md`で依頼した5デモのうち、竹村さんが実際に
公開URLをブラウザで確認したところ、**bulk-chunked-import-demo以外はリセット
ボタンが見当たらない**状態だった。以下4デモについて、`review-files/<demo>/`
側の内容（無変更のはず）が実際に本番へ反映されているか改めて確認し、未反映
であれば反映をお願いしたい。

- workflow-builder-demo（`POST /api/demo-reset`、`src/store/demoReset.js`）
- dlq-dashboard-demo（`POST /api/demo-reset`、`ordersStore.reset()`・
  `dlqStore.reset()`）※ 併せて、2026-09-02T03:45〜04:00頃に投入された古い
  テストデータがDLQ一覧に残っているようなので、リセット反映後に一度
  クリアしてもらえるとありがたい
- excel-instant-webapp-demo（`POST /api/demo-reset`）
- multitenant-isolation-checker-demo（`POST /demo-reset`）※ このデモは
  ログイン後の画面にのみボタンが表示される設計のため、
  `demo-a@example.invalid` / `DemoTenantA-2026`でログインしたうえで確認が必要

反映済みであれば「反映済み・確認方法が違うだけ」の可能性もあるため、その場合は
その旨教えてほしい（例：ボタンの表示位置が分かりにくい等、こちら側の設計の
問題である可能性も考えられるため）。

## 5. 【今回から必須】反映確認は必ずsha256突き合わせスクリプトで

項目27（上記4.）の反映漏れは、依頼文を送っただけで「反映済み」として扱って
しまい、機械的な確認を一度もしなかったことが原因だった。今回からは、
上記1〜4すべての反映作業の最後に、必ず以下を実行し、差分が無い（または
想定通りの差分のみである）ことを確認してから「反映完了」として報告して
ほしい。

```
cd review-files
REMOTE_HOST=<VPS側のsshエイリアス> ./verify-deploy-20260902-v2.sh
```

`local-manifest-20260902-v2.txt`（今回の13デモ分のsha256一覧）と対になって
いる。差分が出た場合は、curlやブラウザでの個別確認より先に、この差分レポート
を貼り付けて共有してほしい。

## 補足

各修正内容の技術的詳細は`VPS-DEPLOY-PENDING.md`の項目29および項目27を参照。
今回も、WebFetchでの外部要約ではなく、VPS側で直接curlまたはブラウザで確認する
方式でお願いします。
