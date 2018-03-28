""""""""""""""""""""""""
" start: dein settings "
""""""""""""""""""""""""
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

  " プラグインリストを収めた TOML ファイル
  " 予め TOML ファイル（後述）を用意しておく
  let g:rc_dir    = expand('~/.vim/dein')
  let s:toml      = g:rc_dir . '/plugins.toml'
  let s:lazy_toml = g:rc_dir . '/plugins-lazy.toml'

  " TOML を読み込み、キャッシュしておく
  call dein#load_toml(s:toml,      {'lazy': 0})
  call dein#load_toml(s:lazy_toml, {'lazy': 1})

  " 設定終了
  call dein#end()
  call dein#save_state()
endif

" もし、未インストールものものがあったらインストール
if dein#check_install()
  call dein#install()
endif

""""""""""""""""""""""
" end: dein settings "
""""""""""""""""""""""


" setting
set fenc=utf-8
set noswapfile

" looks
set number
set cursorline
set list
set listchars=tab:»-,trail:-,eol:↲,extends:»,precedes:«,nbsp:%
set scrolloff=3
:syntax on
set cmdheight=2

" set cursorcolumn
set virtualedit=onemore

" tab etc.
set expandtab
set shiftwidth=2
set softtabstop=2
set smartindent

" BSで削除できるものを指定する
set backspace=indent,eol,start

" ファイルを閉じた後でもUndoできるようにする
let s:undo_dir = expand('$HOME/.cache/.vim/undo')
if !isdirectory(s:undo_dir)
  call mkdir(s:undo_dir, 'p')
endif
if has('persistent_undo')
  let &undodir = s:undo_dir
  set undofile
endif


""""""""""""""""""""""""""""""
" 自動的に閉じ括弧を入力
""""""""""""""""""""""""""""""
" imap { {}<LEFT>
" imap [ []<LEFT>
" imap ( ()<LEFT>
""""""""""""""""""""""""""""""

""""""""""""""""""""""""""""""
" 最後のカーソル位置を復元する
""""""""""""""""""""""""""""""
if has("autocmd")
    autocmd BufReadPost *
    \ if line("'\"") > 0 && line ("'\"") <= line("$") |
    \   exe "normal! g'\"" |
    \ endif
endif
""""""""""""""""""""""""""""""
