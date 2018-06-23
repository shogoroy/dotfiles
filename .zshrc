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
export PATH=$HOME/.nodebrew/current/bin:$PATH

# 自動補完
autoload -U compinit
compinit

# 前方予測
# autoload predict-on
# predict-on

# prompt
PROMPT='[%n@%m]%~%%'
