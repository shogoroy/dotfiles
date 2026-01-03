local keymap = vim.keymap

-- LSP 操作のキーバインド（LSPが有効な時のみ動作させるのが理想ですが、簡易版です）
keymap.set('n', 'K',  '<cmd>lua vim.lsp.buf.hover()<CR>')
keymap.set('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>')
keymap.set('n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>')
keymap.set('n', 'gn', '<cmd>lua vim.lsp.buf.rename()<CR>')
keymap.set('n', 'ga', '<cmd>lua vim.lsp.buf.code_action()<CR>')
keymap.set('n', 'ge', '<cmd>lua vim.diagnostic.open_float()<CR>')