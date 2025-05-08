-- diffview.nvim

require('dotfiles.util').require('diffview').setup({
  hg_cmd = {},
  use_icons = false,
  icons = {
    folder_closed = '◆ ',
    folder_open = '◇ ',
  },
  signs = {
    fold_closed = '◆ ',
    fold_open = '◇ ',
  },
  view = {
    diff_tool = {
      layout = 'diff2_horizontal',
    },
    merge_tool = {
      layout = 'diff4_mixed',
    },
  },
  default_args = {
    DiffviewOpen = { '-uno' },
  },
})
