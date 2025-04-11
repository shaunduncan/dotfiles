-- guihua (gui library required by some things)
require('dotfiles.util').require('guihua').setup({
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
})
