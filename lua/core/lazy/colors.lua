local DEFAULT_THEME = "base16-dracula"

local function set_theme(colorscheme, opts)
  opts = opts or {}
  colorscheme = colorscheme or DEFAULT_THEME

  vim.cmd.colorscheme(colorscheme)

  if opts.transparent == true then
    vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
    vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
  end
end

local THEME_CHOICES = {
  "base16-dracula",
  "kanagawa",
  "night-owl",
  "oxocarbon",
  "dracula_pro",
  "gruvbox",
}

vim.api.nvim_create_user_command("Theme", function(cmd)
  local name = cmd.args ~= "" and cmd.args or DEFAULT_THEME
  set_theme(name, { transparent = true })
end, {
  nargs = "?",
  complete = function()
    return THEME_CHOICES
  end,
})

vim.api.nvim_create_autocmd("User", {
  pattern = "LazyDone",
  once = true,
  callback = function()
    set_theme(DEFAULT_THEME, { transparent = true })
  end,
})

return {
  {
    "Francisco-BT/base16-dracula",
    name = "base16-dracula",
    priority = 1000,
  },
  {
    "rebelot/kanagawa.nvim",
    name = "kanagawa",
    priority = 1000,
    config = function()
      require("kanagawa").setup({
        transparent = true,
        commentStyle = { italic = true },
        keywordStyle = { italic = true },
        statementStyle = { bold = false },
        typeStyle = { bold = false },
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
    "haishanh/night-owl.vim",
    name = "night-owl",
    priority = 1000,
  },
  {
    "nyoom-engineering/oxocarbon.nvim",
    name = "oxocarbon",
    priority = 1000,
  },
  {
    "ellisonleao/gruvbox.nvim",
    name = "gruvbox",
    priority = 1000,
    config = function()
      require("gruvbox").setup({
        terminal_colors = true,
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
        inverse = true,
        contrast = "",
        palette_overrides = {},
        overrides = {},
        dim_inactive = false,
        transparent_mode = true,
      })
    end,
  },
}
