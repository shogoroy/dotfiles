return {
  -- カラースキーム
  {
    "jacoborus/tender.vim",
    lazy = false,
    priority = 1000,
    config = function()
      vim.cmd.colorscheme("tender")

      -- アクティブなペイン(Normal)はテーマの色を維持する

      -- 非アクティブなペイン(NormalNC)の背景色のみ変更
      -- 元の色(Tenderのデフォルト: #282828)より本当にわずかに明るくする (#2b2b2b)
      local normal = vim.api.nvim_get_hl(0, { name = "Normal", link = false })
      local normal_nc = vim.deepcopy(normal)

      normal_nc.bg = "#2b2b2b"
      vim.api.nvim_set_hl(0, "NormalNC", normal_nc)
    end,
  },
}
