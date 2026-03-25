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
          use_nvim_cmp_as_default = true,
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
      "tailwindcss",
    }
    mason_lspconfig.setup({
      ensure_installed = servers,
      automatic_enable = true,
    })

    local server_configs = {
      lua_ls = {
        settings = {
          Lua = {
            runtime = { version = "LuaJIT" },
            workspace = { checkThirdParty = false },
            format = { enable = false },
          },
        },
      },
      tailwindcss = {
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
      },
    }

    local lspconfig = require("lspconfig")
    for server_name, config in pairs(server_configs) do
      config.capabilities = blink.get_lsp_capabilities(config.capabilities)
      vim.lsp.config(server_name, config)
    end

    vim.diagnostic.config({
      -- update_in_insert = true,
      float = {
        focusable = false,
        style = "minimal",
        border = "rounded",
        source = "always",
        header = "",
        prefix = "",
      },
    })
  end,
}
