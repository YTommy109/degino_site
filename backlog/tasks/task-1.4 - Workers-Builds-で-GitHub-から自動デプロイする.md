---
id: TASK-1.4
title: Workers Builds で GitHub から自動デプロイする
status: To Do
assignee: []
created_date: '2026-08-13 16:12'
labels: []
dependencies:
  - TASK-1.3
parent_task_id: TASK-1
priority: high
type: feature
ordinal: 5000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Cloudflare の Workers Builds を GitHub リポジトリに接続し、main への push で自動ビルド・デプロイされるようにする。ビルドコマンドで Zola を取得してから zola build を実行する必要がある点と、themes/hyde が submodule である点（サブモジュール取得が必要）に注意する。
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 main への push で Workers Builds が起動し、デプロイまで自動で完了する
- [ ] #2 ビルドログで submodule が取得され zola build が成功していることが確認できる
- [ ] #3 ビルド失敗時に気づける状態になっている（通知またはビルド状況の確認手順が記録されている）
<!-- AC:END -->
