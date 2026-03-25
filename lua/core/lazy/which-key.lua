return {
  "folke/which-key.nvim",
  event = "VeryLazy", -- Loads nearly last to avoid slowing down startup
  init = function()
    vim.o.timeout = true
    vim.o.timeoutlen = 300 -- Wait time (in ms) before the popup appears
  end,
  opts = {
    -- Customize the layout here, though the default is excellent
    icons = {
      group = "+", -- Symbol used for command groups
    },
  },
}
