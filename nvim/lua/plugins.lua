vim.pack.add({
  "https://github.com/folke/tokyonight.nvim",
  "https://github.com/nvim-treesitter/nvim-treesitter",
  {
    src = "https://github.com/Saghen/blink.cmp",
    version = vim.version.range("1.*"),
  },
  "https://github.com/lewis6991/gitsigns.nvim",
  "https://github.com/mason-org/mason-lspconfig.nvim",
  "https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim",
  "https://github.com/folke/which-key.nvim",
  "https://github.com/folke/snacks.nvim",

  -- libraries --
  "https://github.com/neovim/nvim-lspconfig",        -- deps for lspconfig
  "https://github.com/mason-org/mason.nvim",         -- deps for lspconfig
  "https://github.com/nvim-mini/mini.nvim",          -- mini.icons, mini.ai, mini.surround, mini.statusline
  "https://github.com/rafamadriz/friendly-snippets", -- dep for blink
}, { load = true })

-- Core additions
require("mini.icons").setup()
MiniIcons.mock_nvim_web_devicons()

require("mini.ai").setup()
require("mini.surround").setup()

-- Colorscheme
require("tokyonight").setup({
  styles = {
    comments = { italic = true },
    keywords = { italic = true },
    functions = { italic = true },
    variables = { italic = false },
  },
})
vim.cmd.colorscheme("tokyonight")

-- Snacks
require("snacks").setup {
  terminal = {
    win = { position = "float", border = "rounded" },
  },
  dim = {},
  indent = {},
  picker = {},
  input = {},
  explorer = {},
  image = {},
  quickfile = {},
  zen = {},
  bigfile = {},
  words = {},
  scope = {},
  dashboard = {
    preset = {
      keys = {
        { icon = " ", key = "f", desc = "Find File", action = ":lua Snacks.dashboard.pick('files')" },
        { icon = " ", key = "n", desc = "New File", action = ":ene | startinsert" },
        { icon = " ", key = "g", desc = "Find Text", action = ":lua Snacks.dashboard.pick('grep')" },
        { icon = " ", key = "r", desc = "Recent Files", action = ":lua Snacks.dashboard.pick('recent')" },
        { icon = " ", key = "c", desc = "Config", action = ":lua Snacks.dashboard.pick('files', {cwd = vim.fn.stdpath('config')})" },
        { icon = " ", key = "q", desc = "Quit", action = ":qa" },
      },
    },
    sections = {
      { section = "header" },
      { section = "keys",  gap = 1, padding = 1 },
      function()
        local ms = math.floor((vim.uv.hrtime() - vim.g.start_time) / 1e6 + 0.5)
        return { align = "center", text = "⚡ loaded in " .. ms .. "ms" }
      end,
    },
  },
}

local parsers = {
  "bash",
  "c",
  "css",
  "go",
  "html",
  "javascript",
  "json",
  "lua",
  "markdown",
  "markdown_inline",
  "sql",
  "svelte",
  "toml",
  "tsx",
  "typescript",
  "yaml",
  "zig",
  "python",
}

require("nvim-treesitter").install(parsers)

-- Statusline
local statusline = require("mini.statusline")
statusline.setup({ use_icons = vim.g.have_nerd_font })

---@diagnostic disable-next-line: duplicate-set-field
statusline.section_location = function() return "%2l:%-2v" end


-- Completion
local blink = require("blink.cmp")
blink.setup({
  keymap = {
    preset = "default",
    ["<CR>"] = { "accept", "fallback" },
  },
  signature = { enabled = true },
  completion = {
    accept = { auto_brackets = { enabled = false } },
  },
  cmdline = {
    keymap = {
      ["<CR>"] = { "accept_and_enter", "fallback" },
    },
  },
})

local lsp_capabilities = blink.get_lsp_capabilities()
vim.lsp.config("*", { capabilities = lsp_capabilities })

-- Servers installed by mason-tool-installer. mason-lspconfig enables
-- them automatically, capabilities come from blink.
---@type table<string, vim.lsp.Config>
local servers = {
  biome = {},
  clangd = {},
  gopls = {},
  emmet_language_server = {},
  sqlls = {},
  tailwindcss = {},
  svelte = {},
  zls = {
    settings = {
      zls = {
        enable_build_on_save = true,
        semantic_tokens = "partial",
      },
    },
  },
  lua_ls = {
    settings = {
      Lua = {
        runtime = { version = "LuaJIT" },
        completion = { callSnippet = "Replace" },
        diagnostics = {
          globals = { "vim" },
        },
        workspace = {
          checkThirdParty = false,
        },
        telemetry = { enable = false },
      },
    },
  },
  tsc = {},
  ty = {},
  ruff = {},
}

-- LSP
require("mason").setup()
require("mason-lspconfig").setup {}
require("mason-tool-installer").setup {
  ensure_installed = vim.tbl_keys(servers),
}

-- Key hints
local which_key = require("which-key")
which_key.setup({
  spec = {
    { "<leader>s", group = "[S]earch",   mode = { "n", "v" } },
    { "<leader>t", group = "[T]oggle" },
    { "<leader>h", group = "Git [H]unk", mode = { "n", "v" } },
    { "<leader>w", group = "[W]indow" },
    { "<leader>b", group = "[B]uffer" },
  },
})

vim.keymap.set("n", "<leader>?", function()
  which_key.show({ global = false })
end, { desc = "Buffer Local Keymaps (which-key)" })

