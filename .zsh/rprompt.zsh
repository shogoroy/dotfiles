RPROMPT=$'`branch-status-check`' # %~はpwd
setopt prompt_subst #表示毎にPROMPTで設定されている文字列を評価する

function branch-status-check {
    local prefix branchname suffix
        # .gitの中だから除外
        if [[ "$PWD" =~ '/\.git(/.*)?$' ]]; then
            return
        fi
        branchname=`get-branch-name`
        # ブランチ名が無いので除外
        if [[ -z $branchname ]]; then
            return
        fi
        color_prefix=`get-branch-status-color`
        branch_prefix='['
        branch_suffix=']'
        color_suffix='%{'${reset_color}'%}'
        echo ${color_prefix}${branch_prefix}${branchname}${branch_suffix}${color_suffix}
}

function get-branch-name {
    echo `git rev-parse --abbrev-ref HEAD 2> /dev/null`
}

function get-branch-status-color {
    local res color
        output=`git status --short 2> /dev/null`
        if [ -z "$output" ]; then
            res=':' # status Clean
            color='%{'${fg[cyan]}'%}'
        elif [[ $output =~ "[\n]?\?\? " ]]; then
            res='?:' # Untracked
            color='%{'${fg[yellow]}'%}'
        elif [[ $output =~ "[\n]? M " ]]; then
            res='M:' # Modified
            color='%{'${fg[red]}'%}'
        else
            res='A:' # Added to commit
            color='%{'${fg[green]}'%}'
        fi
        # echo ${color}${res}'%{'${reset_color}'%}'
        echo ${color} # 色だけ返す
}
