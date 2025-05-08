-- TODO:
-- ultisnips/luasnip
-- add to git

local util = require('dotfiles.util')

require('dotfiles.plugins.cmp')
require('dotfiles.plugins.codecompanion')
require('dotfiles.plugins.guihua')
require('dotfiles.plugins.lualine')
require('dotfiles.plugins.markdown')
require('dotfiles.plugins.treesitter')
require('dotfiles.plugins.venn')

require('speedscale').setup({
  configurations = {
    go = {
      {
        name = 'Decoy - Mock Only (no https)',
        description = 'Taggart + Ken, 9/5/2024',
        config_id = 'mock-only',
        additional_flags = '--service postgres=5432',
        snapshots = {
          ['${workspaceFolder}/user/main.go'] = {
            {
              nickname = "Ken's snapshot",
              snapsh_id = '6b70b3eb-5f22-4055-b230-3e4bf559a436'
            },
            {
              nickname = 'Another snapshot',
              snapshot_id = '...'
            }
          }
        }
      }
    }
  }
})
