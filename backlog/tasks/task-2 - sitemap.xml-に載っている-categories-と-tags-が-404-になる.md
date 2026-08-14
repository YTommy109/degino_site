---
id: TASK-2
title: sitemap.xml に載っている /categories/ と /tags/ が 404 になる
status: Done
assignee: []
created_date: '2026-08-14 01:32'
updated_date: '2026-08-14 01:51'
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
- [x] #1 sitemap.xml に 404 になる URL が含まれていない
- [x] #2 タクソノミーを残す場合は /categories/ と /tags/ が 200 を返し、外す場合は config.toml から宣言が削除されている
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
1. content/ 配下でタクソノミー(categories/tags)の使用有無を確認
2. 未使用なら config.toml の taxonomies 宣言を削除する（テンプレート追加より単純）
3. just build して sitemap.xml に /categories/ /tags/ が出ないことを確認
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
content/ 配下の全記事のフロントマターを確認したところ categories / tags の指定は 0 件だった。テンプレートを新設するより宣言を外すほうが単純で、追加の状態も増えないため config.toml の taxonomies 宣言を削除した（[slugify] の taxonomies = "off" は将来タクソノミーを使う場合の日本語スラッグ対策としてそのまま残置）。
検証: just build → sitemap.xml の <loc> は 13 件で /categories/ /tags/ を含まない（grep で確認）。13 件すべてに対応する public/**/index.html の存在を確認。just check もエラーなし。
<!-- SECTION:NOTES:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
config.toml から未使用の taxonomies（categories / tags）宣言を削除し、sitemap.xml に実体の無い URL が載らないようにした。content/ にタクソノミー指定が 1 件も無いことを確認のうえ、テンプレート追加ではなく宣言削除を選択。just build 後の sitemap.xml の 13 URL すべてが生成物として存在することと、/categories/ /tags/ が含まれないことを確認。just check も通過。
<!-- SECTION:FINAL_SUMMARY:END -->
