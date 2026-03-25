local function apply_theme_transparent(color)
  color = color or "rose-pine"
  vim.cmd.colorscheme(color)

  vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
  vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
end

math.randomseed(os.time())

local function pick_random_theme()
  local themes = {
    "base16-dracula",
    "dracula_pro",
    "base16-circus",
    "dracula_pro_blade",
    "base16-dracula",
    "rose-pine",
    "gruvbox",
    "base16-oceanicnext",
    "base16-solarflare",
  }
  local random_theme = themes[math.random(1, #themes)]
  apply_theme_transparent(random_theme)
end

vim.api.nvim_create_autocmd("User", {
  pattern = "LazyDone",
  once = true,
  callback = function()
    pick_random_theme()
  end,
})

return {
  {
    "chriskempson/base16-vim",
    name = "base16",
  },
  {
    "ellisonleao/gruvbox.nvim",
    name = "gruvbox",
    config = function()
      require("gruvbox").setup({
        terminal_colors = true, -- add neovim terminal colors
        undercurl = true,
        underline = false,
        bold = true,
        italic = {
          strings = false,
          emphasis = false,
          comments = false,
          operators = false,
          folds = false,
        },
        strikethrough = true,
        invert_selection = false,
        invert_signs = false,
        invert_tabline = false,
        invert_intend_guides = false,
        inverse = true, -- invert background for search, diffs, statuslines and errors
        contrast = "", -- can be "hard", "soft" or empty string
        palette_overrides = {},
        overrides = {},
        dim_inactive = false,
        transparent_mode = false,
      })
    end,
  },
  {
    dir = vim.fn.stdpath("data") .. "/site/pack/themes/start/dracula_pro",
    name = "dracula_pro",
    priority = 1000,
    cond = function()
      return vim.fn.isdirectory(vim.fn.stdpath("data") .. "/site/pack/themes/start/dracula_pro") == 1
    end,
    config = function() end,
  },
  {
    "rose-pine/neovim",
    name = "rose-pine",
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
