return {
  "stevearc/conform.nvim",
  event = { "BufReadPost", "BufWritePre" },
  cmd = { "ConformInfo" },
  opts = {
    formatters_by_ft = {
      javascript = { "prettierd" },
      typescript = { "prettierd" },
      javascriptreact = { "prettierd" },
      typescriptreact = { "prettierd" },
      lua = { "stylua" },
      prisma = { "prismaFmt" },
    },
    formatters = {
      stylua = {
        prepend_args = { "--indent-type", "Spaces", "--indent-width", "2" },
      },
    },
    -- Tabla sola no respeta vim.g/b.disable_autoformat; hay que usar función (ver :h conform.nvim recipes)
    format_on_save = function(bufnr)
      if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
        return
      end
      return {
        timeout_ms = 1000,
        lsp_format = "fallback",
      }
    end,
    notify_on_error = true,
  },
  init = function()
    vim.keymap.set("n", "<leader>f", function()
      require("conform").format({ bufnr = 0 })
    end)
    vim.api.nvim_create_user_command("FormatDisable", function(args)
      if args.bang then
        vim.b.disable_autoformat = true
      else
        vim.g.disable_autoformat = true
      end
    end, { bang = true, desc = "Desactiva format on save (buffer con !)" })
    vim.api.nvim_create_user_command("FormatEnable", function()
      vim.b.disable_autoformat = false
      vim.g.disable_autoformat = false
    end, { desc = "Reactiva format on save" })
  end,
}
