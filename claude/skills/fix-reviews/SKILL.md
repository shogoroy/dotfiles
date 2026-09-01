---
name: fix-reviews
description: Identify the PR for the current branch, gather all its review comments, judge for each whether a fix is needed, ask the user to confirm each judgment, then plan the approved fixes and ask before implementing.
user-invocable: true
---

# Fix Reviews

現在のブランチに紐づく PR のレビュー・コメントを洗い出し、それぞれについて「修正が必要か」を Claude が一次判断した上で、必ずユーザーに確認を取ってから、修正が必要なものだけ Plan を立てて実装の指示を仰ぐ一連のフロー。

`$ARGUMENTS` に PR 番号 / PR URL が渡された場合はそれを対象にする。空の場合は **現在のブランチに紐づく PR** を対象にする（決め打ちで別ブランチや別 PR を選ばない）。

## Steps

### 1. 対象 PR の特定

```bash
gh pr view $ARGUMENTS --json number,url,title,headRefName,baseRefName,author,state
```

- `$ARGUMENTS` が空なら引数なしで実行し、現在のブランチに紐づく PR を解決する
- PR が見つからない（まだ PR が作られていない等）場合は、その旨をユーザーに報告してここで終了する
- PR が `MERGED` / `CLOSED` の場合も、そのままレビュー確認自体は可能なため続行してよいが、状態をユーザーに一言伝える

### 2. レビュー・コメントの収集

以下を全て収集する（漏れなく洗い出すことが目的なので、種類ごとに取得方法を変える）:

```bash
# owner/repo を取得
gh repo view --json nameWithOwner -q .nameWithOwner

# PR 全体へのレビュー（Approve / Changes requested / Comment とその本文）
gh pr view <n> --json reviews -q '.reviews'

# PR 全体への issue コメント（レビューに紐づかない一般コメント）
gh pr view <n> --json comments -q '.comments'

# インラインの review comment（差分の行に紐づくコメント）+ resolved 状態
gh api graphql -f query='
query($owner:String!, $repo:String!, $pr:Int!) {
  repository(owner:$owner, name:$repo) {
    pullRequest(number:$pr) {
      reviewThreads(first:100) {
        nodes {
          isResolved
          isOutdated
          path
          line
          comments(first:50) {
            nodes { author { login } body url createdAt }
          }
        }
      }
    }
  }
}' -f owner=<owner> -f repo=<repo> -F pr=<n>
```

- インラインコメントは GraphQL の `reviewThreads` から取得する（REST の `pulls/{n}/comments` には resolved 状態が無いため）
- `isResolved: true` のスレッドも一覧には含めるが、「解決済みとしてマークされている」ことを明示し、優先度を下げて扱う
- `isOutdated: true`（対象行が後続コミットで変わっている）の場合もその旨を明示する

### 3. 各コメントについて「修正が必要か」を一次判断する

収集した各レビュー / コメントについて、以下を確認して Claude 自身の判断（要修正 / 不要 / 判断つかず）を用意する:

- そのコメントが指す `path` / `line` の**現在のコードを実際に Read** し、指摘時点の内容と現状を比較する
- 既に別コミットで対応済みに見える場合は「対応済みと思われる（要修正なし）」と判断する
- `isResolved: true` でも、実際のコードを見て対応が不十分に見える場合は「解決済みマークだが要確認」として扱う
- 単純な感想・質問（fix 不要な確認コメント等）は「対応不要（コメントのみ）」と分類する
- 判断が難しいもの（設計判断が要る、意図が読めない等）は「判断つかず」として理由を明記する

### 4. ユーザーに判断を求める

- 一次判断の結果を、コメントごとに「誰から / どのファイル・行 / 指摘内容の要約 / Claude の一次判断とその理由」がわかる形で提示する
- **Claude が自分で「修正する/しない」を決めて先に進まない。** 必ずユーザーに最終判断を求める
- 件数が少ない場合（4件以下）は `AskUserQuestion` で1件ずつ「修正する / 修正しない / 保留」を選んでもらう
- 件数が多い場合は、一覧を提示した上で「番号を指定して修正対象を教えてください」と自由記述で確認する（無理に4択×4問に押し込めない）
- ユーザーの回答が出るまで Step 5 には進まない

### 5. 承認された項目の Plan を立てる

- Step 4 で「修正する」と判断された項目のみ対象にする
- 各項目（または関連する項目のグループ）について、具体的な修正方針を Plan として整理する（`EnterPlanMode` を使う）
- Plan には最低限、対象ファイル・変更方針・関連する既存コードへの影響を含める
- `ExitPlanMode` でユーザーに Plan を提示し、承認を得る
- **承認が得られるまで実装（Edit / Write）に進まない。** 複数項目がある場合、まとめて1つの Plan として提示してよいが、承認は明示的に得る
- 承認された内容のみ実装する。実装後にコミットするかどうかは別途ユーザーの指示を待つ（無断で `git commit` しない）

## Notes

- このフローは「洗い出し → 一次判断 → ユーザー確認 → Plan → 実装確認」の順を厳守する。途中の確認をスキップして先に実装まで進めない
- レビューコメントへの返信・resolve 操作はこの skill の範囲外。別途指示があった場合のみ行う
- PR が存在しない / 権限がなく `gh` が失敗する場合は、コマンドとエラー内容をそのままユーザーに提示する
