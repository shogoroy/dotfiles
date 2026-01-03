vim.opt.number = true
vim.opt.termguicolors = true
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2
vim.opt.expandtab = true
vim.opt.clipboard = "unnamedplus" -- クリップボード連携

-- Migrated from rc/set-command.vim
vim.opt.title = true
vim.opt.fileencoding = "utf-8"
vim.opt.swapfile = false
vim.opt.cursorline = true
vim.opt.cursorcolumn = true
vim.opt.list = true
vim.opt.listchars = "tab:»-,trail:-,extends:»,precedes:«,nbsp:%"
vim.opt.scrolloff = 4
vim.opt.cmdheight = 2
-- vim.opt.number = true -- Already set above
vim.opt.virtualedit = "onemore"
vim.opt.tabstop = 4 -- Overrides previous setting
vim.opt.softtabstop = 4
vim.opt.autoindent = true
vim.opt.smartindent = true
vim.opt.backspace = "indent,eol,start"
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.wrapscan = true
vim.opt.incsearch = true
vim.opt.inccommand = "split"
vim.opt.mouse = ""

-- Migrated from rc/fold.vim
vim.opt.foldmethod = "indent"
vim.opt.foldlevel = 99

-- Migrated from rc/undo.vim
-- ファイルを閉じた後でもUndoできるようにする
local undo_dir = vim.fn.expand('$HOME/.cache/.vim/undo')
if vim.fn.isdirectory(undo_dir) == 0 then
  vim.fn.mkdir(undo_dir, 'p')
end
if vim.fn.has('persistent_undo') == 1 then
  vim.opt.undodir = undo_dir
  vim.opt.undofile = true
end

-- Migrated from rc/guicursor.vim
vim.opt.guicursor = ""

-- Migrated from rc/colors.vim
-- vim.opt.termguicolors = true -- Already set above
vim.cmd('syntax enable')

-- Migrated from rc/filetype.vim
vim.cmd('filetype plugin indent on')
