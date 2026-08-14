---
id: TASK-1.6
title: GitLab Pages と旧ホスティング設定を撤去する
status: To Do
assignee: []
created_date: '2026-08-13 16:13'
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
- [ ] #1 .gitlab-ci.yml と不要になった netlify.toml が削除されている
- [ ] #2 CLAUDE.md / README 等のデプロイ手順が Cloudflare Workers ベースに更新されている
- [ ] #3 GitLab リポジトリの扱い（アーカイブ／削除／保持）が決定され記録されている
<!-- AC:END -->
