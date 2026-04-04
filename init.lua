-- Neovim abierto desde la app (Dock) suele tener un PATH sin Homebrew; nvim-treesitter (main) invoca `tree-sitter`.
local function prepend_path(dir)
  local path = vim.env.PATH or ""
  if vim.fn.isdirectory(dir) == 0 or (":" .. path .. ":"):find(":" .. dir .. ":", 1, true) then
    return
  end
  vim.env.PATH = dir .. ":" .. path
end
prepend_path("/opt/homebrew/bin")
prepend_path("/usr/local/bin")

vim.g.mapleader = " "
vim.g.maplocalleader = " "

require("core")
