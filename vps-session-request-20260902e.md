# VPS側セッションへの依頼（2026-09-02・状態リセット機能の反映＋自動リセットcron設定）

※ このファイルは `vps-session-request-20260902d.md` の後継版。dはまだ渡していないので
無視してよい（手動ボタン方式に設計変更したため内容が古くなった）。

## 背景

複数の企業が同じ本番URLを同時に見る運用のため、前の訪問者の操作履歴（作成した
ワークフロー、実行させたバッチ、アップロードしたファイル等）が残り続けるのは
よくない、という竹村さんからの指摘に対応した。最終的な設計は「各デモページに
訪問者自身が押せる手動リセットボタン＋説明書き」を置いた上で、押し忘れ対策として
「30分ごとの自動リセット（cron）」を併用する、という組み合わせに決まっている。

このセッションでは既に以下5デモのコード側（`review-files/<demo>/`）に、
手動リセットボタン・API・注意書き・テストを追加済み：

- dlq-dashboard-demo（`POST /api/demo-reset`）
- workflow-builder-demo（`POST /api/demo-reset`、加えて生JSON表示バグの修正も含む）
- excel-instant-webapp-demo（`POST /api/demo-reset`）
- bulk-chunked-import-demo（`POST /api/demo-reset`）
- multitenant-isolation-checker-demo（`POST /demo-reset`）

いずれも `review-files/<demo>/README.md` に2026-09-02付けで変更内容を記載済み。
詳細は `VPS-DEPLOY-PENDING.md` の項目27を参照。

以下2点をお願いしたい。

## 1. 上記5デモのコードを本番へ反映

いつもの方式（`review-files/<demo>/`の最新内容を、リモートにしか無い古い
ファイルも含めて完全に「同期」する形。tarでの単純な「追加」だと、以前
csv-insight-chart-demo等で古いビルド成果物が残存した前例があるため、
必ず同期にすること）で反映してほしい。

反映後、以下を確認して報告してほしい（これまでの反省を踏まえ、WebFetchでの
外部要約ではなく、VPS側で直接curlまたはAPI呼び出しして確認する方式でお願いします）：

- 各デモのトップ画面に、リセットボタンと注意書きパネルが表示されていること
- 各デモで `POST /api/demo-reset`（multitenant-isolation-checker-demoのみ
  `POST /demo-reset`）を実際に叩き、`{"ok":true,"resetAt":"..."}` が返ること
- workflow-builder-demoのサンプルワークフローを実際にブラウザから１回実行し、
  生JSONではなく整形されたHTML確認画面が表示されること（今回修正したバグ）
- dlq-dashboard-demoで「バッチを実行する」を押すと、リセット直後は
  `failureCount: 2`（ORD-004・ORD-008が失敗）になり、失敗タスク一覧に新規の
  `pending`エントリが出ること
- multitenant-isolation-checker-demoに、リセット後もこれまで通りテナントA/Bで
  ログインできること（`seedDatabase`の再投入が正しく動くことの確認）

## 2. 30分ごとの自動リセットcronを設定する（手動ボタンの併用・セーフティネット）

`review-files/reset-demo-state.sh` をVPS上の実際の配信先パス（`REMOTE_BASE`）に
合わせて配置し、以下のcronを設定してほしい。

```
*/30 * * * * REMOTE_BASE=/opt/portfolio-demos /path/to/reset-demo-state.sh >> /var/log/demo-reset.log 2>&1
```

（`REMOTE_BASE`・cronのユーザー・ログ出力先は実際の運用に合わせて調整してよい）

このスクリプトは、dlq-dashboard-demo・bulk-chunked-import-demo・
multitenant-isolation-checker-demoの3件については、起動時に一度だけ
ファイル/DBをメモリへ読み込む実装のため、ファイルを戻した後にPM2再起動も
行う設計にしている（スクリプト内コメント参照）。手動ボタン側は各アプリの
既存プロセス内で完結する即時リセットのため再起動しないが、cron側は
プロセスごとクリーンにする、という役割分担になる。

設定後、`crontab -l` の出力と、初回の自動実行が動いたことをログで確認して
報告に含めてほしい。

## 補足

もし実際に動かしてみてスクリプトの前提（読み直し実装かキャッシュ実装か等）と
違う挙動（エラーになる、反映されない等）があれば、コード側の理解が誤っている
可能性があるので、その旨教えてほしい。
