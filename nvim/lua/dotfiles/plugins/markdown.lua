-- render-markdown
local md = require('dotfiles.util').require('render-markdown')

-- get rid of these dumb custom things that add icons to urls
md.default_config.link.custom = {}

md.setup({
  debounce = 50,
  file_types = {
    'markdown',
    'codecompanion',
    'gitcommit',
  },
  quote = {
    repeat_linebreak = true,
  },
  win_options = {
    showbreak = { default = '', rendered = '  ' },
    breakindent = { default = false, rendered = true },
    breakindentopt = { default = '', rendered = '' },
  },
  code = {
    sign = false,
    -- width = 'block',
    render_modes = true,
    left_pad = 2,
    right_pad = 2,
    language_pad = 1,
    -- position = 'right',
    -- min_width = 79,
    inline_pad = 1,
    above = '█',
    below = '█',
  },
  link = {
    footnote = {
      superscript = false,
    },
    image = '',
    email = '',
    hyperlink = '',
    wiki = {
      icon = '',
    },
  },
  bullet = {
    enabled = false,
  },
  pipe_table = {
    alignment_indicator = '',
    cell = 'trimmed',
  },

  -- don't need or want
  checkbox = { enabled = false, },
  heading = { enabled = false, },
  latex = { enabled = false, },

  -- overrides
  overrides = {
    filetype = {
      gitcommit = {
        heading = { enabled = false },
      },
    }
  },

  -- render-markdown has this default, so it may be useful in some cases where you might want markdown to be
  -- interpreted and handled. see :h treesitter-language-injections
  -- injections = {
  --     gitcommit = {
  --         enabled = true,
  --         query = [[
  --             ((message) @injection.content
  --                 (#set! injection.combined)
  --                 (#set! injection.include-children)
  --                 (#set! injection.language "markdown"))
  --         ]],
  --     },
  -- },

  -- other customizations:
  --
  -- callout = { ... } (change 'rendered' to remove any icons)
  --    > [!NOTE]
  --    > This is a note
  -- ref: https://github.com/MeanderingProgrammer/render-markdown.nvim/wiki/Callouts

  --
  -- also, it's possible to override the treesitter highlight query altogether for something like this that
  -- can split highlights for heading text and heading markers
  -- vim.treesitter.query.set(
  --   'markdown2',
  --   'highlights',
  --   [[
  --   ; inherits: markdown
  --   (atx_heading
  --     (atx_h1_marker) @markup.heading.1.marker
  --     (inline) @markup.heading.1)
  --   ]]
  -- )
})

-- things to do only for markdown
local augroup = vim.api.nvim_create_augroup('nvim-dotfiles-markdown', { clear = true })

vim.api.nvim_create_autocmd('FileType', {
  group = augroup,
  pattern = { 'markdown', 'codecompanion' },
  callback = function()
    -- quick access to toggle rendering
    vim.api.nvim_buf_set_keymap(
      0, 'n', '<leader>mt', ':RenderMarkdown toggle<CR>', { noremap = true }
    )
  end
})

-- color mappings, both for treesitter and for render-markdown
vim.api.nvim_set_hl(0, 'RenderMarkdownTableHead', { link = 'normal' })

local tscolors = {
  ['markup.heading']      = '@theme.orange',
  ['markup.heading.1']    = '@theme.lightred',
  ['markup.heading.2']    = '@theme.lightyellow',
  ['markup.heading.3']    = '@theme.lightgreen',
  ['markup.heading.4']    = '@theme.purple',
  ['markup.heading.5']    = '@theme.lightblue',
  ['markup.heading.6']    = '@theme.lightblue',
  ['markup.list']         = '@theme.lightyellow',
  ['markup.raw']          = '@theme.lightorange',
  ['markup.raw.block']    = '@markup.raw',
  ['punctuation.special'] = 'normal',
  ['markup.quote']        = 'comment',
}

for group, link_group in pairs(tscolors) do
  vim.api.nvim_set_hl(0, '@' .. group .. '.markdown', { link = link_group })
end
