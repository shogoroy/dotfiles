if [ "$(uname)" = 'Darwin' ]; then
  alias ls='ls -aGF'
else
  alias ls='ls -a --color=auto'
fi
