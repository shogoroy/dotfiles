---
name: commit
description: Stage and commit changes using the project's commit convention — ticket prefix from branch name + gitmoji + summary. Commits directly without confirmation unless uncertain or content is sensitive.
user-invocable: true
---

# Commit Convention

## Format

```
[TICKET-ID] <gitmoji> <summary in English>
```

- **TICKET-ID**: Extract from the current branch name. If the branch starts with a pattern like `PJ2b0-T32268/...`, the ticket ID is `PJ2b0-T32268`. If no ticket ID is found, omit the bracket prefix.
- **gitmoji**: Choose the most appropriate emoji from https://gitmoji.dev/. Common ones:
  - ✨ `:sparkles:` — new feature
  - 🐛 `:bug:` — bug fix
  - ♻️ `:recycle:` — refactoring
  - 📝 `:memo:` — documentation
  - 🔧 `:wrench:` — configuration
  - 🛂 `:passport_control:` — IAM / permissions
  - 💚 `:green_heart:` — CI fix
  - 📌 `:pushpin:` — pinning dependencies
  - 🚀 `:rocket:` — deployment
  - 🗑️ `:wastebasket:` — removing code/files
- **summary**: Short, imperative English description of the change

## Steps

1. Run `git status` and `git diff` to understand what has changed
2. Run `git log --oneline -5` to check recent commit style
3. Stage the relevant files and commit directly with the proposed message — **skip confirmation** unless:
   - The changes are ambiguous or hard to summarize confidently
   - The diff contains sensitive content (credentials, secrets, personal data)
   - The scope is unusually large or touches unrelated areas
   In those cases, propose the message and ask for confirmation before proceeding.
4. Commit with:

```
Co-Authored-By: Claude Sonnet 4.6 <noreply@anthropic.com>
```

## Example

Branch: `PJ2b0-T32268/shogoro/some-feature`

```
[PJ2b0-T32268] ✨ Add manual approval toggle per environment
```
