return {
    "folke/trouble.nvim",
    config = function()
      require("trouble").setup({})

      vim.keymap.set("n", "<leader>tt", function()
        require("trouble").toggle("diagnostics")
      end)

      vim.keymap.set("n", "]t", function()
        require("trouble").next({ skip_groups = true, jump = true });
      end)

      vim.keymap.set("n", "[t", function()
        require("trouble").prev({ skip_groups = true, jump = true });
      end)

    end
}
