vim.g.dracula_colorterm = 0

vim.opt.mouse = ""
vim.opt.mousescroll = "ver:0,hor:0"
vim.opt.swapfile = false
vim.opt.backup = false
local undodir = vim.fn.stdpath("data") .. "/undodir"
vim.fn.mkdir(undodir, "p")
vim.opt.undodir = undodir
vim.opt.undofile = true

vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.hlsearch = false
vim.opt.incsearch = true

vim.opt.updatetime = 50
vim.opt.signcolumn = "yes"

vim.opt.guicursor = ""
vim.opt.isfname:append("@-@")
vim.opt.colorcolumn = { "80" }
vim.opt.wrap = false
vim.opt.scrolloff = 8
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.smartindent = false
vim.opt.termguicolors = true

vim.opt.list = true
vim.opt.listchars = { tab = "→ ", trail = "•", nbsp = "·" }
vim.opt.cursorline = true

-- Disable netrw, oil.nvim covers it
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
