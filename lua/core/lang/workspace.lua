local Workspace = {}

Workspace.fallback_root_markers = {
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

local function is_real_path(path)
  return type(path) == "string" and path ~= "" and not path:match("^[%w%+%-]+://")
end

---@param path string
---@return string
local function search_start(path)
  if not is_real_path(path) then
    return vim.loop.cwd()
  end
  local stat = vim.loop.fs_stat(path)
  if stat and stat.type == "file" then
    return vim.fs.dirname(path)
  end
  return path
end

--- Git root; handles .git as file (worktrees) or directory.
---@param path string
---@return string|nil
local function git_root(path)
  local start = search_start(path)
  local git_marker = vim.fs.find(".git", { path = start, upward = true })[1]
  if git_marker then
    return vim.fs.dirname(git_marker)
  end
  return nil
end

---@param path string|nil
---@return string
function Workspace.cwd_from_path(path)
  if not path or path == "" then
    path = vim.loop.cwd()
  end

  if not is_real_path(path) then
    return vim.loop.cwd()
  end

  local root = git_root(path)
  if root then
    return root
  end

  local fallback = vim.fs.root(search_start(path), Workspace.fallback_root_markers)
  if fallback then
    return fallback
  end

  return vim.loop.cwd()
end

---@param root string
---@return string
local function ensure_dir(root)
  if vim.loop.fs_stat(root) then
    return root
  end
  return vim.loop.cwd()
end

--- Project root for the current buffer (git root, else markers, else shell cwd).
---@return string
function Workspace.cwd()
  local path = vim.api.nvim_buf_get_name(0)
  if path == "" then
    return ensure_dir(Workspace.cwd_from_path(vim.loop.cwd()))
  end
  return ensure_dir(Workspace.cwd_from_path(path))
end

return Workspace
