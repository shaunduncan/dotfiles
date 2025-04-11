--------------------------------------------------------------------------------
--                                    LSP                                     --
--------------------------------------------------------------------------------


return {
  -- lsp management
  -- {
  --   'williamboman/mason.nvim',
  --   opts = {
  --     ui = {
  --       border = 'single',
  --       icons = {
  --         package_installed = '✓',
  --         package_pending = '➜',
  --         package_uninstalled = '✗'
  --       }
  --     }
  --   },
  -- },
  {
    'gfanto/fzf-lsp.nvim',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'junegunn/fzf.vim',
    },
    init = function()
      vim.g.fzf_lsp_layout = {
        window = { width = 0.7, height = 0.7, border = 'sharp' },
      }
      vim.g.fzf_lsp_preview_window = { 'up,60%,border-sharp', 'ctrl-/' }
    end,
  },
  {
    'neovim/nvim-lspconfig',
    dependencies = {
      'williamboman/mason.nvim',
      'hrsh7th/cmp-nvim-lsp',
      'gfanto/fzf-lsp.nvim',
    },
    config = function()
      require('mason').setup({
        ui = {
          border = 'single',
          icons = {
            package_installed = '✓',
            package_pending = '➜',
            package_uninstalled = '✗'
          }
        }
      })

      local lspconfig = require('lspconfig')
      local utils = require('plugins.utils.lsp')

      local default_caps = require('cmp_nvim_lsp').default_capabilities()

      local default_cfg = {
        capabilities = default_caps,
        on_attach = utils.on_attach,
      }

      -- simple servers requiring no extra configuration
      local std_servers = {
        'bashls',
        'dockerls',
        'rust_analyzer',
        'sqlls',
        'starlark_rust',

        -- protobuf
        'buf_ls',

        -- java
        'jdtls',

        -- python
        'jedi_language_server',

        -- terraform
        'terraformls',
        'tflint',

        -- typescript
        'ts_ls',
      }

      for _, server in ipairs(std_servers) do
        lspconfig[server].setup(default_cfg)
      end

      lspconfig.gopls.setup({
        capabilities = default_caps,
        cmd = { 'gopls', '-remote=auto' },
        on_attach = utils.on_go_attach,
        settings = {
          gopls = {
            buildFlags = { '-tags=smartdns,pcap,kafka,osusergo' },
            analyses = {
              slog = false,
              unusedparams = false,
              unusedvariable = true,
              useany = true,

              -- staticcheck
              -- stdlib misuse
              SA1002 = true, -- invalid time.Parse() format
              SA1004 = true, -- suspisciously small time.Sleep()
              SA1006 = true, -- printf without args
              SA1014 = true, -- non-pointer for unmarshal/decode
              SA1015 = true, -- using leaky time.Tick
              SA1019 = true, -- using deprecated things
              SA1023 = true, -- io.Writer impl that modifies buffer
              SA1027 = true, -- atomic access to 64bit var must be 64bit aligned
              SA1029 = true, -- inappropriate WithValue key
              SA1030 = true, -- invalid strconv arg

              -- concurrency issues
              SA2000 = true, -- WaitGroup.Add inside a goroutine
              SA2002 = true, -- can't FailNow/SkipNow in goroutine
              SA2003 = true, -- deferred Lock after Lock

              -- code not doing anything
              SA4000 = true, -- binary operator identical on both sides
              SA4001 = true, -- &*x does not copy x
              SA4003 = true, -- comparing unsigned against negatives
              SA4004 = true, -- loop exit after one iteration
              SA4005 = true, -- field assignment on non-pointer receiver
              SA4006 = true, -- value assigned changed before read
              SA4008 = true, -- loop condition var never changes
              SA4009 = true, -- func arg overwritten before use
              SA4010 = true, -- append() result never observed
              SA4011 = true, -- using break with no effect
              SA4014 = true, -- repetitive if/else if
              SA4015 = true, -- math.Ceil() called for floats created from ints
              SA4016 = true, -- useless bitwise operator
              SA4017 = true, -- func call with discarded result does nothing
              SA4018 = true, -- self assignment of vars
              SA4019 = true, -- identical build constraints in same file
              SA4020 = true, -- unreachable case in type switch
              SA4022 = true, -- comparing var address to nil
              SA4023 = true, -- impossible comparison of iface value with untyped nil
              SA4024 = true, -- checking impossible return value from builtin
              SA4025 = true, -- integer division that results in 0
              SA4029 = true, -- ineffective slice sort
              SA4030 = true, -- ineffective rand generation
              SA4031 = true, -- checking never-nil value against nil

              -- correctness issues
              SA5000 = true, -- assignment to nil map
              SA5001 = true, -- defer Close before err check
              SA5003 = true, -- defer in infinite loop never runs
              SA5004 = true, -- for { select { with empty default spins
              SA5005 = true, -- finalizer references finalized obj, prevents GC
              SA5007 = true, -- infinite recursive call
              SA5008 = true, -- invalid struct tag
              SA5009 = true, -- invalid printf
              SA5010 = true, -- impossible type assertion
              SA5011 = true, -- possible nil pointer deref
              SA5012 = true, -- odd-sized slice given to func expecting even

              -- perf issues
              SA6000 = true, -- regexp.Match in a loop, use regexp.Compile
              SA6001 = true, -- optimization opportunity indexing maps by byte slices
              SA6002 = true, -- using non-pointer values with sync.Pool (leaky)
              SA6003 = true, -- converting string to rune slice before range
              SA6005 = true, -- inefficient strings.ToLower/ToUpper comparison

              -- dubious (and probably wrong) things
              SA9001 = true, -- defer in loop may not run when you expect
              SA9002 = true, -- non-octal os.FileMode
              SA9003 = true, -- empty if/else
              SA9004 = true, -- only first constant has type
              SA9005 = true, -- marshalling struct without public fields or custom marshalling
              SA9006 = true, -- dubious bit shift of fixed size int
              SA9007 = true, -- deleting dir that shouldn't be deleted
              SA9008 = true, -- type assertion else is probably reading wrong value

              -- simplifications
              S1001 = true, -- use copy instead of for loop
              S1003 = true, -- use strings.Contains vs .Index
              S1004 = true, -- use bytes.Equal vs .Compare
              S1005 = true, -- unnecessary blank identifier
              S1009 = true, -- omit redundant nil check on slices
              S1010 = true, -- omit default slice index
              S1011 = true, -- single append to concat slices
              S1012 = true, -- time.Since not time.Now().Sub
              S1016 = true, -- use type conversion vs copying struct fields
              S1017 = true, -- use strings.TrimPrefix vs manual trim
              S1018 = true, -- use copy() for sliding elements
              S1019 = true, -- omit redundant args to make()
              S1020 = true, -- omit redundant nil check in type assertion
              S1023 = true, -- omit redundant control flow
              S1024 = true, -- use time.Until not x.Sub(time.Now())
              S1025 = true, -- don't fmt.Sprintf("%s", x)
              S1030 = true, -- use bytes.Buffer.String/Bytes
              S1031 = true, -- omit redundant nil check around loop
              S1032 = true, -- use sort.{Ints,Float64s,Strings}
              S1033 = true, -- unnecessary guard around delete()
              S1034 = true, -- redundant call to CanonicalHeaderKey
              S1036 = true, -- unnecessary guard for map access
              S1037 = true, -- elaborate sleep
              S1038 = true, -- complicated string printing
              S1039 = true, -- unnecessary fmt.Sprint

              -- style
              ST1013 = true, -- use constants for http return code
              ST1016 = true, -- use consistent method receiver names
              ST1017 = true, -- no yoda comparisons (like C)
              ST1023 = true, -- redundant type in var decl

              -- quickfix
              QF1003 = true, -- convert if/else to switch
              QF1006 = true, -- use loop cond not if/break
              QF1009 = true, -- use time.Time.Equal not ==
              QF1011 = true, -- omit redundant type in var decl
              QF1012 = true, -- use fmt.Fprintf(x) not x.Write(fmt.Sprintf(...))
            },
            codelenses = {
              generate = true,
              gc_details = false,
              test = true,
              tidy = true,
              vendor = true,
              regenerate_cgo = true,
              upgrade_dependency = true,
            },
          },
        },
        before_init = function(_, cfg)
          cfg.settings.gopls['formatting.local'] = utils.get_current_gomod()
        end,
      })

      -- clangd
      local nproc = string.gsub(vim.fn.system('nproc'), '\n', '')
      local clangd_caps = vim.tbl_deep_extend(
        'force', vim.deepcopy(default_caps), { offsetEncoding = { 'utf-16' } }
      )

      lspconfig.clangd.setup({
        filetypes = { 'c', 'cpp' },
        capabilities = clangd_caps,
        on_attach = utils.on_attach,
        cmd = {
          'clangd',
          '--background-index',
          '--background-index-priority=normal',
          '--clang-tidy',
          '--header-insertion-decorators',
          '--header-insertion=never', -- or iwyu for auto insert
          '--import-insertions',
          '--completion-style=detailed',
          '--function-arg-placeholders',
          '-j', nproc,
        },
      })

      lspconfig.omnisharp.setup({
        capabilities = default_caps,
        on_attach = utils.on_attach,

        -- FIXME: apparently this is in neovim core via vim.fs.root()
        root_dir = function(fname)
          local sln = lspconfig.util.root_pattern('*.sln')(fname)
          local csproj = lspconfig.util.root_pattern('*.csproj')(fname)
          return sln or csproj
        end,

        settings = {
          MsBuild = {
            LoadProjectsOnDemand = true
          },
          Sdk = {
            IncludePrereleases = false
          }
        }
      })

      lspconfig.lua_ls.setup({
        capabilities = default_caps,
        on_attach = utils.on_attach,
        settings = {
          Lua = {
            runtime = {
              version = 'LuaJIT'
            },
            format = {
              enable = true,

              -- NOTE: all of these values have to be strings
              defaultConfig = {
                -- general
                indent_style = 'space',
                indent_size = '2',
                quote_style = 'single',
                call_arg_parentheses = 'keep',
                insert_final_newline = 'true',

                -- whitespace
                space_around_table_field_list = 'true',
                space_before_attribute = 'true',

                -- alignment
                align_call_args = 'true',
                align_function_params = 'true',
                -- align_continuous_assign_statement
                align_continuous_rect_table_field = 'true',
                align_if_branch = 'false',
                -- align_array_table
              },
            },
            diagnostics = {
              globals = {
                'vim'
              },
            },
            workspace = {
              checkThirdParty = false,
              library = {
                vim.env.VIMRUNTIME
              }
            }
          }
        }
      })

      -- other setup setup tasks
      utils.configure_autoformat()
      utils.configure_diagnostics()

      -- NOTE: ARE THE ITEMS BELOW NECESSARY

      -- set all the signs to a solid block
      local sign_icon = '█'
      local signs = { Error = sign_icon, Warn = sign_icon, Hint = sign_icon, Info = sign_icon }
      for type, icon in pairs(signs) do
        local hl = 'DiagnosticSign' .. type
        vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
      end

      -- trick airline into using native lsp
      vim.api.nvim_create_user_command('LspDeclaration', 'echo "nope"', {})

      -- general lsp keybinds
      vim.keymap.set('n', 'd]', vim.diagnostic.goto_next, { desc = 'LSP: Next Diagnostic' })
      vim.keymap.set('n', 'd[', vim.diagnostic.goto_prev, { desc = 'LSP: Prev Diagnostic' })
    end,
  },
}
