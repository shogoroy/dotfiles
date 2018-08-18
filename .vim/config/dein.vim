" プラグインが実際にインストールされるディレクトリ
let s:dein_dir = expand('~/.cache/.vim/dein')
" dein.vim 本体
let s:dein_repo_dir = s:dein_dir . '/repos/github.com/Shougo/dein.vim'

" dein.vim がなければ github から落としてくる
if &runtimepath !~# '/dein.vim'
  if !isdirectory(s:dein_repo_dir)
    execute '!git clone https://github.com/Shougo/dein.vim' s:dein_repo_dir
  endif
  execute 'set runtimepath^=' . fnamemodify(s:dein_repo_dir, ':p')
endif

" 設定開始
if dein#load_state(s:dein_dir)
  call dein#begin(s:dein_dir)
runtime! config/plugins/*.vim

  " プラグインリストを収めた TOML ファイル
  " 予め TOML ファイル（後述）を用意しておく
  let g:dein_dir    = expand('~/.vim/dein')
  let s:plugin_dir      = g:dein_dir . '/plugins'
  let s:lazy_plugin_dir = g:dein_dir . '/lazy-plugins'
  let s:ft_plugin_dir = g:dein_dir . '/ft-plugins'

  let s:tomls = split(glob(s:plugin_dir . '/*.toml'), '\n')
  let s:lazy_tomls = split(glob(s:lazy_plugin_dir . '/*.toml'), '\n')
  let s:ft_tomls = split(glob(s:ft_plugin_dir . '/*.toml'), '\n')

  " TOML を読み込み、キャッシュしておく
  for s:toml in s:tomls
    call dein#load_toml(s:toml, {'lazy': 0})
  endfor

  for s:lazy_toml in s:lazy_tomls + s:ft_tomls
    call dein#load_toml(s:lazy_toml, {'lazy': 1})
  endfor

  " 設定終了
  call dein#end()
  call dein#save_state()
endif

" もし、未インストールものものがあったらインストール
if dein#check_install()
  call dein#install()
endif

