-- go related setup

local util = require('dotfiles.util')

-- setup for go/gopls
util.require('go').setup({
  tag_transform = false, -- check: gomodifytags -h (can set tag casing)
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
    posititon = 'center', -- one of {`top`, `bottom`, `left`, `right`, `center`, `auto`}
    width = 0.8,
    height = 0.8,
    title_colors = 'ayu', -- table of colors for title, or a color scheme name
  },

  -- don't use luasnip
  luasnip = false,

  -- others
  disable_per_project_cfg = false, -- projects: .gonvim/init.lua
  null_ls_document_formatting_disable = true,
})

local gofmt_group = vim.api.nvim_create_augroup('nvim-gofmt', { clear = true })

-- organize imports and format on save
vim.api.nvim_create_autocmd('BufWritePre', {
  group = gofmt_group,
  pattern = '*.go',
  callback = function()
    local wait_ms = 1000

    local params = vim.lsp.util.make_range_params()
    params.context = { only = { 'source.organizeImports' } }

    local result = vim.lsp.buf_request_sync(0, 'textDocument/codeAction', params, wait_ms)

    for _, res in pairs(result or {}) do
      for _, r in pairs(res.result or {}) do
        if r.edit then
          vim.lsp.util.apply_workspace_edit(r.edit, 'utf-8')
        else
          vim.lsp.buf.execute_command(r.command)
        end
      end
    end

    vim.lsp.buf.format()
  end
})

local on_attach = function(client, bufnr)
  -- first get the defaults
  require('dotfiles.lsp.util').on_attach(client, bufnr)

  local function mapkey(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end
  local opts = { noremap = true, silent = true }

  -- more explicit options provided by the plugin
  -- FIXME: GoImpl needs to be wrapped to automatically do something like
  -- `:GoImpl m *MyStruct SomeInterface`
  mapkey('n', '<leader>g?', ':GoDoc<CR>', opts)
  mapkey('n', '<leader>gI', ':GoImpl<CR>', opts)

  -- opening tests
  mapkey('n', '<leader>gA', ':GoAlt<CR>', opts)
  mapkey('n', '<leader>gav', ':GoAltV<CR>', opts)
  mapkey('n', '<leader>gas', ':GoAltS<CR>', opts)
  mapkey('n', '<leader>gat', ':GoAddTest<CR>', opts)

  -- running tests
  local argstr = ' -a -test.timeout=60s<CR>'

  -- mapkey('n', '<leader>gt', ':GoTestFunc' .. argstr, opts)
  mapkey('n', '<leader>gT', ':GoTestSum -f testname<CR>', opts)
  mapkey('n', '<leader>gtv', ':GoTest -v' .. argstr, opts)
  mapkey('n', '<leader>gtf', ':GoTestFunc' .. argstr, opts)
  mapkey('n', '<leader>gtF', ':GoTestFile' .. argstr, opts)
  mapkey('n', '<leader>gtp', ':GoTestPkg' .. argstr, opts)

  mapkey('n', '<leader>gie', ':GoIfErr<CR>', opts)
  mapkey('n', '<leader>gta', ':GoAddTag<SPACE>', opts)
  mapkey('n', '<leader>gtr', ':GoRmTag<SPACE>', opts)
  mapkey('n', '<leader>gti', ':GoToggleInlay<CR>', opts)
  -- mapkey('n', '<leader>gl', ':GoCodeLenAct<CR>', opts)
end

local lsp_capabilities = vim.lsp.protocol.make_client_capabilities()

local get_current_gomod = function()
  local gomod = vim.fn.system { 'go', 'env', 'GOMOD' }

  if gomod == '/dev/null' then
    return nil
  end

  local file = io.open(gomod, 'r')
  if file == nil then
    return nil
  end

  local first_line = file:read()
  local mod_name = first_line:gsub('module ', '')
  file:close()
  return mod_name
end


-- required modules
util.require('lspconfig').gopls.setup({
  cmd = { 'gopls', '-remote=auto' },
  capabilities = lsp_capabilities,
  on_attach = on_attach,
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
      ['local'] = get_current_gomod(),
    },
  },
})
