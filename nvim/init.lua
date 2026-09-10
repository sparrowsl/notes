vim.g.start_time = vim.uv.hrtime()
vim.loader.enable()

require("options")
require("keymaps")
require("diagnostics")
require("plugins")
require("autocmds")

if vim.fn.has("nvim-0.12") == 1 then
  require("vim._core.ui2").enable({})
end
-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
