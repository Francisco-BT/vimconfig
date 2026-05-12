return {
  "nvim-telescope/telescope.nvim",
  branch = "master",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-telescope/telescope-ui-select.nvim",
  },
  config = function()
    local themes = require("telescope.themes")

    require("telescope").setup({
      -- vim.lsp.buf.code_action(), vim.ui.input, etc. usan vim.ui.select → Telescope
      extensions = {
        ["ui-select"] = themes.get_cursor({
          layout_config = {
            width = 80,
            height = 12,
          },
        }),
      },
    })

    require("telescope").load_extension("ui-select")

    local builtin = require("telescope.builtin")

    vim.keymap.set("n", "<leader>pf", builtin.find_files, { desc = "Telescope find files" })

    vim.keymap.set("n", "<leader>pb", function()
      builtin.buffers({ sort_mru = true })
    end, { desc = "Telescope buffers" })

    vim.keymap.set("n", "<leader>pF", function()
      builtin.find_files({ hidden = true, prompt_title = "Find Files (incl. hidden)" })
    end, { desc = "Telescope find files (hidden/dotfiles)" })

    vim.keymap.set("n", "<C-p>", builtin.git_files, { desc = "Telescope git files" })

    vim.keymap.set("n", "<leader>ps", function()
      builtin.grep_string({ search = vim.fn.input("Grep > ") })
    end, { desc = "Telescope grep string" })

    vim.keymap.set("n", "<leader>pg", builtin.live_grep, { desc = "Telescope live grep (rg)" })

    vim.keymap.set("n", "<leader>pw", function()
      builtin.live_grep({ default_text = vim.fn.expand("<cword>") })
    end, { desc = "Telescope live grep (word under cursor)" })

    -- Misma API que :lua vim.lsp.buf.code_action(); ui-select muestra la lista en flotante (tema cursor)
    vim.keymap.set({ "n", "v" }, "<leader>vca", vim.lsp.buf.code_action, {
      desc = "LSP code actions",
    })
  end,
}
