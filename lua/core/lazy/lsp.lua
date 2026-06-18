local WebLang = require("core.lang.web")

return {
  "neovim/nvim-lspconfig",
  dependencies = {
    "stevearc/conform.nvim",
    "williamboman/mason.nvim",
    "williamboman/mason-lspconfig.nvim",
    "j-hui/fidget.nvim",
    { "folke/lazydev.nvim", ft = "lua", opts = {} },
    {
      "saghen/blink.cmp",
      version = "*", -- stable
      opts = {
        keymap = { preset = "default" },
        appearance = {
          use_nvim_cmp_as_default = false,
          nerd_font_variant = "mono",
        },
        sources = {
          default = { "lsp", "path", "snippets", "buffer" },
        },
      },
    },
  },

  config = function()
    require("fidget").setup({})
    require("mason").setup()

    local blink = require("blink.cmp")
    local mason_lspconfig = require("mason-lspconfig")
    local servers = {
      "lua_ls",
      "vtsls",
      "eslint",
      "biome",
      "tailwindcss",
      "prismals",
      "codebook",
    }
    mason_lspconfig.setup({
      ensure_installed = servers,
      automatic_enable = true,
    })

    local server_configs = {
      vtsls = WebLang.vtsls_config(),
      lua_ls = {
        settings = {
          Lua = {
            runtime = { version = "LuaJIT" },
            workspace = { checkThirdParty = false },
            format = { enable = false },
          },
        },
      },
      tailwindcss = WebLang.tailwindcss_config(),
      codebook = {
        init_options = {
          diagnosticSeverity = "hint",
        },
      },
    }

    for server_name, config in pairs(server_configs) do
      config.capabilities = blink.get_lsp_capabilities(config.capabilities)
      vim.lsp.config(server_name, config)
    end

    WebLang.setup_keymaps()
  end,
}
