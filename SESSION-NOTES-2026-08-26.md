# 作業サマリー（2026-08-26時点・圧縮前メモ）

## プロジェクト概要
- ポートフォリオサイト本体: `C:\tk-office-portfollo\index.html`（Windows実機、GitHubリポジトリ `take8661/tk-office-portfolio` にpush）
- クラウド側ミラー: `/home/claude/tk-office-portfolio/index.html`（cloudサンドボックス、GitHubへの直接pushは不可）
- 同期フロー: クラウド側で編集・commit → `SendUserFile` で `file_uuid` 取得 → `device_commit_files(force:true)` で `C:\tk-office-portfollo` に書き込み → `device_bash` で実機側 `git add && git commit`（ロックファイル `.git/index.lock` 等が残ることがあり、`device_request_delete_permission` の再許可が必要になる場合あり）→ 最終的な `git push origin main` はユーザーが実施。

## 今回のセッションでやったこと
1. **GROUP D（35件のデモ）のスクリーンショット埋め込み**
   - ユーザー自身のChromeブラウザ（`mcp__claude-in-chrome__*`）で各デモURLに実際にアクセスし、スクリーンショットを撮影。
   - 33件（d-19, d-30を除く）を `assets/img/demo-shots/d-NN-{slug}.jpg` として保存し、各`.work-visual`カードの先頭に`<img>`として挿入。
   - 撮影パターン: 新規ドメインは `navigate` 単独 → `computer wait` 単独 → `computer screenshot(save_to_disk:true)`。1回目のscreenshotはほぼ毎回タイムアウトするが、2回目（単独呼び出し）で成功する。`browser_batch`で異なるドメインへの複数`navigate`をまとめるとパーミッションエラーになるため、1URL=1回の`navigate`で処理。

2. **「非機能要件オプションカタログ」セクションの追加**
   - AI開発パイプラインが各案件の実装指示作成時に自動判定する非機能要件メニュー（7カテゴリ・18項目：ログ管理/エラーハンドリング/データ整合性/監視/パフォーマンス/セキュリティ/生成AIガードレール）を、既存の`.trigger-block`/`.modules-grid`デザインを流用して追加。
   - ソースは `bunkai-pipeline\non-functional-menu.md`（内部パイプライン仕様、クライアント固有情報は含まれない）。
   - セクション番号を06→07（DEV OPS）、07→08（TECH STACK）にリナンバー。
   - 追加のたびに `grep -n "山渓"` でクライアント名の混入がないか確認（実施済み・全てクリーン）。**これは今後の全編集で毎回チェックすること。**

3. **ユーザーが実際に本番デモを触って見つけた不具合の調査・対応**
   - **①multitenant-isolation-checker-demo（ログイン不可・401）** → 原因: `.env`の`DEMO_TENANT_A_PASSWORD`/`DEMO_TENANT_B_PASSWORD`未設定でランダム生成されログイン不可能だった。ローカル`.env`にデモ用パスワードを設定済み（`DemoTenantA-2026`/`DemoTenantB-2026`、email: `demo-a@example.invalid`/`demo-b@example.invalid`）。**→ VPS側の`.env`にも同じ値を設定してVPS再起動する必要あり（ユーザーがVPS担当のClaude Code(SSH)セッションに依頼する）。** 未デプロイ。ポートフォリオの`.work-result`にログイン情報を追記済み（commit済み）。
   - **②onetime-consent-demo（404）** → 本番投入手順書に「ローカルデモ専用、インターネット公開は想定外」と明記されていたため、修正ではなく**ポートフォリオから該当カードを削除**（ユーザー指示「これは消していいわ」）。GROUP Dの件数を35→34に修正済み、About統計も50→49に修正済み。commit済み。
   - **③bulk-chunked-import-demo（CSVアップロードでエラー）** → 原因はバグではなく、期待スキーマ（`email,name,phone`の3列固定）と異なる列構成のCSVをアップロードしたことによる`MALFORMED_ROW`（列数不一致の位置ベースチェック、`src/validator.js`）。**修正方針: バリデーションロジックは変更せず、UIにフォーマット説明とサンプルCSVダウンロードリンクを追加。** ローカル(`~/mnt/review-files/bulk-chunked-import-demo/public/`)の`index.html`/`style.css`/`sample.csv`は編集済み・`validateRow`関数への直接テストで動作確認済み。**→ まだVPSに未デプロイ。** ユーザーがVPS担当セッションに反映依頼する必要あり。

