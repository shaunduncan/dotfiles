--------------------------------------------------------------------------------
--                               MISC UTILITIES                               --
--------------------------------------------------------------------------------

-- TODO: make this more generic?
-- <leader>C ==> center 80<cr>VU<esc>0v1lr-<esc>40A-<esc>d80<bar>hhvbr<space><esc>yyppVr-kk.

local function decorated_yank()
  vim.cmd [[redir @n | silent! '<,'>number | redir END]]
  local fname = vim.fn.expand('%')
  local border = string.rep('-', string.len(fname) + 1)
  local header = border .. '\n' .. fname .. ':' .. '\n' .. border
  vim.fn.setreg('*', header .. '\n' .. vim.fn.getreg('n'))
end

vim.keymap.set('v', '<C-y>', decorated_yank, { noremap = true })
vim.keymap.set('v', '<leader>Y', decorated_yank, { noremap = true })
