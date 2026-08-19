---
id: TASK-1
title: GitLab から GitHub / Cloudflare Workers へ移行
status: Done
assignee: []
created_date: '2026-08-13 16:12'
updated_date: '2026-08-19 07:48'
labels: []
dependencies: []
priority: high
type: task
ordinal: 1000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
サイト https://www.degino.com/ は現在 GitLab (git@gitlab.com:tommy109/degino_site.git) でホストされ、.gitlab-ci.yml の pages ジョブで GitLab Pages に配信されている。これを GitHub リポジトリ (public) へ移行し、配信先を Cloudflare Workers (Static Assets) に切り替える。DNS は既に Cloudflare で一元管理しているため、レコード切り替えのみで移行できる。デプロイは Cloudflare Workers Builds による GitHub 連携方式を採用する（GitHub Actions は使わない）。
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 配信元が Cloudflare Workers になり https://www.degino.com/ が従来と同じ内容を返す
- [x] #2 main への push で Workers Builds が自動デプロイする
- [x] #3 GitLab Pages と GitLab CI への依存が削除されている
<!-- AC:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
完了確認（2026-08-19）: 全サブタスク TASK-1.1〜1.7 が Done。
- AC#1: https://www.degino.com/ が 200 を返し、server: cloudflare。配信元は Worker degino-site（wrangler.jsonc の routes でカスタムドメイン宣言）
- AC#2: Workers Builds の履歴に main への push 起点のビルドが 9 件あり、直近 5 件すべて buildOutcome=success（最新 4b1f7fa まで）
- AC#3: .gitlab-ci.yml と netlify.toml は TASK-1.6 で削除、git remote gitlab も撤去済み。TASK-1.7 で GitLab 由来 DNS レコードを撤去し、GitLab の Pages カスタムドメイン登録が 0 件・カスタムドメイン証明書失効済みであることを確認
<!-- SECTION:NOTES:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
GitLab (GitLab Pages) から GitHub + Cloudflare Workers へ移行を完了した。配信は Worker degino-site の Static Assets、デプロイは main への push を起点とする Workers Builds（GitHub Actions は不使用）、apex は Redirect Rule で www へ 308。GitLab リポジトリは decision-1 のとおりアーカイブして保持し、正本は github.com:YTommy109/degino_site。検証は www の 200 応答、Workers Builds 履歴の連続 success、GitLab 側のドメイン登録 0 件と証明書失効の実測、および apex の 308 実測。運用は doc-1 に集約。
<!-- SECTION:FINAL_SUMMARY:END -->
