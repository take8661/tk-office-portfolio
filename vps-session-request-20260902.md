# VPS側セッションへの依頼文（2026-09-02）

以下をそのままVPS側のClaude Code(SSH)セッションに貼り付けてください。

---

以下3つのデモで、「サンプルボタン」機能をコミット・デプロイしたはずなのに、
本番URLを直接確認したところ実際には反映されていないことが分かった。
原因調査と、確実な再反映をお願いしたい。

対象：
1. ocr-structuring-demo
2. csv-insight-chart-demo
3. gov-spec-checklist-extractor-demo

## 確認手順（まず現状把握）

各デモについて、以下を順に実行して結果を教えてほしい。

1. 本番が実際に配信している内容を直接確認する（PM2のプロセス一覧やコミットログを
   信用せず、実際にHTTPで取得する）：
   ```
   curl -s https://<demo>.demos.himitsuno-heya123.com/ | grep -c "サンプル"
   ```
   0件なら反映されていない証拠。

2. PM2がそのデモをどのディレクトリ・どのエントリファイルで動かしているか確認：
   ```
   pm2 describe <demo名> | grep -E "cwd|script path|exec cwd"
   ```

3. そのcwd配下の実ファイルが、期待する内容を含んでいるか確認：
   - ocr-structuring-demo: `public/index.html` に `sample-button` という文字列があるか
     （`grep -n "sample-button" public/index.html`）
   - csv-insight-chart-demo: `dist-web/`（または実際に配信されているビルド出力先）配下の
     JSバンドルに「サンプルCSV」という文字列が含まれているか
     （`grep -rl "サンプルCSV" dist-web/`）。また `dist-web/` の生成時刻とソース
     （`src/web/App.tsx` 等）の更新時刻を比較し、ビルドの方が古くないか確認
     （`ls -la --time-style=full-iso dist-web/ src/web/App.tsx`）
   - gov-spec-checklist-extractor-demo: 同様に配信先ビルド出力（`apps/web/dist/`等）に
     「サンプルPDF」という文字列が含まれているか、ビルドとソースの更新時刻を比較

4. 上記3〜4で「本番のファイルが古い／期待する文字列が無い」と分かったら、
   正しいソース（`review-files/<demo>/` の最新版）から改めてビルド・配信先への
   コピー・PM2再起動を行う。csv-insight-chart-demoとgov-spec-checklist-extractor-demoは
   ビルドが必要な構成（Vite/tsc）なので、`npm run build` 等のビルドコマンドを
   review-files側の最新ソースに対して実行してから配信先へ反映すること。

## 絶対にやってほしいこと（今回の教訓）

「PM2がonlineになった」「再起動した」は反映の証拠にならない。**必ず最後に
本番URLへ実際にHTTPでアクセスして、期待する文字列が含まれているかを
grep等で確認**し、その出力（コマンドとその結果）をそのまま報告に含めてほしい。
「反映しました」だけの報告ではなく、「これを実行してこの結果が返ってきたので
反映を確認した」という形で教えてほしい。

例（このコマンドと出力を報告に含める）：
```
$ curl -s https://ocr-structuring-demo.demos.himitsuno-heya123.com/ | grep -o "サンプル[^<]*"
同梱サンプル画像で試す（架空データ）
```

この形式の確認が3つとも取れて初めて完了とする。

## ついでに：まだVPS未反映の新規3件も、同じ確認方式でお願いしたい

`VPS-DEPLOY-PENDING.md` の項目24〜26（text-extraction-demo・workflow-builder-demo・
excel-instant-webapp-demo）はローカルで修正・テスト済みだが、まだVPSに一度も
反映していない。これらも今回まとめて反映してほしい。反映後は、上と同じように
実際にcurlで本番URLを取得し、期待する文字列（例：text-extraction-demoなら
「サンプル文を試す」、workflow-builder-demoなら「サンプルワークフローを作成して
実行してみる」、excel-instant-webapp-demoの一覧画面なら「同梱サンプルExcelで試す」）
が実際に含まれていることを確認したうえで報告してほしい。

## 今後の運用について

今回、「ローカルでテストPASS」「コミットした」「PM2再起動した」の3つが揃っていても、
実際には本番に反映されていないケースが3件見つかった。今後この種のズレを防ぐため、
デプロイ作業の最後に必ず「本番URLへの実アクセス＋grep」による確認を1ステップとして
組み込んでほしい。省略しないでほしい。
