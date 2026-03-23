local keymap = vim.keymap.set

-- Netrw vertical split
keymap("n", "<leader>pv", "<cmd>Vex<cr>", { desc = "Vertical file explorer (netrw)" })
-- Quickfix navigation
keymap("n", "<C-j>", "<cmd>cnext<cr>", { desc = "Quickfix next" })
keymap("n", "<C-k>", "<cmd>cprev<cr>", { desc = "Quickfix previous" })
-- Yank
keymap("x", "<leader>p", '"_dP', { desc = "Paste without overwriting register" })
keymap("x", "<leader>y", '"+y', { desc = "Yank selection to system clipboard" })
keymap("n", "<leader>y", '"+y', { desc = "Yank to system clipboard" })
keymap("n", "<leader>Y", 'gg"+yG', { desc = "Yank entire buffer to clipboard" })
-- Move selection
keymap("x", "J", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
keymap("x", "K", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })
