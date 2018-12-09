" ファイルを閉じた後でもUndoできるようにする
let s:undo_dir = expand('$HOME/.cache/.vim/undo')
if !isdirectory(s:undo_dir)
  call mkdir(s:undo_dir, 'p')
endif
if has('persistent_undo')
  let &undodir = s:undo_dir
  set undofile
endif

