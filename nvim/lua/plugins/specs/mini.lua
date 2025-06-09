--------------------------------------------------------------------------------
--                      echasnovski/mini.nvim COMPONENTS                      --
--------------------------------------------------------------------------------

return {
  -- neovim replacements for tpope/vim-commentary and tpope/vim-surround
  {
    'echasnovski/mini.comment',
    version = '*',
    opts = {
      mappings = {
        comment_line = '<leader>c',
        comment_visual = '<leader>c',
      },
    },
  },
  { 'echasnovski/mini.surround',  version = '*' },

  -- useful operations: evaluate, exchange, multiply, replace, sort
  { 'echasnovski/mini.operators', version = '*' },

  -- auto pair up parens, brackets, quotes
  { 'echasnovski/mini.pairs',     version = '*' },

  -- work with diff hunks
  {
    'echasnovski/mini.diff',
    version = '*',
    config = function()
      local diff = require('mini.diff')
      diff.setup({
        source = diff.gen_source.none(),
        view = {
          style = 'sign',
        },
        delay = {
          text_change = 100,
        },
        mappings = {
          apply = 'ga',
          reset = 'gr',
        }
      })
    end
  },

  -- picker
  -- { 'echasnovski/mini.pick',  version = '*' },

  -- notifications
  {
    'echasnovski/mini.notify',
    version = '*',
    opts = {
      lsp_progress = {
        enable = false,
      },
      window = {
        -- config = {
        --   width = 79,
        --   border = 'none',
        -- },
        config = function()
          return {
            anchor = 'NE',
            col = vim.o.columns - 1,
            row = 0,
            focusable = false,
            zindex = 999,
            style = 'minimal',
            border = 'none',
          }
        end,
        winblend = 0,
      },
    }
  },

  -- extra batteries: mini.pick and mini.hipatters
  { 'echasnovski/mini.extra', version = '*' },

  -- misc utils
  { 'echasnovski/mini.misc',  version = '*' },

  -- other options
  -- mini.splitjoin: better ergonomics for joining or splitting things like func args
  -- mini.visits: track files opened/closed in the current session, quickly pick them
}
