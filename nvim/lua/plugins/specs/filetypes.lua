--------------------------------------------------------------------------------
--                       FILETYPE PLUGINS/ENHANCEMENTS                        --
--------------------------------------------------------------------------------

return {
  -- enhanced markdown experience
  {
    'MeanderingProgrammer/render-markdown.nvim',
    dependencies = {
      'nvim-treesitter/nvim-treesitter',
    },
    config = function()
      local md = require('render-markdown')

      -- get rid of these dumb custom things that add icons to urls
      md.default.link.custom = {}

      md.setup({
        debounce = 50,
        file_types = {
          'markdown',
          'hello',
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
        checkbox = { enabled = false },
        heading = { enabled = false },
        latex = { enabled = false },
        html = { enabled = false },

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
      local aug = vim.api.nvim_create_augroup('my-markdown', { clear = true })

      vim.api.nvim_create_autocmd('FileType', {
        group = aug,
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

      -- change theme coloring
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
    end,
  },

  -- syntax support for justfile
  {
    'NoahTheDuke/vim-just',
    ft = { 'just' },
  },

  -- go: using my fork until i have a reason not to
  {
    'shaunduncan/go.nvim',
    ft = { 'go', 'gomod' },
    dependencies = {
      'ray-x/guihua.lua',
      'neovim/nvim-lspconfig',
      'nvim-treesitter/nvim-treesitter',
    },
    build = ':lua require("go.install").update_all_sync()',
    config = function()
      vim.cmd [[
        aug my-nvim-guihua | au!
          au FileType guihua nn <buffer> <silent> q <C-w>q | setlocal nofoldenable
        aug end
      ]]

      require('go').setup({
        tag_transform = false,       -- check: gomodifytags -h (can set tag casing)
        gotests_template = 'testify',
        comment_placeholder = '',
        icons = { breakpoint = 'B', currentpos = '>' },
        verbose = false,

        -- lsp settings: disable most of these and use settings i already have
        lsp_cfg = false,
        lsp_gofumpt = false,
        lsp_codelens = false,
        lsp_keymaps = false,
        lsp_fmt_async = true,
        lsp_document_formatting = true,
        lsp_inlay_hints = {
          enable = false,
          only_current_line = true,
          only_current_line_autocmd = 'CursorHold,CursorMoved',
          show_variable_name = true,
          show_parameter_hints = true,
          parameter_hints_prefix = '⨍',
          other_hints_prefix = '->',
          highlight = 'Title',
        },
        textobjects = true,

        -- use settings set by vim.diagnostic.config()
        diagnostic = false,

        -- use gopls
        gofmt = 'gopls',
        goimports = 'gopls',

        -- build tags needed for local dev work
        build_tags = 'smartdns,pcap,kafka,osusergo',

        -- DAP
        dap_debug = true,
        dap_debug_gui = true,
        dap_debug_keymap = false,

        -- running tests
        test_runner = 'gotestsum',
        verbose_tests = true,
        run_in_floaterm = true,
        floaterm = {
          autoclose = false,
          posititon = 'center',         -- one of {`top`, `bottom`, `left`, `right`, `center`, `auto`}
          width = 0.8,
          height = 0.8,
          title_colors = 'ayu',         -- table of colors for title, or a color scheme name
        },

        -- don't use luasnip
        luasnip = false,

        -- others
        disable_per_project_cfg = false,       -- projects: .gonvim/init.lua
        null_ls_document_formatting_disable = true,
      })
    end,
  },
}
