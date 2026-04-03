return {
  "nvim-telescope/telescope.nvim",
  branch = "0.1.x",
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
  config = function()
    require("telescope").setup({})

    local builtin = require("telescope.builtin")

    vim.keymap.set("n", "<leader>pf", builtin.find_files, { desc = "Telescope find files" })

    vim.keymap.set("n", "<leader>pF", function()
      builtin.find_files({ hidden = true, prompt_title = "Find Files (incl. hidden)" })
    end, { desc = "Telescope find files (hidden/dotfiles)" })

    -- Search for files respecting .gitignore
    vim.keymap.set("n", "<C-p>", builtin.git_files, { desc = "Telescope git files" })

    -- Global search for a string across the entire project (Powered by Ripgrep)
    vim.keymap.set("n", "<leader>ps", function()
      builtin.grep_string({ search = vim.fn.input("Grep > ") })
    end, { desc = "Telescope grep string" })
  end,
}
