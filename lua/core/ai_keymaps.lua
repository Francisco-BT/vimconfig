local M = {}

local keymap = vim.keymap.set

local function ai_get_relpath()
  local p = vim.fn.expand("%:.")
  if p == "" then
    p = vim.fn.expand("%:p")
  end
  return p
end

local function ai_get_ft()
  local ft = vim.bo.filetype
  if ft == nil or ft == "" then
    return "text"
  end
  return ft
end

--- Range as #L10 or #L10-L20 (stable for @-references)
local function ai_format_range_l(start_line, end_line)
  if start_line == end_line then
    return "#L" .. start_line
  end
  return "#L" .. start_line .. "-L" .. end_line
end

local function ai_build_clipboard(header, ft, code)
  return header .. "\n\n```" .. ft .. "\n" .. code .. "\n```"
end

-- When enabled, copy ONLY the prompt/reference to clipboard, and keep the code block
-- in memory to copy later with <leader>cb. This reduces chat-editor noise.
local SPLIT_CODE_BLOCK = true
local last_code_fence = nil ---@type string|nil

local function ai_build_code_fence(ft, code)
  return "```" .. ft .. "\n" .. code .. "\n```"
end

-- Forward declare because some helpers call it before definition.
local ai_set_clipboard ---@type fun(text: string, code_fence: string)|nil

local function ai_get_cursor_line()
  return vim.api.nvim_win_get_cursor(0)[1]
end

local function ai_copy_range(path, ft, start_line, end_line)
  local header = "@" .. path .. ai_format_range_l(start_line, end_line)
  local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)
  local code = table.concat(lines, "\n")
  local code_fence = ai_build_code_fence(ft, code)

  if SPLIT_CODE_BLOCK then
    ai_set_clipboard(header, code_fence)
    print("AI copy (scope ref): " .. header .. " (code cached)")
  else
    vim.fn.setreg("+", ai_build_clipboard(header, ft, code))
    print("AI copy (scope): " .. header)
  end
end

local function ai_copy_near_cursor(path, ft, radius)
  local r = radius or 20
  local total = vim.api.nvim_buf_line_count(0)
  local cursor = ai_get_cursor_line()
  local start_line = math.max(1, cursor - r)
  local end_line = math.min(total, cursor + r)
  ai_copy_range(path, ft, start_line, end_line)
end

local function ai_treesitter_node_range()
  local ok, ts_utils = pcall(require, "nvim-treesitter.ts_utils")
  if not ok then
    return nil
  end

  local node = ts_utils.get_node_at_cursor()
  if node == nil then
    return nil
  end

  -- Walk up until we find a "good" container node.
  -- Works across languages; node:type() differs, so we match common names.
  local function is_container(t)
    return t == "function_declaration"
      or t == "function_definition"
      or t == "method_definition"
      or t == "function"
      or t == "method"
      or t == "arrow_function"
      or t == "class_declaration"
      or t == "class_definition"
      or t == "class"
      or t == "interface_declaration"
      or t == "type_alias_declaration"
      or t == "lexical_declaration"
      or t == "variable_declaration"
      or t == "call_expression" -- useful for it(...)/describe(...)
      or t == "expression_statement"
      or t == "statement_block"
      or t == "block"
  end

  local cur = node
  for _ = 1, 30 do
    if cur == nil then
      break
    end
    local t = cur:type()
    if is_container(t) then
      local sr, _, er, _ = cur:range() -- 0-indexed, end row exclusive
      return { start_line = sr + 1, end_line = er } -- convert to 1-index, inclusive
    end
    cur = cur:parent()
  end

  return nil
end

ai_set_clipboard = function(text, code_fence)
  vim.fn.setreg("+", text)
  last_code_fence = code_fence
end

local function ai_copy_last_code_block_replace()
  if last_code_fence == nil or last_code_fence == "" then
    print("AI: no code block cached yet")
    return
  end
  vim.fn.setreg("+", last_code_fence)
  print("AI: copied last code block")
