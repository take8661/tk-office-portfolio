# VPS側セッションへの依頼（2026-09-02・config-rollback-demoリセット追加＋自動リセットcronの確認【重要】）

## 背景

竹村さんより「サンプルシナリオを投入した後にクリアするボタンが無い」「30分ごとの
自動リセットも反映されていない」と繰り返し指摘があった。調査の結果2つの問題が
判明した。

1. config-rollback-demoには最初からリセット機能が実装されていなかった（項目27で
   5デモにリセット機能を追加した際、対象の洗い出しからこのデモが漏れていた）
2. 30分ごとの自動リセットcron（`vps-session-request-20260902d.md`・`e.md`で
   依頼済み）が、実際に設定されたかどうかの確認記録が一度も無い

## 1. config-rollback-demoのリセット機能を反映

`review-files/config-rollback-demo/`側で以下を実装・テスト済み（詳細は
`VPS-DEPLOY-PENDING.md`項目30参照）。

- `server/configStore.js`：`resetToInitial()`追加
- `server/app.js`：`POST /api/demo-reset`追加
- `public/admin.html`：「今すぐこのデモをリセットする」ボタン追加
- テスト19/19 PASS

反映後、公開URLの`/admin`で「サンプルシナリオを投入する」→「今すぐこのデモを
リセットする」の順に押し、世代一覧が1行（世代1）に戻ることを確認してほしい。

## 2.【最優先・必ず実施】30分ごとの自動リセットcronの設定と、その証拠の提示

これまで2回（`vps-session-request-20260902d.md`・`e.md`）依頼したが、実際に
設定されたのか、こちらでは一度も確認できていない。今回は「設定しました」だけの
報告では不十分なので、以下の手順で進めてほしい。

### 手順

1. 更新した`review-files/reset-demo-state.sh`（今回config-rollback-demoを追加、
   計6デモ対象）を、VPS上の実際の配信先パスに合わせて配置する
2. まず**手動で1回実行**する
   ```
   REMOTE_BASE=/opt/portfolio-demos ./reset-demo-state.sh
   ```
   （`REMOTE_BASE`は実際の配信先パスに合わせて調整）
3. 対象6デモ（workflow-builder-demo・excel-instant-webapp-demo・
   dlq-dashboard-demo・bulk-chunked-import-demo・multitenant-isolation-checker-demo・
   config-rollback-demo）の公開URLを開き、実際に初期状態へ戻っていることを
   目視で確認する
4. 問題なければcrontabに登録する
   ```
   */30 * * * * REMOTE_BASE=/opt/portfolio-demos /path/to/reset-demo-state.sh >> /var/log/demo-reset.log 2>&1
   ```
5. **`crontab -l`の実際の出力をそのままコピーして報告に含める**（「設定しました」
   という文章だけでなく、コマンドの生出力を貼り付けてほしい）
6. 30分以上経ってから、`/var/log/demo-reset.log`の中身（自動実行が実際に走った
   ログ）も貼り付けて報告する

このcronがもし技術的な理由（VPSのcron権限が無い、PM2の運用と噛み合わない等）で
難しい場合は、「できません」ではなく**具体的に何が障害になっているか**を教えて
ほしい。代替手段（例：Node.js側で`setInterval`によるアプリ内蔵タイマーに変更する等）
を検討する。

## 補足

各修正内容の技術的詳細は`VPS-DEPLOY-PENDING.md`の項目30を参照。今回も、
WebFetchでの外部要約ではなく、VPS側で直接curlまたはブラウザで確認する方式で
お願いします。
