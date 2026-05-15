-- Mappings call `lazy.load` first so `config` runs and `neotest.setup()` attaches
-- consumers (`run`, `summary`, …). Otherwise `require("neotest").run` is nil.
--
-- Typical frontend stacks: Jest (incl. next/jest) and Vitest (e.g. with Vite).
-- cwd = nearest package.json to the buffer; runner prefix from pnpm|yarn|npm|bun via lockfile.
-- Test tree parsing: :TSInstall javascript typescript (tsx if needed). Adapters only apply
-- when that package's package.json lists jest and/or vitest in dependencies.
--
-- Optional per-repo overrides: walk up from the buffer dir for the first file named
-- `.neotest.json` or `.nvim/neotest.json` (JSON). Example:
--   {
--     "jest": {
--       "command": "doppler run --project qnr-server --config tst -- yarn workspace @sb/server jest",
--       "env": { "CI": "vscode-jest-tests", "DEBUG": "safebase:*" },
--       "cwd": "apps/server"
--     },
--     "vitest": { "command": "yarn workspace @sb/web vitest run", "env": {}, "cwd": "apps/web" }
--   }
-- `cwd` is optional; if relative, it is resolved against the directory containing the override file.

-- lazy.nvim registers `{"nvim-neotest/neotest", ...}` under the short id `neotest`
-- (repo name after `/`), not the full GitHub string — so `lazy.load` must use that id.

local function neotest_lazy_plugin_id()
  local ok, plugins = pcall(function()
    return require("lazy.core.config").plugins
  end)
  if not ok or type(plugins) ~= "table" then
    return nil
  end
  for _, id in ipairs({ "neotest", "nvim-neotest/neotest" }) do
    if plugins[id] then
      return id
    end
  end
  return nil
end

local uv = vim.uv or vim.loop
local stop_dir = vim.env.HOME or uv.os_homedir() or "/"

--- vim.fs.joinpath is Neovim 0.10+; keep 0.9.x working on a second machine.
local function joinpath(a, b)
  if vim.fs and vim.fs.joinpath then
    return vim.fs.joinpath(a, b)
  end
  local sep = package.config:sub(1, 1) == "\\" and "\\" or "/"
  return (tostring(a):gsub("[/\\]+$", "")) .. sep .. tostring(b):gsub("^[/\\]+", "")
end

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
  if vim.fn.filereadable(joinpath(root, "pnpm-lock.yaml")) == 1 then
    return "pnpm exec"
  end
  if vim.fn.filereadable(joinpath(root, "yarn.lock")) == 1 or vim.fn.filereadable(joinpath(root, ".yarnrc.yml")) == 1 then
    return "yarn exec"
  end
  if vim.fn.filereadable(joinpath(root, "bun.lock")) == 1 or vim.fn.filereadable(joinpath(root, "bun.lockb")) == 1 then
    return "bunx"
  end
  return "npx"
end

--- @return string|nil path to first `.neotest.json` or `.nvim/neotest.json` walking up from buffer dir.
local function find_neotest_override_path()
  local buf = vim.api.nvim_buf_get_name(0)
  local dir = buf ~= "" and vim.fn.fnamemodify(buf, ":p:h") or uv.cwd()
  local names = { ".neotest.json", joinpath(".nvim", "neotest.json") }
  while dir and dir ~= "" do
    for _, rel in ipairs(names) do
      local p = joinpath(dir, rel)
      if vim.fn.filereadable(p) == 1 then
        return vim.fn.fnamemodify(p, ":p")
      end
    end
    local parent = vim.fn.fnamemodify(dir, ":h")
    if parent == dir or dir == stop_dir then
      break
    end
    dir = parent
  end
  return nil
end

local override_cache = { path = nil, mtime = -1, data = nil, dir = nil }

--- @return { data: table, dir: string|nil }
local function load_neotest_overrides()
  local path = find_neotest_override_path()
  if not path then
    override_cache.path, override_cache.mtime, override_cache.data, override_cache.dir = nil, -1, {}, nil
    return { data = {}, dir = nil }
  end
  local mtime = vim.fn.getftime(path)
  if path == override_cache.path and mtime == override_cache.mtime and override_cache.data then
    return { data = override_cache.data, dir = override_cache.dir }
  end
  local lines = vim.fn.readfile(path)
  local text = table.concat(lines, "\n")
  local ok, data = pcall(vim.json.decode, text, { luanil = { object = true } })
  if not ok or type(data) ~= "table" then
    vim.notify("neotest: invalid or empty JSON in " .. path .. ": " .. tostring(data), vim.log.levels.WARN)
    data = {}
  end
  local dir = vim.fn.fnamemodify(path, ":p:h")
  override_cache.path, override_cache.mtime, override_cache.data, override_cache.dir = path, mtime, data, dir
  return { data = data, dir = dir }