-- Terminal and toggles
vim.keymap.set({ "n", "i", "t" }, [[<C-/>]], function()
  Snacks.terminal.toggle()
end, { desc = "Toggle floating terminal" })
Snacks.toggle.dim():map("<leader>td")
Snacks.toggle.zen():map("<leader>tz")
Snacks.toggle.zoom():map("<leader>Z")
vim.keymap.set("n", "<leader>e", function() Snacks.explorer() end, { desc = "File Explorer" })

-- Pickers
vim.keymap.set("n", "<leader>sh", function() Snacks.picker.help() end, { desc = "[S]earch [H]elp" })
vim.keymap.set("n", "<leader>sk", function() Snacks.picker.keymaps() end, { desc = "[S]earch [K]eymaps" })
vim.keymap.set("n", "<leader>sf", function() Snacks.picker.files() end, { desc = "[S]earch [F]iles" })
vim.keymap.set("n", "<leader>ss", function() Snacks.picker.pickers() end, { desc = "[S]earch [S]elect picker" })
vim.keymap.set({ "n", "x" }, "<leader>sw", function() Snacks.picker.grep_word() end,
  { desc = "[S]earch [W]ord (visual selection or cword)" })
vim.keymap.set("n", "<leader>/", function() Snacks.picker.lines() end, { desc = "[S]earch Current Buffer" })
vim.keymap.set("n", "<leader>sg", function() Snacks.picker.grep() end,
  { desc = "[S]earch by [G]rep in current project" })
vim.keymap.set("n", "<leader>sr", function() Snacks.picker.resume() end, { desc = "[S]earch [R]esume" })
vim.keymap.set("n", "<leader>s.", function() Snacks.picker.recent() end,
  { desc = '[S]earch Recent Files ("." for repeat)' })
vim.keymap.set("n", "<leader><leader>", function() Snacks.picker.buffers() end, { desc = "[ ] Find existing buffers" })
vim.keymap.set("n", "<leader>su", function() Snacks.picker.spelling() end, { desc = "[S]pell S[u]ggestions" })
vim.keymap.set("n", "<leader>sp", function() Snacks.picker.grep({ hidden = true }) end, { desc = "[S]earch [P]roject (hidden)" })
vim.keymap.set("n", "<leader>sn", function()
  Snacks.picker.files({ cwd = vim.fn.stdpath("config") })
end, { desc = "[S]earch [N]eovim files" })
vim.keymap.set("n", "<leader>q", function() Snacks.picker.diagnostics() end, { desc = "Show [Q]uickfix diagnostics" })

-- Git signs
local gitsigns = require("gitsigns")
gitsigns.setup({
  current_line_blame = false, -- Toggle with `<leader>tb`
  signs = {
    add = { text = "+" },
    change = { text = "~" },
    delete = { text = "_" },
    topdelete = { text = "" },
    changedelete = { text = "~" },
    untracked = { text = "" },
  },
  on_attach = function(bufnr)
    -- Navigation
    vim.keymap.set("n", "]c", function() gitsigns.nav_hunk("next") end, { desc = "Next git [c]hange", buf = bufnr })
    vim.keymap.set("n", "[c", function() gitsigns.nav_hunk("prev") end, { desc = "Prev git [c]hange", buf = bufnr })

    -- Stage / Reset hunk
    vim.keymap.set("n", "<leader>hs", gitsigns.stage_hunk, { desc = "git [s]tage hunk", buf = bufnr })
    vim.keymap.set("n", "<leader>hr", gitsigns.reset_hunk, { desc = "git [r]eset hunk", buf = bufnr })
    vim.keymap.set("v", "<leader>hs", function() gitsigns.stage_hunk({ vim.fn.line("."), vim.fn.line("v") }) end,
      { desc = "git [s]tage hunk", buf = bufnr })
    vim.keymap.set("v", "<leader>hr", function() gitsigns.reset_hunk({ vim.fn.line("."), vim.fn.line("v") }) end,
      { desc = "git [r]eset hunk", buf = bufnr })

    -- Stage / Reset buffer
    vim.keymap.set("n", "<leader>hS", gitsigns.stage_buffer, { desc = "git [S]tage buffer", buf = bufnr })
    vim.keymap.set("n", "<leader>hR", gitsigns.reset_buffer, { desc = "git [R]eset buffer", buf = bufnr })

    -- Preview
    vim.keymap.set("n", "<leader>hp", gitsigns.preview_hunk, { desc = "git [p]review hunk", buf = bufnr })
    vim.keymap.set("n", "<leader>hi", gitsigns.preview_hunk_inline, { desc = "git preview hunk [i]nline", buf = bufnr })

    -- Diff
    vim.keymap.set("n", "<leader>hd", gitsigns.diffthis, { desc = "git [d]iff against index", buf = bufnr })
    vim.keymap.set("n", "<leader>hD", function() gitsigns.diffthis("~") end,
      { desc = "git [D]iff against last commit", buf = bufnr })

    -- Quickfix
    vim.keymap.set("n", "<leader>hQ", function() gitsigns.setqflist("all") end,
      { desc = "git hunk [Q]uickfix list (all files)", buf = bufnr })
    vim.keymap.set("n", "<leader>hq", gitsigns.setqflist, { desc = "git hunk [q]uickfix list (this file)", buf = bufnr })

    -- Toggles
    vim.keymap.set("n", "<leader>tb", gitsigns.toggle_current_line_blame,
      { desc = "[T]oggle git show [b]lame line", buf = bufnr })
    vim.keymap.set("n", "<leader>tw", gitsigns.toggle_word_diff,
      { desc = "[T]oggle git intra-line [w]ord diff", buf = bufnr })

    -- Text object
    vim.keymap.set({ "o", "x" }, "ih", gitsigns.select_hunk, { desc = "text object [i]nside [h]unk", buf = bufnr })
  end,
})
