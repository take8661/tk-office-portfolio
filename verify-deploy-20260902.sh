#!/bin/bash
# 使い方：
#   1. review-files フォルダの直下（local-manifest-20260902.txt と同じ場所）で実行する
#   2. VPS上の配信先ベースディレクトリを REMOTE_BASE に合わせて調整する
#      （例：/opt/portfolio-demos。demoごとに違う場合はスクリプト内のロジックを調整）
#   3. VPSへの疎通が確立済みのsshエイリアス名を REMOTE_HOST に設定する
#
# このスクリプトは「PM2がonlineか」「特定の1文字列がgrepで見つかるか」ではなく、
# ローカル（review-files）とVPS上の配信ファイルを1ファイルずつsha256で突き合わせて、
# 本当に一致しているかを機械的に確認する。今回のような「一部のファイルだけ
# 反映されていない」「古いファイルが残っている」という食い違いを漏れなく検出する。

set -euo pipefail

REMOTE_HOST="${REMOTE_HOST:?REMOTE_HOSTを設定してください（例: REMOTE_HOST=vps-prod ./verify-deploy-20260902.sh）}"
REMOTE_BASE="${REMOTE_BASE:-/opt/portfolio-demos}"
LOCAL_MANIFEST="local-manifest-20260902.txt"

if [ ! -f "$LOCAL_MANIFEST" ]; then
  echo "エラー: $LOCAL_MANIFEST が見つかりません。review-filesフォルダ直下で実行してください。" >&2
  exit 1
fi

DEMOS=$(cut -d'|' -f1 "$LOCAL_MANIFEST" | sort -u)

echo "=== リモート側マニフェストを取得中（demoごとに1回SSH） ==="
> /tmp/remote-manifest.txt
for demo in $DEMOS; do
  echo "  - $demo"
  ssh "$REMOTE_HOST" "
    cd '$REMOTE_BASE/$demo' 2>/dev/null && \
    find . -type f \
      -not -path '*/node_modules/*' -not -path '*/.git/*' \
      -not -path './logs/*' -not -path './data/*' \
      -not -name '.env' -not -name '*.log' \
      -exec sha256sum {} \; | \
    awk -v demo='$demo' '{print demo\"|\"\$2\"|\"\$1}'
  " >> /tmp/remote-manifest.txt || echo "$demo|__DEMO_DIR_NOT_FOUND__|-" >> /tmp/remote-manifest.txt
done

echo ""
echo "=== 突き合わせ結果 ==="
sort "$LOCAL_MANIFEST" > /tmp/local-sorted.txt
sort /tmp/remote-manifest.txt > /tmp/remote-sorted.txt

MISMATCH=0
for demo in $DEMOS; do
  local_only=$(comm -23 <(grep "^$demo|" /tmp/local-sorted.txt) <(grep "^$demo|" /tmp/remote-sorted.txt) | wc -l)
  remote_only=$(comm -13 <(grep "^$demo|" /tmp/local-sorted.txt) <(grep "^$demo|" /tmp/remote-sorted.txt) | wc -l)
  if [ "$local_only" -gt 0 ] || [ "$remote_only" -gt 0 ]; then
    MISMATCH=1
    echo ""
    echo "## $demo : 不一致あり（ローカルのみ${local_only}件 / リモートのみ${remote_only}件）"
    echo "--- ローカルにあってリモートに無い、またはハッシュが違うファイル ---"
    comm -23 <(grep "^$demo|" /tmp/local-sorted.txt) <(grep "^$demo|" /tmp/remote-sorted.txt) | cut -d'|' -f2
    echo "--- リモートにあってローカルに無い、またはハッシュが違うファイル（残存ゴミの可能性） ---"
    comm -13 <(grep "^$demo|" /tmp/local-sorted.txt) <(grep "^$demo|" /tmp/remote-sorted.txt) | cut -d'|' -f2
  else
    echo "## $demo : 完全一致（OK）"
  fi
done

echo ""
if [ "$MISMATCH" -eq 0 ]; then
  echo "=== 結論：全demo完全一致。反映漏れなし ==="
else
  echo "=== 結論：不一致のあったdemoを上記の通り修正・再反映し、もう一度このスクリプトを実行して0件になることを確認してください ==="
fi
