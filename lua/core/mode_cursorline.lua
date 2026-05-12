--- CursorLine por modo: Insert, Visual, operador pendiente (d/y/c, …).
---
--- vim.g.mode_cursorline_palette = "theme" | "rose_pine" (default: theme)
---   "theme" → Insert / Visual / delete (dD) mezclan CursorLine del tema con un acento leído del mismo colorscheme.
--- vim.g.mode_cursorline_mix        insert (default 0.10), mezcla hacia blanco
--- vim.g.mode_cursorline_mix_visual (default 0.18), acento desde grupo Visual
--- vim.g.mode_cursorline_mix_delete (default 0.20), acento desde DiffDelete / Error / …

local M = {}

local cursorline_theme = nil ---@type table|nil
local normal_bg = nil

local function rgb_split(c)
  if not c then
    return nil
  end
  local r = math.floor(c / 65536) % 256
  local g = math.floor(c / 256) % 256
  local b = c % 256
  return r, g, b
end

local function rgb_mix(c1, c2, t)
  local r1, g1, b1 = rgb_split(c1)
  local r2, g2, b2 = rgb_split(c2)
  if not r1 or not r2 then
    return c1 or c2
  end
  local r = math.floor(r1 + (r2 - r1) * t + 0.5)
  local g = math.floor(g1 + (g2 - g1) * t + 0.5)
  local b = math.floor(b1 + (b2 - b1) * t + 0.5)
  return r * 65536 + g * 256 + b
end

-- Rose Pine Moon — paleta fija si mode_cursorline_palette = "rose_pine"
local BASE_MOON = 0x232136
local GOLD_LINE = rgb_mix(BASE_MOON, 0xf6c177, 0.32)
local PINE_LINE = rgb_mix(BASE_MOON, 0x3e8fb0, 0.22)
local ROSE_PINE = {
  insert = PINE_LINE,
  delete_op = rgb_mix(BASE_MOON, 0xeb6f92, 0.24),
  yank_op = GOLD_LINE,
  change_op = rgb_mix(BASE_MOON, 0x9ccfd8, 0.28),
  visual = rgb_mix(BASE_MOON, 0x908caa, 0.18),
  operator_other = rgb_mix(BASE_MOON, 0x6e6a86, 0.14),
}

local function insertish(m)
  local ch = (m or vim.fn.mode(1)):sub(1, 1)
  return ch == "i" or ch == "R"
end

local function is_visual(m)
  local s = m or vim.fn.mode(1)
  local f = s:sub(1, 1)
  return f == "v" or f == "V" or f:byte() == 22
end

local function is_operator_pending(m)
  return (m or vim.fn.mode(1)):match("^no") ~= nil
end

---@return string
local function classify()
  local m = vim.fn.mode(1)
  if insertish(m) then
    return "insert"
  end
  if is_visual(m) then
    return "visual"
  end
  if is_operator_pending(m) then
    local op = vim.v.operator or ""
    if op == "d" or op == "D" then
      return "delete_op"
    end
    if op == "y" or op == "Y" then
      return "yank_op"
    end
    if op == "c" or op == "C" then
      return "change_op"
    end
    return "operator_other"
  end
  return "normal"
end

function M._cache()
  if not vim.o.termguicolors then
    return
  end
  local n = vim.api.nvim_get_hl(0, { name = "Normal", link = true })
  normal_bg = n.bg
  cursorline_theme = vim.api.nvim_get_hl(0, { name = "CursorLine", link = true })
end

local function restore_theme_cursorline()
  if cursorline_theme and next(cursorline_theme) then
    vim.api.nvim_set_hl(0, "CursorLine", cursorline_theme)
  else
    vim.api.nvim_set_hl(0, "CursorLine", { default = true })
  end
end

--- First usable RGB from highlight (bg preferred, then fg).
---@param name string
---@return integer|nil
local function hl_accent_rgb(name)
  local h = vim.api.nvim_get_hl(0, { name = name, link = true })
  if h.bg then
    return h.bg
  end
  if h.fg then
    return h.fg
  end
  return nil
end

---@param names string[]
---@param fallback integer
---@return integer
local function pick_first_rgb(names, fallback)
  for _, n in ipairs(names) do
    local c = hl_accent_rgb(n)
    if c then
      return c
    end
  end
  return fallback
end

local function base_cursorline_bg()
  if cursorline_theme and cursorline_theme.bg then
    return cursorline_theme.bg
  end
  return normal_bg
end

--- Mix theme CursorLine (or Normal) bg toward accent by t in [0,1].
---@param accent integer
---@param t number
---@return boolean
local function apply_theme_tint(accent, t)
  local base = base_cursorline_bg()
  if not base or not accent or type(t) ~= "number" then
    return false
  end
  local tinted = rgb_mix(base, accent, t)
  local hl = vim.deepcopy(cursorline_theme or {})
  hl.bg = tinted
  hl.default = false
  vim.api.nvim_set_hl(0, "CursorLine", hl)
  return true
end

function M._apply()
  if not vim.o.cursorline or not vim.o.termguicolors then
    return
  end

  local role = classify()
  local palette = vim.g.mode_cursorline_palette or "theme"

  if role == "normal" then
    restore_theme_cursorline()
    return
  end

  if palette == "theme" then
    if role == "insert" then
      local mix = vim.g.mode_cursorline_mix
      if type(mix) ~= "number" then
        mix = 0.10
      end
      apply_theme_tint(0xffffff, mix)
    elseif role == "visual" then
      local mix = vim.g.mode_cursorline_mix_visual
      if type(mix) ~= "number" then
        mix = 0.18
      end
      local accent = pick_first_rgb({ "Visual", "PmenuSel", "WildMenu" }, 0x7c6f64)
      apply_theme_tint(accent, mix)
    elseif role == "delete_op" then
      local mix = vim.g.mode_cursorline_mix_delete
      if type(mix) ~= "number" then
        mix = 0.20
      end
      local accent = pick_first_rgb({
        "DiffDelete",
        "ErrorMsg",
        "Error",
        "DiagnosticError",
      }, 0xcc241d)
      apply_theme_tint(accent, mix)
    else
      restore_theme_cursorline()
    end
    return
  end

  local bg = ROSE_PINE[role]
  if not bg then
    restore_theme_cursorline()
    return
  end
  vim.api.nvim_set_hl(0, "CursorLine", { bg = bg, default = false })
end

local function sync()
  vim.schedule(function()
    M._cache()
    M._apply()
  end)
end

function M.setup()
  if vim.g.mode_cursorline_palette == nil then
    vim.g.mode_cursorline_palette = "theme"
  end

  local aug = vim.api.nvim_create_augroup("mode_cursorline", { clear = true })

  vim.api.nvim_create_autocmd("ColorScheme", {
    group = aug,
    callback = sync,
  })

  vim.api.nvim_create_autocmd("VimEnter", {
    group = aug,
    callback = sync,
  })

  vim.api.nvim_create_autocmd("ModeChanged", {
    group = aug,
    pattern = "*:*",
    callback = function()
      vim.schedule(M._apply)
    end,
  })

  sync()
end

return M
