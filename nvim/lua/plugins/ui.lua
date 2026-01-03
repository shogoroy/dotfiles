return {
  -- カラースキーム
  {
    "jacoborus/tender.vim",
    lazy = false,
    priority = 1000,
    config = function()
      vim.cmd.colorscheme("tender")
    end
  },
  -- ステータスライン
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
  },
  -- Gitのサイン表示
  { "lewis6991/gitsigns.nvim", opts = { current_line_blame = true } },
}
