return {
  "nvim-tree/nvim-tree.lua",
  version = "*",
  lazy = false, -- 起動時に読み込む（または 'keys' で遅延読み込み）
  dependencies = {
    "nvim-tree/nvim-web-devicons", -- アイコンを表示するために必要
  },
  config = function()
    require("nvim-tree").setup({
      sort_by = "case_sensitive",
      view = {
        width = 30,
        side = "left",
      },
      renderer = {
        group_empty = true,
        icons = {
          show = {
            git = true,
            folder = true,
            file = true,
          },
        },
      },
      filters = {
        dotfiles = false, -- ドットファイルを表示するかどうか
      },
    })

    -- キーバインドの設定（例：Ctrl + n でトグル）
    vim.keymap.set('n', '<C-n>', ':NvimTreeToggle<CR>', { silent = true })
    -- 現在のファイルの場所をフォーカスして開く
    vim.keymap.set('n', '<leader>nf', ':NvimTreeFindFile<CR>', { silent = true })
    vim.keymap.set('n', '<C-e>', ':NvimTreeFindFile<CR>', { silent = true })
  end,
}
