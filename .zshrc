for zsh in `dirname $(readlink ~/.zshrc)`/.zsh/**/*.zsh; do
  source $zsh
done
