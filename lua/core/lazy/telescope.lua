return {
  "nvim-telescope/telescope.nvim",
  branch = "master",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-telescope/telescope-ui-select.nvim",
  },
  config = function()
    local themes = require("telescope.themes")
    local layout_actions = require("telescope.actions.layout")

    require("telescope").setup({
      defaults = {
        -- Long paths: show `file.ext` first, then directories; wrap the result line.
        path_display = { "filename_first" },
        wrap_results = true,
        -- Skip huge trees in all pickers (pf, pF, ps, etc.).
        file_ignore_patterns = { "%.git/", "node_modules/", "%.venv/", "%.cache/" },
        -- Preview on by default; <M-p> toggles it when you need more path width.
        preview = { hide_on_startup = false },
        layout_config = {
          horizontal = {
            width = 0.92,
            preview_width = 0.40,
          },
        },
        mappings = {
          i = { ["<M-p>"] = layout_actions.toggle_preview },
          n = { ["<M-p>"] = layout_actions.toggle_preview },
        },
      },
      -- vim.lsp.buf.code_action(), vim.ui.input, etc. use vim.ui.select → Telescope
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

    -- Respects .gitignore / exclude; lists untracked files that are not ignored.
    vim.keymap.set("n", "<leader>pf", builtin.find_files, { desc = "Telescope find files" })

    vim.keymap.set("n", "<leader>pb", function()
      builtin.buffers({ sort_mru = true })
    end, { desc = "Telescope buffers" })

    vim.keymap.set("n", "<leader>pF", function()
      -- Solo agrega "hidden" (dotfiles), manteniendo reglas de ignore para evitar node_modules.
      builtin.find_files({
        hidden = true,
        prompt_title = "Find Files (hidden)",
      })
    end, { desc = "Telescope find files (hidden)" })

    -- Default was changed upstream: untracked are off unless show_untracked.
    vim.keymap.set("n", "<C-p>", function()
      builtin.git_files({ show_untracked = true })
    end, { desc = "Telescope git files (incl. untracked)" })

    vim.keymap.set("n", "<leader>ps", function()
      builtin.grep_string({
        search = vim.fn.input("Grep > "),
        hidden = true,
      })
    end, { desc = "Telescope grep string (incl. hidden)" })

    vim.keymap.set("n", "<leader>pg", builtin.live_grep, { desc = "Telescope live grep (rg)" })

    vim.keymap.set("n", "<leader>pw", function()
      builtin.live_grep({ default_text = vim.fn.expand("<cword>") })
    end, { desc = "Telescope live grep (word under cursor)" })

    -- Same API as :lua vim.lsp.buf.code_action(); ui-select shows the list in a float (cursor theme)
    vim.keymap.set({ "n", "v" }, "<leader>vca", vim.lsp.buf.code_action, {
      desc = "LSP code actions",
    })
  end,
}
