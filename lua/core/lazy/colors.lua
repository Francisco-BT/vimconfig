function apply_theme_transparent(color)
	color = color or "rose-pine"
	vim.cmd.colorscheme(color)

	vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
	vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
end


return {
  {
    name = "dracula_pro",
    dir = vim.fn.stdpath("data") .. "/site/pack/themes/start/dracula_pro",
    cond = function()
      return vim.fn.isdirectory(vim.fn.stdpath("data") .. "/site/pack/themes/start/dracula_pro") == 1
    end,
    config = function()
      apply_theme_transparent("dracula_pro")
    end,
  },
  {
    "rose-pine/neovim",
    name = "rose-pine",
    lazy = true,
    config = function()
      require("rose-pine").setup({
        variant = "auto",
        dark_variant = "moon",
        disable_background = true,
        styles = {
          italic = false,
        },
      })
      -- apply_theme_transparent("rose-pine")
    end,
  },
}
