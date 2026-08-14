---
id: TASK-1.6
title: GitLab Pages と旧ホスティング設定を撤去する
status: Done
assignee:
  - '@claude'
created_date: '2026-08-13 16:13'
updated_date: '2026-08-14 04:45'
labels: []
dependencies:
  - TASK-1.5
parent_task_id: TASK-1
priority: medium
type: chore
ordinal: 7000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
本番が Cloudflare Workers で安定して稼働していることを確認したうえで、GitLab 由来・旧ホスティング由来の設定とドキュメントを整理する。対象は .gitlab-ci.yml、netlify.toml、および GitLab Pages 前提の記述。GitLab リポジトリ自体をアーカイブするかどうかもここで決める。
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 .gitlab-ci.yml と不要になった netlify.toml が削除されている
- [x] #2 CLAUDE.md / README 等のデプロイ手順が Cloudflare Workers ベースに更新されている
- [x] #3 GitLab リポジトリの扱い（アーカイブ／削除／保持）が決定され記録されている
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
1. リポジトリ直下の .env を削除する。inventory/ がこのリポジトリに存在せず、DNS 集約作業のファイルが置き去りになっていたもの。削除すれば wrangler が OAuth 認証を上書きされる問題も原因側で消える
2. .gitignore に .env を追加する。現状 ~/.config/git/ignore（グローバル）でしか除外されておらず、単一障害点になっている
3. .gitlab-ci.yml と netlify.toml を削除する（いずれも Zola 0.20.0 を固定した死んだ設定）
4. CLAUDE.md にデプロイ手順を追記する。現状 just build/serve/check しか記載が無く Workers への言及がゼロ
5. git remote gitlab を削除し、GitLab リポジトリはアーカイブする方針を記録する（アーカイブ操作自体はダッシュボード）
6. doc-1 の .env に関する注意書きを、削除済みの前提に合わせて更新する
7. DNS 側の GitLab 残骸（検証用 TXT 2 件、apex CNAME の向き先）の撤去は別タスクとして起票する
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
## 実施内容

- .env を削除した。冒頭のコメントが指す inventory/ がこのリポジトリに存在せず、DNS 集約作業のファイルが置き去りになっていたもの。Cloudflare / AWS / Netlify / eNom の資格情報が同居していた
- .gitignore に .env / .env.* を追加した。それまで除外していたのはグローバルの ~/.config/git/ignore だけで、ファイル内のコメントの「.env は gitignore 済み」はこのリポジトリに関しては誤りだった。単一障害点になっていた
- .gitlab-ci.yml と netlify.toml を削除した（いずれも Zola 0.20.0 を固定。現行は 0.22.1 で、動かしても失敗する死んだ設定）
- CLAUDE.md にデプロイ手順と npm run build / npm run deploy を追記した
- git remote gitlab を削除した
- doc-1 の .env に関する注意書きを、削除済みの前提に合わせて書き換えた

## npm run deploy の修正方針を変更した

当初は package.json に --env-file /dev/null を足して .env の読み込みを拒否する案だったが、
.env 自体がこのリポジトリの持ち物ではなかったため、原因側（.env）を消す方を採った。
回避策のフラグは不要になり、wrangler whoami が OAuth 認証で通ることを確認済み。

## 資格情報の扱い（ユーザー判断待ち）

.env にあった Cloudflare トークンは、コメントの「権限: Zone / Zone / Read」と異なり
DNS レコードの削除・更新が可能だった（TASK-1.5 で実際に使用）。2026-08-16 で期限切れ。
AWS アクセスキー・Netlify PAT・eNom リセラー API 資格情報も同居していた。
失効・ローテーションはユーザー側の操作として残っている。

## 検証

- npm run build が zola 0.22.1 で 11 pages を生成して成功
- npx wrangler whoami が OAuth Token で認証を通過（.env による上書きが解消）
- git remote が origin のみ

## 別タスクに切り出したもの

DNS 側の GitLab 残骸（検証用 TXT 2 件、apex CNAME の向き先、gitlab.com の Pages ドメイン登録）
の撤去は TASK-1.7 として起票した。切り戻し経路を残すため、本番の安定稼働を確認してから着手する。

## 追記（2026-08-14）

- gitlab.com 側のリポジトリのアーカイブをユーザーが実施済み。decision-1 の方針が実行に移された
- .env にあった資格情報は、AWS / Netlify / eNom から Cloudflare へのドメイン移管作業で現に使用中のものであり、ユーザーが状況を把握している。失効・ローテーションの提案は取り下げる（このリポジトリに置かれていたこと自体が誤配置だった、という指摘のみが有効）
<!-- SECTION:NOTES:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
GitLab / 旧ホスティング由来の設定を撤去した。.gitlab-ci.yml と netlify.toml（いずれも Zola 0.20.0 固定で、現行 0.22.1 では動かない死んだ設定）を削除し、git remote gitlab を外し、CLAUDE.md に Workers ベースのデプロイ手順と正本リポジトリを追記した。GitLab リポジトリの扱いは decision-1 として『アーカイブして保持』を記録（誤 push による Pages 再ビルドを防ぎつつ、TASK-1.7 まで安価な切り戻し経路を残すため）。

調査の過程で、リポジトリ直下の .env がこのリポジトリの持ち物ではないことが判明したため削除した。当初予定していた --env-file /dev/null による回避策ではなく原因側を消す方針に変更し、wrangler の認証が OAuth で通ることを確認した。.env を除外していたのはグローバルの ~/.config/git/ignore だけだったため、.gitignore にも明記した。

検証: npm run build が zola 0.22.1 で 11 pages を生成、just check がエラーなし、npx wrangler whoami が OAuth で認証通過、git remote が origin のみ、リポジトリ内の gitlab/netlify 参照は意図的な 2 件（正本の注記と wrangler.jsonc の経緯コメント）のみ。

DNS 側の GitLab 残骸の撤去は TASK-1.7 に切り出した。gitlab.com でのアーカイブ操作と .env にあった資格情報の失効はユーザー操作として残っている。
<!-- SECTION:FINAL_SUMMARY:END -->
