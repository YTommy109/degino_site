---
id: TASK-1.1
title: GitHub リポジトリを作成しリモートを移行する
status: Done
assignee:
  - '@tokutomi'
created_date: '2026-08-13 16:12'
updated_date: '2026-08-14 01:21'
labels: []
dependencies: []
parent_task_id: TASK-1
priority: high
type: task
ordinal: 2000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
GitHub 上に public リポジトリを新規作成し、GitLab の全履歴・ブランチ・タグを push する。ローカルの origin を GitHub に切り替え、GitLab リポジトリは当面 read-only の控えとして残す。themes/hyde は git submodule (https://github.com/getzola/hyde.git) なので .gitmodules がそのまま機能することも確認する。
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 GitHub に public リポジトリが存在し、main を含む全ブランチとタグが push されている
- [x] #2 ローカルの git remote origin が GitHub を指している
- [x] #3 クリーンな clone + git submodule update --init --recursive で themes/hyde が取得できる
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
1. gh CLI の認証と対象アカウントを確認する（YTommy109 でログイン済み）
2. gh repo create YTommy109/degino_site --public --source=. --remote=github で GitHub 側に空の public リポジトリを作成する（--push はせず、まず remote 追加のみ）
3. git push github --all および --tags で全ブランチ・タグを push する（現状 main のみ、タグなし）
4. GitHub 側のデフォルトブランチが main であることを確認する
5. origin を GitLab から GitHub へ張り替える（旧 GitLab は gitlab リモートとして残し、控えにする）
6. 一時ディレクトリへ clone し直し、git submodule update --init --recursive で themes/hyde が取得できること、just build が通ることを検証する
7. 検証用の一時 clone を削除する

作業対象はリモート設定のみで、ワーキングツリーの未コミット変更（config.toml は TASK-1.2 の範囲）には触れない。
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
GitHub リポジトリを gh repo create で作成: https://github.com/YTommy109/degino_site (public, デフォルトブランチ main)。

検証エビデンス:
- git push github --all / --tags 実行後、git ls-remote で local main / GitHub / GitLab がいずれも 4db9050 で一致（20 commits、ブランチは main のみ、タグは 0 件）。
- リモート名を入れ替え、origin=GitHub / gitlab=GitLab（控え）に変更。main の upstream は origin/main。
- 一時ディレクトリへクリーン clone し、git submodule update --init --recursive で themes/hyde が b608547 で取得できることを確認（検証用 clone は削除済み）。

補足: クリーン clone での zola build は config.toml の highlight_code で失敗する。これは TASK-1.2 の対象で、当該修正はローカル未コミットのため本タスクの範囲外。
<!-- SECTION:NOTES:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
GitLab から GitHub (public) へリポジトリを移行した。全履歴 20 commits を push し、ハッシュ一致を git ls-remote で確認。origin を GitHub に張り替え、GitLab は gitlab リモートとして控えに残した。クリーン clone + submodule 取得で themes/hyde が復元できることを実測で確認済み。
<!-- SECTION:FINAL_SUMMARY:END -->
