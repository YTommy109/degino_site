---
id: TASK-1.4
title: Workers Builds で GitHub から自動デプロイする
status: In Progress
assignee:
  - '@tokutomi'
created_date: '2026-08-13 16:12'
updated_date: '2026-08-14 01:36'
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

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
1. Workers Builds はビルド環境に Zola を持たず、wrangler の custom builds も無視するため、ビルド手順を scripts/ci-build.sh に集約し npm script 'build' から呼ぶ
2. ci-build.sh は .zola-version を単一の情報源として Zola を取得し、themes/hyde submodule を取得してから zola build を実行する
3. ローカルで ci-build.sh を実行して public/ が生成されることを確認する
4. Cloudflare ダッシュボードでの GitHub 接続手順（build command / deploy command / branch）とビルド失敗の検知手順を backlog doc に記録する
5. main へ push して Workers Builds が起動・成功することをビルドログで確認する（接続はユーザー操作が必要）
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
scripts/ci-build.sh を追加し、npm script 'build' から呼ぶようにした。Workers Builds のビルド環境には Zola が無く、wrangler の [build] custom builds も無視される（Cloudflare 公式ドキュメント記載）ため、Zola 取得・submodule 取得・zola build をスクリプトに集約している。Zola のバージョンは .zola-version を参照する。

ローカル検証: 'npm run build' で既存 zola を使う経路、PATH を絞った状態で実行してダウンロード経路（aarch64-apple-darwin）、いずれも public/ の生成まで成功を確認。

ダッシュボードでの GitHub 接続手順・ビルド設定値・ビルド失敗通知の設定手順を doc-1 に記録した。GitHub 連携は OAuth を伴うためダッシュボード操作が必要で、AC #1 / #2 は接続後の push で確認する。
<!-- SECTION:NOTES:END -->
