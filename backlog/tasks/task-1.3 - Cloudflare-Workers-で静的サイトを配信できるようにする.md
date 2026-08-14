---
id: TASK-1.3
title: Cloudflare Workers で静的サイトを配信できるようにする
status: To Do
assignee: []
created_date: '2026-08-13 16:12'
labels: []
dependencies:
  - TASK-1.1
  - TASK-1.2
parent_task_id: TASK-1
priority: high
type: feature
ordinal: 4000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Zola の出力 (public/) を Cloudflare Workers の Static Assets で配信するための設定を追加する。wrangler.jsonc に assets ディレクトリ・not_found_handling などを定義し、ローカルで動作確認できる状態にする。GitLab Pages 時代の挙動（末尾スラッシュ URL、404 ページ、atom.xml、静的ファイル）が壊れないことを確認する。リポジトリに残っている netlify.toml は旧ホスティングの遺物なので、この移行で扱いを決める。
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 wrangler.jsonc が追加され、zola build 後に wrangler dev でサイトがローカル配信できる
- [ ] #2 トップ・各記事・タクソノミー・atom.xml・存在しない URL の 404 が期待通り返る
- [ ] #3 workers.dev のプレビュー URL で本番同等の表示が確認できる
<!-- AC:END -->
