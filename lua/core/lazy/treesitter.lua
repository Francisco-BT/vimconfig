return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    lazy = false,
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter").setup()

      require("nvim-treesitter").install({
        "lua",
        "vim",
        "vimdoc",
        "javascript",
        "typescript",
        "tsx",
        "prisma",
        "json",
        "bash",
        "markdown",
      })

      local max_filesize = 300 * 1024
      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("MineTreesitterStart", { clear = true }),
        pattern = {
          "lua",
          "vim",
          "javascript",
          "javascriptreact",
          "typescript",
          "typescriptreact",
          "prisma",
          "json",
          "jsonc",
          "bash",
          "sh",
          "markdown",
          "help",
        },
        callback = function(args)
          local buf = args.buf
          local path = vim.api.nvim_buf_get_name(buf)
          local ok, stats = pcall(vim.loop.fs_stat, path)
          if ok and stats and stats.size > max_filesize then
            vim.notify(
              "File larger than 300KB: treesitter not started for performance",
              vim.log.levels.WARN,
              { title = "Treesitter" }
            )
            return
          end

          vim.api.nvim_buf_call(buf, function()
            vim.treesitter.start()
            if vim.bo.filetype == "markdown" then
              vim.opt_local.syntax = "on"
            end
            -- Plain .js: indent del ftplugin de Vim; TS/TSX/etc.: indent experimental de nvim-treesitter (main).
            if vim.bo.filetype ~= "javascript" then
              vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
            end
          end)
        end,
      })
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter-context",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    config = function()
      require("treesitter-context").setup({
        multiwindow = false,
        enable = true,
        max_lines = 4,
        line_numbers = true,
        trim_scope = "outer",
        mode = "cursor",
        zindex = 20,
      })
    end,
  },
}
