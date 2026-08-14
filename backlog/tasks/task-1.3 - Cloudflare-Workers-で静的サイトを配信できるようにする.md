---
id: TASK-1.3
title: Cloudflare Workers で静的サイトを配信できるようにする
status: Done
assignee:
  - '@tokutomi'
created_date: '2026-08-13 16:12'
updated_date: '2026-08-14 01:33'
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
- [x] #1 wrangler.jsonc が追加され、zola build 後に wrangler dev でサイトがローカル配信できる
- [x] #2 トップ・各記事・タクソノミー・atom.xml・存在しない URL の 404 が期待通り返る
- [x] #3 workers.dev のプレビュー URL で本番同等の表示が確認できる
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
1. GitLab Pages の現行挙動を実測して基準を確定する（/articles/trace-atdd -> 302 で末尾スラッシュ付きへ、/index.html は 200、存在しない URL は 404 で public/404.html の内容）。
2. wrangler を devDependency として package.json に固定し、バージョンの再現性を確保する。
3. wrangler.jsonc を追加する。Worker スクリプトは持たず assets のみの構成とし、assets.directory = ./public、html_handling = force-trailing-slash（GitLab の 302 挙動に一致）、not_found_handling = 404-page（public/404.html を使う）を設定する。main と binding は Worker スクリプトが無いため設定しない。
4. public/ は .gitignore 済みでビルド生成物のため、リポジトリには含めない。
5. zola build 後に wrangler dev を起動し、トップ・記事・タクソノミー・atom.xml・静的ファイル・末尾スラッシュ無し URL・存在しない URL を実測して本番と突き合わせる。
6. wrangler deploy で workers.dev のプレビュー URL に配信し、本番同等の表示を確認する。
7. netlify.toml の扱いを判断する（旧ホスティングの遺物。撤去は TASK-1.6 の範囲）。
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
wrangler.jsonc を追加（Worker スクリプトを持たない assets のみの構成。main と assets.binding は設定しない）。wrangler のバージョン固定のため package.json / package-lock.json を追加し、node_modules と .wrangler を .gitignore に追加した。

設定値の根拠（GitLab Pages の実測挙動に合わせた）:
- html_handling: force-trailing-slash … 本番は /about や /articles/trace-atdd を 302 で末尾スラッシュ付きへリダイレクトしていた
- not_found_handling: 404-page … 本番は存在しない URL で public/404.html の内容を 404 で返していた

検証エビデンス:
- zola build 後に wrangler dev (port 8788) で起動し、本番と URL ごとの HTTP ステータス／リダイレクト先を突き合わせ
- wrangler deploy で https://degino-site.tommy109.workers.dev に配信し、同じ突き合わせを実施
- /, /about/, /service/, /articles/, 各記事, atom.xml, sitemap.xml, robots.txt, degino.css, dependence.png はすべて 200
- 末尾スラッシュ無し URL は本番 302 に対し Workers は 307。いずれも一時リダイレクトで遷移先は同一。Cloudflare 側の仕様でコードは変更できない
- /index.html は本番 200 に対し Workers は 307 で / へ正規化。外部から /index.html を参照している箇所は無い
- 存在しない URL は 404 で、レスポンス本文が public/404.html と完全一致することを diff で確認
- トップページの HTML を本番と比較した差分は、日付・weight を持たないページの並び順が Zola 0.20 と 0.22 で入れ替わる点のみ。ユーザー判断により順序は固定せず現状のままとする

netlify.toml の扱い: hyde テーマのスターター由来の残骸（コメントが docs フォルダ構成を前提としており本リポジトリと不一致）。Netlify は使用していないため TASK-1.6 で削除する。

派生して TASK-2 を起票（sitemap.xml に載る /categories/ と /tags/ が 404。移行前後の双方で再現する既存の問題）。
<!-- SECTION:NOTES:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Zola の出力 public/ を Cloudflare Workers Static Assets で配信する wrangler.jsonc を追加した。GitLab Pages の実測挙動に合わせて html_handling=force-trailing-slash / not_found_handling=404-page を設定し、wrangler のバージョンは package.json で固定した。wrangler dev と workers.dev への実デプロイ（https://degino-site.tommy109.workers.dev）の両方で、主要 URL のステータス・リダイレクト先・404 本文・HTML 内容を本番と突き合わせて検証済み。残る差分はリダイレクトコード 302/307 と /index.html の正規化のみで、いずれも実害なし。
<!-- SECTION:FINAL_SUMMARY:END -->
