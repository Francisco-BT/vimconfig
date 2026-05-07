local DEFAULT_THEME = "base16-dracula"

local function set_theme(colorscheme, opts)
  opts = opts or {}
  colorscheme = colorscheme or DEFAULT_THEME

  vim.cmd.colorscheme(colorscheme)
end

local function dracula_pro_dir()
  return vim.fn.stdpath("data") .. "/site/pack/themes/start/dracula_pro"
end

local function dracula_pro_available()
  return vim.fn.isdirectory(dracula_pro_dir()) == 1
end

local THEME_CHOICES = {
  "base16-dracula",
  "kanagawa",
  "night-owl",
  "oxocarbon",
  "dracula_pro",
  "gruvbox",
  "rose-pine",
}

local function available_themes()
  local out = {}
  for _, name in ipairs(THEME_CHOICES) do
    if name == "dracula_pro" then
      if dracula_pro_available() then
        table.insert(out, name)
      end
    else
      table.insert(out, name)
    end
  end
  return out
end

local function pick_random_theme()
  local themes = available_themes()
  if #themes == 0 then
    return DEFAULT_THEME
  end
  return themes[math.random(#themes)]
end

-- TODO: Add a command to toggle the transparent background
vim.api.nvim_create_user_command("Theme", function(cmd)
  local name = cmd.args ~= "" and cmd.args or DEFAULT_THEME
  set_theme(name, {})
end, {
  nargs = "?",
  complete = function()
    return available_themes()
  end,
})

vim.api.nvim_create_autocmd("User", {
  pattern = "LazyDone",
  once = true,
  callback = function()
    math.randomseed(os.time())
    set_theme(pick_random_theme(), {})
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
        transparent = false,
        commentStyle = { italic = true },
        keywordStyle = { italic = true },
        statementStyle = { bold = false },
        typeStyle = { bold = false },
      })
    end,
  },
  {
    dir = dracula_pro_dir(),
    name = "dracula_pro",
    priority = 1000,
    cond = function()
      return dracula_pro_available()
    end,
    config = function()
      vim.g.dracula_colorterm = 1
    end,
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
    "rose-pine/neovim",
    name = "rose-pine",
    priority = 1000,
    config = function()
      require("rose-pine").setup({
        variant = "auto",
        dark_variant = "moon",
        disable_background = false,
        styles = {
          italic = false,
        },
      })
    end,
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
        transparent_mode = false,
      })
    end,
  },
}
