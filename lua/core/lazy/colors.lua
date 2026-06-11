local DEFAULT_THEME = "base16-dracula"
local GHOSTTY_THEME_LIGHT = "DraculaAlucard"
local GHOSTTY_THEME_DARK = "DraculaPro"

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

---@class ThemeEntry
---@field id string
---@field bg "light"|"dark"
---@field available? fun(): boolean
---@field apply fun()

local function apply_solarized(background)
  vim.o.background = background
  vim.cmd.colorscheme("solarized")
end

local THEMES ---@type ThemeEntry[]
THEMES = {
  { id = "base16-dracula", bg = "dark", apply = function() vim.cmd.colorscheme("base16-dracula") end },
  { id = "kanagawa", bg = "dark", apply = function() vim.cmd.colorscheme("kanagawa") end },
  { id = "night-owl", bg = "dark", apply = function() vim.cmd.colorscheme("night-owl") end },
  { id = "oxocarbon", bg = "dark", apply = function() vim.cmd.colorscheme("oxocarbon") end },
  {
    id = "dracula_pro",
    bg = "dark",
    available = dracula_pro_available,
    apply = function()
      vim.cmd.colorscheme("dracula_pro")
    end,
  },
  {
    id = "dracula_alucard",
    bg = "light",
    available = dracula_pro_available,
    apply = function()
      vim.cmd.colorscheme("dracula_pro_alucard")
    end,
  },
  { id = "gruvbox", bg = "dark", apply = function() vim.cmd.colorscheme("gruvbox") end },
  { id = "rose-pine-moon", bg = "dark", apply = function() vim.cmd.colorscheme("rose-pine-moon") end },
  { id = "rose-pine-dawn", bg = "light", apply = function() vim.cmd.colorscheme("rose-pine-dawn") end },
  { id = "catppuccin-mocha", bg = "dark", apply = function() vim.cmd.colorscheme("catppuccin") end },
  { id = "onedark", bg = "dark", apply = function() vim.cmd.colorscheme("onedark") end },
  { id = "cyberdream", bg = "dark", apply = function() vim.cmd.colorscheme("cyberdream") end },
  { id = "nordic", bg = "dark", apply = function() vim.cmd.colorscheme("nordic") end },
  {
    id = "solarized-dark",
    bg = "dark",
    apply = function()
      apply_solarized("dark")
    end,
  },
  {
    id = "solarized-light",
    bg = "light",
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

local TMUX_THEMES_DIR = vim.fn.expand("~/.config/tmux/themes")

local function sync_ghostty_appearance(bg)
  if vim.fn.has("unix") ~= 1 then
    return
  end
  local name = bg == "light" and GHOSTTY_THEME_LIGHT or GHOSTTY_THEME_DARK
  local path = vim.fn.expand("~/.config/ghostty/theme-current")
  vim.fn.writefile({ "theme = " .. name }, path)
  vim.system({ "pkill", "-SIGUSR2", "ghostty" }, { detach = true })
end

local function sync_tmux_appearance(bg)
  if vim.fn.has("unix") ~= 1 then
    return
  end
  local theme_file = bg == "light" and "light.conf" or "dark.conf"
  local current = vim.fn.expand("~/.config/tmux/theme-current.conf")
  vim.fn.writefile({ 'source-file "' .. TMUX_THEMES_DIR .. "/" .. theme_file .. '"' }, current)
  vim.system({ "tmux", "source-file", current }, { detach = true })
end

local function sync_terminal_appearance(bg)
  sync_ghostty_appearance(bg)
  sync_tmux_appearance(bg)
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
  theme.apply()
  sync_terminal_appearance(theme.bg)
end

-- TODO: Add a command to toggle the transparent background
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
    priority = 1000,
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
  {
    "catppuccin/nvim",
    name = "catppuccin-mocha",
    priority = 1000,
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
    priority = 1000,
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
    priority = 1000,
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
    priority = 1000,
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
