
<!-- BACKLOG.MD GUIDELINES START -->
<!-- backlog.md-instructions-version: 1.50.1 -->
<CRITICAL_INSTRUCTION>

## Backlog.md Workflow

This project uses Backlog.md for task and project management.

**For every user request in this project, run `backlog instructions overview` before answering or taking action.**

Use the overview to decide whether to search, read, create, or update Backlog tasks.

Before task lifecycle actions, read the matching detailed guide:
- `backlog instructions task-creation` before creating or splitting tasks
- `backlog instructions task-execution` before planning, changing status or assignee, adding a plan or implementation notes, or implementing task work
- `backlog instructions task-finalization` before checking acceptance criteria, writing final summaries, or moving tasks to terminal statuses

Use `backlog <command> --help` before running unfamiliar commands. Help shows options, fields, and examples.

Do not edit Backlog task, draft, document, decision, or milestone markdown files directly. Use the `backlog` CLI so metadata, relationships, and history stay consistent.

</CRITICAL_INSTRUCTION>
<!-- BACKLOG.MD GUIDELINES END -->

## ビルド環境

このサイトは静的サイトジェネレータ **Zola** でビルドする。

- 使用バージョンは `.zola-version` を単一の情報源とする（現在: 0.22.1）
- ローカル・CI とも `.zola-version` と同じバージョンを使うこと。バージョンが異なると
  `config.toml` の設定形式が非互換になりビルドが失敗する
- テーマ `themes/hyde` は git submodule。clone 直後は
  `git submodule update --init --recursive` が必要

| コマンド | 内容 |
| --- | --- |
| `just build` | `public/` へビルド |
| `just serve` | ローカルサーバ起動（http://127.0.0.1:1111） |
| `just check` | リンク切れ等のチェック |

### シンタックスハイライト

Zola 0.22 で設定形式が変わり、`[markdown]` の `highlight_code` / `highlight_theme` は
`[markdown.highlighting]` テーブルに置き換わった。旧デフォルトの `base16-ocean-dark` は
同梱テーマから削除されているため、近い配色の `Nord` を使用している。
