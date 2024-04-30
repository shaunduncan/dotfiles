local vim = vim

-- TODO:
-- dap
-- ultisnips/luasnip
-- add to git

-- dap {{{
-- local dap = require("dap")
-- require("dap-go").setup()
-- }}}

-- glow {{{
require('glow').setup({
  height_ratio = 0.85,
})
-- }}}

-- shade {{{
-- require('shade').setup()
-- }}}

-- guilua {{{
require('guihua').setup({
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
      var = '𝒳 ',
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
})
-- }}}

-- venn.nvim (diagramming) {{{
local actions = require('diffview.actions')
require('diffview').setup({
  icons = {
    folder_closed = '◆ ',
    folder_open = '◇ ',
  },
  signs = {
    fold_closed = '◆ ',
    fold_open = '◇ ',
  },
  view = {
    merge_tool = {
      layout = 'diff3_mixed',
    },
  },
})
-- }}}

-- venn.nvim (diagramming) {{{
function _G.Toggle_venn()
  local venn_enabled = vim.inspect(vim.b.venn_enabled)

  if venn_enabled == "nil" then
    vim.b.venn_enabled = true
    vim.cmd[[setlocal ve=all]]

    -- draw a line on HJKL keystokes
    vim.api.nvim_buf_set_keymap(0, "n", "J", "<C-v>j:VBox<CR>", {noremap = true})
    vim.api.nvim_buf_set_keymap(0, "n", "K", "<C-v>k:VBox<CR>", {noremap = true})
    vim.api.nvim_buf_set_keymap(0, "n", "L", "<C-v>l:VBox<CR>", {noremap = true})
    vim.api.nvim_buf_set_keymap(0, "n", "H", "<C-v>h:VBox<CR>", {noremap = true})

    -- draw a box by pressing "b" with visual selection
    vim.api.nvim_buf_set_keymap(0, "v", "b", ":VBox<CR>", {noremap = true})
  else
    vim.cmd[[setlocal ve=]]
    vim.cmd[[mapclear <buffer>]]
    vim.b.venn_enabled = nil
  end
end

vim.api.nvim_set_keymap('n', '<leader>V', ":lua Toggle_venn()<CR>", { noremap = true})
-- }}}

-- lualine {{{
local mode_colors = {
  normal = {
    a = { fg = '#3d424d', bg ='#c2d94c' },
    b = { fg = '#c2d94c', bg ='#304357' },
    c = { fg = '#b3b1ad', bg ='#0a0e14' },
  },
  insert = {
    a = { fg = '#3d424d', bg ='#39bae6' },
    b = { fg = '#39bae6', bg ='#304357' },
    c = { fg = '#b3b1ad', bg ='#0a0e14' },
  },
  visual = {
    a = { fg = '#3d424d', bg ='#ff8f40' },
    b = { fg = '#ff8f40', bg ='#304357' },
    c = { fg = '#b3b1ad', bg ='#0a0e14' },
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
    [''] = 'V-B',
    ['s']  = 'S',
    ['S']  = 'S-L',
    [''] = 'S-B',
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
    component_separators = { left = '|', right = '|'},
    section_separators = { left = '', right = ''},
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
    lualine_x = {'filetype'},
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
-- }}}

-- treesitter {{{

-- incremental_selection indent
require('nvim-treesitter.configs').setup({
  ensure_installed = {
    'c',
    'cpp',
    'go',
    'gomod',
    'gosum',
    'gowork',
    'java',
    'javascript',
    'lua',
    'make',
    'markdown',
    'markdown_inline',
    'proto',
    'python',
    'terraform',
    'vimdoc',
    'vim',
    'yaml',
  },

  highlight = {
    enable = false,
  },

  indent = {
    enable = true,
    disable = { 'yaml' },
  },

  incremental_selection = {
    enable = true,
    keymaps = {
      init_selection = "gnn",
      node_incremental = "grn",
      scope_incremental = "grc",
      node_decremental = "grm",
    },
  },

  textobjects = {
    enable = true,
    -- lsp_interop = {
    --   enable = true,
    --   peek_definition_code = {
    --     ['DF'] = '@function.outer',
    --     ['DF'] = '@class.outer',
    --   },
    -- },

    select = {
      enable = true,
      lookahead = true,
      keymaps = {
        ['aa'] = '@parameter.outer',
        ['ia'] = '@parameter.inner',
        ['af'] = '@function.outer',
        ['if'] = '@function.inner',
        ['ac'] = '@class.outer',
        ['ic'] = '@class.inner',
      },
    },

    move = {
      enable = true,
      set_jumps = true,
      goto_next_start = {
        [']]'] = '@function.outer',
        [']m'] = '@class.outer',
      },
      goto_next_end = {
        [']['] = '@function.outer',
        [']M'] = '@class.outer',
      },
      goto_previous_start = {
        ['[['] = '@function.outer',
        ['[m'] = '@class.outer',
      },
      goto_previous_end = {
        ['[]'] = '@function.outer',
        ['[M'] = '@class.outer',
      }
    },

    swap = {
      enable = true,
      swap_next = {
        ['<leader>a'] = '@parameter.inner',
      },
      swap_previous = {
        ['<leader>A'] = '@parameter.inner',
      },
    },

    keymaps = {
      ['af'] = '@function.outer',
      ['if'] = '@function.inner',
      ['aC'] = '@class.outer',
      ['iC'] = '@class.inner',
      ['ac'] = '@conditional.outer',
      ['ic'] = '@conditional.inner',
      ['ae'] = '@block.outer',
      ['ie'] = '@block.inner',
      ['al'] = '@loop.outer',
      ['il'] = '@loop.inner',
      ['is'] = '@statement.inner',
      ['as'] = '@statement.outer',
      ['ad'] = '@comment.outer',
      ['am'] = '@call.outer',
      ['im'] = '@call.inner',
    },
  },
})

-- }}}
