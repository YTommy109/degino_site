---
id: TASK-2
title: sitemap.xml に載っている /categories/ と /tags/ が 404 になる
status: To Do
assignee: []
created_date: '2026-08-14 01:32'
labels: []
dependencies: []
priority: low
type: bug
ordinal: 8000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
sitemap.xml は https://www.degino.com/categories/ と https://www.degino.com/tags/ を出力しているが、どちらも 404 を返す。移行前の GitLab Pages（Zola 0.20）と Cloudflare Workers 上の新ビルド（Zola 0.22）の双方で再現するため、ホスティング移行による退行ではなく従来からの問題である。

config.toml で categories / tags のタクソノミーを宣言している一方、テーマ hyde にタクソノミー用テンプレートが無いためタクソノミーページ自体が生成されていない。sitemap テンプレートは宣言されたタクソノミーを列挙するため、実体の無い URL が sitemap に載る。

対応の方向性は「タクソノミーページを生成する（テンプレートを用意する）」か「使っていないタクソノミー宣言を config.toml から外す」のいずれか。現状 content/ 配下の記事にタクソノミーの指定があるかを確認したうえで判断する。
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 sitemap.xml に 404 になる URL が含まれていない
- [ ] #2 タクソノミーを残す場合は /categories/ と /tags/ が 200 を返し、外す場合は config.toml から宣言が削除されている
<!-- AC:END -->
