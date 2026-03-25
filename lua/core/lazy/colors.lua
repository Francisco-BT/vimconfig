local function apply_theme_transparent(color)
  color = color or "rose-pine"
  vim.cmd.colorscheme(color)

  vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
  vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
end

math.randomseed(os.time())

local function pick_random_theme()
  local themes = { "dracula_pro", "dracula_pro_blade", "rose-pine" }
  local random_theme = themes[math.random(1, #themes)]
  apply_theme_transparent(random_theme)
end

vim.api.nvim_create_autocmd("User", {
  pattern = "LazyDone",
  once = true,
  callback = function()
    pick_random_theme()
  end,
})

return {
  {
    dir = vim.fn.stdpath("data") .. "/site/pack/themes/start/dracula_pro",
    name = "dracula_pro",
    priority = 1000,
    cond = function()
      return vim.fn.isdirectory(vim.fn.stdpath("data") .. "/site/pack/themes/start/dracula_pro") == 1
    end,
    config = function() end,
  },
  {
    "rose-pine/neovim",
    name = "rose-pine",
    priority = 1000,
    config = function()
      require("rose-pine").setup({
        variant = "auto",
        dark_variant = "moon",
        disable_background = true,
        styles = {
          italic = false,
        },
      })
    end,
  },
}
