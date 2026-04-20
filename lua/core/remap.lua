local keymap = vim.keymap.set

-- File explorer: <leader>pv is set in lua/core/lazy/oil.lua (Oil float)

require("core.buffer_close").setup()

-- Quickfix navigation
keymap("n", "<leader>k", "<cmd>lnext<CR>zz", { desc = "Next location list item (centered)" })
keymap("n", "<leader>j", "<cmd>lprev<CR>zz", { desc = "Previous location list item (centered)" })
keymap("n", "<C-j>", "<cmd>cnext<cr>zz", { desc = "Quickfix next" })
keymap("n", "<C-k>", "<cmd>cprev<cr>zz", { desc = "Quickfix previous" })
keymap("n", "<C-d>", "<C-d>zz", { desc = "Jump down half page and center" })
keymap("n", "<C-u>", "<C-u>zz", { desc = "Jump up half page and center" })
keymap("n", "n", "nzzzv", { desc = "Next search result (centered)" })
keymap("n", "N", "Nzzzv", { desc = "Previous search result (centered)" })

-- Yank
keymap("x", "<leader>p", '"_dP', { desc = "Paste without overwriting register" })
keymap("x", "<leader>y", '"+y', { desc = "Yank selection to system clipboard" })
keymap("n", "<leader>y", '"+y', { desc = "Yank to system clipboard" })
keymap("n", "<leader>Y", 'gg"+yG', { desc = "Yank entire buffer to clipboard" })
keymap({ "n", "v" }, "<leader>d", [["_d]], { desc = "Delete to void register" })

-- Move selection
keymap("x", "J", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
keymap("x", "K", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })

-- Replace
keymap(
  "n",
  "<leader>s",
  [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]],
  { desc = "Replace word under cursor globally" }
)

-- Helpers
keymap("n", "J", "mzJ`z", { desc = "Join lines without moving cursor" })
keymap("n", "<leader>x", "<cmd>!chmod +x %<CR>", { silent = true, desc = "Make current file executable" })

-- Static formatting
keymap("n", "=ap", "ma=ap'a", { desc = "Format paragraph keeping cursor position" })

-- Just kidding
keymap("n", "<leader>mir", function()
  require("cellular-automaton").start_animation("make_it_rain")
end, { desc = "Cellular Automaton: Make it rain!" })

require("core.ai_keymaps").setup()

-- [C]ode [F]ormat: trim EOL + conform (pcall if plugin not ready)
keymap("n", "<leader>cf", function()
  local ok, conform = pcall(require, "conform")
  if not ok then
    vim.notify("conform.nvim is not loaded yet", vim.log.levels.WARN)
    return
  end
  local save_cursor = vim.fn.getpos(".")
  vim.cmd([[%s/\s\+$//e]])
  conform.format({ lsp_fallback = true })
  vim.fn.setpos(".", save_cursor)
  vim.notify("Formatted", vim.log.levels.INFO, { title = "Conform" })
end, { desc = "Format buffer (trim + conform)" })
