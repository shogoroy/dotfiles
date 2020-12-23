if type go > /dev/null 2>&1; then # コマンドが存在すれば
  if ! type gopls > /dev/null 2>&1 ; then
    go get \
      golang.org/x/tools/gopls@latest
  fi

  if ! type gofumpt > /dev/null 2>&1 ; then
    GO111MODULE=on go get mvdan.cc/gofumpt
  fi
fi

