---
id: doc-1
title: Workers Builds によるデプロイ運用
type: guide
created_date: '2026-08-14 01:35'
updated_date: '2026-08-14 01:35'
---
Cloudflare Workers Builds で GitHub の `YTommy109/degino_site` を自動デプロイするための設定と運用手順。

<!-- constrained-by ../tasks/task-1.3 - Cloudflare-Workers-へ手動でデプロイする.md -->

## ビルド構成

Workers Builds のビルド環境には Zola が入っておらず、また
[wrangler の custom builds（`[build]` セクション）は Workers Builds では無視される](https://developers.cloudflare.com/workers/ci-cd/builds/configuration/)。
そのため Zola の取得・submodule 取得・`zola build` をすべて `scripts/ci-build.sh` に集約し、
`npm run build` から呼び出している。

- Zola のバージョンは `.zola-version` が単一の情報源。CI もローカルもこのファイルを読む
- テーマ `themes/hyde` は submodule のため、スクリプト内で `git submodule update --init --recursive` を実行する
- ローカルに同一バージョンの `zola` がある場合はダウンロードをスキップする

## ダッシュボードでの接続手順

Worker `degino-site` は作成済み。GitHub 連携は OAuth が必要なためダッシュボードで行う。

1. Cloudflare ダッシュボード > Compute (Workers) > `degino-site` > Settings > Build
2. **Connect to Git** から GitHub の `YTommy109/degino_site` を選択（初回は Cloudflare GitHub App の認可が必要）
3. 各項目を以下で設定する

| 項目 | 値 |
| --- | --- |
| Git branch | `main` |
| Build command | `npm run build` |
| Deploy command | `npx wrangler deploy` |
| Root directory | （空欄 = リポジトリルート） |

4. 保存後、`main` へ push するとビルドが起動する

## ビルド失敗の検知

- **通知**: ダッシュボード > Notifications > Add > Workers Builds の
  "Build failed" を有効にし、宛先に tokutomi@degino.com を設定する
- **ビルド状況の確認**: `degino-site` > Deployments タブ、または Settings > Build のビルド履歴からログを参照する
- GitHub 側では、push したコミットのステータスチェックに Workers Builds の結果が表示される

## ビルドログで確認すべき点

- `git submodule update --init --recursive` が成功し `themes/hyde` が取得されていること
- `zola 0.22.1` が表示され `zola build` が `Done in ...` で終わること
- `wrangler deploy` が `public/` のアセットをアップロードして完了すること
