return {
  "tpope/vim-fugitive",
  config = function()
    vim.keymap.set("n", "<leader>gs", function()
      vim.cmd("Git")
    end, { desc = "Fugitive: Git status" })

    local Mine_Fugitive = vim.api.nvim_create_augroup("Mine_Fugitive", {})

    local autocmd = vim.api.nvim_create_autocmd
    autocmd("BufWinEnter", {
      group = Mine_Fugitive,
      pattern = "*",
      callback = function()
        if vim.bo.ft ~= "fugitive" then
          return
        end

        local bufnr = vim.api.nvim_get_current_buf()
        local opts = { buffer = bufnr, remap = false }
        vim.keymap.set("n", "<leader>p", function()
          vim.cmd("Git push")
        end, opts)

        -- rebase always
        vim.keymap.set("n", "<leader>l", function()
          vim.cmd("Git pull --rebase")
        end, opts)

        -- NOTE: It allows me to easily set the branch i am pushing and any tracking
        -- needed if i did not set the branch up correctly
        vim.keymap.set("n", "<leader>t", ":Git push -u origin ", opts)
      end,
    })

    -- Merge conflict / vimdiff: //2 and //3 (common fugitive mnemonic: gl / gh).
    vim.keymap.set("n", "gl", "<cmd>diffget //2<cr>", { desc = "Diffget from //2" })
    vim.keymap.set("n", "gh", "<cmd>diffget //3<cr>", { desc = "Diffget from //3" })
    vim.keymap.set("x", "gl", ":diffget //2<cr>", { silent = true, desc = "Diffget //2 (visual)" })
    vim.keymap.set("x", "gh", ":diffget //3<cr>", { silent = true, desc = "Diffget //3 (visual)" })
  end,
}