4. **件数の訂正**
   - 「残り21件」という発言は誤り（本番投入手順書がある案件だけを数えていた）。実際は35案件（現在34）全体が対象。ユーザーは残りを自分で一つずつ手動テストすると発言（「いや、俺が一個一個動かすわ」）。→ 今後は指摘があったものだけ個別対応する方針。

5. **【調査中・未完了】ocr-structuring-demo（D-01・OCR構造化デモ）**
   - ユーザーが実際の領収書画像をアップロードしたところ、全く無関係な固定データ（店舗名「サンプルコンビニ」、2270円、2026-08-30、ステータス「成功」）が返ってきた。
   - `test/`ディレクトリに`mockProvider.test.js`・`aiFallbackClassifier.test.js`が存在することから、APIキー未設定時にモック/フォールバックプロバイダが**エラー表示なしで**サイレントに動作している可能性が濃厚（他のデモのような「APIキー未設定」バナーが出ない）。
   - **【根本原因、確定】** `src/ocr/ocrProvider.js`の`resolveProviderName()`にて、`OCR_PROVIDER_RECEIPT`/`OCR_PROVIDER_HANDWRITTEN_FORM`/`OCR_PROVIDER`のいずれも未設定の場合、**エラーを出さずに`mock`プロバイダへ静かにフォールバックする設計**になっている（コメント曰く「デモ用既定値」）。`src/ocr/providers/mockProvider.js`は画像のSHA256ハッシュから決定論的に店名/金額を生成するダミー実装（`SAMPLE_STORES = ['サンプルコンビニ','サンプル文具店','サンプル飲食店']`、日付は常に`2026-08-30`固定、confidence常に0.9）で、外部通信は一切行わない。
   - `src/routes/documents.js`のAPIレスポンスには`provider: provider.name`（"mock"等）が含まれているが、`public/app.js`はこの値を一切読んでおらず、画面に警告表示するロジックが存在しない。→ **他のデモ（text-extraction-demoなど）が使っている「.envにOPENAI_API_KEYを設定してください」のような赤字バナーパターンが、このデモにだけ実装されていない。**
   - つまり: バグではなく「未設定時はmockで動くように作られている」という設計自体は他デモと同じだが、**ユーザーへの警告表示だけが漏れている**のが真因。同じセッションでユーザーが試したtext-extraction-demoは正しく警告バナーが出ており（正常挙動）、この非対称性で確定した。
   - **提案した修正（未実装・ユーザー未回答）**: `public/app.js`側でAPIレスポンスの`provider`が`"mock"`の場合に、他デモと統一感のある警告バナー（例:「⚠️ OCR_PROVIDER未設定のため、ダミーデータを表示しています。実データではありません。」）を結果表示欄の上に出すよう修正する。バリデーション・判定ロジック自体は変更不要。

## 標準ルール（今後も遵守）
- コミットメッセージは末尾に以下を必ず含める:
  ```
  Co-Authored-By: Claude Sonnet 5 <noreply@anthropic.com>
  Claude-Session: https://claude.ai/code/session_01B1feY8yeBUJKbRhCAR2Usj
  ```
- PR説明文の末尾には `🤖 Generated with [Claude Code](https://claude.com/claude-code)` を含める。
- クラウド側からはGitHubにpushできないため、変更サイクルの最後には必ずユーザーに`git push origin main`を促す。
- VPSへの反映はこのセッションでは実施できない（SSHアクセスなし）。ユーザーが別のClaude Code(SSH)セッションに依頼する運用。コピペ可能な具体的手順・値を渡すこと。

## 未解決・保留中の課題
- D-30 (multichannel-inventory-demo) が`Cannot GET /`のまま未対応（初回フラグ後、ユーザーから再言及なし）。
- ①②③の修正はローカルには反映済みだが、VPS本番環境への反映はまだ（ユーザー側で対応予定）。
- ocr-structuring-demo (D-01) の根本原因調査が未完了（次のアクション: `server.js`とプロバイダ選択ロジックを読む）。
