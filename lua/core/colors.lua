local M = {}

function M.activate_dracula_pro()
  vim.cmd([[
let g:dracula_colorterm = 0
colorscheme dracula_pro
]])
end

return M
