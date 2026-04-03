return {
  {
    "aznhe21/actions-preview.nvim",
    event = "LspAttach",
    config = function()
      -- <leader>vca in normal + visual (buffer-local LSP maps stay in autocmd.lua)
      vim.keymap.set({ "v", "n" }, "<leader>vca", require("actions-preview").code_actions, {
        desc = "LSP Code Actions with Preview",
      })

      -- Plugin configuration
      require("actions-preview").setup({
        -- UI backend: Uses Telescope for the selection list
        backend = { "telescope" },

        -- Layout and appearance settings
        nui = {
          -- Direction of the diff preview: "col" (side by side) or "row" (above/below)
          dir = "col",
          keymap = {
            close = { "<Esc>", "q" },
            accept = { "<CR>" },
          },
          layout = {
            position = "50%",
            size = {
              width = "80%",
              height = "60%",
            },
            min_width = 40,
            min_height = 10,
            relative = "editor",
          },
        },
      })
    end,
  },
}
