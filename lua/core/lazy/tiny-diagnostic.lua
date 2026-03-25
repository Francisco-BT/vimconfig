return {
  "rachartier/tiny-inline-diagnostic.nvim",
  event = "LspAttach", -- Only load when an LSP is attached to a buffer
  priority = 1000, -- Ensure it renders on top of other UI elements
  config = function()
    require("tiny-inline-diagnostic").setup({
      preset = "modern", -- The clean, boxed style from the image you saw
      options = {
        show_source = true, -- Displays the provider (e.g., vtsls, eslint, prisma)
        -- Aligns the diagnostic box with the code's indentation level
        virt_texts_span_indent_col = true,
        -- If multiple errors exist on one line, show the most important one
        multiple_diag_under_cursor = true,
      },
    })

    vim.diagnostic.config({
      virtual_text = false, -- Disable the default plain text on the right
      underline = true, -- Keep the colored underlines (red/yellow) under the code
      signs = true, -- Keep the icons (E, W, H) in the gutter/sign column
      update_in_insert = false, -- Don't annoy us while we are still typing
    })
  end,
}
