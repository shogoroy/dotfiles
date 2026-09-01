---
name: adversarial-review
description: Run adversarial verification against a GitHub PR or the local diff — surface candidate issues, then have independent skeptic subagents try to refute each one via a Workflow pipeline, and report only what survives.
user-invocable: true
---

# Adversarial Review

`$ARGUMENTS` で検証対象を指定する:

- PR 番号 (`123`, `#123`) や PR URL → その PR を対象にする。`gh pr view <n>` でメタデータ、`gh pr diff <n>` で差分を取得する
- それ以外（ブランチ名、`local` 等）で意図が自明でない場合、または **`$ARGUMENTS` が空の場合** → 決め打ちせず、必ずユーザーに確認する:
  - PR を検証したいのか、ローカルの diff を検証したいのか
  - ローカル diff の場合、何との差分か（未コミットの変更 / 現在のブランチと base ブランチとの差分 / 特定のコミット範囲）

`push-and-merge-to` skill と同じ方針で、`master` や「未コミットの変更」を勝手にデフォルトとして選ばない。

## Steps

1. **対象の解決**（上記の通り。曖昧なら先にユーザーへ確認する）
2. **コンテキストの収集**
   - PR 対象: `gh pr view <n>` と `gh pr diff <n>` を実行する（許可済みなので確認プロンプトは出ない）。変更されたファイルは diff の hunk だけでなく Read で全体を読み、周辺コードの文脈を把握する
   - ローカル diff 対象: `git status` と、対象範囲に応じた `git diff` (`git diff`, `git diff --cached`, `git diff <base>...HEAD` 等) を実行する
3. **Workflow tool による多段パイプラインで検証する**
   - この skill の指示に基づく Workflow 呼び出しは明示的な opt-in であり、"ultracode" の指定有無に関わらず許可される
   - Phase "Review": 観点（correctness / security / edge-cases / simplification・test-coverage など）ごとに、収集した diff とコンテキストから候補となる指摘を洗い出す
   - 候補指摘は Verify に渡す前に明らかな重複を軽くまとめる
   - Phase "Verify": 各指摘につき複数（目安 3 体）の懐疑的サブエージェントを並列起動し、「この指摘を反証せよ。確信が持てない場合はデフォルトで反証成立（refuted）とせよ」という指示で反証を試みさせる。過半数が反証に成功した指摘は却下し、反証できなかった指摘のみ生存させる
4. **結果報告**
   - `ReportFindings` tool で、生存した指摘のみを重大度順に報告する。各指摘に `verdict: CONFIRMED`（反証されなかった）または `PLAUSIBLE`（一部懐疑的エージェントは反証したが過半数には届かなかった）を設定する
   - 何も生き残らなければ空配列で報告する。素のテキストで指摘一覧を書き出さない
5. **PRへのインラインコメント投稿（PR対象のときのみ）**
   - Step 1 の対象がローカル diff だった場合、このステップはスキップし「対象が PR ではないため投稿はスキップします」とだけ伝える
   - `ReportFindings` の直後、確認を尋ねる前に、投稿先を取り違えないよう `gh pr view <n> --json title,headRefName,author,createdAt,commits` 等で以下を取得し、ユーザーに一度提示する:
     - Title
     - Branch（head ブランチ名）
     - Author
     - PR作成日
     - 最終コミットの日付（最新コミットの日時）
   - その上で `AskUserQuestion` で「この結果を PR #<n>（上記の対象）にインラインコメントとして投稿しますか？」を尋ねる（投稿する / しない）。「しない」が選ばれたらここで終了する。ユーザーの明示的な確認なしに絶対に投稿しない
   - 投稿する場合、まず `gh api repos/{owner}/{repo}/pulls/{n} -q .head.sha` 等でその時点の実際の PR head commit を取り直す。ローカルに、この PR に対する未コミット・未push の追加修正があり、指摘の行番号がその修正後の状態を基準にしている場合は、行番号がズレる可能性があるため、先にコミット・push するか、push 前の版に合わせて行番号を読み替えるかをユーザーに確認する
   - 生存した指摘それぞれを、次の形式の1コメントに変換する:
     - 先頭に `🤖 [adversarial-review by claude]` タグを付ける
     - 重要度は `verdict` だけでなく `failure_scenario` の実害の大きさから判断し、絵文字＋太字ラベルで示す（GitHub コメントは色そのものを使えないため、この絵文字＋太字が「色分け」の代替になる）:
       - 🔴 **重大** — データ消失・セキュリティ・クラッシュ級
       - 🟡 **中程度** — 実害はあるが影響範囲が限定的な correctness バグ
       - 🟢 **軽微** — テストカバレッジ不足・簡素化・スタイル
     - 確信度（`verdict`）も併記する: `CONFIRMED`（反証されず）/ `PLAUSIBLE`（一部反証あり、要検討）
     - 指摘内容と失敗シナリオを日本語で要約する
     - 具体的な修正コード例を提示できる場合は ```go 等の言語指定付きコードブロックで示す。目安として15行を超える、または複数箇所にまたがる場合は `<details><summary>修正例</summary>`...`</details>` で折りたたむ
   - 全体サマリ（`body`）には、指摘件数の内訳に加えて「各コメントは adversarial-review 実行者 が目視確認のうえ返信する想定です。返信が無い場合はお知らせください」という趣旨の一文を必ず含める
   - 1件ずつ `pulls/{n}/comments` を叩くのではなく、コメント一式を scratchpad に JSON ファイルとして書き出し、`gh api repos/{owner}/{repo}/pulls/{n}/reviews --input <tmpfile.json>` で一括投稿する。JSON は `{"commit_id": "...", "event": "COMMENT", "body": "<全体サマリ>", "comments": [{"path": "...", "line": N, "side": "RIGHT", "body": "..."}, ...]}` の形。`event` は常に `COMMENT`（承認/変更要求にはしない）
   - あるコメントの行が diff の範囲外で API に 422 で拒否された場合は、そのコメントだけ `gh pr comment` で PR 全体宛のコメントとして代替投稿し、どの指摘がインライン化できなかったかをユーザーに報告する
   - 投稿完了後、作成されたレビューの URL と、それをブラウザで開くためのコマンド（`open <URL>` / macOS 以外なら環境に応じて `xdg-open` 等）をユーザーに提示する
   - 続けて `AskUserQuestion` で「ブラウザで開きますか？」を尋ねる（開く / 開かない）。「開く」が選ばれた場合のみ、そのコマンドを実行してブラウザで開く

## Notes

- PR 対象の場合、Web fetch ではなく `gh pr view` / `gh pr diff` を使う
- 懐疑的サブエージェントへのプロンプトは常に「反証してみよ」という向きにする。「これは正しいか？」のような肯定確認の向きにすると、確証バイアスがかかり敵対的検証にならない
- PR へのコメント投稿はユーザーの目に見える・後から消しづらいアクションなので、`push-and-merge-to` skill と同じ方針で必ず事前に対話で確認してから実行する
