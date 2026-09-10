--- Single source of truth for diagnostic UI.
--- Avoid calling vim.diagnostic.config() from options.lua, keymaps.lua, or autocmds.lua.

local palette = {
  err = "#51202A",
  warn = "#3B3B1B",
  info = "#1F3342",
  hint = "#1E2E1E",
}

local function set_highlights()
  vim.api.nvim_set_hl(0, "DiagnosticErrorLine", { bg = palette.err })
  vim.api.nvim_set_hl(0, "DiagnosticWarnLine", { bg = palette.warn })
  vim.api.nvim_set_hl(0, "DiagnosticInfoLine", { bg = palette.info })
  vim.api.nvim_set_hl(0, "DiagnosticHintLine", { bg = palette.hint })
end

local function diagnostic_goto(forward, level)
  local filter = nil
  if level then
    assert(vim.diagnostic.severity[level], "invalid diagnostic severity: " .. tostring(level))
    filter = vim.diagnostic.severity[level]
  end

  return function()
    vim.diagnostic.jump({ count = forward and 1 or -1, severity = filter })
  end
end

vim.api.nvim_create_autocmd("ColorScheme", {
  group = vim.api.nvim_create_augroup("diagnostic_highlights", { clear = true }),
  callback = set_highlights,
})

vim.diagnostic.config({
  virtual_text = true,
  underline = { severity = vim.diagnostic.severity.ERROR },
  severity_sort = true,
  update_in_insert = false,
  float = {
    source = "if_many",
  },
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = "",
      [vim.diagnostic.severity.WARN]  = "",
      [vim.diagnostic.severity.INFO]  = "",
      [vim.diagnostic.severity.HINT]  = "",
    },
    linehl = {
      [vim.diagnostic.severity.ERROR] = "DiagnosticErrorLine",
      [vim.diagnostic.severity.WARN] = "DiagnosticWarnLine",
      [vim.diagnostic.severity.INFO] = "DiagnosticInfoLine",
      [vim.diagnostic.severity.HINT] = "DiagnosticHintLine",
    },
  },
  jump = {
    on_jump = function(_, bufnr)
      vim.diagnostic.open_float({
        bufnr = bufnr,
        scope = "cursor",
        focus = false,
      })
    end,
  },
})

vim.keymap.set("n", "<leader>cd", vim.diagnostic.open_float, { desc = "Line Diagnostics" })
vim.keymap.set("n", "]d", diagnostic_goto(true), { desc = "Next Diagnostic" })
vim.keymap.set("n", "[d", diagnostic_goto(false), { desc = "Prev Diagnostic" })
vim.keymap.set("n", "]e", diagnostic_goto(true, "ERROR"), { desc = "Next Error" })
vim.keymap.set("n", "[e", diagnostic_goto(false, "ERROR"), { desc = "Prev Error" })
vim.keymap.set("n", "]w", diagnostic_goto(true, "WARN"), { desc = "Next Warning" })
vim.keymap.set("n", "[w", diagnostic_goto(false, "WARN"), { desc = "Prev Warning" })
