""""""
" ale
""""""
let g:ale_fixers = {
      \ 'typescript': ['tslint']
      \ }
let g:ale_fix_on_save = 1
let g:ale_completion_enabled = 1
let g:ale_javascript_prettier_use_local_config = 1


"""""""""""
" NERDTree
"""""""""""
let NERDTreeShowHidden=1
nnoremap <silent><C-e> :NERDTreeToggle<CR>


"""""""""""
" deoplete
"""""""""""
call dein#add('Shougo/deoplete.nvim')
  call dein#add('Shougo/deoplete-rct')

  if !has('nvim')
  call dein#add('roxma/nvim-yarp')
  call dein#add('roxma/vim-hug-neovim-rpc')
  endif

""""""""""""
" tsuquyomi
""""""""""""
let g:tsuquyomi_completion_detail = 1

"""""""""
" gotham
"""""""""
colorscheme gotham

"""""""""""""""
" markdown関連
"""""""""""""""
autocmd BufRead,BufNewFile *.mkd  set filetype=markdown
autocmd BufRead,BufNewFile *.md  set filetype=markdown
" Need: kannokanno/previm
nnoremap <silent> <C-p> :PrevimOpen<CR> " Ctrl-pでプレビュー
" 自動で折りたたまないようにする
let g:vim_markdown_folding_disabled=1

""""""""""""""""""""
" vim-javacomplete2
""""""""""""""""""""
autocmd FileType java setlocal omnifunc=javacomplete#Complete

""""""""""""""""""
" dart-vim-plugin
""""""""""""""""""
let dart_format_on_save = 1
