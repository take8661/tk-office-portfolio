# VPS側セッションへの依頼（2026-09-02・状態リセットの自動化）

竹村さんから、複数の企業が同じ本番URLを見る前提で、前の訪問者の操作履歴が
残り続けるのはよくないという指摘があった。状態を持つデモを調査したところ、
以下5件が対象と判明した：

- dlq-dashboard-demo（db/orders.json・db/dlq.jsonl）
- workflow-builder-demo（data/workflows.json・data/executions.json）
- excel-instant-webapp-demo（data/apps.json・data/records/・data/import-jobs/）
- bulk-chunked-import-demo（data/import.db）
- multitenant-isolation-checker-demo（db/data.sqlite）

`review-files` 直下に `reset-demo-state.sh` を置いた。以下をそのままVPS側の
Claude Code(SSH)セッションに貼り付けてほしい。

---

`review-files/reset-demo-state.sh` を、VPS上の実際の配信先パスに合わせて
（`REMOTE_BASE`を調整して）VPSへ配置し、以下2点を対応してほしい。

## 1. 今すぐ一回、手動で実行して現状をクリーンにする

竹村さんが今日指摘した2件（dlq-dashboard-demoの「バッチを実行しても何も
起きない」＝2026-08-30の検証データが残ったまま、workflow-builder-demoの
「テスト用フロー」が残っている）を含め、5デモ全部を一度リセットしてほしい。

```bash
REMOTE_BASE=/opt/portfolio-demos ./reset-demo-state.sh
```

実行後、以下を確認して報告してほしい：
- dlq-dashboard-demoで「バッチを実行する」を押すと、`failureCount: 2`
  （ORD-004・ORD-008が失敗）になり、失敗タスク一覧に新規の`pending`エントリが
  出ること（＝リセット前の「全部resolved」状態から、本来のデモ挙動に戻ったこと）
- workflow-builder-demoの一覧から「テスト用フロー」が消えていること
- multitenant-isolation-checker-demoに、これまで通りテナントA/Bでログインできること
  （seedが正しく再実行されていることの確認）

## 2. 30分ごとに自動実行するcronを設定する

```
*/30 * * * * /path/to/reset-demo-state.sh >> /var/log/demo-reset.log 2>&1
```

（`REMOTE_BASE`はスクリプト内で固定するか、cron行に環境変数として埋め込むこと。
実際のログの出力先・cronユーザーは今の運用に合わせて調整してほしい）

設定後、`crontab -l`の出力と、初回の自動実行が動いたことをログで確認して報告に
含めてほしい。

## 補足：スクリプトの中身について

各アプリのソースコードを実際に読んで、以下を確認した上でスクリプトを書いている。

- dlq-dashboard-demo・bulk-chunked-import-demo・multitenant-isolation-checker-demoは、
  起動時に一度だけファイル/DBをメモリに読み込む実装のため、ファイルを戻すだけでは
  反映されない → このスクリプトはこの3つについてPM2再起動も行う
- workflow-builder-demo・excel-instant-webapp-demoは、リクエストのたびにファイルを
  読み直す実装のため、ファイルを戻すだけで反映される → 再起動なしで済ませている
- multitenant-isolation-checker-demoはDB削除後、アプリ自身の起動処理
  （`db/seed.js`のseedDatabase）がテナントA/Bのダミーデータを自動的に再投入する
  設計になっているため、削除だけで安全に初期状態へ戻る
- bulk-chunked-import-demoも同様に、`CREATE TABLE IF NOT EXISTS`で起動時に
  スキーマを自動再作成する設計のため、DBファイル削除だけで安全

もし実際に動かしてみて上記の前提と違う挙動（エラーになる等）があれば、
コード側の理解が誤っている可能性があるので、その旨教えてほしい。
