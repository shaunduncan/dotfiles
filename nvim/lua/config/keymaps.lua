--------------------------------------------------------------------------------
--                                  KEYMAPS                                   --
--------------------------------------------------------------------------------

-- leader key: space, 500ms timeout
vim.o.timeoutlen = 500
vim.o.updatetime = 500

-- toggle colorcolumn to visualize text wraps
vim.keymap.set(
  { 'n', 'v' },
  '<leader><bar><bar>',
  function()
    if vim.o.colorcolumn == '' then
      vim.o.colorcolumn = tostring(vim.o.textwidth)
    else
      vim.o.colorcolumn = ''
    end
  end,
  { noremap = true, silent = true }
)

-- tmux ctrl-a makes the increment number option useless, so remap it
vim.keymap.set('n', '<c-k>', '<c-a>', { noremap = true })
vim.keymap.set('n', '<c-j>', '<c-x>', { noremap = true })

-- double esc to close location/quickfix
vim.keymap.set(
  'n',
  '<esc><esc>',
  function()
    vim.cmd.lclose()
    vim.cmd.cclose()
  end,
  { silent = true, noremap = true }
)

-- jq formtting, allow in both normal and visual block mode
vim.keymap.set({ 'n', 'v' }, '<leader>jq', ":%!jq '.'<cr>")

-- TODO: turn this back on: disable macros
vim.keymap.set({ 'n', 'v' }, 'q', '<nop>', { noremap = true })

-- visual block up/down movement
vim.keymap.set('v', '<C-j>', ":m '>+1<CR>gv=gv", { noremap = true })
vim.keymap.set('v', '<C-k>', ":m '<-2<CR>gv=gv", { noremap = true })

-- next/previous search item, but redraw the screen
vim.keymap.set('n', 'n', 'nzz', { noremap = true })
vim.keymap.set('n', 'N', 'Nzz', { noremap = true })

-- quickly adjust between 2 and 4 space indents
vim.keymap.set({ 'n', 'v' }, '<leader>t2', ':setlocal ts=2 sw=2 sts=2<CR>', { noremap = true })
vim.keymap.set({ 'n', 'v' }, '<leader>t4', ':setlocal ts=4 sw=4 sts=4<CR>', { noremap = true })

-- utility: capitalize and center
-- vim.api.nvim_create_user_command(
--   'CommentTitle',
--   function()
--   end
-- )

-- TODO: fixme so it works with any language?
vim.cmd [[nn <leader>C :center 80<cr>0v1lr-<esc>40A-<esc>d80<bar>hhvbr<space><esc>yyppVr-kk.]]
-- vim.keymap.set(
--   'n',
--   '<leader>C',
--   function()
--     nn <leader>C :center 80<cr>VU<esc>0v1lr-<esc>40A-<esc>d80<bar>hhvbr<space><esc>yyppVr-kk.
--   end,
--   { noremap = true, desc = 'create a comment title block' }
-- )
