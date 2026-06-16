local BiomeConfig = require("core.lang.biome")

local WebLang = {}

local web_chain = BiomeConfig.formatter_chain("prettierd")

WebLang.formatters_by_ft = {
  javascript = web_chain,
  typescript = web_chain,
  javascriptreact = web_chain,
  typescriptreact = web_chain,
  css = web_chain,
  scss = web_chain,
  html = web_chain,
  json = web_chain,
  jsonc = web_chain,
  graphql = web_chain,
}

WebLang.formatters = {
  ["biome-check"] = {
    condition = function(_, ctx)
      return BiomeConfig.has_config(ctx)
    end,
  },
}

-- Server computes hints; Neovim shows them only after <leader>vih.
-- Light profile: parameter names only (less noise in React/TS).
local inlay_hints = {
  parameterNames = { enabled = "all" },
  parameterTypes = { enabled = false },
  variableTypes = { enabled = false },
  propertyDeclarationTypes = { enabled = false },
  functionLikeReturnTypes = { enabled = false },
  enumMemberValues = { enabled = false },
}

function WebLang.vtsls_config()
  return {
    settings = {
      experimental = {
        maxInlayHintLength = 30,
      },
      typescript = {
        tsserver = {
          maxTsServerMemory = 8192,
        },
        inlayHints = inlay_hints,
      },
      javascript = {
        tsserver = {
          maxTsServerMemory = 8192,
        },
        inlayHints = inlay_hints,
      },
    },
  }
end

function WebLang.tailwindcss_config()
  return {
    filetypes = {
      "html",
      "css",
      "scss",
      "javascript",
      "javascriptreact",
      "typescript",
      "typescriptreact",
      "vue",
      "svelte",
      "heex",
    },
  }
end

--- Default off for vtsls; use <leader>vih to toggle per buffer.
---@param ev vim.api.nvim_set_autocmds.callback.args
---@param client vim.lsp.Client
function WebLang.on_lsp_attach(ev, client)
  if client.name ~= "vtsls" then
    return
  end
  if vim.lsp.inlay_hint then
    vim.lsp.inlay_hint.enable(false, { bufnr = ev.buf })
  end
end

function WebLang.setup_keymaps()
  vim.keymap.set("n", "<leader>vih", function()
    if not vim.lsp.inlay_hint then
      vim.notify("Inlay hints require Neovim 0.10+", vim.log.levels.WARN)
      return
    end
    local bufnr = vim.api.nvim_get_current_buf()
    local has_vtsls = false
    for _, client in ipairs(vim.lsp.get_clients({ bufnr = bufnr, name = "vtsls" })) do
      if client.supports_method("textDocument/inlayHint") then
        has_vtsls = true
        break
      end
    end
    if not has_vtsls then
      vim.notify("No vtsls attached to this buffer", vim.log.levels.WARN)
      return
    end
    local enabled = vim.lsp.inlay_hint.is_enabled({ bufnr = bufnr })
    vim.lsp.inlay_hint.enable(not enabled, { bufnr = bufnr })
    vim.notify(
      enabled and "Inlay hints off" or "Inlay hints on",
      vim.log.levels.INFO,
      { title = "vtsls" }
    )
  end, { desc = "LSP: toggle inlay hints (vtsls)" })
end

return WebLang
