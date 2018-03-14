
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

