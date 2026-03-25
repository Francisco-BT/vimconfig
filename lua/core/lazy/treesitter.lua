return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "master",
    config = function()
      require("nvim-treesitter.configs").setup({
        modules = {},
        ignore_install = {},
        ensure_installed = {
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
        },
        sync_install = false,
        auto_install = true,
        indent = { enable = true },
        highlight = {
          enable = true,
          additional_vim_regex_highlighting = { "markdown" },

          -- ThePrimeagen's Anti-Lag Shield
          disable = function(lang, buf)
            local max_filesize = 300 * 1024 -- 300 KB
            local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
            if ok and stats and stats.size > max_filesize then
              vim.notify(
                "File larger than 100KB treesitter disabled for performance",
                vim.log.levels.WARN,
                { title = "Treesitter" }
              )
              return true
            end
          end,
        },
      })
    end,
  },
  -- The Context Plugin (Sticky headers for functions/classes)
  {
    "nvim-treesitter/nvim-treesitter-context",
    after = "nvim-treesitter",
    config = function()
      require("treesitter-context").setup({
        multiwindow = false,
        enable = true,
        max_lines = 4, -- Limits the sticky header to 4 lines max
        line_numbers = true,
        trim_scope = "outer",
        mode = "cursor",
        zindex = 20,
      })
    end,
  },
}
