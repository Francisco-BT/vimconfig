return {
  "stevearc/oil.nvim",
  lazy = false,
  dependencies = { "nvim-tree/nvim-web-devicons" },
  -- Single setup() here (no top-level `opts`) so lazy.nvim does not call setup before this runs.
  config = function()
    require("oil").setup({
      default_file_explorer = true,
      columns = { "icon" },
      view_options = {
        show_hidden = true,
      },
      float = {
        padding = 2,
        max_width = 0.82,
        max_height = 0.72,
        border = "rounded",
      },
      keymaps = {
        ["q"] = "actions.close",
      },
    })

    vim.keymap.set("n", "-", "<cmd>Oil --float<cr>", { desc = "Oil: directory (float)" })

    vim.keymap.set("n", "<leader>pv", function()
      if vim.w.is_oil_win then
        require("oil").close()
      else
        vim.cmd("Oil --float")
      end
    end, { desc = "Oil: toggle float" })
  end,
}
