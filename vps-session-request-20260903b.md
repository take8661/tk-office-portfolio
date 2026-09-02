# VPS側セッションへの依頼（2026-09-03・共有状態リセット機能の追加 バッチ2／3）

## 背景

バッチ1（`vps-session-request-20260903a.md`）に続き、GROUP D全33デモの機械的な
棚卸しで見つかった「共有状態はあるのにリセット手段が無い」9デモのうち、
今回はバッチ2の3件を対応済み。

## 反映してほしい変更（3デモ）

いずれも`review-files/<デモ名>/`側で実装・テスト（可能な範囲で）・grep
（山渓混入なし）確認済み。

### 1. escalation-router-demo

- `lib/store.js`：変更なし（元々あった`reset(nextMessages)`関数がテストのみで
  実際のルートに未接続だった＝死んだコードだったことを確認）
- `lib/app.js`：`POST /api/demo-reset`を追加。`getSeedMessages`が渡されていれば
  それを、無ければ空配列を`store.reset()`に渡す
- `server.js`：起動時と同じシードメッセージを組み立てる`getSeedMessages`関数を
  作り、`createApp()`に渡すよう変更
- `public/index.html`・`public/app.js`：メッセージ一覧欄に
  「今すぐこのデモの投稿を全てクリアする」ボタン追加（`confirm()`で確認）
- テスト20件（既存18件＋新規2件）PASS

### 2. idempotency-demo

- `src/repository/db.js`：`resetOrders(db)`追加（`orders`・`orders_naive`両
  テーブルをDELETE）
- `src/logging/logger.js`：`clear()`追加（ログファイルを空にする）
- `src/routes/admin.js`：`POST /admin/demo-reset`を追加（上記2つを呼ぶ）
- `public/index.html`・`public/app.js`：検証パネルに
  「今すぐこのデモのデータを全て消す」ボタン追加（`confirm()`で確認）
- **重要：本セッションの検証環境（Windows側でインストールされたnode_modulesを
  Linux VM上で実行する構成）ではsqlite3のネイティブバイナリの都合で
  `npm test`が（今回の変更前から）一切実行できませんでした**（`invalid ELF
  header`→`npm rebuild`で`GLIBC_2.38`不足→`--build-from-source`はネットワーク
  タイムアウト）。既存の9件の旧テストも同じ理由で失敗することを確認済みのため
  コード自体の問題ではないと判断していますが、**このデモについては
  VPS側で`npm test`を実際に実行し、結果（PASS件数）を報告してください**。
  本番環境はこのデモが既に正常稼働している環境なので、テストも通るはずです。

### 3. library-reservation-demo

- `apps/api/src/routes/admin.ts`（新規ファイル）：`POST /admin/demo-reset`を
  追加。`LibraryStore`に既存の`seed()`メソッドと、起動時と同じ
  `buildSeedState()`（`seedData.js`）を使ってDBを初期状態へ戻す
- `apps/api/src/server.ts`：上記ルートを登録
- `apps/web/src/api/client.ts`：`resetDemo()`追加
- `apps/web/src/screens/AuditLog.tsx`（SCR-06監査ログ画面）：
  「今すぐこのデモのデータを全て初期状態に戻す」ボタン追加（`confirm()`で確認）
- **`apps/web/`はVite製SPAのため`npm run build --workspaces --if-present`で
  `apps/web/dist/`へ再ビルド済みです。`apps/web/src/`だけを反映しても画面には
  反映されません。必ず`apps/web/dist/`一式（`index.html`・`assets/index-*.js`）
  を反映してください。もしVPS側で改めてビルドする場合はリポジトリルートで
  `npm install`後に`npm run build --workspaces --if-present`を実行してください**
- `apps/api/`側はビルド不要です（`node --experimental-strip-types src/index.ts`
  でTypeScriptを直接実行する構成のため、`apps/api/src/`をそのまま反映すれば
  よいです）
- テスト34件（既存33件＋新規1件）PASS

## 確認手順（必須・実際の出力を貼り付けてください）

各デモについて、公開URLで以下を確認し、結果をそのまま報告に含めてください。

1. **escalation-router-demo**：`https://escalation-router-demo.demos.himitsuno-heya123.com/`
   → 何かメッセージを1件投稿 → 一覧に表示されることを確認 →
   「今すぐこのデモの投稿を全てクリアする」ボタンを押す →
   投稿が消える（起動時のシードメッセージのみに戻る）ことを確認
2. **idempotency-demo**：`https://idempotency-demo.demos.himitsuno-heya123.com/`
   → **まず`npm test`を実行し、結果（PASS件数）をそのまま貼り付けてください**
   → 画面で何か注文を1件実行 → 管理画面（`/admin/orders`等）に表示される
   ことを確認 → 「今すぐこのデモのデータを全て消す」ボタンを押す →
   データが消えることを確認
3. **library-reservation-demo**：`https://library-reservation-demo.demos.himitsuno-heya123.com/`
   → 何か予約または貸出操作を1件実行 → 監査ログ画面（SCR-06）に表示される
   ことを確認 → 「今すぐこのデモのデータを全て初期状態に戻す」ボタンを押す →
   監査ログ・予約一覧が初期状態（起動直後と同じ件数）に戻ることを確認
   （**フロントのビルド成果物が正しく反映されていないとボタン自体が
   表示されないので、特に注意して確認してください**）

## 重要

WebFetchでの外部要約ではなく、実際にブラウザまたはcurlで動作確認したうえで、
各手順の実際の結果（画面のスクリーンショット、またはcurlの生出力、
idempotency-demoについては`npm test`の実際の出力）を報告に含めてください。
「反映しました」という文章だけの報告は受け付けられません。

続けてバッチ3（multichannel-inventory-demo・simple-waf-demo・
state-tracker-deadline-alert-demo）も準備中です。準備でき次第、別ファイルで
依頼します。
