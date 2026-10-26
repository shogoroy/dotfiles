export GOPATH=$HOME/dev
export GOBIN=$GOPATH/bin
export PATH=$PATH:$GOPATH/bin
export PATH=$HOME/.nodebrew/current/bin:$PATH

export GHQ_ROOT=$GOPATH/src
export XDG_CONFIG_HOME=~/.config

export PATH=$PATH:~/.cargo/bin

export PATH=$PATH:/opt/homebrew/bin

# brew 版 curl が入っていれば優先する
if [ -d /opt/homebrew/opt/curl/bin ]; then
  export PATH="/opt/homebrew/opt/curl/bin:$PATH"
fi
