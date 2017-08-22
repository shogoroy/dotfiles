if [ "$(uname)" = 'Darwin' ]; then
  alias ls='ls -aGF'
else
  alias ls='ls -a --color=auto'
fi

# ls の色
export LS_COLORS="${LS_COLORS}:di=01;36"

# PATH
export GOPATH=$HOME/dev/go
export PATH=$PATH:%GOPATH/bin

autoload -U compinit
compinit
