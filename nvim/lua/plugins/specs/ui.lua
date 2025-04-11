--------------------------------------------------------------------------------
--                                 UI ADDONS                                  --
--------------------------------------------------------------------------------

return {
  {
    'srcery-colors/srcery-vim',
    init = function()
      vim.g.srcery_italic = 0
      vim.g.srcery_inverse = 0
      vim.g.srcery_inverse_matches = 0
      vim.g.srcery_bg_passthrough = 1
    end,
    config = function()
      vim.cmd.colorscheme('srcery')

      -- custom
      vim.cmd [[
        hi! link Title SrceryYellowBold
        hi! link Added SrceryGreen
        hi! link Removed SrceryRed
        hi! link DiagnosticOK SrceryBrightGreen
        hi! link DiagnosticHint SrceryBrightCyan
        hi! link Directory SrceryBrightOrange
      ]]
    end,
    lazy = false,
  },

  {
    'ray-x/guihua.lua',
    opts = {
      icons = {
        panel = {
          section_separator = '─',
          line_num_left = ':',
          line_num_right = '',

          range_left = '«',
          range_right = '»',
          inner_node = '',
          folded = '+',
          unfolded = '-',

          outer_node = '',
          bracket_left = '',
          bracket_right = '',
        },
        syntax = {
          var = '∈',
          method = '  ⨍',
          ['function'] = '⨍',
          ['arrow_function'] = '⨍>',
          parameter = '->',
          associated = '🔗',
          namespace = '§',
          type = '⮻',
          field = 'arg:',
          interface = '⮻',
          module = '▣',
          flag = '⚑',
          declaration = '⨍',
        },
      },
    }
  },

  {
    'nvim-lualine/lualine.nvim',
    config = function()
      local mode_colors = {
        normal = {
          a = { fg = '#3d424d', bg = '#c2d94c' },
          b = { fg = '#c2d94c', bg = '#304357' },
          c = { fg = '#cccccc', bg = '#202020' },
        },
        insert = {
          a = { fg = '#3d424d', bg = '#39bae6' },
          b = { fg = '#39bae6', bg = '#304357' },
          c = { fg = '#cccccc', bg = '#202020' },
        },
        visual = {
          a = { fg = '#3d424d', bg = '#ff8f40' },
          b = { fg = '#ff8f40', bg = '#304357' },
          c = { fg = '#cccccc', bg = '#202020' },
        },
        replace = {
          a = { fg = '#3d424d', bg = '#ff3333' },
          b = { fg = '#3d424d', bg = '#ff3333' },
          c = { fg = '#3d424d', bg = '#ff3333' },
        },
      }

      -- reverse them for x, y, and z
      for _, colors in pairs(mode_colors) do
        colors.x = colors.c
        colors.y = colors.b
        colors.z = colors.a
      end

      local function modestr()
        local mode_map = {
          ['__'] = '--',
          ['n']  = 'N',
          ['i']  = 'I',
          ['R']  = 'R',
          ['c']  = 'C',
          ['v']  = 'V',
          ['V']  = 'V-L',
          ['']  = 'V-B',
          ['s']  = 'S',
          ['S']  = 'S-L',
          ['']  = 'S-B',
          ['t']  = 'T',
          ['r']  = 'P',
          ['rm'] = 'P-M',
        }
        return mode_map[vim.fn.mode()]
      end

      local function locationstr()
        return string.format(
          '%d/%d:%d',
          vim.fn.line('.'),
          vim.fn.line('$'),
          vim.fn.virtcol('.')
        )
      end

      require('lualine').setup({
        options = {
          icons_enabled = true,
          theme = mode_colors,
          component_separators = { left = '|', right = '|' },
          section_separators = { left = '', right = '' },
          disabled_filetypes = {
            statusline = {},
            winbar = {},
          },
          ignore_focus = {},
          always_divide_middle = true,
          globalstatus = false,
          refresh = {
            statusline = 1000,
            tabline = 1000,
            winbar = 1000,
          }
        },
        sections = {
          lualine_a = {
            { modestr },
          },
          lualine_b = {
            {
              'branch',
              icon = '⎇ ',
            },
          },
          lualine_c = {
            {
              'filename',
              path = 1,
            },
          },
          lualine_x = { 'filetype' },
          lualine_y = {
            {
              'searchcount',
              fmt = function(str)
                if str == '' then
                  return ''
                else
                  return string.format('/%s%s', vim.fn.getreg('/'), str)
                end
              end,
            },
          },
          lualine_z = {
            { locationstr },
          },
        },
        inactive_sections = {
          lualine_a = {},
          lualine_b = {},
          lualine_c = {
            {
              'filename',
              path = 1,
            },
          },
          lualine_x = {
            { locationstr },
          },
          lualine_y = {},
          lualine_z = {},
        },
        tabline = {},
        winbar = {},
        inactive_winbar = {},
        extensions = {}
      })
    end
  },

  -- evaluate: possible utility for doing custom stuff
  -- { 'MunifTanjim/nui.nvim' }
}
