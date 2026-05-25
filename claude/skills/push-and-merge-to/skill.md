---
name: push-and-merge-to
description: Push the current branch, checkout the target branch passed as an argument, merge the current branch into it, push it to origin, then return to the original branch.
user-invocable: true
---

# Push and Merge to `<target>`

引数で指定した対象ブランチ `$ARGUMENTS` に対して、現在のブランチを push し、対象ブランチへ merge して push した後、元のブランチに戻る一連の操作を行う。

`$ARGUMENTS` が空（対象ブランチ名が渡されていない）場合は、処理に入る前にユーザーへ対象ブランチ名を確認する。`qa` や `develop` など特定の値を決め打ちで選ばない。

## Steps

以下、`<target>` = 引数で渡された対象ブランチ名 (`$ARGUMENTS`) とする。

1. 現在のブランチ名を記録する（後で戻るため）
   ```
   git branch --show-current
   ```

2. 現在のブランチを origin へ push する
   ```
   git push origin <current-branch>
   ```

3. `<target>` ブランチへ checkout する
   ```
   git checkout <target>
   ```

4. `origin/<target>` を pull する
   ```
   git pull origin <target>
   ```

5. 現在のブランチ（手順1で記録したもの）を `<target>` へ merge する
   ```
   git merge <current-branch>
   ```
   - コンフリクトが発生した場合は、**その時点で処理を中断し、コンフリクトが発生したファイルと内容をユーザーに報告して対応を確認する**
   - ユーザーの指示を受けてから解決・続行する

6. `<target>` を origin へ push する
   ```
   git push origin <target>
   ```

7. 元のブランチへ戻る
   ```
   git checkout <current-branch>
   ```

## Notes

- 各ステップの実行結果を簡潔に報告する
- push 前に type-check などの pre-push hook が走る場合があるが、失敗しない限りそのまま続行する
- コンフリクトが発生した場合は自動解決せず、必ずユーザーに確認を求めてから続行する
- `<target>` に `main` / `master` を渡された場合は誤操作の可能性があるため、ユーザーに確認してから続行する
