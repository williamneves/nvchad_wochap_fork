local M = {}

M.luasnip = {
  -- Show snippets related to the language
  -- in the current cursor position
  ft_func = function()
    return require("luasnip.extras.filetype_functions").from_pos_or_filetype()
  end,
}

M.gitsigns = {
  signs = {
    add = {
      hl = "GitSignsAdd",
      text = "▍",
      numhl = "GitSignsAddNr",
      linehl = "GitSignsAddLn",
    },
    change = {
      hl = "GitSignsChange",
      text = "▍",
      numhl = "GitSignsChangeNr",
      linehl = "GitSignsChangeLn",
    },
    delete = {
      hl = "GitSignsDelete",
      text = "",
      numhl = "GitSignsDeleteNr",
      linehl = "GitSignsDeleteLn",
    },
    changedelete = {
      hl = "GitSignsChange",
      text = "~",
      numhl = "GitSignsChangeNr",
      linehl = "GitSignsChangeLn",
    },
    topdelete = {
      hl = "GitSignsDelete",
      text = "‾",
      numhl = "GitSignsDeleteNr",
      linehl = "GitSignsDeleteLn",
    },
  },
  keymaps = {
    ["n <leader>gR"] = "<cmd>Gitsigns reset_buffer<CR>",
    ["n <leader>gS"] = "<cmd>Gitsigns stage_buffer<CR>",
    ["n <leader>gs"] = "<cmd>Gitsigns stage_hunk<CR>",
    ["n <leader>gU"] = "<cmd>Gitsigns reset_buffer_index<CR>",
    ["n <leader>gu"] = "<cmd>Gitsigns undo_stage_hunk<CR>",

    ["v <leader>gs"] = ":Gitsigns stage_hunk<CR>",

    -- Text objects
    -- ['o ih'] = ':<C-U>Gitsigns select_hunk<CR>',
    -- ['x ih'] = ':<C-U>Gitsigns select_hunk<CR>'
  },
}

M.comment = {
  pre_hook = function(ctx)
    local U = require "Comment.utils"

    local location = nil
    if ctx.ctype == U.ctype.block then
      location = require("ts_context_commentstring.utils").get_cursor_location()
    elseif ctx.cmotion == U.cmotion.v or ctx.cmotion == U.cmotion.V then
      location = require("ts_context_commentstring.utils").get_visual_start_location()
    end

    return require("ts_context_commentstring.internal").calculate_commentstring {
      key = ctx.ctype == U.ctype.line and "__default" or "__multiline",
      location = location,
    }
  end,
}

return M
