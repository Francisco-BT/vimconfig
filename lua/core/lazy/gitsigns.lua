return {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
        -- Gutter signs configuration
        signs = {
            add          = { text = '┃' },
            change       = { text = '┃' },
            delete       = { text = '_' },
            topdelete    = { text = '‾' },
            changedelete = { text = '~' },
            untracked    = { text = '┆' },
        },
        -- Toggle current line blame (the "ghost text" at the end of the line)
        current_line_blame = false, -- Toggle this with <leader>tb
        current_line_blame_opts = {
            virt_text = true,
            virt_text_pos = 'eol', -- 'eol' | 'overlay' | 'right_align'
            delay = 1000,
            ignore_whitespace = false,
        },
        sign_priority = 6,
        update_debounce = 100,
        status_formatter = nil, -- Use default
        max_file_length = 40000, -- Disable if file is too large

        -- Keybindings
        on_attach = function(bufnr)
            local gitsigns = require('gitsigns')

            local function map(mode, l, r, opts)
                opts = opts or {}
                opts.buffer = bufnr
                vim.keymap.set(mode, l, r, opts)
            end

            -- Navigation: Jump between hunks (changes)
            map('n', ']c', function()
                if vim.wo.diff then
                    vim.cmd.normal({']c', bang = true})
                else
                    gitsigns.nav_hunk('next')
                end
            end, { desc = "Next Git hunk" })

            map('n', '[c', function()
                if vim.wo.diff then
                    vim.cmd.normal({'[c', bang = true})
                else
                    gitsigns.nav_hunk('prev')
                end
            end, { desc = "Previous Git hunk" })

            -- Actions: Stage, Reset, Preview
            map('n', '<leader>hs', gitsigns.stage_hunk, { desc = "Git: Stage hunk" })
            map('n', '<leader>hr', gitsigns.reset_hunk, { desc = "Git: Reset hunk" })
            map('n', '<leader>hS', gitsigns.stage_buffer, { desc = "Git: Stage buffer" })
            map('n', '<leader>hu', gitsigns.undo_stage_hunk, { desc = "Git: Undo stage hunk" })
            map('n', '<leader>hR', gitsigns.reset_buffer, { desc = "Git: Reset buffer" })
            map('n', '<leader>hp', gitsigns.preview_hunk, { desc = "Git: Preview hunk" })
            map('n', '<leader>hb', function() gitsigns.blame_line{full=true} end, { desc = "Git: Blame line" })
            map('n', '<leader>tb', gitsigns.toggle_current_line_blame, { desc = "Git: Toggle inline blame" })
            map('n', '<leader>hd', gitsigns.diffthis, { desc = "Git: Diff this" })
            map('n', '<leader>hD', function() gitsigns.diffthis('~') end, { desc = "Git: Diff this (base)" })
            map('n', '<leader>td', gitsigns.toggle_deleted, { desc = "Git: Toggle deleted lines" })

            -- Text object: Allows 'ih' for 'inner hunk' (e.g., 'dih' to delete a hunk)
            map({'o', 'x'}, 'ih', ':<C-U>Gitsigns select_hunk<CR>', { desc = "Select Git hunk" })
        end
    }
}
