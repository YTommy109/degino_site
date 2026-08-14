---
id: TASK-3
title: ビルドコマンドを package.json に一本化し justfile を廃止する
status: Done
assignee:
  - '@claude'
created_date: '2026-08-14 04:28'
updated_date: '2026-08-14 04:41'
labels:
  - build
dependencies: []
priority: medium
type: chore
ordinal: 10000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
justfile と package.json の両方にビルド系コマンドがあり、二重管理になっている。

## 本当の問題は重複ではなくバージョンの分岐

justfile の build / serve / check は PATH 上の zola をバージョン確認なしで使う。一方 scripts/ci-build.sh は .zola-version（現在 0.22.1）に固定する。CLAUDE.md が警告している「バージョンが違うと config.toml の形式が非互換でビルドが失敗する」状態を、ローカル側だけが踏みうる。

TASK-1.6 ではこの分岐を注意書き（「just build は PATH 上の zola をそのまま使う。CI と同じ経路を再現したい場合は npm run build を使うこと」）で回避したが、経路を一本化すれば注意書きごと消せる。

## 方針

scripts/ci-build.sh を scripts/zola.sh に一般化する。submodule 取得と .zola-version の zola 用意までを担い、最後に exec zola "$@" で引数を委譲する薄いラッパーにする。呼び分けは package.json の scripts 側に置く。

打鍵の増加（just serve -> npm run serve）は、ユーザーが antfu-collective/ni を導入して nr serve で解決する。

Cloudflare のビルドコマンドは npm run build のままなので、ダッシュボード側の変更は不要。
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 justfile が削除され、build / serve / draft / check / clean が package.json の scripts から実行できる
- [x] #2 ローカルのすべてのコマンドが .zola-version に固定された zola を使う（PATH 上の別バージョンに依存しない）
- [x] #3 CLAUDE.md のコマンド表が更新され、just と npm run の使い分けに関する注意書きが削除されている
- [x] #4 npm run build と npm run check がローカルで成功し、push 後の Workers Builds も成功する
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
1. scripts/ci-build.sh を git mv で scripts/zola.sh にリネームし、末尾の zola build を exec zola "$@" に変える。PATH の設定を if の外に出して、既存インストールを使う場合も同じ経路になるようにする
2. package.json の scripts に build / serve / draft / check / clean を定義する
3. justfile を削除する
4. CLAUDE.md のコマンド表を npm run ベースに書き換え、just と npm run の使い分けの注意書きを削除する
5. doc-1 の scripts/ci-build.sh への参照を scripts/zola.sh に更新する
6. ローカルで npm run build / npm run check / npm run serve を実行して検証する
7. push して Workers Builds が成功することをビルドログで確認する
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
## 実施内容

- scripts/ci-build.sh を scripts/zola.sh にリネームし、末尾の zola build を exec zola "$@" に変えて引数委譲のラッパーにした
- package.json の scripts に build / serve / draft / check / clean を定義した
- justfile を削除した（set dotenv-load も .env 削除済みで死んでいた）
- CLAUDE.md のコマンド表を npm run ベースに更新し、just と npm run の使い分けの注意書きを削除した
- doc-1 と .gitignore の scripts/ci-build.sh への参照を更新した

## 設計上の判断

zola の解決に .zola-bin の再利用分岐を追加した。元のスクリプトは PATH に一致バージョンが
無ければ毎回ダウンロードしていたが、ローカルで PATH に zola が無い環境では実行のたびに
36MB を取り直すことになる。CI はキャッシュが無いためダウンロード経路を通り、挙動は変わらない。

## 検証

- npm run clean -> public/ が消える
- npm run build -> 11 pages 生成
- npm run check -> エラーなし（15.3s）
- npm run serve -> http://127.0.0.1:1111/ が 200 を返す。停止も確認
- zola の解決 3 経路すべてを実測: PATH 上の zola を使う場合、.zola-bin を再利用する場合
  （PATH を /usr/bin:/bin:/usr/sbin:/sbin に絞って実行）、.zola-bin を退避して
  ダウンロードから行う場合（CI 相当）。いずれも zola 0.22.1 で 11 pages を生成
<!-- SECTION:NOTES:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
justfile を廃止し、Zola を呼ぶコマンドを package.json の scripts に一本化した。狙いは重複解消ではなくバージョン分岐の解消で、justfile が PATH 上の zola をバージョン確認なしに使っていたのに対し、いまはすべてのコマンドが scripts/zola.sh 経由で .zola-version に固定された zola を使う。TASK-1.6 で CLAUDE.md に書いた『just build は PATH 上の zola をそのまま使う』という注意書きは、経路の統一により不要になったので削除した。

scripts/ci-build.sh は scripts/zola.sh にリネームし、末尾を exec zola "$@" にして build 以外のサブコマンドも同じ経路を通るようにした。あわせて .zola-bin の再利用分岐を追加し、PATH に zola が無い環境で毎回 36MB を取り直すのを避けた。

検証: ローカルで npm run clean / build / check / serve をすべて実行（serve は http://127.0.0.1:1111/ が 200 を返し停止も確認）。zola の解決 3 経路（PATH 上の zola、.zola-bin の再利用、ダウンロード）を PATH を絞る・.zola-bin を退避するかたちで個別に実測し、いずれも 0.22.1 で 11 pages を生成。push 後の Workers Builds（d6911b1a）も 'bash scripts/zola.sh build' で成功し、www.degino.com のカスタムドメイン付きでデプロイ完了。本番の応答も確認済み。
<!-- SECTION:FINAL_SUMMARY:END -->
