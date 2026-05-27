for zsh in `dirname $(readlink ~/.zshrc)`/zsh/**/*.zsh; do
  source $zsh
done

# 外部 CLI ツールの未インストール時セットアップ
for tool in `dirname $(readlink ~/.zshrc)`/tool-install/*.sh; do
  source $tool
done
