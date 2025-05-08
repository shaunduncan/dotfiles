--------------------------------------------------------------------------------
--                      EDITOR QoL FEATURES/ENHANCEMENTS                      --
--------------------------------------------------------------------------------

return {
  -- replacement for vim-whichkey
  {
    'folke/which-key.nvim',
    event = 'VeryLazy',
    config = function()
      require('which-key').setup({
        delay = vim.o.timeoutlen,
        notify = false,
        win = {
          width = 0.9,
          height = { min = 4, max = 25 },
          col = 0.5,
          row = -1,
          border = 'single',
          title = true,
          title_pos = 'center',
        },
        plugins = {
          spelling = {
            enabled = false,
          },
          presets = {
            operators = false,
            motions = false,
            text_objects = false,
            windows = false,
            nav = false,
            z = false,
            g = false,
          },
        },
        icons = {
          breadcrumb = '+',
          colors = false,
          mappings = false,
          keys = {
            Space = '<Leader>',
          },
        },
      })
    end,
  },

  -- {
  --   "chrisgrieser/nvim-origami",
  --   event = "VeryLazy",
  --   opts = {}, -- needed even when using default config
  -- { 'kevinhwang91/promise-async' },
  -- {
  --   'kevinhwang91/nvim-ufo',
  --   dependences = {
  --     'kevinhwang91/promise-async',
  --   },
  --   config = function()
  --     local ufo = require('ufo')
  --
  --     ufo.setup({
  --       open_fold_hl_timeout = 0,
  --       fold_virt_text_handler = function(virtText, lnum, endLnum, width, truncate)
  --           local newVirtText = {}
  --           local totalLines = vim.api.nvim_buf_line_count(0)
  --           local foldedLines = endLnum - lnum
  --           local suffix = (' 󰦸 %d %d%%'):format(foldedLines, foldedLines / totalLines * 100)
  --           local sufWidth = vim.fn.strdisplaywidth(suffix)
  --           local targetWidth = width - sufWidth
  --           local curWidth = 0
  --           for _, chunk in ipairs(virtText) do
  --               local chunkText = chunk[1]
  --               local chunkWidth = vim.fn.strdisplaywidth(chunkText)
  --               if targetWidth > curWidth + chunkWidth then
  --                   table.insert(newVirtText, chunk)
  --               else
  --                   chunkText = truncate(chunkText, targetWidth - curWidth)
  --                   local hlGroup = chunk[2]
  --                   table.insert(newVirtText, { chunkText, hlGroup })
  --                   chunkWidth = vim.fn.strdisplaywidth(chunkText)
  --                   -- str width returned from truncate() may less than 2nd argument, need padding
  --                   if curWidth + chunkWidth < targetWidth then
  --                       suffix = suffix .. (' '):rep(targetWidth - curWidth - chunkWidth)
  --                   end
  --                   break
  --               end
  --               curWidth = curWidth + chunkWidth
  --           end
  --           local rAlignAppndx =
  --               math.max(math.min(vim.opt.textwidth['_value'], width - 1) - curWidth - sufWidth, 0)
  --           suffix = (' '):rep(rAlignAppndx) .. suffix
  --           table.insert(newVirtText, { suffix, 'MoreMsg' })
  --           return newVirtText
  --       end
  --     })
  --
  --
  --     -- optional: use treesitter config
  --     -- ufo.setup({
  --     --     provider_selector = function(bufnr, filetype, buftype)
  --     --         return {'treesitter', 'indent'}
  --     --     end
  --     -- })
  --
  --     vim.keymap.set('n', 'zR', ufo.openAllFolds, { noremap = true })
  --     vim.keymap.set('n', 'zM', ufo.closeAllFolds, { noremap = true })
  --     vim.keymap.set('n', 'zP', ufo.peekFoldedLinesUnderCursor, { noremap = true })
  --   end
  -- },

  {
    'anuvyklack/pretty-fold.nvim',
    -- see: https://github.com/anuvyklack/pretty-fold.nvim/pull/41
    commit = 'c55b86edf946765a49889c445c811db277e1ff6d',
    opts = {
      sections = {
        left = {
          'content',
        },
        right = {
          ' [', 'number_of_folded_lines', '] ',
        }
      },
      fill_char = '-',
    },
  },

  -- {
  --   "OXY2DEV/foldtext.nvim",
  --   lazy = false
  -- },

  -- ascii boxes
  {
    'jbyuki/venn.nvim',
    config = function()
      -- no setup call for this guy
      require('venn')

      local bufopts = {
        buffer = true,
        noremap = true,
      }

      -- keymap to toggle venn mode
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
            vim.cmd('setlocal ve=')
            vim.cmd('mapclear <buffer>')
            vim.b.venn_enabled = nil
          end
        end,
        {
          desc = 'Toggle Venn',
          noremap = true,
        }
      )
    end,
  },

  -- TODO: are there newer/better alternatives?
  { 'ivyl/vim-bling' },
  { 'troydm/zoomwintab.vim' },
  { 'zhimsel/vim-stay' },
  { 'mbbill/undotree' },

  {
    'junegunn/fzf',
    build = ':call fzf#install()',
  },

  {
    'junegunn/fzf.vim',
    dependencies = {
      'junegunn/fzf',
    },
    init = function()
      vim.g.fzf_action = {
        ['ctrl-v'] = 'vsplit',
        ['ctrl-x'] = 'split',
      }
      vim.g.fzf_layout = {
        window = { width = 0.7, height = 0.7, border = 'sharp' },
      }
      vim.g.fzf_vim = {
        preview_window = { 'up,60%,border-sharp', 'ctrl-/' },
        -- commits_options = '--style full:sharp --border sharp --border-label " Git Commits " --border-label-pos 3 --color dark',
      }
    end,
  },

  -- necessary with mini.clue?
  -- { 'liuchengxu/vim-which-key' },
}
