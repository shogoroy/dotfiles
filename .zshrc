if [ "$(uname)" = 'Darwin' ]; then
  alias ls='ls -aGF'
else
  alias ls='ls -a --color=auto'
fi

# PATH
export GOPATH=$HOME/dev/go
export PATH=$PATH:%GOPATH/bin
