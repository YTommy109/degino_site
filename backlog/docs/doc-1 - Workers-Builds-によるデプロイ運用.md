---
id: doc-1
title: Workers Builds によるデプロイ運用
type: guide
created_date: '2026-08-14 01:35'
updated_date: '2026-08-14 04:03'
---
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

Cloudflare の Notifications には Workers Builds のビルド失敗という通知種別は無い。
利用できる手段は以下の 2 つ。

### 1. GitHub のチェック実行（追加設定不要・現在の運用）

Workers Builds は push したコミットに Check Run を付けるため、失敗すると GitHub から通知される。
失敗した Check Run の「Details」から Cloudflare のビルドログへ遷移でき、GitHub 上から Rerun もできる。

### 2. Queues の Event Subscriptions（任意）

`cf.workersBuilds.worker.build.failed` イベントを Queue に流し、通知用 Worker から
Slack / メール / webhook へ送る。Cloudflare 公式の Slack 通知テンプレートがある。
Queue と通知用 Worker を別途作る必要があるため、必要になった時点で導入する。

- https://developers.cloudflare.com/queues/event-subscriptions/
- https://github.com/cloudflare/templates/tree/main/workers-builds-notifications-template

### ビルド状況の確認

`degino-site` > Deployments タブ、または Settings > Build のビルド履歴からログを参照する。

## ビルドログで確認すべき点

- `git submodule update --init --recursive` が成功し `themes/hyde` が取得されていること
- `zola 0.22.1` が表示され `zola build` が `Done in ...` で終わること
- `wrangler deploy` が `public/` のアセットをアップロードして完了すること


## 本番ドメインの構成

<!-- derived-from #ビルドログで確認すべき点 -->

TASK-1.5 で www.degino.com を GitLab Pages から Workers へ切り替えた時点の構成。

| 対象 | 設定 | 管理場所 |
| --- | --- | --- |
| www.degino.com | Workers カスタムドメイン（degino-site） | `wrangler.jsonc` の `routes` |
| degino.com | 308 -> `https://www.degino.com{path}`（クエリ保持） | Cloudflare の Redirect Rule（ダッシュボード） |
| degino.com の DNS | CNAME -> tommy109.gitlab.io（プロキシ ON） | Cloudflare DNS |
| HTTPS 強制 | Always Use HTTPS = ON | SSL/TLS > Edge Certificates |
| 証明書 | Universal SSL（degino.com / *.degino.com） | Cloudflare 自動発行・自動更新 |

Redirect Rule だけはリポジトリではなくダッシュボードにしか無い。ゾーン設定を作り直す際は
再作成が必要になる。Cloudflare 提供の「Redirect from WWW to root」テンプレートは向きが逆で、
適用すると www 側が壊れる。カスタムルール（`Hostname equals degino.com`）で作ること。

## ローカルからの手動デプロイ

`npm run deploy`（`wrangler deploy`）で実行する。認証は `wrangler login` の OAuth を使う。

かつてリポジトリ直下に `.env` が置かれており、wrangler がその `CLOUDFLARE_API_TOKEN` を
読んで OAuth 認証を上書きするため `Authentication error` で失敗していた。この `.env` は
DNS 集約作業のファイルが置き去りになっていたもので、TASK-1.6 で削除済み。同じ事故を防ぐため
`.gitignore` にも `.env` を明記した（それまではグローバルの `~/.config/git/ignore` だけが
除外しており、単一障害点になっていた）。
