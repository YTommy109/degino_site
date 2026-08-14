---
id: TASK-1
title: GitLab から GitHub / Cloudflare Workers へ移行
status: To Do
assignee: []
created_date: '2026-08-13 16:12'
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
- [ ] #1 配信元が Cloudflare Workers になり https://www.degino.com/ が従来と同じ内容を返す
- [ ] #2 main への push で Workers Builds が自動デプロイする
- [ ] #3 GitLab Pages と GitLab CI への依存が削除されている
<!-- AC:END -->
