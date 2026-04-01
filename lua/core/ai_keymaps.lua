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
    if vim.api.nvim_win_is_valid(win) then
      vim.api.nvim_win_close(win, true)
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

  -- Keymaps inside prompt window:
  -- - <C-s>: submit
  -- - <Esc>: cancel
  -- - q: cancel
  keymap("n", "<C-s>", submit, { buffer = buf, nowait = true, silent = true })
  keymap("i", "<C-s>", submit, { buffer = buf, nowait = true, silent = true })
  keymap({ "n", "i" }, "<Esc>", close, { buffer = buf, nowait = true, silent = true })
  keymap("n", "q", close, { buffer = buf, nowait = true, silent = true })

  vim.cmd("startinsert")
end

function M.setup()
  -- File context (Cursor / Claude friendly: @path#Lx-Ly + fenced code)

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
      vim.fn.setreg("+", ai_build_clipboard(header, ft, code))
      print("AI copy (selection): " .. header)
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
    vim.fn.setreg("+", ai_build_clipboard(header, ft, code))
    print("AI copy (file): " .. header)
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

      ai_open_prompt_float({ title = "AI question (selection)" }, function(input)
        local prompt = input .. "\n\n" .. ai_build_clipboard(header, ft, code)
        vim.fn.setreg("+", prompt)
        print("AI copy (question + selection): " .. header)
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

    ai_open_prompt_float({ title = "AI question (file)" }, function(input)
      local prompt = input .. "\n\n" .. ai_build_clipboard(header, ft, code)
      vim.fn.setreg("+", prompt)
      print("AI copy (question + file): " .. header)
    end)
  end, { desc = "AI: [C]ode [Q]uestion + full file" })
end

return M

