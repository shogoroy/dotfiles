call dein#add('Shougo/deoplete.nvim')
  call dein#add('Shougo/deoplete-rct')

  if !has('nvim')
  call dein#add('roxma/nvim-yarp')
  call dein#add('roxma/vim-hug-neovim-rpc')
  endif

