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

      -- no underlines
      vim.cmd.hi('StatusLineNC gui=NONE cterm=NONE')

      -- set colors
      local black = '#' .. string.format('%06x', vim.api.nvim_get_hl(0, { name = 'SrceryHardBlack', link = false }).fg)
      local white = '#' .. string.format('%06x', vim.api.nvim_get_hl(0, { name = 'SrceryBrightWhite', link = false }).fg)

      vim.cmd.hi('StatusLineNC guifg=' .. white .. ' guibg=' .. black)
      vim.cmd.hi('StatusLine guifg=' .. white .. ' guibg=' .. black)

      -- color overrides
      local theme = {
        blue        = { fg = vim.g.srcery_blue or '#36a3d9' },
        cyan        = { fg = vim.g.srcery_cyan or '#95e6cb' },
        green       = { fg = vim.g.srcery_green or '#aad94c' },
        lightblue   = { fg = vim.g.srcery_bright_blue or '#8fbcbb' },
        lightgreen  = { fg = vim.g.srcery_bright_green or '#b8cc52' },
        lightred    = { fg = vim.g.srcery_bright_red or '#db4b4b' },
        lightyellow = { fg = vim.g.srcery_bright_yellow or '#ebcb8b' },
        lightorange = { fg = vim.g.srcery_bright_orange or '#ffefd5' },
        magenta     = { fg = vim.g.srcery_magenta or '#e799ff' },
        orange      = { fg = vim.g.srcery_orange or '#ffb454' },
        purple      = { fg = vim.g.srcery_bright_magenta or '#b48ead' },
        red         = { fg = vim.g.srcery_red or '#ff3333' },
        white       = { fg = '#ffffff' },
        yellow      = { fg = vim.g.srcery_yellow or '#ffee99' },
      }

      for name, opts in pairs(theme) do
        vim.api.nvim_set_hl(0, '@theme.' .. name, opts)
      end

      vim.api.nvim_set_hl(0, 'DiagnosticError', { link = '@theme.red' })
      vim.api.nvim_set_hl(0, 'DiagnosticOk', { link = '@theme.green' })
      vim.api.nvim_set_hl(0, 'DiagnosticInfo', { link = '@theme.blue' })
      vim.api.nvim_set_hl(0, 'DiagnosticWarn', { link = '@theme.orange' })
      vim.api.nvim_set_hl(0, 'DiagnosticHint', { link = '@theme.purple' })

      vim.api.nvim_set_hl(0, 'Visual', { bg = vim.g.srcery_xgray3 or '#253340' })
      vim.api.nvim_set_hl(0, 'ColorColumn', { bg = vim.g.srcery_hard_black or '#151a1e' })

      vim.api.nvim_set_hl(0, 'Search', { fg = '#000000', bg = vim.g.srcery_bright_yellow or '#ebcb8b' })
    end
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
    dependencies = {
      'srcery-colors/srcery-vim',
    },
    config = function()
      -- default colors
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

      -- if srcery is enabled, use those colors
      if next(vim.api.nvim_get_hl(0, { name = 'SrceryRed' })) ~= nil then
        -- shorthand
        local function hl(name)
          return vim.api.nvim_get_hl(0, { name = name, link = false }).fg
        end

        local function hexrgb(val)
          return '#' .. string.format('%06x', val)
        end

        local colors = {
          black = hexrgb(hl('SrceryHardBlack')),
          blue = hexrgb(hl('SrceryBrightBlue')),
          darkgray = hexrgb(hl('SrceryBlack')),
          gray = hexrgb(hl('SrceryXgray2')),
          green = hexrgb(hl('SrceryGreen')),
          lightgray = hexrgb(hl('SrceryXgray6')),
          magenta = hexrgb(hl('SrceryBrightMagenta')),
          orange = hexrgb(hl('SrceryBrightOrange')),
          red = hexrgb(hl('SrceryBrightRed')),
          white = hexrgb(hl('SrceryBrightWhite')),
        }

        mode_colors.normal = {
          a = { fg = colors.black, bg = colors.green },
          b = { fg = colors.green, bg = colors.gray },
          c = { fg = colors.white, bg = colors.black },
        }
        mode_colors.insert = {
          a = { fg = colors.black, bg = colors.blue },
          b = { fg = colors.blue, bg = colors.gray },
          c = { fg = colors.white, bg = colors.black },
        }
        mode_colors.visual = {
          a = { fg = colors.black, bg = colors.orange },
          b = { fg = colors.orange, bg = colors.gray },
          c = { fg = colors.white, bg = colors.black },
        }
        mode_colors.replace = {
          a = { fg = colors.black, bg = colors.red },
          b = { fg = colors.red, bg = colors.black },
          c = { fg = colors.white, bg = colors.black },
        }
      end

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
            statusline = 100,
            tabline = 100,
            winbar = 100,
          }
        },
        sections = {
          lualine_a = {
            { modestr },
          },
          lualine_b = {
            { 'branch', icon = '⎇ ' },
          },
          lualine_c = {
            { 'filename', path = 1 },
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
            { 'filename', path = 1 },
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
