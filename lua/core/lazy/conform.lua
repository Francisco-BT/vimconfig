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
    -- A plain table ignores vim.g/b.disable_autoformat; use a function (see :h conform.nvim recipes)
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
    end, { desc = "Format buffer (conform)" })
    vim.api.nvim_create_user_command("FormatDisable", function(args)
      if args.bang then
        vim.b.disable_autoformat = true
      else
        vim.g.disable_autoformat = true
      end
    end, { bang = true, desc = "Disable format on save (! = this buffer only)" })
    vim.api.nvim_create_user_command("FormatEnable", function()
      vim.b.disable_autoformat = false
      vim.g.disable_autoformat = false
    end, { desc = "Enable format on save" })
  end,
}
