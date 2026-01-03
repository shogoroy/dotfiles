return {
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    event = "InsertEnter", -- 挿入モードに入った時に起動
    config = function()
      require("copilot").setup({
        -- 補完パネル（デフォルトの nvim-cmp を使う場合は false にする）
        suggestion = {
          enabled = true,
          auto_trigger = true, -- 自動で提案を出す
          keymap = {
            accept = "<C-l>",  -- Ctrl + l で提案を確定
            next = "<M-]>",    -- Alt + ] で次の提案
            prev = "<M-[>",    -- Alt + [ で前の提案
            dismiss = "<C-]>",
          },
        },
        panel = { enabled = false },
        filetypes = {
          markdown = true, -- markdown でも有効にする
          help = false,
          gitcommit = false,
          cvs = false,
          ["."] = false,
        },
      })
    end,
  },
}
