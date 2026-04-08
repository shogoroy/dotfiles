return {
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    event = "InsertEnter", -- 挿入モードに入った時に起動
    enabled = false,
    config = function()
      require("copilot").setup({
        copilot_node_command = vim.fn.expand("$HOME") .. "/.n/n/versions/node/24.12.0/bin/node",
        -- 補完パネル（デフォルトの nvim-cmp を使う場合は false にする）
        suggestion = {
          enabled = true,
          auto_trigger = true, -- 自動で提案を出す
          keymap = {
            accept = "<C-l>", -- Ctrl + l で提案を確定
            next = "<M-]>", -- Alt + ] で次の提案
            prev = "<M-[>", -- Alt + [ で前の提案
            dismiss = "<C-]>",
          },
        },
        panel = { enabled = false },
        filetypes = {
          markdown = true, -- markdown でも有効にする
          typescript = true, -- allow specific filetype
          go = true,
          lua = true,
          help = false,
          gitcommit = true,
          cvs = false,
          ["."] = false,
        },
      })

      -- 手動で Tab キーのマッピングを設定
      vim.keymap.set("i", "<Tab>", function()
        if require("copilot.suggestion").is_visible() then
          require("copilot.suggestion").accept()
        else
          vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Tab>", true, false, true), "n", false)
        end
      end, { desc = "Copilot Tab Accept" })
    end,
  },
}
