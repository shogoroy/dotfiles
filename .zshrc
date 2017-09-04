if [ "$(uname)" = 'Darwin' ]; then
  alias ls='ls -aGF'
  # ls の色
  export LSCOLORS=gxfxcxdxbxegedabagacad
else
  alias ls='ls -a --color=auto'
  # ls の色
  export LS_COLORS="${LS_COLORS}:di=01;36"
fi


# PATH
export GOPATH=$HOME/dev/go
export PATH=$PATH:%GOPATH/bin

# 自動補完
autoload -U compinit
compinit

# prompt
# prompt
PROMPT='[%n@%m]%~%%'
