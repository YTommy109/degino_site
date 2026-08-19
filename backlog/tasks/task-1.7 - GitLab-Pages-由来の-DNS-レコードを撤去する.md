---
id: TASK-1.7
title: GitLab Pages 由来の DNS レコードを撤去する
status: Done
assignee: []
created_date: '2026-08-14 04:04'
updated_date: '2026-08-19 07:48'
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
- [x] #1 gitlab.com 側の Pages ドメイン登録が削除されている
- [x] #2 _gitlab-pages-verification-code の TXT 2 件が削除されている
- [x] #3 apex の DNS が GitLab に依存しない向き先に変更され、https://degino.com/ が引き続き www へ 308 リダイレクトすることを実測で確認できている
- [x] #4 撤去後の DNS 構成が doc-1 に反映されている
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
1. apex の CNAME(→tommy109.gitlab.io) を AAAA 100:: proxied へ置換（www/befold と同じ慣行に揃える）
2. _gitlab-pages-verification-code の TXT 2 件を削除
3. https://degino.com/ が www へ 308 リダイレクトすることを実測
4. doc-1 の DNS 構成を更新
5. gitlab.com 側の Pages ドメイン登録削除はユーザーが実施
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
調査（2026-08-19）: Cloudflare ゾーン degino.com (27bb9209...) の GitLab 残骸は当初の記載どおり 3 件。
- CNAME degino.com -> tommy109.gitlab.io (proxied, id 678f113d7699c56771bc36995bb482a5)
- TXT _gitlab-pages-verification-code.degino.com (id f956f902b79c2856c33c9833c655181a)
- TXT _gitlab-pages-verification-code.www.degino.com (id 9683c9cff904a9f153478d4c23e0298a)

apex の向き先: ゾーン内の www.degino.com / befold.degino.com / staging.befold.degino.com はいずれも AAAA 100:: (proxied) のプレースホルダ方式。apex も同方式に揃えるのが最小変更で、GitLab 非依存・オリジンループなし・Redirect Rule はエッジで従来どおり適用される。新方式は不要。

ブロッカー: cloudflare-api MCP のトークンは DNS が読み取り専用。dns_records への PUT/PATCH/DELETE がいずれも 10000 Authentication error で失敗。環境に CLOUDFLARE_API_TOKEN もローカル wrangler 認証も無し。DNS 変更を実行するには DNS:Edit 権限のトークン付与か、ダッシュボードでの手動操作が必要。

実行（2026-08-19）:
- apex 678f113d… を CNAME(tommy109.gitlab.io) -> AAAA 100:: プロキシ ON に置換（PUT success）
- TXT f956f902… / 9683c9cf… を削除（DELETE success）
- ゾーンの全レコードを再取得し、name/content に gitlab を含むものが 0 件であることを確認
- 権威 NS 2 台（tony/tina.ns.cloudflare.com）で _gitlab-pages-verification-code の TXT が NXDOMAIN、apex は A 104.21.87.88 / 172.67.169.46 を返す（CNAME なし）
- curl -sI https://degino.com/ -> 308 location: https://www.degino.com/
- curl -sI 'https://degino.com/posts/?a=1' -> 308 location: https://www.degino.com/posts/?a=1（パス・クエリ保持を確認）
- curl -sI https://www.degino.com/ -> 200
- doc-1 の DNS 表を更新し、apex がプレースホルダ AAAA である理由（Redirect Rule はプロキシ済みトラフィックのみに適用／同一ゾーンへの CNAME はオリジンループ）を追記

AC#1（gitlab.com 側の Pages ドメイン登録削除）はユーザーが実施する方針のため未チェック。

AC#1 の確認（2026-08-19）:
GitLab UI が「Get started with GitLab Pages」ウィザードを出して一覧に辿り着けなかったため、GitLab API で直接確認した。
- GET /projects/tommy109%2Fdegino_site/pages/domains -> [] （登録済みカスタムドメインは 0 件。削除対象は既に存在しなかった）
- GitLab Pages のエッジ（35.185.44.232）に SNI degino.com / www.degino.com で TLS 接続すると、返る証明書は CN=*.gitlab.io のワイルドカードのみ。カスタムドメイン用 Let's Encrypt 証明書は失効済み
- 平文 HTTP は両ホストとも projects.gitlab.io/auth へ 302 を返すだけでコンテンツを返さない

ドメイン登録が消えていた理由は特定していないが、.gitlab-ci.yml 撤去により Pages デプロイが失効し、検証用 TXT の削除で所有確認も失われたことと整合する。

作業中にユーザーがプロジェクトのアーカイブを解除していたため、API で再アーカイブした（POST /projects/:id/archive -> archived: true）。decision-1 の「アーカイブして保持する」状態を維持している。

最終実測: https://degino.com/ -> 308 https://www.degino.com/ 、https://degino.com/posts/?a=1 -> 308 https://www.degino.com/posts/?a=1 、https://www.degino.com/ -> 200。
<!-- SECTION:NOTES:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
GitLab 由来の DNS レコードを撤去した。apex degino.com の CNAME(tommy109.gitlab.io) を AAAA 100::（プロキシ ON）のプレースホルダへ置換し、_gitlab-pages-verification-code の TXT 2 件を削除。apex の方式はゾーン内の www / befold に揃えたもので、Redirect Rule はプロキシ済みトラフィックにのみ適用されるためプロキシ ON のレコードが必要、かつ同一ゾーンへの CNAME はオリジンループになり得るためこの形を選んだ。GitLab 側の Pages カスタムドメイン登録は API 確認の結果 0 件で、カスタムドメイン証明書も失効済みだった。検証は権威 NS 2 台での TXT 消滅確認、ゾーン全レコードに gitlab 参照 0 件、https://degino.com/ とクエリ付き URL の 308 実測、www の 200 実測、および doc-1 への構成反映。
<!-- SECTION:FINAL_SUMMARY:END -->
