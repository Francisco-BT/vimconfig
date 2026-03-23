--- Rosé Pine por lazy; el tema activo al arranque lo fija init.lua (dracula_pro). Para Rosé Pine: :colorscheme rose-pine-moon

return {
  {
    "rose-pine/neovim",
    name = "rose-pine",
    lazy = false,
    priority = 1000,
    config = function()
      require("rose-pine").setup({
        variant = "auto",
        dark_variant = "moon",
        disable_background = true,
        styles = {
          italic = false,
        },
      })
    end,
  },
}
