---
id: TASK-1.7
title: GitLab Pages 由来の DNS レコードを撤去する
status: To Do
assignee: []
created_date: '2026-08-14 04:04'
labels:
  - dns
dependencies:
  - TASK-1.6
parent_task_id: TASK-1
priority: medium
type: chore
ordinal: 9000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
TASK-1.5 で www.degino.com を Cloudflare Workers へ切り替えたが、切り戻し経路を残すため GitLab 由来の DNS 設定はそのままにしてある。本番が安定して稼働していると判断できた時点で撤去する。

## 現状（2026-08-14 時点）

| レコード | 内容 | 備考 |
| --- | --- | --- |
| CNAME degino.com | -> tommy109.gitlab.io（プロキシ ON） | Redirect Rule がエッジで完結するためオリジンには到達しないが、向き先としては GitLab のまま |
| TXT _gitlab-pages-verification-code.degino.com | gitlab-pages-verification-code=... | GitLab のドメイン所有確認用 |
| TXT _gitlab-pages-verification-code.www.degino.com | gitlab-pages-verification-code=... | 同上 |

gitlab.com 側の Pages ドメイン登録も残っている。これを削除すると GitLab が取得していた Let's Encrypt 証明書も失われ、GitLab への切り戻しは再取得（＝ダウンタイム）を伴うようになる。

## apex CNAME の向き先について

単に削除すると apex の名前解決が消える。Redirect Rule はプロキシされたトラフィックにしか適用されないため、プロキシ ON のレコードが apex に存在し続ける必要がある。向き先の候補を比較して決めること。同一ゾーン内のプロキシ済みレコードへ CNAME するとオリジンループになり得る点に注意。

## 前提

撤去後は GitLab への切り戻しが実質不可能になるため、本番の安定稼働を確認してから着手する。
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 gitlab.com 側の Pages ドメイン登録が削除されている
- [ ] #2 _gitlab-pages-verification-code の TXT 2 件が削除されている
- [ ] #3 apex の DNS が GitLab に依存しない向き先に変更され、https://degino.com/ が引き続き www へ 308 リダイレクトすることを実測で確認できている
- [ ] #4 撤去後の DNS 構成が doc-1 に反映されている
<!-- AC:END -->
