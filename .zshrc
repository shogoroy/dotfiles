if [ "$(uname)" = 'Darwin' ]; then
  alias ls='ls -aGF'
  # ls の色
  export LSCOLORS=gxfxcxdxbxegedabagacad

  #
  # tmp path to develope Matilda
  #

  # dev PCF
  # YKVSHOST1=cassandra01.direct30.kvs.ssk.ynwm.yahoo.co.jp
  # YKVSHOST2=cassandra02.direct30.kvs.ssk.ynwm.yahoo.co.jp
  # YKVSHOST3=cassandra03.direct30.kvs.ssk.ynwm.yahoo.co.jp
  #
  # YKVSKEYSPACE=y_mempf_kvs
  # YKVSPASSWORD=mempf_matilda
  # YKVSPROTOVERSION=3
  # YKVSUSERNAME=mempf_matilda
  # export VCAP_SERVICES="{\"user-provided\":[{\"credentials\":{\"YKVSHOST1\":\""${YKVSHOST1}"\",\"YKVSHOST2\":\""${YKVSHOST2}"\",\"YKVSHOST3\":\""${YKVSHOST3}"\",\"YKVSKEYSPACE\":\""${YKVSKEYSPACE}"\",\"YKVSPASSWORD\":\""${YKVSPASSWORD}"\",\"YKVSPROTOVERSION\":\""${YKVSPROTOVERSION}"\",\"YKVSUSERNAME\":\""${YKVSUSERNAME}"\"},\"syslog_drain_url\":\"\",\"volume_mounts\":[],\"label\":\"user-provided\",\"name\":\"rw-cassandra\",\"tags\":[]},{\"credentials\": {\"udbFeeder\": \"http://dev03.matilda.ssk.ynwm.yahoo.co.jp/udbFeederImportIdWebAPI.php\" }, \"syslog_drain_url\": \"\", \"volume_mounts\": [], \"label\": \"user-provided\", \"name\": \"url\", \"tags\": [] }]}"
  #
  # export PORT=8080
  # export CASSANDRA_KEY="rw-cassandra"
  # export APP_CONFIG_KEY="url"

  #
  YKVSHOST1=127.0.0.1
  YKVSHOST2=127.0.0.1
  YKVSHOST3=127.0.0.1

  YKVSKEYSPACE=y_mempf_kvs_dev_offercount
  YKVSPASSWORD=mempf_matilda
  YKVSPROTOVERSION=3
  YKVSUSERNAME=mempf_matilda
  export VCAP_SERVICES="{\"user-provided\":[{\"credentials\":{\"YKVSHOST1\":\""${YKVSHOST1}"\",\"YKVSHOST2\":\""${YKVSHOST2}"\",\"YKVSHOST3\":\""${YKVSHOST3}"\",\"YKVSKEYSPACE\":\""${YKVSKEYSPACE}"\",\"YKVSPASSWORD\":\""${YKVSPASSWORD}"\",\"YKVSPROTOVERSION\":\""${YKVSPROTOVERSION}"\",\"YKVSUSERNAME\":\""${YKVSUSERNAME}"\"},\"syslog_drain_url\":\"\",\"volume_mounts\":[],\"label\":\"user-provided\",\"name\":\"rw-cassandra\",\"tags\":[]},{\"credentials\": {\"udbFeeder\": \"http://dev03.matilda.ssk.ynwm.yahoo.co.jp/udbFeederImportIdWebAPI.php\" }, \"syslog_drain_url\": \"\", \"volume_mounts\": [], \"label\": \"user-provided\", \"name\": \"url\", \"tags\": [] }]}"

  export PORT=8080
  export CASSANDRA_KEY="rw-cassandra"
  export APP_CONFIG_KEY="url"


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
PROMPT='[%n@%m]%~%%'
