---
id: TASK-1.2
title: Zola のバージョンと設定を最新に揃える
status: Done
assignee:
  - '@tokutomi'
created_date: '2026-08-13 16:12'
updated_date: '2026-08-14 01:24'
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
- [x] #1 just build がローカルで成功する
- [x] #2 config.toml のシンタックスハイライト設定が採用した Zola バージョンの形式になっている
- [x] #3 採用した Zola バージョンがビルド設定と README/CLAUDE.md 等の記述で一致している
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
1. 現状把握: zola 0.22.1（ローカル）に対し .gitlab-ci.yml は 0.20.0 を固定。config.toml の [markdown] highlight_code は 0.22 で廃止済み。
2. 採用バージョンをローカルと同じ 0.22.1 に揃える（移行先の Workers Builds でも同バージョンを取得する前提。TASK-1.4 で参照する）。
3. config.toml のシンタックスハイライト設定を [markdown.highlighting] 形式へ書き換える。テーマは同梱テーマから選ぶ（base16-ocean-dark は 0.22 で削除済みのため、実測で存在を確認した Nord / github-light / github-dark / monokai / ayu-dark が候補）。
4. コードブロックを含む唯一の記事 content/articles/2018-11-18-trace-atdd.md（javascript フェンス 11 個）をビルドして、ハイライトが実際に出力されることを確認する。
5. バージョンの単一の情報源として .zola-version を追加し、CLAUDE.md にビルド手順とバージョンを記載する。.gitlab-ci.yml は TASK-1.6 で撤去するため本タスクでは変更しない。
6. just build / just check を実行して成功を確認する。
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
採用バージョン: 0.22.1（ローカルの zola と同じ）。.zola-version を単一の情報源として追加し、CLAUDE.md にビルド手順とシンタックスハイライトの経緯を記載した。

config.toml の変更:
- [markdown] highlight_code = true を削除
- [markdown.highlighting] theme = "Nord" を追加

テーマ選定の根拠: 本番 https://www.degino.com/articles/trace-atdd/ の実際の出力が background-color:#2b303b / color:#c0c5ce（= base16-ocean-dark）だった。0.22 の同梱テーマに base16-ocean-dark は存在しない（実測で候補を総当たりし、Nord / github-light / github-dark / monokai / ayu-dark が有効と確認）。このうち配色が最も近い Nord (#2E3440 / #D8DEE9) を採用した。

検証エビデンス:
- just build 成功（11 pages / 1 section、Done in 220ms）
- just check 成功（リンク切れなし、Done in 10.6s）
- content/articles/2018-11-18-trace-atdd.md のコードブロック 11 個すべてに Nord のハイライトが適用されていることを出力 HTML で確認（本番の 11 個と一致）
- 本番サイト（Zola 0.20 ビルド）と新ビルド出力を全ページ差分比較:
  - / と /articles/ は完全一致
  - /about/ /service/ と atom.xml の差分は、外部リンクに rel="external" が付く点のみ。これは 0.22 の既定動作の変更で、表示・機能への影響はない
  - コードブロック内部のマークアップは変化（<code> の class="language-*" が data-lang のみになり、行ごとの span が追加）。テーマ側 CSS (themes/hyde/sass/poole.scss) は pre / pre code しか参照しておらず .language-* に依存しないため、表示は崩れない

.gitlab-ci.yml は zola 0.20.0 を固定したままだが、TASK-1.6 で撤去するため本タスクでは変更していない。
<!-- SECTION:NOTES:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Zola 0.22 で廃止された [markdown] highlight_code を [markdown.highlighting] へ移行し、just build の失敗を解消した。テーマは本番の実出力色から base16-ocean-dark 相当と特定し、0.22 に同梱される中で最も近い Nord を採用。バージョンは .zola-version (0.22.1) を単一の情報源とし CLAUDE.md に手順を記載した。just build / just check の成功と、本番サイトとの全ページ差分比較（差分は rel="external" 付与とコードブロック内部マークアップのみ）で検証済み。
<!-- SECTION:FINAL_SUMMARY:END -->
