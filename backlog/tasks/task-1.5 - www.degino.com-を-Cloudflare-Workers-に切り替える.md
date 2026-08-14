---
id: TASK-1.5
title: www.degino.com を Cloudflare Workers に切り替える
status: Done
assignee:
  - '@claude'
created_date: '2026-08-13 16:13'
updated_date: '2026-08-14 03:04'
labels: []
dependencies:
  - TASK-1.4
parent_task_id: TASK-1
priority: high
type: task
ordinal: 6000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
DNS は既に Cloudflare で一元管理しているため、www.degino.com の向き先を GitLab Pages から Workers のカスタムドメインに切り替える。

## 移行前の実測状況（2026-08-14 時点）

- www.degino.com CNAME → tommy109.gitlab.io（Cloudflare プロキシ OFF＝グレークラウド）
- degino.com A → 35.185.44.232（GitLab Pages。https://degino.com/ は 308 で https://www.degino.com/ へリダイレクト）
- 証明書: Let's Encrypt / CN=www.degino.com / 有効期限 2026-09-29。TLS 終端は Cloudflare ではなく GitLab Pages 側
- CAA レコードは degino.com・www.degino.com とも未設定（証明書発行のブロック要因なし）

## 証明書の扱い

GitLab Pages の証明書は GitLab が自動取得・自動更新しているもので、秘密鍵を取り出して Cloudflare へ持ち込むことはできないし、その必要もない。Workers のカスタムドメインを設定するとレコードは自動的にプロキシ ON になり、TLS 終端が Cloudflare エッジへ移って Universal SSL が自動発行・自動更新する。移行作業としての証明書コピーは発生しない。

## 注意点

1. カスタムドメイン追加直後は証明書発行まで数十秒〜数分の空白があり、その間 ERR_CERT_* になり得る。低トラフィック時間帯に切り替える。
2. 切り戻しのため、Workers 側が安定するまで GitLab 側のドメイン登録を削除しない。削除すると証明書も失われ、戻す際に再取得＝再びダウンタイムになる。
3. apex の www へのリダイレクトを返しているのは GitLab Pages 自身であり、A レコードを外すと同時に消える。Cloudflare の Redirect Rule で置き換えること。証明書よりこちらの方が忘れた際の実害が大きい。
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 https://www.degino.com/ が Cloudflare Workers から配信されている
- [x] #2 https://degino.com/ が Cloudflare の Redirect Rule で https://www.degino.com/ へリダイレクトする
- [x] #3 HTTPS が有効で証明書エラーが出ない（Universal SSL の発行完了を確認）
- [x] #4 切り戻し手順が記録されている（GitLab 側のドメイン登録を残した状態で戻せること）
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
1. 事前確認: degino-site worker が最新デプロイ済みで、workers.dev の応答が本番と一致することを確認する（済: / の HTML が完全一致）
2. Universal SSL の状態を確認する（済: degino.com / *.degino.com を含む universal pack が active。証明書の空白は発生しない）
3. www: 既存 CNAME www.degino.com -> tommy109.gitlab.io を削除し、degino-site に Workers Custom Domain として www.degino.com を追加する（レコードは自動でプロキシ ON になる）
4. www の HTTPS 応答・server ヘッダ・本文が Workers 由来であることを確認する
5. apex: CNAME degino.com -> tommy109.gitlab.io を CNAME degino.com -> www.degino.com（プロキシ ON）に置き換え、http_request_dynamic_redirect ruleset に degino.com -> https://www.degino.com/$1 の 301 Redirect Rule を追加する（GitLab Pages が返していた apex リダイレクトの代替）
6. apex / www 双方のリダイレクトとステータスを実測で検証する
7. GitLab 側のドメイン登録・_gitlab-pages-verification-code TXT は削除せず残す。切り戻し手順を Implementation Notes に記録する（撤去は TASK-1.6）
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
www.degino.com の切り替えを完了した（2026-08-14 02:20 UTC）。

## 実施内容
- CNAME www.degino.com -> tommy109.gitlab.io（proxied=false, ttl=300）を削除
- wrangler.jsonc に routes: [{ pattern: 'www.degino.com', custom_domain: true }] を宣言し wrangler deploy。Cloudflare がプロキシ ON のレコードを自動作成した
- routes を設定すると workers.dev が既定で無効化されるため、切り戻し確認用に workers_dev: true を明示した

## 実測（切替後）
- dig www.degino.com -> 104.21.87.88 / 172.67.169.46（Cloudflare エッジ）
- https://www.degino.com/ -> 200, server: cloudflare。本文は workers.dev の応答と完全一致
- 証明書エラーなし。Universal SSL の pack（degino.com / *.degino.com, Google Trust Services, 2026-11-10 まで）が切替前から active だったため、証明書発行の空白は発生しなかった
- /about -> 307 /about/（trailing slash 正規化）、存在しない URL -> 404

