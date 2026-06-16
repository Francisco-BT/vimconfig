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
    local builtin = require("telescope.builtin")
    local workspace = require("core.lang.workspace")

    local heavy_ignore_patterns = workspace.heavy_ignore_patterns()

    local function quick_open_files()
      builtin.find_files({
        cwd = workspace.cwd(),
        prompt_title = "Go to File",
        find_command = workspace.quick_open_find_command(),
        file_ignore_patterns = heavy_ignore_patterns,
      })
    end

    require("telescope").setup({
      defaults = {
        path_display = { "filename_first" },
        wrap_results = true,
        file_ignore_patterns = heavy_ignore_patterns,
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

    vim.keymap.set("n", "<C-p>", quick_open_files, { desc = "Quick open file (incl. gitignored)" })

    vim.keymap.set("n", "<leader>pf", function()
      builtin.find_files({
        cwd = workspace.cwd(),
        prompt_title = "Find Files",
      })
    end, { desc = "Telescope find files (respect .gitignore)" })

    vim.keymap.set("n", "<leader>pb", function()
      builtin.buffers({ sort_mru = true })
    end, { desc = "Telescope buffers" })

    vim.keymap.set("n", "<leader>ps", function()
      builtin.grep_string({
        cwd = workspace.cwd(),
        search = vim.fn.input("Grep > "),
        hidden = true,
      })
    end, { desc = "Telescope grep string (incl. hidden)" })

    vim.keymap.set("n", "<leader>pg", function()
      builtin.live_grep({ cwd = workspace.cwd() })
    end, { desc = "Telescope live grep (rg)" })

    vim.keymap.set("n", "<leader>pw", function()
      builtin.live_grep({
        cwd = workspace.cwd(),
        default_text = vim.fn.expand("<cword>"),
      })
    end, { desc = "Telescope live grep (word under cursor)" })

    vim.keymap.set({ "n", "v" }, "<leader>vca", vim.lsp.buf.code_action, {
      desc = "LSP code actions",
    })
  end,
}
