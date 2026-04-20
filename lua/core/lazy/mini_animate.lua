-- Cursor path only. Scroll/resize/open/close stay off: they mutate state async and
-- clash with centered motion maps (zz after n, <C-d>, etc.); see :h MiniAnimate.config.scroll
return {
  "nvim-mini/mini.animate",
  version = false,
  config = function()
    require("mini.animate").setup({
      cursor = {
        enable = true,
      },
      scroll = { enable = false },
      resize = { enable = false },
      open = { enable = false },
      close = { enable = false },
    })
  end,
}
