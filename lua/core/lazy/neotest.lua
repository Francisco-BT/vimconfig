-- Mappings call `lazy.load` first so `config` runs and `neotest.setup()` attaches
-- consumers (`run`, `summary`, …). Otherwise `require("neotest").run` is nil.

local NEOTEST_PLUGIN = "nvim-neotest/neotest"

local uv = vim.uv or vim.loop
local stop_dir = vim.env.HOME

local function nearest_package_root(path)
  local start
  if not path or path == "" then
    start = uv.cwd()
  elseif vim.fn.isdirectory(path) == 1 then
    start = vim.fn.fnamemodify(path, ":p")
  else
    start = vim.fn.fnamemodify(path, ":p:h")
  end
  local found = vim.fs.find("package.json", { path = start, upward = true, stop = stop_dir })
  if found[1] then
    return vim.fn.fnamemodify(found[1], ":p:h")
  end
  return uv.cwd()
end

local function lockfile_root(from_dir)
  local found = vim.fs.find({
    "pnpm-lock.yaml",
    "yarn.lock",
    "package-lock.json",
    "bun.lock",
    "bun.lockb",
  }, {
    path = from_dir,
    upward = true,
    stop = stop_dir,
  })
  if found[1] then
    return vim.fn.fnamemodify(found[1], ":p:h")
  end
  return from_dir
end

local function js_project_root()
  local buf = vim.api.nvim_buf_get_name(0)
  return nearest_package_root((buf ~= "" and buf) or uv.cwd())
end

local function package_manager_exec()
  local pkg = js_project_root()
  local root = lockfile_root(pkg)
  local join = vim.fs.joinpath
  if vim.fn.filereadable(join(root, "pnpm-lock.yaml")) == 1 then
    return "pnpm exec"
  end
  if vim.fn.filereadable(join(root, "yarn.lock")) == 1 or vim.fn.filereadable(join(root, ".yarnrc.yml")) == 1 then
    return "yarn exec"
  end
  if vim.fn.filereadable(join(root, "bun.lock")) == 1 or vim.fn.filereadable(join(root, "bun.lockb")) == 1 then
    return "bunx"
  end
  return "npx"
end

local function ensure_neotest()
  local lazy_ok, lazy = pcall(require, "lazy")
  if lazy_ok and lazy.load then
    lazy.load({ plugins = { NEOTEST_PLUGIN } })
  end
  local nt = require("neotest")
  if nt.run == nil then
    vim.notify(
      "Neotest no está listo (setup no corrió o falló). Revisa :messages y :Lazy.",
      vim.log.levels.ERROR
    )
    return nil
  end
  return nt
end

local function run_nearest()
  local nt = ensure_neotest()
  if nt then
    nt.run.run()
  end
end

local function run_file()
  local nt = ensure_neotest()
  if nt then
    nt.run.run(vim.fn.expand("%"))
  end
end

local function run_cwd()
  local nt = ensure_neotest()
  if nt then
    nt.run.run(js_project_root())
  end
end

local function toggle_summary()
  local nt = ensure_neotest()
  if nt then
    nt.summary.toggle()
  end
end

local function open_output()
  local nt = ensure_neotest()
  if nt then
    nt.output.open({ enter = true })
  end
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
    { "<leader>ts", run_cwd, desc = "Neotest: all tests (package)" },
    { "<leader>tv", toggle_summary, desc = "Neotest: toggle summary" },
    { "<leader>to", open_output, desc = "Neotest: output" },
  },
  config = function()
    local adapters = {}

    local jest_ok, jest_adapter = pcall(function()
      return require("neotest-jest")({
        jestCommand = function()
          local prefix = package_manager_exec()
          if prefix == "yarn exec" then
            return "yarn jest"
          end
          return prefix .. " jest"
        end,
        env = { CI = "true" },
        cwd = function()
          return js_project_root()
        end,
      })
    end)
    if jest_ok then
      adapters[#adapters + 1] = jest_adapter
    else
      vim.notify("neotest-jest: " .. tostring(jest_adapter), vim.log.levels.WARN)
    end

    local vitest_ok, vitest_adapter = pcall(function()
      return require("neotest-vitest")({
        vitestCommand = function()
          local prefix = package_manager_exec()
          if prefix == "yarn exec" then
            return "yarn vitest run"
          end
          if prefix == "bunx" then
            return "bunx vitest run"
          end
          return prefix .. " vitest run"
        end,
        cwd = function()
          return js_project_root()
        end,
      })
    end)
    if vitest_ok then
      adapters[#adapters + 1] = vitest_adapter
    else
      vim.notify("neotest-vitest: " .. tostring(vitest_adapter), vim.log.levels.WARN)
    end

    ---@diagnostic disable-next-line: missing-fields
    local setup_ok, setup_err = pcall(require("neotest").setup, {
      adapters = adapters,
      summary = {
        open = "botright",
      },
    })
    if not setup_ok then
      vim.notify("neotest.setup falló: " .. tostring(setup_err), vim.log.levels.ERROR)
    end
  end,
}
