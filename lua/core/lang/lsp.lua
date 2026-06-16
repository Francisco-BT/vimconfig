local WebLang = require("core.lang.web")

--- Language modules that run buffer-local LSP setup on attach.
--- Add future modules here (e.g. RustLang, GodotLang).
local attach_handlers = {
  WebLang,
}

local LangLsp = {}

---@param ev vim.api.nvim_set_autocmds.callback.args
---@param client vim.lsp.Client
function LangLsp.on_attach(ev, client)
  for _, handler in ipairs(attach_handlers) do
    if handler.on_lsp_attach then
      handler.on_lsp_attach(ev, client)
    end
  end
end

return LangLsp
