for zsh in `dirname $(readlink ~/.zshrc)`/zsh/**/*.zsh; do
  source $zsh
done

# 外部 CLI ツールの未インストール時セットアップ
# サブプロセスとして実行する (source すると、スクリプト内の `exit` が
# ログインシェル自体を終了させてしまうため)
for tool in `dirname $(readlink ~/.zshrc)`/tool-install/*.zsh; do
  zsh "$tool"
done
