if &compatible
  set nocompatible               " Be iMproved
endif

" プラグインが実際にインストールされるディレクトリ
let s:dein_dir = expand('~/.cache/dein')
" dein.vim 本体
let s:dein_repo_dir = s:dein_dir . '/repos/github.com/Shougo/dein.vim'

" install dein.vim if not
if &runtimepath !~# '/dein.vim'
  if !isdirectory(s:dein_repo_dir)
    execute '!git clone https://github.com/Shougo/dein.vim' s:dein_repo_dir
  endif
  execute 'set runtimepath^=' . fnamemodify(s:dein_repo_dir, ':p')
endif

if !dein#load_state(s:dein_dir)
  finish
endif

"
" start dein settings
"
call dein#begin(s:dein_dir)

let s:dein_toml_dir = expand('~/.config/nvim/dein')
call dein#load_toml(s:dein_toml_dir . '/plugins.toml', {'lazy': 0})
call dein#load_toml(s:dein_toml_dir . '/lazy-plugins.toml', {'lazy' : 1})
call dein#load_toml(s:dein_toml_dir . '/ft-plugins.toml')

call dein#end()
call dein#save_state()

if dein#check_install()
  " Installation check.
  call dein#install()
endif
