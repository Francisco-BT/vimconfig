-- Carga diferida: no se instala el plugin hasta el primer uso de un <leader>t* (lazy.keys).
-- Requiere treesitter (ya lo tienes en lazy); no duplicamos dependencia para no forzar orden raro.

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

local function run_nearest_dap()
  local ok = pcall(require, "dap")
  if not ok then
    vim.notify("nvim-dap no está cargado: ejecutando test sin DAP", vim.log.levels.WARN)
    run_nearest()
    return
  end
  require("neotest").run.run({ strategy = "dap" })
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
    { "<leader>td", run_nearest_dap, desc = "Neotest: nearest (DAP si existe)" },
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
