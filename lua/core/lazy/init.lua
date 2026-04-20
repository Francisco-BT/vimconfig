-- List plugins with no extra configuration
return {
  {
    "nvim-lua/plenary.nvim",
    name = "plenary",
  },
  "eandrju/cellular-automaton.nvim",
  -- Cursor path only. Scroll/resize/open/close off (async state vs zz maps); :h MiniAnimate.config.scroll
  {
    "nvim-mini/mini.animate",
    version = false,
    config = function()
      require("mini.animate").setup({
        cursor = { enable = true },
        scroll = { enable = false },
        resize = { enable = false },
        open = { enable = false },
        close = { enable = false },
      })
    end,
  },
}
