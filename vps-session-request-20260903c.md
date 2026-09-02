# VPS側セッションへの依頼（2026-09-03・共有状態リセット機能の追加 バッチ3／3・最終）

## 背景

バッチ1（`vps-session-request-20260903a.md`）・バッチ2
（`vps-session-request-20260903b.md`）に続き、GROUP D全33デモの機械的な
棚卸しで見つかった「共有状態はあるのにリセット手段が無い」9デモのうち、
今回はバッチ3（最後の3件）を対応済み。**これで9件全て実装・テスト完了**。

## 反映してほしい変更（3デモ）

いずれも`review-files/<デモ名>/`側で実装・テスト・grep（山渓混入なし）確認済み。

### 1. multichannel-inventory-demo

- `src/seed.js`（新規ファイル）：起動時の`seedIfNeeded()`ロジックを
  `server.js`から切り出し、あわせて`resetToSeed(db, settings)`を追加
  （orders・products・products_naiveを全削除後、起動時と同じ
  `settings.seedProducts`を再投入）
- `src/routes/admin.js`：`POST /admin/demo-reset`を追加
- `public/index.html`：トップページに「今すぐこのデモの在庫・注文データを
  全て初期状態に戻す」ボタン追加（`confirm()`で確認）
- テスト16件（既存15件＋新規1件）PASS。**このデモも本セッションの検証環境
  ではsqlite3のネイティブバイナリの都合でテストが直接実行できなかったため
  （既存の旧テストも同じ理由で失敗することを確認済み）、ソース一式を
  クラウド側の別環境（GLIBC 2.39搭載）へ退避し、そちらで`npm install`
  からやり直して検証しました。本番環境はこのデモが既に正常稼働している
  環境のため、通常通りテストが通るはずです**

### 2. simple-waf-demo

- `lib/vulnerable-api-app.js`：`POST /api/admin/demo-reset`を追加
  （問い合わせ一覧を全削除後、起動時と同じ`seedRows`を再投入）
- `public/index.html`・`public/app.js`：「今すぐこのデモの問い合わせ一覧を
  初期状態に戻す」ボタンを追加。SQLi/XSSシグネチャ検査とは無関係の管理
  操作のため、既存の`/direct`バイパス経路（WAFを経由しない直叩き用経路）
  を使って送信する
- テスト16件（既存15件＋新規1件）PASS（本デモは`node:sqlite`使用のため
  ネイティブバイナリ依存が無く、環境固有の問題は発生しませんでした）

### 3. state-tracker-deadline-alert-demo

- `src/store/matterStore.js`：`reset()`を追加（本デモは初期シードデータを
  持たない設計＝案件はユーザー操作のみで作られるため、単純に空の状態へ戻す）
- `src/routes/matters.js`：`POST /api/demo-reset`を追加
- `public/matters.html`・`public/matters.js`（案件一覧・履歴画面）：
  「今すぐこのデモの案件・履歴を全て初期状態に戻す」ボタン追加（`confirm()`で確認）
- テスト53件（既存52件＋新規1件）PASS

## 確認手順（必須・実際の出力を貼り付けてください）

各デモについて、公開URLで以下を確認し、結果をそのまま報告に含めてください。

1. **multichannel-inventory-demo**：`https://multichannel-inventory-demo.demos.himitsuno-heya123.com/`
   → いずれかのチャネル画面（ec.html等）で商品を1つ購入 → トップページに
   戻り「今すぐこのデモの在庫・注文データを全て初期状態に戻す」ボタンを押す
   → 各チャネル画面の在庫表示が初期値に戻っていることを確認
   （**このデモは本番環境で改めて`npm test`を実行し、結果もあわせて
   報告してください**）
2. **simple-waf-demo**：`https://simple-waf-demo.demos.himitsuno-heya123.com/`
   → 「2. XSS」欄から何か投稿 → 一覧に表示されることを確認 →
   「今すぐこのデモの問い合わせ一覧を初期状態に戻す」ボタンを押す →
   一覧が初期シード件数（投稿分が消えた状態）に戻ることを確認
3. **state-tracker-deadline-alert-demo**：`https://state-tracker-deadline-alert-demo.demos.himitsuno-heya123.com/`
   → 何か状態報告を1件登録（「同梱サンプルシナリオを試す」でも可）→
   「案件一覧・履歴」画面に表示されることを確認 →
   「今すぐこのデモの案件・履歴を全て初期状態に戻す」ボタンを押す →
   一覧が0件に戻ることを確認

## 重要

WebFetchでの外部要約ではなく、実際にブラウザまたはcurlで動作確認したうえで、
各手順の実際の結果（画面のスクリーンショット、またはcurlの生出力、
multichannel-inventory-demoについては`npm test`の実際の出力）を報告に
含めてください。「反映しました」という文章だけの報告は受け付けられません。

## 全体について

これでバッチ1〜3、GROUP D全33デモの機械的な棚卸しで見つかった9件全ての
「共有状態はあるのにリセット手段が無い」問題への対応が完了します。3バッチ
全ての反映確認が取れ次第、`VPS-DEPLOY-PENDING.md`の該当項目をクローズします。
