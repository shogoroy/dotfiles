return {
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      "hrsh7th/cmp-nvim-lsp", -- 補完とLSPを連携させる
    },
    config = function()
      require("mason").setup()
      require("mason-lspconfig").setup({
        -- 使用する言語サーバーをリストアップ
        ensure_installed = { 
          "gopls", "vtsls", "rust_analyzer", "solargraph", "bashls", "perlnavigator" 
        },
      })

      local lspconfig = require("lspconfig")
      local capabilities = require('cmp_nvim_lsp').default_capabilities()

      -- 各言語サーバーの個別設定
      local servers = { "gopls", "vtsls", "rust_analyzer", "solargraph", "bashls", "perlnavigator" }
      for _, lsp in ipairs(servers) do
        lspconfig[lsp].setup({
          capabilities = capabilities,
        })
      end
    end,
  },
}