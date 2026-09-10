vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.g.have_nerd_font = true
vim.g.markdown_recommended_style = 0

-- Disable netrw; using another file explorer.
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- ======= Indentation ========
vim.opt.tabstop = 2        -- Insert spaces for tabs
vim.opt.shiftwidth = 2     -- Number of spaces for each indent
vim.opt.expandtab = true   -- Convert tabs to spaces
vim.opt.breakindent = true -- Indent wrapped lines for readability

-- ======= Search settings ========
vim.opt.ignorecase = true -- Case-insensitive searching UNLESS \C or one or more capital letters in the search term
vim.opt.smartcase = true  -- Case sensitive if uppercase in search

-- ======= Visual settings ========
vim.opt.number = true
-- vim.opt.relativenumber = true
vim.opt.signcolumn = "yes"   -- Keep signcolumn on by default (default: 'auto')
vim.opt.showmode = false     -- We don't need to see things like -- INSERT -- anymore (default: true)
vim.opt.confirm = true       -- Confirm to save changes before exiting modified buffer
vim.opt.inccommand = 'split' -- Preview substitutions live, as you type!
vim.opt.cursorline = true -- Highlight the current line (default: false)
vim.opt.scrolloff = 10    -- Keep 10 lines of context above/below cursor
vim.opt.winborder = "rounded"
vim.opt.list = true
-- Sets how neovim will display certain whitespace characters in the editor.
vim.opt.listchars = {
  tab = "» ",
  trail = "·",
  nbsp = "␣",
  extends = "»",
  precedes = "«",
  leadmultispace = "···" .. string.rep("·", vim.o.shiftwidth - 1)
}
vim.opt.fillchars = {  eob = "~" }

-- ======= File handling ========
vim.opt.undofile = true     -- Save undo history (default: false)
vim.opt.updatetime = 250    -- Decrease update time (default: 4000)
vim.opt.timeoutlen = 300    -- Time to wait for a mapped sequence to complete (in milliseconds) (default: 1000)

-- ======= Behavior settings ========
vim.opt.mouse = "a"           -- Enable mouse mode!
vim.schedule(function() vim.o.clipboard = 'unnamedplus' end)

-- ======= Folding settings ========
vim.opt.smoothscroll = true
vim.opt.foldlevel = 99             -- Start with all folds open

-- ======= Split behavior ========
vim.opt.splitbelow = true -- Force all horizontal splits to go below current window (default: false)
vim.opt.splitright = true -- Force all vertical splits to go to the right of current window (default: false)
vim.opt.splitkeep = "screen"
