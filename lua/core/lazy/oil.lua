return {
  "stevearc/oil.nvim",
  lazy = false,
  opts = {
    default_file_explorer = true,
    columns = { "icon" },
    view_options = {
      show_hidden = true,
    },
  },
  init = function()
    vim.keymap.set("n", "-", "<cmd>Oil<cr>", { desc = "Oil: Parent directory" })
  end,
}