end

local MAX_FILE_LINES = 300
local FILE_HEAD_LINES = 150
local FILE_TAIL_LINES = 150

local function ai_clip_file_lines(all_lines)
  local n = #all_lines
  if n <= MAX_FILE_LINES then
    return all_lines, { truncated = false, n = n }
  end

  local head_n = math.min(FILE_HEAD_LINES, n)
  local tail_n = math.min(FILE_TAIL_LINES, math.max(n - head_n, 0))
  local omitted = math.max(n - head_n - tail_n, 0)

  local clipped = {}
  for i = 1, head_n do
    clipped[#clipped + 1] = all_lines[i] or ""
  end

  clipped[#clipped + 1] = ("... omitted %d lines (file too large) ..."):format(omitted)

  for i = n - tail_n + 1, n do
    if i >= 1 and i <= n then
      clipped[#clipped + 1] = all_lines[i] or ""
    end
  end

  return clipped, { truncated = true, n = n, head_n = head_n, tail_n = tail_n, omitted = omitted }
end

local function ai_open_prompt_float(opts, on_submit)
  local title = (opts and opts.title) or "AI prompt"
  local placeholder = (opts and opts.placeholder) or ""
  local start_in_insert = true
  if opts and opts.start_in_insert == false then
    start_in_insert = false
  end

  local return_win = vim.api.nvim_get_current_win()

  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_set_option_value("buftype", "nofile", { buf = buf })
  vim.api.nvim_set_option_value("swapfile", false, { buf = buf })
  vim.api.nvim_set_option_value("bufhidden", "wipe", { buf = buf })
  vim.api.nvim_set_option_value("filetype", "markdown", { buf = buf })

  local initial_lines = {}
  if placeholder ~= "" then
    initial_lines = vim.split(placeholder, "\n", { plain = true })
  end
  if #initial_lines == 0 then
    initial_lines = { "" }
  end
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, initial_lines)

  local columns = vim.o.columns
  local lines = vim.o.lines
  local width = math.max(60, math.floor(columns * 0.6))
  local height = math.max(10, math.floor(lines * 0.35))
  local row = math.floor((lines - height) / 2 - 1)
  local col = math.floor((columns - width) / 2)

  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    style = "minimal",
    border = "rounded",
    title = title,
    title_pos = "center",
    width = width,
    height = height,
    row = math.max(row, 0),
    col = math.max(col, 0),
  })

  vim.api.nvim_set_option_value("wrap", true, { win = win })

  local function close()
    -- Ensure we exit insert mode so we don't "leak" it back.
    pcall(vim.cmd, "stopinsert")
    if vim.api.nvim_win_is_valid(win) then
      vim.api.nvim_win_close(win, true)
    end
    if return_win ~= nil and vim.api.nvim_win_is_valid(return_win) then
      vim.api.nvim_set_current_win(return_win)
    end
  end

  local function submit()
    local prompt_lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
    local text = table.concat(prompt_lines, "\n")
    text = vim.trim(text)
    if text == "" then
      close()
      return
    end
    close()
    on_submit(text)
  end

  local function insert_text_at_cursor(text)
    local row, col = unpack(vim.api.nvim_win_get_cursor(win))
    local line = vim.api.nvim_buf_get_lines(buf, row - 1, row, false)[1] or ""
    local before = string.sub(line, 1, col)
    local after = string.sub(line, col + 1)
    vim.api.nvim_buf_set_lines(buf, row - 1, row, false, { before .. text .. after })
    vim.api.nvim_win_set_cursor(win, { row, col + #text })
  end

  local function pick_file_and_insert_reference()
    local ok_builtin, builtin = pcall(require, "telescope.builtin")
    if not ok_builtin then
      print("AI: Telescope not available")
      return
    end

    local function on_select(prompt_bufnr)
      local ok_actions, actions = pcall(require, "telescope.actions")
      local ok_state, action_state = pcall(require, "telescope.actions.state")
      if not ok_actions or not ok_state then
        return
      end
      local entry = action_state.get_selected_entry()
      actions.close(prompt_bufnr)

      if entry == nil then
        return
      end

      local value = entry.path or entry.value
      if type(value) ~= "string" or value == "" then
        return
      end

      -- Normalize to repo-relative if possible
      local cwd = vim.loop.cwd() or ""
      local rel = value
      if cwd ~= "" and vim.startswith(value, cwd) then
        rel = value:sub(#cwd + 2)
      end

      insert_text_at_cursor("@" .. rel .. " ")
      vim.schedule(function()
        if vim.api.nvim_win_is_valid(win) then
          vim.api.nvim_set_current_win(win)
          vim.cmd("startinsert")
        end
      end)
    end

    local function attach_mappings(_, map)
      map("i", "<CR>", on_select)
      map("n", "<CR>", on_select)
      return true
    end

    -- Prefer git_files when inside a git repo; fallback to find_files.
    local ok_git = pcall(builtin.git_files, { attach_mappings = attach_mappings, show_untracked = true })
    if not ok_git then
      builtin.find_files({ attach_mappings = attach_mappings })
    end
  end

  -- Keymaps inside prompt window:
  -- - <C-s>: submit
  -- - <Esc>: cancel
  -- - q: cancel
  -- - <C-p>: pick file, insert @path
  keymap("n", "<C-s>", submit, { buffer = buf, nowait = true, silent = true })
  keymap("i", "<C-s>", submit, { buffer = buf, nowait = true, silent = true })
  keymap({ "n", "i" }, "<Esc>", close, { buffer = buf, nowait = true, silent = true })
  keymap("n", "q", close, { buffer = buf, nowait = true, silent = true })
  keymap({ "n", "i" }, "<C-p>", pick_file_and_insert_reference, { buffer = buf, nowait = true, silent = true })

  if start_in_insert then
    -- Place cursor at end of buffer content so user types after placeholder.
    local last_row = math.max(1, vim.api.nvim_buf_line_count(buf))
    local last_line = vim.api.nvim_buf_get_lines(buf, last_row - 1, last_row, false)[1] or ""
    vim.api.nvim_win_set_cursor(win, { last_row, #last_line })
    vim.cmd("startinsert")
  end
end

function M.setup()
  -- File context (Cursor / Claude friendly: @path#Lx-Ly + fenced code)

  -- Copy cached last code block (when SPLIT_CODE_BLOCK=true)
  keymap("n", "<leader>cb", ai_copy_last_code_block_replace, { desc = "AI: copy cached code block" })

  -- Copy Treesitter scope around cursor (function/class/test block). Falls back to +/-20 lines.
  keymap("n", "<leader>cR", function()
    local path = ai_get_relpath()
    local ft = ai_get_ft()

    local r = ai_treesitter_node_range()
    if r == nil then
      ai_copy_near_cursor(path, ft, 20)
      return
    end

    -- Clamp to buffer range and ensure non-empty.
    local total = vim.api.nvim_buf_line_count(0)
    local start_line = math.max(1, math.min(r.start_line, total))
    local end_line = math.max(start_line, math.min(r.end_line, total))
    ai_copy_range(path, ft, start_line, end_line)
  end, { desc = "AI: [C]ode [R]ange from Treesitter scope" })

  -- 1. [C]ode [S]election (Visual Mode: <leader>cs)
  keymap("v", "<leader>cs", function()
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "x", false)

    vim.schedule(function()
      local path = ai_get_relpath()
      local ft = ai_get_ft()
      local start_line = vim.fn.line("'<")
      local end_line = vim.fn.line("'>")
      if start_line < 1 or end_line < 1 then
        return
      end
      if start_line > end_line then
        start_line, end_line = end_line, start_line
      end

      local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)
      local code = table.concat(lines, "\n")

      local header = "@" .. path .. ai_format_range_l(start_line, end_line)
      local code_fence = ai_build_code_fence(ft, code)

      if SPLIT_CODE_BLOCK then
        ai_set_clipboard(header, code_fence)
        print("AI copy (selection ref): " .. header .. " (code cached)")
      else
        vim.fn.setreg("+", ai_build_clipboard(header, ft, code))
        print("AI copy (selection): " .. header)
      end
    end)
  end, { desc = "AI: [C]ode [S]election (@path#L..)" })

  -- 2. [C]ode [A]ll (Normal Mode: <leader>ca)
  keymap("n", "<leader>ca", function()
    local path = ai_get_relpath()
    local ft = ai_get_ft()
    local buf_lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
    local clipped_lines, meta = ai_clip_file_lines(buf_lines)
    local code = table.concat(clipped_lines, "\n")
    local n = meta.n

    local header = "@" .. path .. "#L1-L" .. math.max(n, 1)

    if SPLIT_CODE_BLOCK then
      ai_set_clipboard(header, ai_build_code_fence(ft, code))
      print("AI copy (file ref): " .. header .. " (code cached)")
    else
      vim.fn.setreg("+", ai_build_clipboard(header, ft, code))
      print("AI copy (file): " .. header)
    end
  end, { desc = "AI: [C]ode [A]ll (full file, @path#L1-LN)" })

  -- 3. [C]ode [P]ath (Normal Mode: <leader>cp)
  keymap("n", "<leader>cp", function()
    local agent_path = "@" .. ai_get_relpath()
    vim.fn.setreg("+", agent_path)
    print("AI copy (path): " .. agent_path)
  end, { desc = "AI: [C]ode [P]ath (@path only)" })

  -- 4. [C]ode [Q]uestion + selection (Visual Mode: <leader>cq)
  keymap("v", "<leader>cq", function()
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "x", false)

    vim.schedule(function()
      local path = ai_get_relpath()
      local ft = ai_get_ft()
      local start_line = vim.fn.line("'<")
      local end_line = vim.fn.line("'>")
      if start_line < 1 or end_line < 1 then
        return
      end
      if start_line > end_line then
        start_line, end_line = end_line, start_line
      end

      local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)
      local code = table.concat(lines, "\n")
      local header = "@" .. path .. ai_format_range_l(start_line, end_line)

      ai_open_prompt_float({ title = "AI question (selection)", placeholder = header .. " " }, function(input)
        local code_fence = ai_build_code_fence(ft, code)
        if SPLIT_CODE_BLOCK then
          -- header is prefilled at top of the prompt buffer
          ai_set_clipboard(input, code_fence)
          print("AI copy (question + selection ref): " .. header .. " (code cached)")
        else
          vim.fn.setreg("+", input .. "\n\n" .. ai_build_clipboard(header, ft, code))
          print("AI copy (question + selection): " .. header)
        end
      end)
    end)
  end, { desc = "AI: [C]ode [Q]uestion + selection" })

  -- 5. [C]ode [Q]uestion + file (Normal Mode: <leader>cq)
  keymap("n", "<leader>cq", function()
    local path = ai_get_relpath()
    local ft = ai_get_ft()
    local buf_lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
    local clipped_lines, meta = ai_clip_file_lines(buf_lines)
    local code = table.concat(clipped_lines, "\n")
    local n = meta.n
    local header = "@" .. path .. "#L1-L" .. math.max(n, 1)

    ai_open_prompt_float({ title = "AI question (file)", placeholder = header .. " " }, function(input)
      if SPLIT_CODE_BLOCK then
        -- header is prefilled at top of the prompt buffer
        ai_set_clipboard(input, ai_build_code_fence(ft, code))
        print("AI copy (question + file ref): " .. header .. " (code cached)")
      else
        vim.fn.setreg("+", input .. "\n\n" .. ai_build_clipboard(header, ft, code))
        print("AI copy (question + file): " .. header)
      end
    end)
  end, { desc = "AI: [C]ode [Q]uestion + full file" })
end

return M