## 判明したこと
- リポジトリ直下の .env に CLOUDFLARE_API_TOKEN があり、wrangler がこれを読んで OAuth 認証を上書きするため deploy が Authentication error で失敗する。ローカルで wrangler を実行する際は .env を退避する必要がある。Workers Builds の CI には .env が無いため影響しない

## 未完了: apex の Redirect Rule
- degino.com は現時点も GitLab Pages 経由で 308 -> https://www.degino.com/ を返しており、リダイレクト自体は生きている
- Cloudflare の Redirect Rule（rulesets phase http_request_dynamic_redirect）の作成が、.env のトークン・MCP のトークンとも 10000 Authentication error で拒否された。rulesets の書き込み権限が無い
- ルールを作る前に apex を Cloudflare プロキシへ向けると重複コンテンツになるため、apex の DNS は GitLab のまま据え置いた

## 切り戻し手順
1. wrangler.jsonc の routes を削除して wrangler deploy（.env を退避して実行）。またはダッシュボードで degino-site のカスタムドメイン www.degino.com を削除する
2. CNAME www.degino.com -> tommy109.gitlab.io（proxied=false, ttl=300）を再作成する
3. GitLab 側のドメイン登録と _gitlab-pages-verification-code.www.degino.com TXT は削除していないため、GitLab Pages の証明書はそのまま有効で再取得は不要

## apex の切り替えと HTTPS 強制（2026-08-14 03:00 UTC）

- Redirect Rule はユーザーがダッシュボードで作成（rulesets の書き込み権限が両トークンとも無いため）。Cloudflare 提供の 'Redirect from WWW to root' テンプレートは向きが逆で、適用すると www 側が壊れるためカスタムルールで作成した
- ルール作成後に CNAME degino.com のプロキシを ON に変更（content は tommy109.gitlab.io のまま。ルールがエッジで完結するためオリジンには到達しない）
- 順序: ルール作成 -> DNS プロキシ ON。逆順にすると apex が www と同一内容を配信する重複コンテンツの窓ができる
- ダッシュボード作成時に 'DNS configuration may not be proxying traffic' の警告が出るが、上記の順序に沿った想定どおりの状態なので 'Ignore and deploy rule anyway' を選んだ

## 移行で見つけたデグレと対処
GitLab Pages は HTTPS を強制していたが、Cloudflare の Always Use HTTPS が OFF だったため切替直後は http://www.degino.com/ が 200 で平文配信されていた。ユーザーが SSL/TLS > Edge Certificates で ON にして解消。

## 最終検証（実測）
| URL | 結果 |
| --- | --- |
| https://www.degino.com/ | 200、本文が workers.dev の応答と完全一致 |
| https://degino.com/ | 308 -> https://www.degino.com/ |
| https://degino.com/about/?x=1 | 308 -> https://www.degino.com/about/?x=1（パス・クエリ保持） |
| http://www.degino.com/ | 301 -> https://www.degino.com/ |
| http://www.degino.com/about/ | 301 -> https://www.degino.com/about/ |
| http://degino.com/ | 308 -> https://www.degino.com/ |
| 証明書 | CN=degino.com / Google Trust Services / 2026-11-12 まで。エラーなし |

apex のリダイレクトが GitLab ではなく Cloudflare エッジから返っていることは、GitLab 由来のヘッダ（permissions-policy: interest-cohort=(), x-request-id）が消えたことで確認した。
<!-- SECTION:NOTES:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
www.degino.com を GitLab Pages から Cloudflare Workers へ切り替えた。カスタムドメインはダッシュボードでの手作業ではなく wrangler.jsonc の routes に custom_domain で宣言し、Workers Builds からのデプロイでも維持されるようにした。apex は GitLab Pages 自身が返していた 308 リダイレクトを Cloudflare の Redirect Rule で置き換え、その後 CNAME をプロキシ ON にした（逆順だと重複コンテンツの窓ができる）。移行で HTTPS 強制が失われていたことを実測で検出し Always Use HTTPS を有効化した。

検証: https://www.degino.com/ が 200 で本文が workers.dev の応答と完全一致、https://degino.com/ と http:// の apex・www がいずれも www の HTTPS へリダイレクト（パス・クエリ保持を /about/?x=1 で確認）、証明書は CN=degino.com / Google Trust Services / 2026-11-12 まででエラーなし。GitLab 由来ヘッダの消失により apex のリダイレクトが Cloudflare エッジ由来であることを確認した。

GitLab 側のドメイン登録と検証用 TXT は残したままで、CNAME を戻すだけで切り戻せる。手順は Implementation Notes に記録済み。撤去は TASK-1.6。
<!-- SECTION:FINAL_SUMMARY:END -->
