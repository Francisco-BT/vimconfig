return {
  {
    "piacsek/ghostty-mirror.nvim",
    lazy = false,
    priority = 1100,
    opts = {
      themes_dir = vim.fn.expand("~/.config/ghostty/themes"),
      theme_file = vim.fn.expand("~/.config/ghostty/theme-current"),
      light_variant_suffix = "-light",
      generate = true,
      manage_background = true,
      sync_on_startup = false,
    },
  },
}
