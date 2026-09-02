#!/bin/bash
# 状態を持つデモ5件を、30分ごとに「サンプルのみ・訪問者の操作痕跡なし」の
# 初期状態へ自動的に戻すスクリプト。VPS上でcronから30分おきに実行する想定。
#
# 対象と方式（各アプリのストア実装を実際に読んで、キャッシュの有無を確認した上で決定）：
#   - dlq-dashboard-demo, bulk-chunked-import-demo, multitenant-isolation-checker-demo：
#     起動時にファイル/DBをメモリへ読み込みキャッシュする実装のため、
#     ファイルを戻すだけでは反映されない。PM2再起動が必須。
#   - workflow-builder-demo, excel-instant-webapp-demo：
#     リクエストのたびにファイルを読み直す実装のため、ファイルを戻すだけで反映される
#     （再起動不要）。
#
# 使い方：
#   REMOTE_BASE=/opt/portfolio-demos ./reset-demo-state.sh
# （デモの配信先ベースディレクトリが違う場合はREMOTE_BASEを調整）

set -euo pipefail
BASE="${REMOTE_BASE:-/opt/portfolio-demos}"

echo "[$(date -Iseconds)] デモ状態リセット開始"

# --- 再起動不要（ファイル上書きのみ） ---

echo "workflow-builder-demo をリセット"
echo '[]' > "$BASE/workflow-builder-demo/data/workflows.json"
echo '[]' > "$BASE/workflow-builder-demo/data/executions.json"
find "$BASE/workflow-builder-demo/data" -maxdepth 1 -type f -name "*.csv" -delete

echo "excel-instant-webapp-demo をリセット"
printf '[]\n' > "$BASE/excel-instant-webapp-demo/data/apps.json"
find "$BASE/excel-instant-webapp-demo/data/records" -maxdepth 1 -type f -name "*.json" -delete
find "$BASE/excel-instant-webapp-demo/data/import-jobs" -maxdepth 1 -type f -not -name ".gitkeep" -delete

# --- ファイル初期化 + PM2再起動が必須（起動時に一度だけメモリへ読み込む実装のため） ---

echo "dlq-dashboard-demo をリセット"
echo '{}' > "$BASE/dlq-dashboard-demo/db/orders.json"
: > "$BASE/dlq-dashboard-demo/db/dlq.jsonl"

echo "bulk-chunked-import-demo をリセット"
rm -f "$BASE/bulk-chunked-import-demo/data/import.db"

echo "multitenant-isolation-checker-demo をリセット"
rm -f "$BASE/multitenant-isolation-checker-demo/db/data.sqlite"

echo "PM2再起動（上記3件。テナントA/Bやフィクスチャは各アプリの起動処理が自動で再生成する）"
pm2 restart dlq-dashboard-demo bulk-chunked-import-demo multitenant-isolation-checker-demo

echo "[$(date -Iseconds)] デモ状態リセット完了"
