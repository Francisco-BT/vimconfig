local Workspace = {}

--- Project root markers (first match walking up from the buffer path).
Workspace.root_markers = {
  ".git",
  "package.json",
  "pnpm-workspace.yaml",
  "pyproject.toml",
  "setup.py",
  "Cargo.toml",
  "go.mod",
  "go.work",
  "Gemfile",
  "mix.exs",
  "composer.json",
  "project.godot",
  "Makefile",
}

--- Heavy directories: excluded from quick-open even when .gitignore is bypassed.
Workspace.heavy_dirs = {
  ".git",
  "node_modules",
  ".venv",
  ".cache",
  "dist",
  "build",
  ".next",
  "coverage",
  "target",
  "vendor",
  "__pycache__",
  ".tox",
  ".godot",
}

local function dir_to_ignore_pattern(dir)
  if vim.startswith(dir, ".") then
    return "%" .. dir:gsub("%.", "%%.") .. "/"
  end
  return dir .. "/"
end

function Workspace.heavy_ignore_patterns()
  local patterns = {}
  for _, dir in ipairs(Workspace.heavy_dirs) do
    patterns[#patterns + 1] = dir_to_ignore_pattern(dir)
  end
  return patterns
end

function Workspace.quick_open_find_command()
  local cmd = { "fd", "--type", "f", "--hidden", "--no-ignore-vcs" }
  for _, dir in ipairs(Workspace.heavy_dirs) do
    cmd[#cmd + 1] = "--exclude"
    cmd[#cmd + 1] = dir
  end
  return cmd
end

---@param path string|nil
---@return string
function Workspace.cwd_from_path(path)
  if not path or path == "" then
    path = vim.loop.cwd()
  end
  return vim.fs.root(path, Workspace.root_markers) or vim.loop.cwd()
end

--- Workspace root for the current buffer.
---@return string
function Workspace.cwd()
  local path = vim.api.nvim_buf_get_name(0)
  if path == "" then
    return Workspace.cwd_from_path(vim.loop.cwd())
  end
  return Workspace.cwd_from_path(path)
end

return Workspace
