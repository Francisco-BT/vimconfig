--- Per-mode CursorLine: same role table as Rose Pine, but colors mix
--- Normal.bg + an accent sampled from the active colorscheme (not a fixed palette).
---
--- vim.g.mode_cursorline_palette = "theme" | "rose_pine" (default: theme)
---
--- Optional strengths (0–1; defaults mirror Rose Pine-style mix weights):
---   g:mode_cursorline_theme_strength_insert / _visual / _delete / _yank / _change / _other
--- Legacy: g:mode_cursorline_mix → insert; _mix_visual → visual; _mix_delete → delete

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

-- Rose Pine Moon — only when palette == "rose_pine"
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

--- Per role: highlight groups to try, fg/bg preference, hex fallback, default strength (Rose Pine-like).
---@type table<string, { groups: string[], prefer: "fg"|"bg", fallback: integer, default: number, gvar: string, legacy?: string }>
local THEME_BY_ROLE = {
  insert = {
    groups = {
      "@type",
      "Type",
      "Directory",
      "MoreMsg",
      "Question",
      "Special",
      "Identifier",
      "String",
      "@string",
    },
    prefer = "fg",
    fallback = 0x458588,
    default = 0.22,
    gvar = "mode_cursorline_theme_strength_insert",
    legacy = "mode_cursorline_mix",
  },
  visual = {
    groups = {
      "Visual",
      "VisualNOS",
      "PmenuSel",
      "WildMenu",
      "TabLineSel",
      "Substitute",
      "Search",
    },
    prefer = "bg",
    fallback = 0x928374,
    default = 0.18,
    gvar = "mode_cursorline_theme_strength_visual",
    legacy = "mode_cursorline_mix_visual",
  },
  delete_op = {
    groups = {
      "DiffDelete",
      "ErrorMsg",
      "Error",
      "DiagnosticError",
      "NvimTreeGitDeleted",
    },
    prefer = "bg",
    fallback = 0xcc241d,
    default = 0.24,
    gvar = "mode_cursorline_theme_strength_delete",
    legacy = "mode_cursorline_mix_delete",
  },
  yank_op = {
    groups = {
      "Number",
      "Float",
      "@number",
      "@float",
      "WarningMsg",
      "Macro",
      "PreProc",
      "Tag",
      "Constant",
    },
    prefer = "fg",
    fallback = 0xd79921,
    default = 0.32,
    gvar = "mode_cursorline_theme_strength_yank",
  },
  change_op = {
    groups = {
      "@function",
      "Function",
      "Statement",
      "Conditional",
      "Repeat",
      "Structure",
      "Operator",
      "SpecialKey",
      "Title",
    },
    prefer = "fg",
    fallback = 0x83a598,
    default = 0.28,
    gvar = "mode_cursorline_theme_strength_change",
  },
  operator_other = {
    groups = {
      "Comment",
      "LineNr",
      "NonText",
      "Conceal",
      "Folded",
      "Whitespace",
    },
    prefer = "fg",
    fallback = 0x665c54,
    default = 0.14,
    gvar = "mode_cursorline_theme_strength_other",
  },
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

--- Parse "#RRGGBB" or "RRGGBB" to 24-bit int (for synIDattr).
---@param s string|nil
---@return integer|nil
local function hex_to_rgb(s)
  if type(s) ~= "string" or s == "" then
    return nil
  end
  s = s:gsub("^#", "")
  if #s ~= 6 then
    return nil
  end
  local n = tonumber(s, 16)
  if not n then
    return nil
  end
  return n
end

--- Resolved GUI color (nvim_get_hl with link=false + synIDattr fallback).
---@param name string
---@param prefer "fg"|"bg"
---@return integer|nil
local function hl_rgb(name, prefer)
  -- link=false → effective colors after resolving links (link=true often omits fg/bg).
  local h = vim.api.nvim_get_hl(0, { name = name, link = false })
  if prefer == "fg" then
    if h.fg then
      return h.fg
    end
    if h.bg then
      return h.bg
    end
  else
    if h.bg then
      return h.bg
    end
    if h.fg then
      return h.fg
    end
  end

  local id = vim.fn.hlID(name)
  if id == 0 then
    return nil
  end
  local tid = vim.fn.synIDtrans(id)
  local attr = vim.fn.synIDattr(tid, prefer == "fg" and "fg#" or "bg#", "gui")
  local parsed = hex_to_rgb(attr)
  if parsed then
    return parsed
  end
  attr = vim.fn.synIDattr(tid, prefer == "fg" and "bg#" or "fg#", "gui")
  return hex_to_rgb(attr)
end

---@param names string[]
---@param prefer "fg"|"bg"
---@param fallback integer
---@return integer
local function pick_first(names, prefer, fallback)
  for _, n in ipairs(names) do
    local c = hl_rgb(n, prefer)
    if c then
      return c
    end
  end
  return fallback
end

local function theme_canvas_bg()
  if normal_bg then
    return normal_bg
  end
  if cursorline_theme and cursorline_theme.bg then
    return cursorline_theme.bg
  end
  return nil
end

---@param accent integer
---@param strength number
---@return boolean
local function apply_theme_semantic_line(accent, strength)
  local base = theme_canvas_bg()
  if not base or not accent or type(strength) ~= "number" then
    return false
  end
  local tinted = rgb_mix(base, accent, strength)
  local hl = vim.deepcopy(cursorline_theme or {})
  hl.bg = tinted
  hl.default = false
  vim.api.nvim_set_hl(0, "CursorLine", hl)
  return true
end

---@param spec { gvar: string, legacy?: string, default: number }
local function resolve_strength(spec)
  local v = vim.g[spec.gvar]
  if type(v) == "number" then
    return v
  end
  if spec.legacy then
    local leg = vim.g[spec.legacy]
    if type(leg) == "number" then
      return leg
    end
  end
  return spec.default
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
    local spec = THEME_BY_ROLE[role]
    if spec then
      local accent = pick_first(spec.groups, spec.prefer, spec.fallback)
      local strength = resolve_strength(spec)
      apply_theme_semantic_line(accent, strength)
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
