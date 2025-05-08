-- venn.nvim (diagramming)
require('dotfiles.util').require('venn')

local bufopts = {
  buffer = true,
  noremap = true,
}

vim.keymap.set(
  'n', '<leader>V',
  function()
    if not vim.b.venn_enabled then
      vim.b.venn_enabled = true
      vim.cmd('setlocal ve=all')

      -- draw a line on HJKL keystokes
      vim.keymap.set('n', 'J', '<C-v>j:VBox<CR>', bufopts)
      vim.keymap.set('n', 'K', '<C-v>k:VBox<CR>', bufopts)
      vim.keymap.set('n', 'L', '<C-v>l:VBox<CR>', bufopts)
      vim.keymap.set('n', 'H', '<C-v>h:VBox<CR>', bufopts)

      -- draw a box by pressing "b" with visual selection
      vim.keymap.set('v', 'b', ':VBox<CR>', bufopts)
    else
      print('enabled')
      vim.cmd('setlocal ve=')
      vim.cmd('mapclear <buffer>')
      vim.b.venn_enabled = nil
    end
  end,
  { noremap = true }
)
