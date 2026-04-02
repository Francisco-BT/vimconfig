local augroup = vim.api.nvim_create_augroup
local MineGroup = augroup("Mine", {})

local autocmd = vim.api.nvim_create_autocmd
local yank_group = augroup("HighlightYank", {})

autocmd("TextYankPost", {
  group = yank_group,
  pattern = "*",
  callback = function()
    vim.highlight.on_yank({
      higroup = "IncSearch",
      timeout = 40,
    })
  end,
})

-- Remove EOL white spaces before save
autocmd({ "BufWritePre" }, {
  group = MineGroup,
  pattern = "*",
  command = [[%s/\s\+$//e]],
})

autocmd("LspAttach", {
  group = MineGroup,
  callback = function(ev)
    -- Helper for shorter descriptions
    local function opts(desc)
      return { buffer = ev.buf, desc = "LSP: " .. desc }
    end

    -- Navigation
    vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts("Go to Definition"))
    vim.keymap.set("n", "K", vim.lsp.buf.hover, opts("Hover Documentation"))
    vim.keymap.set("n", "<leader>vrr", vim.lsp.buf.references, opts("Go to References"))

    -- Symbols & Workspace
    vim.keymap.set("n", "<leader>vws", vim.lsp.buf.workspace_symbol, opts("Workspace Symbol"))
    vim.keymap.set("n", "<leader>vd", vim.diagnostic.open_float, opts("Open Diagnostic Float"))
    vim.keymap.set("i", "<C-h>", vim.lsp.buf.signature_help, opts("Signature Help"))

    -- Actions & Refactoring
    vim.keymap.set("n", "<leader>vca", require("actions-preview").code_actions, opts("Code Action (Preview)"))
    vim.keymap.set("n", "<leader>vrn", vim.lsp.buf.rename, opts("Rename Symbol"))

    -- Diagnostics Navigation
    vim.keymap.set("n", "]d", function()
      vim.diagnostic.jump({ count = 1, float = true })
    end, opts("Next Diagnostic"))
    vim.keymap.set("n", "[d", function()
      vim.diagnostic.jump({ count = -1, float = true })
    end, opts("Previous Diagnostic"))
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "python", "go", "c" },
  group = MineGroup,
  callback = function()
    vim.opt_local.shiftwidth = 4
    vim.opt_local.tabstop = 4
    vim.opt_local.softtabstop = 4
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "typescript", "javascript", "prisma", "lua", "css" },
  group = MineGroup,
  callback = function()
    vim.opt_local.shiftwidth = 2
    vim.opt_local.tabstop = 2
    vim.opt_local.softtabstop = 2
  end,
})

local function hex_to_rgb(hex)
  hex = hex:gsub("#", "")
  return tonumber(hex:sub(1, 2), 16), tonumber(hex:sub(3, 4), 16), tonumber(hex:sub(5, 6), 16)
end

local function rgb_to_hex(r, g, b)
  return string.format("#%02x%02x%02x", r, g, b)
end

---ColorColumn: update ColorColumn based on the selected ColorScheme
local function set_colorcolumn_hl()
  local ref = vim.api.nvim_get_hl(0, { name = "Normal", link = false })
  local bg = ref.bg
  if type(bg) == "number" then
    bg = string.format("#%06x", bg)
  end
  if not bg then
    ref = vim.api.nvim_get_hl(0, { name = "CursorLine", link = false })
    if ref.bg then
      bg = string.format("#%06x", ref.bg)
    end
  end
  if not bg then
    bg = "#1e1e2e"
  end

  local r, g, b = hex_to_rgb(bg)
  local lum = (r + g + b) / 3
  local delta = lum < 140 and 20 or -20
  r = math.min(255, math.max(0, r + delta))
  g = math.min(255, math.max(0, g + delta))
  b = math.min(255, math.max(0, b + delta))

  vim.api.nvim_set_hl(0, "ColorColumn", { bg = rgb_to_hex(r, g, b), force = true })
end

local function set_blink_menu_highlights()
  local accent = "#d4a373"
  local menu_bg = "#1f1f1f"
  local sel_bg = "#333333"
  local sel_fg = "#5eacd3"

  vim.api.nvim_set_hl(0, "Pmenu", { bg = menu_bg, fg = "NONE", force = true })
  vim.api.nvim_set_hl(0, "BlinkCmpMenu", { link = "Pmenu", force = true })

  vim.api.nvim_set_hl(0, "BlinkCmpMenuSelection", {
    bg = sel_bg,
    fg = sel_fg,
    bold = true,
    nocombine = true,
    force = true,
  })
  vim.api.nvim_set_hl(0, "PmenuSel", { bg = sel_bg, fg = sel_fg, bold = true, force = true })

  vim.api.nvim_set_hl(0, "BlinkCmpLabelMatch", { fg = accent, bold = true, force = true })

  vim.api.nvim_set_hl(0, "BlinkCmpMenuBorder", { fg = accent, force = true })

  set_colorcolumn_hl()
end

vim.schedule(set_blink_menu_highlights)
vim.api.nvim_create_autocmd("ColorScheme", {
  pattern = "*",
  group = MineGroup,
  callback = function()
    vim.schedule(set_blink_menu_highlights)
  end,
})