end

local function resolve_override_cwd(override_dir, cwd_spec)
  if type(cwd_spec) ~= "string" or cwd_spec == "" or not override_dir then
    return nil
  end
  if vim.startswith(cwd_spec, "/") then
    return vim.fn.fnamemodify(cwd_spec, ":p")
  end
  return vim.fn.fnamemodify(joinpath(override_dir, cwd_spec), ":p")
end

--- Build a jest/vitest adapter instance. Factories use `__call(_, opts)` and index `opts`
--- immediately; a nil opts breaks config. Patch `__call` once, then invoke the metamethod
--- with an explicit options table (never rely on a bare `factory()` call).
local function build_adapter(modname, opts)
  assert(type(opts) == "table", modname .. ": adapter options must be a table")
  local mod = require(modname)
  local mt = getmetatable(mod)
  if not (mt and mt.__call) then
    error(modname .. ": expected a callable adapter factory (metatable.__call)")
  end
  if not mt.__neotest_opts_patched then
    local orig = mt.__call
    mt.__call = function(t, o)
      local safe = type(o) == "table" and o or {}
      return orig(t, safe)
    end
    mt.__neotest_opts_patched = true
  end
  return mt.__call(mod, opts)
end

local function ensure_neotest()
  local lazy_ok, lazy = pcall(require, "lazy")
  if lazy_ok and lazy.load then
    local id = neotest_lazy_plugin_id()
    if id then
      lazy.load({ plugins = { id } })
    end
  end
  local nt = require("neotest")
  if nt.run == nil then
    vim.notify(
      "Neotest is not ready (setup did not run or failed). Check :messages and :Lazy.",
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
      return build_adapter("neotest-jest", {
        jestCommand = function()
          local loaded = load_neotest_overrides()
          local j = loaded.data.jest
          if type(j) == "table" and type(j.command) == "string" and vim.fn.trim(j.command) ~= "" then
            return vim.fn.trim(j.command)
          end
          local prefix = package_manager_exec()
          if prefix == "yarn exec" then
            return "yarn jest"
          end
          return prefix .. " jest"
        end,
        env = function(specEnv)
          specEnv = type(specEnv) == "table" and specEnv or {}
          local base = { CI = "true", NODE_ENV = "test" }
          local loaded = load_neotest_overrides()
          local j = loaded.data.jest
          if type(j) == "table" and type(j.env) == "table" then
            vim.tbl_extend("force", base, j.env)
          end
          return vim.tbl_extend("force", base, specEnv)
        end,
        cwd = function()
          local loaded = load_neotest_overrides()
          local j = loaded.data.jest
          if type(j) == "table" and type(j.cwd) == "string" then
            local resolved = resolve_override_cwd(loaded.dir, j.cwd)
            if resolved then
              return resolved
            end
          end
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
      return build_adapter("neotest-vitest", {
        vitestCommand = function()
          local loaded = load_neotest_overrides()
          local v = loaded.data.vitest
          if type(v) == "table" and type(v.command) == "string" and vim.fn.trim(v.command) ~= "" then
            return vim.fn.trim(v.command)
          end
          local prefix = package_manager_exec()
          if prefix == "yarn exec" then
            return "yarn vitest run"
          end
          if prefix == "bunx" then
            return "bunx vitest run"
          end
          return prefix .. " vitest run"
        end,
        env = function(specEnv)
          specEnv = type(specEnv) == "table" and specEnv or {}
          local base = { CI = "true", NODE_ENV = "test" }
          local loaded = load_neotest_overrides()
          local v = loaded.data.vitest
          if type(v) == "table" and type(v.env) == "table" then
            vim.tbl_extend("force", base, v.env)
          end
          return vim.tbl_extend("force", base, specEnv)
        end,
        cwd = function()
          local loaded = load_neotest_overrides()
          local v = loaded.data.vitest
          if type(v) == "table" and type(v.cwd) == "string" then
            local resolved = resolve_override_cwd(loaded.dir, v.cwd)
            if resolved then
              return resolved
            end
          end
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
      vim.notify("neotest.setup failed: " .. tostring(setup_err), vim.log.levels.ERROR)
    end
  end,
}
