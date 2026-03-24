local keymap = vim.keymap.set

-- Netrw vertical split
keymap("n", "<leader>pv", "<cmd>Vex<cr>", { desc = "Vertical file explorer (netrw)" })

-- Quickfix navigation
keymap("n", "<C-j>", "<cmd>cnext<cr>zz", { desc = "Quickfix next" })
keymap("n", "<C-k>", "<cmd>cprev<cr>zz", { desc = "Quickfix previous" })
keymap("n", "<C-d>", "<C-d>zz", { desc = "Jump down half page and center" })
keymap("n", "<C-u>", "<C-u>zz", { desc = "Jump up half page and center" })

-- Yank
keymap("x", "<leader>p", '"_dP', { desc = "Paste without overwriting register" })
keymap("x", "<leader>y", '"+y', { desc = "Yank selection to system clipboard" })
keymap("n", "<leader>y", '"+y', { desc = "Yank to system clipboard" })
keymap("n", "<leader>Y", 'gg"+yG', { desc = "Yank entire buffer to clipboard" })

-- Move selection
keymap("x", "J", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
keymap("x", "K", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })



-- Replace
keymap("n", "<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]], { desc = "Replace word under cursor globally" })

-- Helpers
keymap("n", "J", "mzJ`z", { desc = "Join lines without moving cursor" })
keymap("n", "<leader>x", "<cmd>!chmod +x %<CR>", { silent = true, desc = "Make current file executable" })
