vim.cmd.syntax("enable")

local ok = pcall(function()
  vim.cmd.packadd("dracula_pro")
  vim.g.dracula_colorterm = 0
  vim.cmd.colorscheme("dracula_pro")
end)
if not ok then
  vim.cmd.colorscheme("desert")
end
