-- lazy.nvim の自動インストール
require("config.lazy")

-- オプション読み込み
require("config.options")

-- キーバインドの読み込み
require("config.keymaps")

-- プラグインの読み込み
require("lazy").setup("plugins")
