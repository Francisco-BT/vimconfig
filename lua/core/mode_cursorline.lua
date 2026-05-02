--- CursorLine por modo: Insert, Visual, operador pendiente (d/y/c, …).
--- Paleta fija Rose Pine Moon (solo oscuro; sin rama light).
---
--- vim.g.mode_cursorline_palette = "rose_pine" | "theme"
---   "theme" → solo Insert/Replace mezcla con el tema; resto como el tema.
--- vim.g.mode_cursorline_mix  (solo palette "theme", insert): 0.08–0.12

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

-- Rose Pine Moon — insert = pine (antes yank); yank = gold (antes insert)
local BASE_MOON = 0x232136
local GOLD_LINE = rgb_mix(BASE_MOON, 0xf6c177, 0.32)
local PINE_LINE = rgb_mix(BASE_MOON, 0x3e8fb0, 0.22)
local ROSE_PINE = {
  insert = PINE_LINE,
  delete_op = rgb_mix(BASE_MOON, 0xeb6f92, 0.24), -- love
  yank_op = GOLD_LINE,
  change_op = rgb_mix(BASE_MOON, 0x9ccfd8, 0.28), -- foam (azul cian, como keyword Lua)
  visual = rgb_mix(BASE_MOON, 0x908caa, 0.18), -- subtle
  operator_other = rgb_mix(BASE_MOON, 0x6e6a86, 0.14), -- muted
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

local function apply_theme_insert_tint()
  local mix = vim.g.mode_cursorline_mix
  if type(mix) ~= "number" then
    mix = 0.10
  end
  local base_bg = cursorline_theme and cursorline_theme.bg or normal_bg
  if not base_bg then
    return
  end
  local tinted = rgb_mix(base_bg, 0xffffff, mix)
  local hl = vim.deepcopy(cursorline_theme or {})
  hl.bg = tinted
  hl.default = false
  vim.api.nvim_set_hl(0, "CursorLine", hl)
end

function M._apply()
  if not vim.o.cursorline or not vim.o.termguicolors then
    return
  end

  local role = classify()
  local palette = vim.g.mode_cursorline_palette or "rose_pine"

  if role == "normal" then
    restore_theme_cursorline()
    return
  end

  if palette == "theme" then
    if role == "insert" then
      apply_theme_insert_tint()
    else
      restore_theme_cursorline()
    end
    return
  end

  -- rose_pine (default): fixed CursorLine bg per role
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
    vim.g.mode_cursorline_palette = "rose_pine"
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
