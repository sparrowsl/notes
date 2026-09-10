vim.api.nvim_create_autocmd("FileType", {
  callback = function(args)
    local lang = vim.treesitter.language.get_lang(args.match)
    if not lang then
      return
    end

    if not pcall(vim.treesitter.start, args.buf, lang) then
      return
    end

    vim.wo.foldmethod = "expr"
    vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
  end,
})

-- update tree-sitter parsers whenever ‘nvim-treesitter’ is updated:
vim.api.nvim_create_autocmd('PackChanged', {
  callback = function(ev)
    local name = ev.data.spec.name
    local kind = ev.data.kind
    if kind ~= 'install' and kind ~= 'update' then return end

    if name == 'nvim-treesitter' then
      if not ev.data.active then vim.cmd.packadd 'nvim-treesitter' end
      vim.cmd 'TSUpdate'
      return
    end
  end
})

-- Check if we need to reload the file when it changed
vim.api.nvim_create_autocmd({ "FocusGained", "TermClose", "TermLeave" }, {
  group = vim.api.nvim_create_augroup("checktime", { clear = true }),
  callback = function()
    if vim.o.buftype ~= "nofile" then
      vim.cmd("checktime")
    end
  end,
})

-- Highlight when yanking (copying) text
vim.api.nvim_create_autocmd("TextYankPost", {
  desc = "Highlight when yanking (copying) text",
  group = vim.api.nvim_create_augroup("highlight-yank", { clear = true }),
  callback = function()
    vim.hl.on_yank()
  end,
})

vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("lsp-attach", { clear = true }),
  callback = function(event)
    local bufnr = event.buf

    local client = vim.lsp.get_client_by_id(event.data.client_id)

    -----------------------------------------------------------
    -- Inlay hints toggle keymap
    -----------------------------------------------------------
    if client and client:supports_method("textDocument/inlayHint") then
      vim.keymap.set("n", "<leader>th", function()
        vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = bufnr }), { bufnr = bufnr })
      end, { desc = "[T]oggle Inlay [H]ints", buffer = bufnr })
    end

    -----------------------------------------------------------
    -- LSP navigation keymaps (buffer-scoped)
    -----------------------------------------------------------
    vim.keymap.set("n", "K", vim.lsp.buf.hover, { desc = "Hover", buffer = bufnr })
    vim.keymap.set("n", "gd", vim.lsp.buf.definition, { desc = "[G]oto [D]efinition", buffer = bufnr })
    vim.keymap.set("n", "gD", vim.lsp.buf.declaration, { desc = "[G]oto [D]eclaration", buffer = bufnr })
    vim.keymap.set("n", "gI", vim.lsp.buf.implementation, { desc = "[G]oto [I]mplementation", buffer = bufnr })
    vim.keymap.set("n", "gr", vim.lsp.buf.references, { desc = "[G]oto [R]eferences", buffer = bufnr })
    vim.keymap.set("n", "<leader>D", vim.lsp.buf.type_definition, { desc = "Type [D]efinition", buffer = bufnr })
    vim.keymap.set("n", "<leader>ds", vim.lsp.buf.document_symbol, { desc = "[D]ocument [S]ymbols", buffer = bufnr })
    vim.keymap.set("n", "<leader>ws", vim.lsp.buf.workspace_symbol, { desc = "[W]orkspace [S]ymbols", buffer = bufnr })
    vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, { desc = "[R]e[n]ame", buffer = bufnr })
    vim.keymap.set({ "n", "x" }, "<leader>ca", vim.lsp.buf.code_action, { desc = "[C]ode [A]ction", buffer = bufnr })
    vim.keymap.set({ "n", "v" }, "<leader>f", function()
      vim.lsp.buf.format({ bufnr = bufnr })
    end, { desc = "[F]ormat buffer", buffer = bufnr })
    --
  end,
})

local formatters = {
  lua = { "lua_ls" },
  javascript = { "biome" },
  typescript = { "biome" },
  json = { "biome" },
  css = { "biome" },
  svelte = { "biome" },
  python = { "ruff" },
  go = { "gopls" },
  zig = { "zls" },
}
-- Autoformat on save using built-in LSP
vim.api.nvim_create_autocmd("BufWritePre", {
  group = vim.api.nvim_create_augroup("lsp-format", { clear = true }),
  callback = function(args)
    local bufnr = args.buf
    local disable_filetypes = { cpp = true }

    if disable_filetypes[vim.bo[bufnr].filetype] then
      return
    end

    local clients = vim.lsp.get_clients({
      bufnr = args.buf,
      method = "textDocument/formatting",
    })

    if #clients == 0 then
      return
    end

    vim.lsp.buf.format({
      bufnr = bufnr,
      timeout_ms = 500,
      filter = function(client)
        local allowed = formatters[vim.bo[bufnr].filetype]
        return allowed and vim.tbl_contains(allowed, client.name)
      end,
    })
  end,
})
