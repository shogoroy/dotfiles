-- lazy.nvim の自動インストール
require("config.lazy")

-- プラグインの読み込み
require("lazy").setup("plugins")

-- キーバインドの読み込み
require("config.keymaps")
