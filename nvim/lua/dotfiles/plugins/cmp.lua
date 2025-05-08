-- nvim-cmp
local health = require('dotfiles.health')

local ok, cmp = pcall(require, 'cmp')
if not ok then
  health.issue(vim.log.levels.WARN, 'Unable to load and setup plugin "cmp":\n' .. cmp)
  return
end

local cmp_window = {
  border = { '╒', '═', '╕', '│', '╛', '═', '╘', '│' },
  col_offset = 0,
  scrollbar = true,
  scrolloff = 0,
  side_padding = 1,
  winhighlight = 'Normal:Normal,FloatBorder:FloatBorder,CursorLine:Visual,Search:None',
  zindex = 1001,
  max_width = 79
}

local cmp_kind_icons = {
  Constant = '∁',
  Variable = 'χ',
  Function = '⨍',
  Interface = '⮻',
  Method = '⨍',
  Class = '⮻',
  Field = '∈',

  ['arrow_function'] = '⨍>',
  parameter = '->',
  associated = '🔗',
  namespace = '§',
  type = '⮻',
  field = 'arg:',
  module = '▣',
  flag = '⚑',
  declaration = '⨍',
}

cmp.setup({
  -- disabled for everything except whitelisted filetypes
  enabled = false,
  performance = {
    max_view_entries = 25
  },
  -- don't guess at which option to select
  preselect = cmp.PreselectMode.None,
  snippet = {
    expand = function(args)
      -- snippet expand is required, but don't do anything
      vim.fn['UltiSnips#Anon'](args.body)
    end,
  },
  window = {
    completion = cmp_window,
    documentation = cmp_window,
  },
  view = {
    docs = {
      auto_open = true
    }
  },
  experimental = {
    ghost_text = true
  },
  completion = {
    -- only when i ask for it
    autocomplete = false
  },
  formatting = {
    expandable_indicator = true,
    --   -- fields = [] ItemField
    format = function(entry, item)
      item.kind = cmp_kind_icons[item.kind] or item.kind
      return item
    end
  },
  mapping = cmp.mapping.preset.insert({
    ['<Tab>'] = cmp.mapping.select_next_item(),
    ['<S-Tab>'] = cmp.mapping.select_prev_item(),
    ['<C-b>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),            -- <M-M> <C-CR> are the same
    ['<C-e>'] = cmp.mapping.abort(),
    ['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
  }),
  -- SourceConfig
  sources = cmp.config.sources(
  -- group 1: lsp
    {
      -- lsp results are always preferred over snippets
      {
        name = 'nvim_lsp',
        entry_filter = function(entry, ctx)
          local kind = require('cmp.types').lsp.CompletionItemKind[entry:get_kind()]
          return kind ~= 'Text' and kind ~= 'Keyword'
        end
      },
      { name = 'ultisnips' }
    },

    -- group 2: less important (or questionaly useful ones)
    {
      {
        name = 'path',
        option = {
          trailing_slash = true
        }
      }
    }
  ),
  sorting = {
    priority_weight = 10,
    comparators = {
      cmp.config.compare.offset,
      cmp.config.compare.exact,
      cmp.config.compare.sort_text,
      cmp.config.compare.score,
      cmp.config.compare.recently_used,
      cmp.config.compare.kind,
      cmp.config.compare.length,
      cmp.config.compare.order,
    }
  }
})

-- cmp: languages {{{
cmp.setup.filetype(
  {
    'c',
    'cpp',
    'go',
    'lua',
    'typescript',
    'javascript',
    'java'
  },
  { enabled = true }
)
-- }}}
