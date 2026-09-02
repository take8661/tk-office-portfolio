# VPS側セッションへの依頼（2026-09-02・サンプル機能追加／不具合修正 8デモ一括反映）

## 背景

竹村さんから、以下のような報告が続けて届いた（一部はスクリーンショット付き）。

> 極小ワークフロービルダー／ER図即時生成ツールデモ：まだ修正されてない
> 大量データチャンク分割インポートデモ：サンプルが入ってない
> 官公庁調達仕様書 要件チェックリスト抽出器：サンプルを押してもエラーになる
> 雑多メモ自動マークダウン階層化デモ：サンプル入ってない
> 時系列ステートトラッカー＆期限アラート：サンプル入ってない
> 簡易WAF自作デモ：正常に動作しない
> multichannel-inventory-demo：開けない
> 管理画面 — 設定世代管理デモ：サンプルがない

調査した結果、単なる「サンプルデータが無い」ではなく、**AI API未設定時に
通常利用も含めて全操作が500エラーになる**（er-diagram・messy-memo・
state-tracker）、**本番ビルドにlocalhostアドレスが焼き込まれている**
（gov-spec・simple-waf）、**ルートパス`/`用ページが存在せず`Cannot GET /`に
なる**（multichannel-inventory、既知のD-30）といった、より根の深い原因が
複数含まれていた。詳細は`VPS-DEPLOY-PENDING.md`の項目28を参照。

対象8デモすべて `review-files/<demo>/` 側でコード修正・自動テスト・
README追記まで完了済み。以下、デモ全体の反映と反映後の確認をお願いしたい。

## 1. 8デモのコードを本番へ反映

いつもの方式（`review-files/<demo>/`の最新内容を、リモートにしか無い
古いファイルも含めて完全に「同期」する形）で以下8デモを反映してほしい。

- er-diagram-instant-generator-demo
- bulk-chunked-import-demo
- gov-spec-checklist-extractor-demo
- messy-memo-markdown-organizer-demo
- state-tracker-deadline-alert-demo
- simple-waf-demo
- multichannel-inventory-demo
- config-rollback-demo

### 環境変数について（重要）

er-diagram-instant-generator-demo・messy-memo-markdown-organizer-demo・
state-tracker-deadline-alert-demoの3件は、今回`AI_PROVIDER`環境変数
（未設定時は`ANTHROPIC_API_KEY`/`OPENAI_API_KEY`の有無で自動判定、
未設定なら安全な`mock`モードが既定）に対応した。**現状すでにAPIキーが
未設定のはずなので、`.env`は変更不要**で、反映するだけで自動的に
mockモード（課金なしのサンプル動作）になるはず。もし将来的に実際のAI
呼び出しへ切り替えたい場合は、該当キーを設定するか`AI_PROVIDER=openai`
（またはanthropic）を明示すればよい。

gov-spec-checklist-extractor-demoは`apps/web/dist/`を再ビルドしたものを
含めて同期する必要がある（`apps/web/.env.production`を新規追加した上で
`npx vite build apps/web`を実行し直したもの）。もしVPS側のデプロイ
スクリプトが独自にビルドし直す設計なら、そちらでビルドし直しても同じ
結果になるはず（`VITE_API_BASE_URL=`を空文字にする変更のため）。

### simple-waf-demoについて：ネットワーク公開範囲の注意（重要）

このデモは教育目的で意図的にSQLi/XSSが成立するダミーAPI
（`vulnerable-api.js`、ポート8081）を含む。**`vulnerable-api.js`は
VPSの外部ネットワークへ公開しないでください**（README冒頭にも
localhost限定運用の警告あり）。今回の修正で、WAFプロキシ
（`waf-proxy.js`、ポート8080）自身に`/direct`というバイパス経路を
追加したため、**外部公開は`waf-proxy.js`（8080）1ポートのみで足りる**
構成になっている。`vulnerable-api.js`はWAFプロキシと同じVPS上で
`127.0.0.1`限定のまま起動し、WAFプロキシからの内部転送
（`TARGET_VULNERABLE_API_URL`）でのみ到達できれば動作する。

もし現状のVPS側デプロイでこの2プロセス構成が難しい場合は、その旨
教えてほしい（デモ画面側の対応方法を再検討する）。

## 2. 反映後の確認（各デモでcurlまたはAPI呼び出しにより直接確認）

これまでの反省を踏まえ、WebFetchでの外部要約ではなく、VPS側で直接
curlまたはブラウザ確認する方式でお願いします。

- **er-diagram-instant-generator-demo**：
  - `GET /api/config` → `{"aiProvider":"mock"}`（または実キー設定時は`"anthropic"`）
  - `GET /api/sample-text` → 図書館システムの要件定義文（複数行）が返る
  - 画面上の「同梱サンプルを試す」ボタンで、実際にER図・DDLが生成されること
- **bulk-chunked-import-demo**：
  - 画面上の「同梱サンプルCSVで試す」ボタンを押すと、確認・再選択の手順なしに
    そのままインポートが開始され、4/4件成功すること
- **gov-spec-checklist-extractor-demo**：
  - 画面のサンプルボタンを押して「Failed to fetch」にならず、チェックリストが
    生成されること（本番URLで実施。localhostではなく実際の公開ドメインで
    確認することが重要）
- **messy-memo-markdown-organizer-demo**：
  - `GET /api/config` → `{"aiProvider":"mock", ...}`
  - 画面上の「同梱サンプルを試す」ボタンで、「田中さん」を含む行が同じ見出しに
    まとまったMarkdownが生成されること
- **state-tracker-deadline-alert-demo**：
  - `GET /api/config` → `{"aiProvider":"mock", ...}`
  - 画面上の「同梱サンプルシナリオを試す」ボタンで、新規案件が登録され、
    ステータスが「対応中」→「先方確認待ち」と時系列で遷移すること
- **simple-waf-demo**：
  - 公開URL（`https://simple-waf-demo.demos.himitsuno-heya123.com/`）を
    ブラウザで開き、「接続先設定」欄が空欄のまま、SQLi例をWAF経由で送信すると
    403でブロックされ、「直叩き（WAFなし）」で送信すると200で全件返る
    （脆弱性が実際に成立する）ことを確認
- **multichannel-inventory-demo**：
  - 公開URL（パス無し、`https://multichannel-inventory-demo.demos.himitsuno-heya123.com/`）
    を開くと「Cannot GET /」ではなく、3チャネル画面へのリンクが並ぶ
    ランディングページが表示されること
- **config-rollback-demo**：
  - `/admin`の「サンプルシナリオを投入する」ボタンを押すと、世代一覧に
    世代2（正常な変更）・世代3（誤った変更、料金0円）・世代4
    （世代2へのロールバック）の3行が追加され、フォームの内容が
    世代2の内容に戻っていること

## 補足

各デモの`review-files/<demo>/README.md`に2026-09-02付けで変更内容を
記載済み。実際に動かしてみて想定と異なる挙動があれば、コード側の
理解が誤っている可能性があるため、その旨教えてほしい。
