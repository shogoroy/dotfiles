---
name: granular-commits
description: Split the working-tree changes into small, logically separate commits (one purpose per commit, each commit passing tests on its own), using the project's commit convention. Optionally push (`push`) and create a GitHub PR (`pr`).
user-invocable: true
---

# Granular Commits

作業ツリーの変更を、**目的ごとの小さなコミット**に分けてコミットする。各コミットは単独でテストが通る状態にする。
`$ARGUMENTS` に `push` があれば push まで、`pr` があれば PR 作成まで行う(`pr` は `push` を含む)。
引数が無ければ、コミットのみ(push / PR は、ユーザーの明示的な指示があるまで行わない)。

コミットメッセージの規約は `/commit` スキルと同じ形式(`[TICKET-ID] <gitmoji> <summary>`、summary は英語)。

## Steps

### 1. 事前確認

```bash
git branch --show-current && git status --short && git log --oneline -5
```

- **デフォルトブランチ(main / master)上なら、コミットせず、ユーザーに確認する**(ブランチを切るか聞く。勝手に切らない)。
- 未追跡ファイル・今回の作業と無関係な変更が混ざっていれば、それはコミット対象に含めない(`git add -A` / `git add .` は使わず、パスを明示して `git add` する)。無関係なものは最後に「残っているファイル」として報告する。
- 認証情報・秘密情報・個人情報を含みそうな差分があれば、コミットせず確認する。

### 2. 変更をグループに分ける

`git diff` で変更を読み、**1 コミット = 1 つの目的**になるようにグループ分けする。

- 機能のコード + そのテストは、同じコミットにまとめる。ドキュメントだけの追従は、別コミットにしてよい。
- 依存関係の順に並べる(後のコミットが、前のコミットに依存する順)。**各コミットの時点で、ビルド・テストが通ること。**
- 分けた計画(コミット名と対象ファイルの一覧)を、短くユーザーに示す。変更が曖昧・大きすぎる場合を除き、確認なしで進めてよい。

### 3. 分割して、コミットする

**ファイルが 1 つのグループにだけ属する場合**: そのパスを `git add <path>` して、グループごとにコミットする。

**同じファイルに複数のグループの変更が混ざっている場合**: 対話式の `git add -p` / `-i` は使えない。次の「段階ごとの状態」で分ける。

1. 混ざっているファイルの**最終状態を、スクラッチパッドにバックアップ**する(`cp`)。
2. 最終状態から、**後ろのグループの変更を逆に取り除いた状態**を順に作る(`perl -0pi` などの的を絞った置換)。ブロック(定数 + コメント、テストの期待値の追記など)単位で取り除く。
3. コミットの順に、そのコミットの状態のファイルを置き、**テスト(リポジトリのテストコマンド。例: `yarn test`)を実行**してから、そのコミットの対象パスだけを `git add` してコミットする。
4. 最後のコミットの前に、バックアップから最終状態を復元する。
5. **検証**: 全コミット後、作業ツリーが clean であり、ファイルが最初のバックアップと同一であることを `diff` で確認する(フォーマッタが整形した差だけは許容)。一致しなければ、バックアップから復元して報告し、そこで止める。

**注意**:

- `--no-verify` は使わない。pre-commit hook(lint 等)が失敗したら、原因を直す。hook が自動整形したら、そのまま受け入れ、最終状態を再確認する。
- 既に push 済みのコミットは書き換えない(force push しない)。打ち消す必要があれば、新しいコミットを追加する。
- zsh の落とし穴: 変数を `$VAR` のまま複数の引数に展開しない(配列を使う)。`$B:path` は修飾子と解釈されるので `"${B}:path"` と書く。BSD sed の `-i` には空文字の引数が要るため、置換は `perl -0pi -e` を使う。

### 4. コミットメッセージ

```
[TICKET-ID] <gitmoji> <summary>

- <one-line bullet (optional, at most 3-4)>
```

- **TICKET-ID**: ブランチ名の先頭の ID(例: `AWSQ-T36721/shogoro/...` → `AWSQ-T36721`)。見つからなければ、`[...]` ごと省略する。
- **gitmoji / summary**: `/commit` スキルの一覧に従う。summary は、短い命令形の英語の 1 行。
- 本文は、必要なときだけ。1 行の箇条書きを 3〜4 個まで(長い散文は書かない)。補足は、会話で伝える。
- **Co-Authored-By**: セッションの system-reminder で与えられた attribution(「Attribution for git commits ...」)の行を、そのまま末尾に付ける。**モデル名を固定で書かない。** 与えられていなければ、付けない。

### 5. 検証と報告(コミットのみの場合はここで終了)

```bash
git log --oneline <base>..HEAD && git status --short
```

コミットの一覧(ハッシュ・メッセージ・内容)、各コミットでテストが通ったこと、残っているファイル(未追跡など)を、簡潔に報告する。

### 6. `push`(引数に `push` または `pr` がある場合)

```bash
git push -u origin HEAD
```

- force push はしない。拒否されたら、そのまま報告して止める。

### 7. `pr`(引数に `pr` がある場合)

- **PR のテンプレートを使う**(`~/.claude/CLAUDE.md` の方針)。`.github/pull_request_template.md`、`.github/PULL_REQUEST_TEMPLATE.md`、`.github/PULL_REQUEST_TEMPLATE/*.md`、リポジトリ直下、`docs/` を探す。見つかれば、その構造をそのまま使い、各セクションに内容を埋める。見つからなければ、`## Summary` / `## Notes` / `## Test plan` の形式にフォールバックする(日本語で書く)。
- タイトルは `[TICKET-ID] <日本語の要約>`。base は、デフォルトブランチ(積んだ PR がある場合は、その PR のブランチ。迷ったら確認する)。
- Summary には、コミットの一覧と、変更の要点、背景を書く。Notes には、影響範囲・既知の制約・デプロイ時の注意を書く。
- **Test plan は、実際に実行したものだけを `[x]` にする。** 実行していないもの(デプロイ後の確認など)は、`[ ]` のままにする。
- 末尾に、セッションの attribution で与えられた行(例: `🤖 Generated with [Claude Code](...)`)を付ける。
- 作成後、PR の URL を報告する。

## Notes

- このスキルを呼び出したことは、「コミットしてよい」という明示的な指示とみなす。`push` / `pr` は、引数があるときだけ行う。
- `/commit`(`/gc`)は、変更全体を **1 つ**のコミットにする。分けたいときだけ、このスキルを使う。
