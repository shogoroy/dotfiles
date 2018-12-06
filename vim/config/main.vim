
" setting
set fenc=utf-8
set noswapfile

" looks
set number
set cursorline
set list
set listchars=tab:»-,trail:-,eol:↲,extends:»,precedes:«,nbsp:%
set scrolloff=3
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

