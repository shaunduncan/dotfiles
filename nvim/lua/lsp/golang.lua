local vim = vim
local utils = require('lsp.utils')

-- setup for go/gopls
require('go').setup({
  tag_transform = false, -- check: gomodifytags -h (can set tag casing)
  test_template = '', -- default to testify if not set; g:go_nvim_tests_template  check gotests for details
  test_template_dir = '', -- default to nil if not set; g:go_nvim_tests_template_dir  check gotests for details
  comment_placeholder = '',
  icons = { breakpoint = 'B', currentpos = '>' },
  verbose = true,
  log_path = '/tmp/go.nvim.log',
  lsp_cfg = true, -- internally managed
  lsp_gofumpt = false,
  lsp_on_attach = function(client, bufnr)
    -- first get the defaults
    utils.on_attach(client, bufnr)

    local function mapkey(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end
    local opts = { noremap=true, silent=true }

    -- more explicit options provided by the plugin
    mapkey('n', '<leader>gx', ':GoDoc<CR>', opts)
    mapkey('n', '<leader>gI', ':GoImpl<CR>', opts)

    -- opening tests
    mapkey('n', '<leader>gA', ':GoAlt<CR>', opts)
    mapkey('n', '<leader>gav', ':GoAltV<CR>', opts)
    mapkey('n', '<leader>gas', ':GoAltS<CR>', opts)

    -- running tests
    mapkey('n', '<leader>gT', ':GoTest<CR>', opts)
    mapkey('n', '<leader>gtv', ':GoTest -v<CR>', opts)

    -- a way to quit a goterm buffer
    mapkey('n', '<leader>gtq', ':bd goterm<CR>', opts)

    mapkey('n', '<leader>gie', ':GoIfErr<CR>', opts)
    mapkey('n', '<leader>gta', ':GoAddTag<SPACE>', opts)
    mapkey('n', '<leader>gtr', ':GoRmTag<SPACE>', opts)
  end,
  lsp_codelens = false,
  lsp_keymaps = false,
  diagnostic = {
    hdlr = true,
    signs = true,
    underline = false,
    update_in_insert = true,
    virtual_text = false,
  },
  lsp_fmt_async = false,
  lsp_document_formatting = true,
  null_ls_document_formatting_disable = true,
  gofmt = 'gopls',
  goimport = 'gopls',
  lsp_inlay_hints = {
    enable = false,
  },
  gocoverage_sign = '█',
  dap_debug = false,
  dap_debug_keymap = false,
  dap_debug_gui = false,
  dap_debug_vt = false,
  build_tags = 'smartdns,pcap',
  textobjects = false,
  test_runner = 'go',
  verbose_tests = true,
  run_in_floaterm = true,
})

local gofmt_group = vim.api.nvim_create_augroup('nvim-gofmt', {clear = true})
vim.api.nvim_create_autocmd('BufWritePre', {
  group = gofmt_group,
  pattern = '*.go',
  callback = function()
    local wait_ms = 1000

    local params = vim.lsp.util.make_range_params()
    params.context = {only = {'source.organizeImports'}}

    local result = vim.lsp.buf_request_sync(0, 'textDocument/codeAction', params, wait_ms)

    for _, res in pairs(result or {}) do
      for _, r in pairs(res.result or {}) do
        if r.edit then
          vim.lsp.util.apply_workspace_edit(r.edit, 'UTF-8')
        else
          vim.lsp.buf.execute_command(r.command)
        end
      end
    end

    -- require('go.format').goimport()
    -- args.buf
    vim.lsp.buf.format()
  end
})
