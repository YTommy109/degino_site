---
id: TASK-1.5
title: www.degino.com を Cloudflare Workers に切り替える
status: To Do
assignee: []
created_date: '2026-08-13 16:13'
updated_date: '2026-08-14 01:19'
labels: []
dependencies:
  - TASK-1.4
parent_task_id: TASK-1
priority: high
type: task
ordinal: 6000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
DNS は既に Cloudflare で一元管理しているため、www.degino.com の向き先を GitLab Pages から Workers のカスタムドメインに切り替える。

## 移行前の実測状況（2026-08-14 時点）

- www.degino.com CNAME → tommy109.gitlab.io（Cloudflare プロキシ OFF＝グレークラウド）
- degino.com A → 35.185.44.232（GitLab Pages。https://degino.com/ は 308 で https://www.degino.com/ へリダイレクト）
- 証明書: Let's Encrypt / CN=www.degino.com / 有効期限 2026-09-29。TLS 終端は Cloudflare ではなく GitLab Pages 側
- CAA レコードは degino.com・www.degino.com とも未設定（証明書発行のブロック要因なし）

## 証明書の扱い

GitLab Pages の証明書は GitLab が自動取得・自動更新しているもので、秘密鍵を取り出して Cloudflare へ持ち込むことはできないし、その必要もない。Workers のカスタムドメインを設定するとレコードは自動的にプロキシ ON になり、TLS 終端が Cloudflare エッジへ移って Universal SSL が自動発行・自動更新する。移行作業としての証明書コピーは発生しない。

## 注意点

1. カスタムドメイン追加直後は証明書発行まで数十秒〜数分の空白があり、その間 ERR_CERT_* になり得る。低トラフィック時間帯に切り替える。
2. 切り戻しのため、Workers 側が安定するまで GitLab 側のドメイン登録を削除しない。削除すると証明書も失われ、戻す際に再取得＝再びダウンタイムになる。
3. apex の www へのリダイレクトを返しているのは GitLab Pages 自身であり、A レコードを外すと同時に消える。Cloudflare の Redirect Rule で置き換えること。証明書よりこちらの方が忘れた際の実害が大きい。
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 https://www.degino.com/ が Cloudflare Workers から配信されている
- [ ] #2 https://degino.com/ が Cloudflare の Redirect Rule で https://www.degino.com/ へリダイレクトする
- [ ] #3 HTTPS が有効で証明書エラーが出ない（Universal SSL の発行完了を確認）
- [ ] #4 切り戻し手順が記録されている（GitLab 側のドメイン登録を残した状態で戻せること）
<!-- AC:END -->
