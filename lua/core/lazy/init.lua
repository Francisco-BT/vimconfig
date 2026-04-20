-- List plugins with no extra configuration
return {
  {
    "nvim-lua/plenary.nvim",
    name = "plenary",
  },
  "eandrju/cellular-automaton.nvim",
  { import = "core.lazy.mini_animate" },
}
