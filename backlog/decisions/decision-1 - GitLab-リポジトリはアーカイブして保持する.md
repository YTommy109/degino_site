---
id: decision-1
title: GitLab リポジトリはアーカイブして保持する
date: '2026-08-14 04:04'
status: accepted
---
## Context

<!-- derived-from ../tasks/task-1.5 - www.degino.com-を-Cloudflare-Workers-に切り替える.md -->

degino_site のホスティングを GitLab Pages から GitHub + Cloudflare Workers へ移行した
（TASK-1.1 〜 TASK-1.5）。移行完了時点で gitlab.com:tommy109/degino_site は
リポジトリ・CI・Pages のドメイン登録・Let's Encrypt 証明書がすべて生きたまま残っていた。

保持したままだと、誤って gitlab remote へ push した際に GitLab Pages が古い内容で
再ビルドされる。一方で削除すると Pages のドメイン登録と証明書も同時に失われ、
GitLab への切り戻しは証明書の再取得を伴うダウンタイム込みの作業になる。

## Decision

GitLab リポジトリはアーカイブして保持する。削除はしない。

- ローカルの git remote `gitlab` は削除した（TASK-1.6）
- gitlab.com 側でのアーカイブ操作はダッシュボードから行う（ユーザー操作）
- Pages のドメイン登録と検証用 TXT レコードの撤去は TASK-1.7 で別途扱う

## Consequences

- アーカイブすると読み取り専用になるため、誤 push による GitLab Pages の再ビルドは起きない
- 履歴と Pages の証明書が残るため、TASK-1.7 に着手するまでは GitLab への切り戻しが安価に行える
- アーカイブは解除可能なので、この決定は後から巻き戻せる
- リポジトリ本体を消していない以上、GitLab 上に古いコードが残り続ける。正本は
  github.com:YTommy109/degino_site である旨を CLAUDE.md とデプロイ運用ドキュメントに明記して補う
