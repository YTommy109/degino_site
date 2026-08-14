---
id: TASK-1.2
title: Zola のバージョンと設定を最新に揃える
status: To Do
assignee: []
created_date: '2026-08-13 16:12'
labels: []
dependencies: []
parent_task_id: TASK-1
priority: high
type: chore
ordinal: 3000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
ローカルの zola は 0.22.1 だが .gitlab-ci.yml は 0.20.0 を固定しており、config.toml も 0.22 で廃止された [markdown] highlight_code を使っていて just build が失敗する。移行先のビルド環境で使う Zola バージョンを決め、config.toml をその形式に合わせる。0.22 では [markdown.highlighting] テーブルに変わり、旧デフォルトの base16-ocean-dark は同梱テーマから消えている（利用可能な例: Nord, github-light, github-dark, monokai, ayu-dark）。
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 just build がローカルで成功する
- [ ] #2 config.toml のシンタックスハイライト設定が採用した Zola バージョンの形式になっている
- [ ] #3 採用した Zola バージョンがビルド設定と README/CLAUDE.md 等の記述で一致している
<!-- AC:END -->
