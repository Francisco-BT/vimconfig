local DEFAULT_THEME = "base16-dracula"

local function dracula_pro_dir()
  return vim.fn.stdpath("data") .. "/site/pack/themes/start/dracula_pro"
end

local function dracula_pro_available()
  return vim.fn.isdirectory(dracula_pro_dir()) == 1
end

local function read_macos_appearance_pool()
  if vim.fn.has("mac") ~= 1 then
    return "dark"
  end
  vim.fn.system({ "defaults", "read", "-g", "AppleInterfaceStyle" })
  if vim.v.shell_error == 0 then
    return "dark"
  end
  return "light"
end

local function apply_solarized(background)
  vim.o.background = background
  vim.cmd.colorscheme("solarized")
end

---@class ThemeEntry
---@field id string
---@field bg "light"|"dark"
---@field lazy_plugin string lazy.nvim plugin id to load before apply
---@field eager? boolean load at startup (only the default theme)
---@field available? fun(): boolean
---@field apply fun()

---@type ThemeEntry[]
local THEMES = {
  {
    id = DEFAULT_THEME,
    bg = "dark",
    lazy_plugin = DEFAULT_THEME,
    eager = true,
    apply = function()
      vim.cmd.colorscheme(DEFAULT_THEME)
    end,
  },
  {
    id = "kanagawa",
    bg = "dark",
    lazy_plugin = "kanagawa",
    apply = function()
      vim.cmd.colorscheme("kanagawa")
    end,
  },
  {
    id = "night-owl",
    bg = "dark",
    lazy_plugin = "night-owl",
    apply = function()
      vim.cmd.colorscheme("night-owl")
    end,
  },
  {
    id = "oxocarbon",
    bg = "dark",
    lazy_plugin = "oxocarbon",
    apply = function()
      vim.cmd.colorscheme("oxocarbon")
    end,
  },
  {
    id = "dracula_pro",
    bg = "dark",
    lazy_plugin = "dracula_pro",
    available = dracula_pro_available,
    apply = function()
      vim.cmd.colorscheme("dracula_pro")
    end,
  },
  {
    id = "dracula_alucard",
    bg = "light",
    lazy_plugin = "dracula_pro",
    available = dracula_pro_available,
    apply = function()
      vim.cmd.colorscheme("dracula_pro_alucard")
    end,
  },
  {
    id = "gruvbox",
    bg = "dark",
    lazy_plugin = "gruvbox",
    apply = function()
      vim.cmd.colorscheme("gruvbox")
    end,
  },
  {
    id = "rose-pine-moon",
    bg = "dark",
    lazy_plugin = "rose-pine",
    apply = function()
      vim.cmd.colorscheme("rose-pine-moon")
    end,
  },
  {
    id = "rose-pine-dawn",
    bg = "light",
    lazy_plugin = "rose-pine",
    apply = function()
      vim.cmd.colorscheme("rose-pine-dawn")
    end,
  },
  {
    id = "catppuccin-mocha",
    bg = "dark",
    lazy_plugin = "catppuccin-mocha",
    apply = function()
      vim.cmd.colorscheme("catppuccin")
    end,
  },
  {
    id = "onedark",
    bg = "dark",
    lazy_plugin = "onedark",
    apply = function()
      vim.cmd.colorscheme("onedark")
    end,
  },
  {
    id = "cyberdream",
    bg = "dark",
    lazy_plugin = "cyberdream",
    apply = function()
      vim.cmd.colorscheme("cyberdream")
    end,
  },
  {
    id = "nordic",
    bg = "dark",
    lazy_plugin = "nordic",
    apply = function()
      vim.cmd.colorscheme("nordic")
    end,
  },
  {
    id = "solarized-dark",
    bg = "dark",
    lazy_plugin = "solarized",
    apply = function()
      apply_solarized("dark")
    end,
  },
  {
    id = "solarized-light",
    bg = "light",
    lazy_plugin = "solarized",
    apply = function()
      apply_solarized("light")
    end,
  },
}

local function theme_by_id(id)
  for _, theme in ipairs(THEMES) do
    if theme.id == id then
      return theme
    end
  end
  return nil
end

local function theme_available(theme)
  if theme.available and not theme.available() then
    return false
  end
  return true
end

local function available_themes()
  local out = {}
  for _, theme in ipairs(THEMES) do
    if theme_available(theme) then
      table.insert(out, theme.id)
    end
  end
  return out
end

local function pick_random_theme(pool)
  local candidates = {}
  for _, theme in ipairs(THEMES) do
    if theme.bg == pool and theme_available(theme) then
      table.insert(candidates, theme.id)
    end
  end
  if #candidates == 0 then
    return DEFAULT_THEME
  end
  return candidates[math.random(#candidates)]
end

local function ensure_theme_loaded(theme)
  if theme.eager then
    return true
  end
  local ok, lazy = pcall(require, "lazy")
  if not ok then
    return true
  end
  lazy.load({ plugins = { theme.lazy_plugin } })
  return true
end

local function set_theme(id)
  local theme = theme_by_id(id)
  if not theme then
    vim.notify("Unknown theme: " .. id, vim.log.levels.WARN)
    return
  end
  if not theme_available(theme) then
    vim.notify("Theme not available: " .. id, vim.log.levels.WARN)
    return
  end
  ensure_theme_loaded(theme)
  theme.apply()
end

vim.api.nvim_create_user_command("Theme", function(cmd)
  local name = cmd.args ~= "" and cmd.args or DEFAULT_THEME
  set_theme(name)
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
    set_theme(pick_random_theme(read_macos_appearance_pool()))
  end,
})

return {
  {
    "Francisco-BT/base16-dracula",
    name = DEFAULT_THEME,
    priority = 1000,
  },
  {
    "rebelot/kanagawa.nvim",
    name = "kanagawa",
    lazy = true,
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
    lazy = true,
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
    lazy = true,
  },
  {
    "nyoom-engineering/oxocarbon.nvim",
    name = "oxocarbon",
    lazy = true,
  },
  {
    "rose-pine/neovim",
    name = "rose-pine",
    lazy = true,
    config = function()
      require("rose-pine").setup({
        disable_background = false,
        styles = {
          italic = false,
        },
      })
    end,
  },
  {
    "maxmx03/solarized.nvim",
    name = "solarized",
    lazy = true,
    config = function()
      require("solarized").setup({
        transparent = {
          enabled = false,
        },
      })
    end,
  },
  {
    "ellisonleao/gruvbox.nvim",
    name = "gruvbox",
    lazy = true,
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
  {
    "catppuccin/nvim",
    name = "catppuccin-mocha",
    lazy = true,
    config = function()
      require("catppuccin").setup({
        flavour = "mocha",
        transparent_background = false,
      })
    end,
  },
  {
    "navarasu/onedark.nvim",
    name = "onedark",
    lazy = true,
    config = function()
      require("onedark").setup({
        style = "dark",
        transparent = false,
        term_colors = true,
        code_style = {
          comments = "italic",
        },
      })
    end,
  },
  {
    "scottmckendry/cyberdream.nvim",
    name = "cyberdream",
    lazy = true,
    config = function()
      require("cyberdream").setup({
        variant = "default",
        transparent = true,
        italic_comments = true,
        hide_fillchars = true,
        borderless_pickers = true,
        terminal_colors = true,
      })
    end,
  },
  {
    "AlexvZyl/nordic.nvim",
    name = "nordic",
    lazy = true,
    config = function()
      require("nordic").setup({
        transparent = {
          bg = false,
          float = true,
        },
        italic_comments = true,
        reduced_blue = true,
      })
    end,
  },
}
