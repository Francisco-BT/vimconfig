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

  -- Azul oscuro suave para la columna 80 (match con accent, no intrusivo)
  vim.api.nvim_set_hl(0, "ColorColumn", { bg = "#152b36", force = true })
end

vim.schedule(set_blink_menu_highlights)
vim.api.nvim_create_autocmd("ColorScheme", {
  pattern = "*",
  group = MineGroup,
  callback = function()
    vim.schedule(set_blink_menu_highlights)
  end,
})
