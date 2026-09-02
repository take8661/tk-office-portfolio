# VPS側セッションへの依頼（2026-09-03・共有状態リセット機能の追加 バッチ1／3）

## 背景

竹村さんから「リセットボタンがあるデモと無いデモがあって、外から見て仕様か
バグか分からない」との指摘を受け、GROUP D全33デモのサーバーコードを機械的に
棚卸しした（`review-files/group-d-shared-state-audit.md`参照）。結果、
「他の閲覧者からも見える形でデータが溜まる設計なのに、リセット手段が無い」
デモが新たに9件見つかった。今回はそのうち3件（バッチ1）を対応済み。

## 反映してほしい変更（3デモ）

いずれも`review-files/<デモ名>/`側で実装・テスト・grep（山渓混入なし）確認済み。

### 1. anomaly-dashboard-demo

- `src/store/runStore.js`：`clear()`追加
- `src/routes/runs.js`：`POST /api/runs/demo-reset`追加
- `public/index.html`・`public/app.js`：副モード「実行履歴」欄に
  「今すぐこのデモの実行履歴をクリアする」ボタン追加
- テスト47件（既存45件＋新規2件）PASS
- インメモリのみのストアのためPM2再起動は不要（APIを叩けば即座に反映）

### 2. churn-risk-scoring-demo

- `server.js`：`POST /api/demo-reset`追加（`scoring-config.default.json`を
  `scoring-config.json`へ上書きコピー）
- `public/settings.html`・`public/app.js`：設定画面に「今すぐ設定を既定値に
  戻す」ボタン追加
- テスト43件（既存42件＋新規1件）PASS
- README.md新規作成（このデモには元々READMEが無かった）

### 3. employment-contract-pdf-demo

- `src/store/historyStore.js`：`resetHistory()`追加（`index.json`を空配列に戻し、
  対応する全PDFファイルを削除）
- `src/routes/history.js`：`POST /api/history/demo-reset`追加
- `frontend/`：Reactコンポーネント（`HistoryPage.jsx`）を修正し
  **`npm run build`で`public/assets/`へ再ビルド済み**（このデモはVite製SPAのため、
  `frontend/src/`を直接VPSへ反映しても画面には反映されません。必ず
  `public/assets/index-*.js`・`index-*.css`とそれを参照する`public/index.html`
  一式を反映してください。もしVPS側で改めて`npm run build`を実行する場合は
  `frontend/`配下で`npm install`後に`npm run build`を実行してください）
- テスト46件（既存45件＋新規1件）PASS

## 確認手順（必須・実際の出力を貼り付けてください）

各デモについて、公開URLで以下を確認し、結果をそのまま報告に含めてください。

1. **anomaly-dashboard-demo**：`https://anomaly-dashboard-demo.demos.himitsuno-heya123.com/`
   → 副モードタブを開き、何かシミュレーションを1回実行 → 実行履歴に表示される
   ことを確認 → 「今すぐこのデモの実行履歴をクリアする」ボタンを押す →
   履歴が消えることを確認
2. **churn-risk-scoring-demo**：`https://churn-risk-scoring-demo.demos.himitsuno-heya123.com/settings.html`
   → 何か値を変更して保存 → 「今すぐ設定を既定値に戻す」ボタンを押す →
   値が既定値に戻ることを確認
3. **employment-contract-pdf-demo**：`https://employment-contract-pdf-demo.demos.himitsuno-heya123.com/`
   → 契約書を1件生成 → 履歴画面で表示されることを確認 →
   「今すぐこのデモの履歴を全て削除する」ボタンを押す → 履歴が0件になることを確認
   （**ビルド成果物が正しく反映されていないとボタン自体が表示されないので、
   特に注意して確認してください**）

## 重要

WebFetchでの外部要約ではなく、実際にブラウザまたはcurlで動作確認したうえで、
各手順の実際の結果（画面のスクリーンショット、またはcurlの生出力）を報告に
含めてください。「反映しました」という文章だけの報告は受け付けられません。

続けてバッチ2・3（escalation-router-demo・idempotency-demo・library-reservation-demo、
multichannel-inventory-demo・simple-waf-demo・state-tracker-deadline-alert-demo）も
準備中です。準備でき次第、別ファイルで依頼します。
