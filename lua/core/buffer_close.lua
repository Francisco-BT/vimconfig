local BufDelete = {}

local function visible_bufs()
  local set = {}
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    if vim.api.nvim_win_is_valid(win) then
      set[vim.api.nvim_win_get_buf(win)] = true
    end
  end
  return set
end

--- Delete buffer. Returns 1 if skipped due to unsaved changes (no force); 0 otherwise.
--- Other delete failures only raise a one-off notification.
---@param buf integer
---@param force boolean
---@return integer
local function try_delete(buf, force)
  if not vim.api.nvim_buf_is_valid(buf) then
    return 0
  end
  if not force and vim.bo[buf].modified then
    return 1
  end
  local ok, err = pcall(vim.api.nvim_buf_delete, buf, { force = force })
  if not ok then
    vim.notify(
      ("Could not delete buffer %d: %s"):format(buf, tostring(err)),
      vim.log.levels.WARN
    )
  end
  return 0
end

---@param force boolean
---@return integer modified_skipped
local function delete_all_listed(force)
  local modified_skipped = 0
  local cur = vim.api.nvim_get_current_buf()
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].buflisted and buf ~= cur then
      modified_skipped = modified_skipped + try_delete(buf, force)
    end
  end
  if vim.api.nvim_buf_is_valid(cur) and vim.bo[cur].buflisted then
    modified_skipped = modified_skipped + try_delete(cur, force)
  end
  return modified_skipped
end

---@param kind "all"|"hidden"|"other"
---@param opts? { force?: boolean }
function BufDelete.delete(kind, opts)
  opts = opts or {}
  local force = opts.force == true

  if kind ~= "all" and kind ~= "hidden" and kind ~= "other" then
    vim.notify("buffer_close: invalid kind: " .. tostring(kind), vim.log.levels.ERROR)
    return
  end

  local modified_skipped = 0

  if kind == "all" then
    modified_skipped = delete_all_listed(force)
  else
    local visible = kind == "hidden" and visible_bufs() or nil
    local cur = vim.api.nvim_get_current_buf()

    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
      if vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].buflisted then
        local drop
        if kind == "hidden" then
          drop = not visible[buf]
        else
          drop = buf ~= cur
        end
        if drop then
          modified_skipped = modified_skipped + try_delete(buf, force)
        end
      end
    end
  end

  if modified_skipped > 0 and not force then
    vim.notify(
      ("Skipped %d buffer(s) with unsaved changes. Use :BDelete! %s to close them anyway."):format(
        modified_skipped,
        kind
      ),
      vim.log.levels.WARN
    )
  end
end

local function complete_arg_lead(arg_lead)
  local opts = { "all", "hidden", "other" }
  local out = {}
  for _, o in ipairs(opts) do
    if vim.startswith(o, arg_lead) then
      out[#out + 1] = o
    end
  end
  return out
end

function BufDelete.setup()
  vim.api.nvim_create_user_command("BDelete", function(cmd_opts)
    local kind = vim.trim(cmd_opts.args):lower()
    if kind == "" then
      vim.notify("BDelete: specify all, hidden, or other", vim.log.levels.ERROR)
      return
    end
    if kind ~= "all" and kind ~= "hidden" and kind ~= "other" then
      vim.notify("BDelete: invalid argument: " .. cmd_opts.args, vim.log.levels.ERROR)
      return
    end
    BufDelete.delete(kind, { force = cmd_opts.bang })
  end, {
    nargs = 1,
    bang = true,
    complete = complete_arg_lead,
    desc = "Delete listed buffers (all | hidden | other); use ! to force",
  })

  local keymap = vim.keymap.set
  keymap("n", "<leader>bh", function()
    BufDelete.delete("hidden", {})
  end, { desc = "Close hidden buffers (not shown in any window)" })

  keymap("n", "<leader>bo", function()
    BufDelete.delete("other", {})
  end, { desc = "Close other buffers (keep current)" })

  keymap("n", "<leader>bA", function()
    BufDelete.delete("all", {})
  end, { desc = "Close all listed buffers" })
end

return BufDelete
