local constants = require "custom.utils.constants"
local autocmd = vim.api.nvim_create_autocmd
local function augroup(name)
  return vim.api.nvim_create_augroup("custom_" .. name, { clear = true })
end

autocmd("FileType", {
  group = augroup "nvr_as_git_editor",
  pattern = {
    "gitcommit",
    "gitrebase",
    "gitconfig",
  },
  command = "set bufhidden=wipe",
})

-- close some filetypes with <q>
autocmd("FileType", {
  group = augroup "close_with_q",
  pattern = {
    "PlenaryTestPopup",
    "help",
    "lspinfo",
    "man",
    "notify",
    "qf",
    "query",
    "spectre_panel",
    "startuptime",
    "tsplayground",
    "neotest-output",
    "checkhealth",
    "neotest-summary",
    "neotest-output-panel",
  },
  callback = function(event)
    vim.bo[event.buf].buflisted = false
    vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = event.buf, silent = true })
  end,
})
autocmd({ "CmdwinEnter" }, {
  group = augroup "close_with_q_cmd",
  command = "nnoremap <buffer> q :q<CR>",
})

-- Highlight on yank
autocmd("TextYankPost", {
  group = augroup "highlight_yank",
  callback = function()
    vim.highlight.on_yank { higroup = "Visual", timeout = 200 }
  end,
})

-- go to last loc when opening a buffer
autocmd("BufReadPost", {
  group = augroup "last_loc",
  callback = function()
    local exclude = { "gitcommit" }
    local buf = vim.api.nvim_get_current_buf()
    if vim.tbl_contains(exclude, vim.bo[buf].filetype) then
      return
    end
    local mark = vim.api.nvim_buf_get_mark(buf, '"')
    local lcount = vim.api.nvim_buf_line_count(buf)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

autocmd("FileType", {
  group = augroup "show_numbers_trouble",
  pattern = "Trouble",
  command = "set nu",
})

-- autocmd({ "BufEnter" }, {
--   group = augroup "tint_refresh",
--   pattern = "*",
--   callback = function()
--     local ok, tint = pcall(require, "tint")
--
--     if not ok then
--       return
--     end
--
--     if not vim.g.vimenter then
--       return
--     end
--
--     tint.refresh()
--   end,
-- })

autocmd({ "VimEnter" }, {
  group = augroup "set_vimenter",
  callback = function()
    vim.g.vimenter = true
  end,
})

-- Always edit files with swap
autocmd({ "SwapExists" }, {
  group = augroup "always_edit_with_swap",
  pattern = "*",
  command = 'let v:swapchoice = "e"',
})

autocmd({ "BufEnter" }, {
  group = augroup "nowrap_text_files",
  pattern = "*",
  command = "if &filetype == '' || expand('%:e') == 'norg' | set wrap | else | set nowrap | endif",
})

autocmd({ "BufEnter" }, {
  group = augroup "load_peek_mappings",
  pattern = "*.md",
  callback = function()
    local bufnr = vim.api.nvim_get_current_buf()
    require("core.utils").load_mappings("peek", { buffer = bufnr })
  end,
})

autocmd("FileType", {
  group = augroup "hide_ufo_folds",
  pattern = constants.exclude_filetypes,
  callback = function()
    local has_ufo, ufo = pcall(require, "ufo")
    if not has_ufo then
      return
    end
    pcall(ufo.detach)
    vim.opt_local.foldenable = false
    vim.opt_local.foldcolumn = "0"
  end,
})

autocmd({ "CmdlineLeave", "CmdlineEnter" }, {
  group = augroup "turn_off_flash_search",
  callback = function()
    local has_flash, flash = pcall(require, "flash")
    if not has_flash then
      return
    end
    pcall(flash.toggle, false)
  end,
})

-- HACK: fix buffer not showing on tabnew
-- https://github.com/NvChad/ui/blob/v2.0/lua/nvchad/tabufline/lazyload.lua
autocmd({ "tabnew" }, {
  callback = function(args)
    vim.schedule(function()
      if vim.t.bufs == nil then
        vim.t.bufs = vim.api.nvim_get_current_buf() == args.buf and {} or { args.buf }
      end
    end)
  end,
})

-- TODO: only when inside terminal
-- HACK: disable autoindent when pasting
-- missing register ":.="
local registers = '*+"-%/#abcdefghijklmnopqrstuvwxyz0123456789'
for i = 1, #registers do
  local register = registers:sub(i, i)

  -- disable paste mode before pasting and
  -- enable paste mode after pasting
  vim.keymap.set("i", "<C-r>" .. register, function()
    vim.o.paste = true
    pcall(vim.cmd, 'normal! "' .. register .. "p")
    -- vim.cmd('normal! "' .. register .. "p")
    vim.o.paste = false
  end, { expr = false, noremap = true })
end

-- vim.cmd [[
--    " Protect large files from sourcing and other overhead.
--    " Files become read only
--    if !exists("my_auto_commands_loaded")
--    let my_auto_commands_loaded = 1
--       " Large files are > 10M
--       " Set options:
--       " eventignore+=FileType (no syntax highlighting etc
--       " assumes FileType always on)
--       " noswapfile (save copy of file)
--       " bufhidden=unload (save memory when other file is viewed)
--       " buftype=nowrite (file is read-only)
--       " undolevels=-1 (no undo possible)
--       let g:LargeFile = 1024 * 1024 * 10
--       augroup LargeFile
--          autocmd BufReadPre * let f=expand("<afile>") | if getfsize(f) > g:LargeFile | set eventignore+=FileType | setlocal noswapfile bufhidden=unload buftype=nowrite undolevels=-1 | else | set eventignore-=FileType | endif
--       augroup END
--    endif
-- ]]
