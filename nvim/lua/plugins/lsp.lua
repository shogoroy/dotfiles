return {
  {
    "neovim/nvim-lspconfig",
    -- Bufferが読み込まれるときをトリガーに遅延ロードする
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/nvim-cmp",
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
    },
    config = function()
      -- 各プラグインを読み込む
      local mason = require("mason")
      local mason_lspconfig = require("mason-lspconfig")
      local lspconfig = require("lspconfig")
      local cmp_nvim_lsp = require("cmp_nvim_lsp")

      mason.setup()
      mason_lspconfig.setup({
        ensure_installed = { "ts_ls", "volar", "lua_ls" },
      })

      local capabilities = cmp_nvim_lsp.default_capabilities()

      require("mason-lspconfig").setup {
        automatic_enable = false
      }

      -- nvim-cmp の設定
      local cmp = require("cmp")
      cmp.setup({
        snippet = { expand = function(args) require("luasnip").lsp_expand(args.body) end },
        mapping = cmp.mapping.preset.insert({
          ['<CR>'] = cmp.mapping.confirm({ select = true }),
        }),
        sources = cmp.config.sources({ { name = 'nvim_lsp' } }, { { name = 'buffer' } })
      })
    end
  }
}
