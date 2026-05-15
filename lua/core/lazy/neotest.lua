-- Lazy-load: plugin is not loaded until a <leader>t* mapping is used (lazy.nvim `keys`).
-- Treesitter is loaded elsewhere; we do not depend on it here to avoid load-order coupling.

local function run_nearest()
  require("neotest").run.run()
end

local function run_file()
  require("neotest").run.run(vim.fn.expand("%"))
end

local function run_cwd()
  require("neotest").run.run(vim.fn.getcwd())
end

local function toggle_summary()
  require("neotest").summary.toggle()
end

local function open_output()
  require("neotest").output.open({ enter = true })
end

return {
  "nvim-neotest/neotest",
  lazy = true,
  dependencies = {
    "nvim-neotest/nvim-nio",
    "nvim-lua/plenary.nvim",
    "antoinemadec/FixCursorHold.nvim",
    "nvim-neotest/neotest-jest",
    "marilari88/neotest-vitest",
  },
  keys = {
    { "<leader>tr", run_nearest, desc = "Neotest: nearest test" },
    { "<leader>ta", run_file, desc = "Neotest: tests in this file" },
    { "<leader>ts", run_cwd, desc = "Neotest: all tests (cwd)" },
    { "<leader>tv", toggle_summary, desc = "Neotest: toggle summary" },
    { "<leader>to", open_output, desc = "Neotest: output" },
  },
  config = function()
    ---@diagnostic disable-next-line: missing-fields
    require("neotest").setup({
      adapters = {
        require("neotest-jest")({
          jestCommand = "npm test --",
          env = { CI = "true" },
          cwd = function()
            return vim.fn.getcwd()
          end,
        }),
        require("neotest-vitest")(),
      },
      summary = {
        open = "botright",
      },
    })
  end,
}
