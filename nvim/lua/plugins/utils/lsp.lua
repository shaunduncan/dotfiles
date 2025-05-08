--------------------------------------------------------------------------------
--                       LSP: UTILTIES AND CONFIGURATION                       --
--------------------------------------------------------------------------------

local M = {}

-- on_attach to ensure that keymappings are only set with an active lsp buffer
function M.on_attach(_, bufnr)
  -- Mappings.
  local function opts(desc)
    return {
      desc = desc,
      buffer = bufnr,
      noremap = true,
      silent = true,
    }
  end

  -- See `:help vim.lsp.*` for documentation on any of the below functions
  -- these should map to an equivalent keymapping set for vim-go in .vimrc

  -- jump to definition (current buffer, split, and vsplit)
  vim.keymap.set('n', '<leader>gd', vim.lsp.buf.definition, opts('LSP: Goto Definition'))
  vim.keymap.set(
    'n', '<leader>gsd',
    function()
      vim.cmd('split')
      vim.lsp.buf.definition()
    end,
    opts('LSP: Goto Definition (Split)')
  )
  vim.keymap.set(
    'n', '<leader>gvd',
    function()
      vim.cmd('vsplit')
      vim.lsp.buf.definition()
    end,
    opts('LSP: Goto Definition (VSplit)')
  )

  -- jump to type definition (current buffer, split, and vsplit)
  vim.keymap.set('n', '<leader>gD', vim.lsp.buf.type_definition, opts('LSP: Goto Type Definition'))
  vim.keymap.set(
    'n', '<leader>gsD',
    function()
      vim.cmd('split')
      vim.lsp.buf.type_definition()
    end,
    opts('LSP: Goto Type Definition (Split)')
  )
  vim.keymap.set(
    'n', '<leader>gvD',
    function()
      vim.cmd('vsplit')
      vim.lsp.buf.definition()
    end,
    opts('LSP: Goto Type Definition (VSplit)')
  )

  -- info (godoc, etc)
  vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts('LSP: Hover'))

  -- TODO: color HoverNormal and HoverBorder

  vim.keymap.set('n', '<leader>gr', vim.lsp.buf.rename, opts('LSP: Rename'))

  -- show who implements an interface (function call shows quicklist, command is fzf)
  vim.keymap.set('n', '<leader>gi', ':Implementations<CR>', opts('LSP: Implementations'))
  -- vim.keymap.set('n', '<leader>gi', vim.lsp.buf.implementation, opts)

  -- show var usage (function call shows quicklist, command is fzf)
  vim.keymap.set('n', '<leader>gu', ':References<CR>', opts('LSP: References'))

  -- code actions
  vim.keymap.set('n', '<leader>gca', ':CodeActions<CR>', opts('LSP: CodeActions'))
  -- vim.keymap.set('n', '<leader>gca', vim.lsp.buf.code_action, opts)

  -- show diagnostics
  -- mapkey('n', '<leader>gxl', '<cmd>lua vim.diagnostic.setloclist()<CR>', opts)

  -- popup function signature when requested
  vim.keymap.set('i', '<C-H>', vim.lsp.buf.signature_help, opts('LSP: Signature Help'))

  -- workspace --
  -- mapkey('n', '<leader>gwa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', opts)
  -- mapkey('n', '<leader>gwr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', opts)
  -- mapkey('n', '<leader>gwl', '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>', opts)
end

-- on_go_attach specific attach behavior for gopls
function M.on_go_attach(client, bufnr)
  -- first get the defaults
  M.on_attach(client, bufnr)

  local function mapkey(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end
  local function opts(desc)
    return { desc = desc, noremap = true, silent = true }
  end

  -- more explicit options provided by the plugin
  -- FIXME: GoImpl needs to be wrapped to automatically do something like
  -- `:GoImpl m *MyStruct SomeInterface`
  mapkey('n', '<leader>g?', ':GoDoc<CR>', opts('Go: Doc'))
  mapkey('n', '<leader>gI', ':GoImpl<CR>', opts('Go: Implementations'))

  -- opening tests
  mapkey('n', '<leader>gA', ':GoAlt<CR>', opts('Go: Open Test File'))
  mapkey('n', '<leader>gav', ':GoAltV<CR>', opts('Go: Open Test File (VSplit)'))
  mapkey('n', '<leader>gas', ':GoAltS<CR>', opts('Go: Open Test File (Split)'))
  mapkey('n', '<leader>gat', ':GoAddTest<CR>', opts('Go: Add Test'))

  -- running tests
  local argstr = ' -a -test.timeout=60s<CR>'

  -- mapkey('n', '<leader>gt', ':GoTestFunc' .. argstr, opts)
  -- mapkey('n', '<leader>gT', ':GoTestSum -f testname<CR>', opts('Go: Test'))
  -- mapkey('n', '<leader>gtv', ':GoTest -v' .. argstr, opts('Go: Test Verbose'))
  mapkey('n', '<leader>gtf', ':GoTestFunc' .. argstr, opts('Go: Test Current Function'))
  mapkey('n', '<leader>gtF', ':GoTestFile' .. argstr, opts('Go: Test Current File'))
  mapkey('n', '<leader>gtp', ':GoTestPkg' .. argstr, opts('Go: Test Current Package'))

  mapkey('n', '<leader>gie', ':GoIfErr<CR>', opts('Go: Add IfErr'))
  mapkey('n', '<leader>gta', ':GoAddTag<SPACE>', opts('Go: Add Tag'))
  mapkey('n', '<leader>gtr', ':GoRmTag<SPACE>', opts('Go: Remove Tag'))
  -- mapkey('n', '<leader>gti', ':GoToggleInlay<CR>', opts('Go: Toggle Inlay'))
  -- mapkey('n', '<leader>gl', ':GoCodeLenAct<CR>', opts)
end

-- utility function for gopls to try and get the current module name (mostly for new files)
function M.get_current_gomod()
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

-- setup pre-write rules to auto format files via lsp if they support it
function M.configure_autoformat()
  -- auto formatting on save for simple filetypes that dont' require any extra work
  local aug = vim.api.nvim_create_augroup('nvim-lsp-format', { clear = true })

  vim.api.nvim_create_autocmd('BufWritePre', {
    group = aug,
    pattern = {
      -- c/c++
      '*.c', '*.cpp', '*.h', '*.hpp',

      '*.java',
      '*.lua',
      '*.proto',
    },
    callback = function()
      vim.lsp.buf.format()
    end,
  })

  -- go: organize imports AND format on save
  vim.api.nvim_create_autocmd('BufWritePre', {
    group = aug,
    pattern = '*.go',
    callback = function()
      local wait_ms = 1000

      local params = vim.lsp.util.make_range_params(0, vim.lsp.get_clients()[1].offset_encoding or 'utf-16')
      params.context = { only = { 'source.organizeImports' } }

      local result = vim.lsp.buf_request_sync(0, 'textDocument/codeAction', params, wait_ms)

      for _, res in pairs(result or {}) do
        for _, r in pairs(res.result or {}) do
          if r.edit then
            vim.lsp.util.apply_workspace_edit(r.edit, vim.lsp.get_clients()[1].offset_encoding or 'utf-16')
          else
            vim.lsp.buf.execute_command(r.command)
          end
        end
      end

      vim.lsp.buf.format()
    end
  })
end

-- configure the overall look and feel of lsp diagnostics
function M.configure_diagnostics()
  local border_chars = { '╒', '═', '╕', '│', '╛', '═', '╘', '│' }

  local float_opts = {
    focusable = false,
    close_events = {
      'BufLeave',
      'CursorMoved',
      'ModeChanged',
      'FocusLost',
      'MenuPopup',
      'WinNew',
    },
    border = border_chars,
    source = false,
    header = false,
    prefix = function(diagnostic, _, _)
      local sev = vim.diagnostic.severity
      local hlgroup = 'Normal'

      if diagnostic.severity == sev.ERROR then
        hlgroup = 'Error'
      elseif diagnostic.severity == sev.WARN then
        hlgroup = 'Warn'
      elseif diagnostic.severity == sev.INFO then
        hlgroup = 'Info'
      elseif diagnostic.severity == sev.HINT then
        hlgroup = 'Hint'
      end

      local prefix = '[' .. string.sub(hlgroup, 0, 1) .. '] '
      hlgroup = 'Diagnostic' .. hlgroup

      -- local msg = ' [' .. diagnostic.source .. ':' .. diagnostic.code .. '] '
      if diagnostic.code == nil or diagnostic.code == 'default' then
        return prefix, hlgroup
      end

      return prefix .. diagnostic.code .. ': ', hlgroup
    end,
    suffix = '',
    pad_top = 0,
    pad_bottom = 0,
    max_width = 80,
    title = ' Diagnostics ',
    title_pos = 'center',
  }

  vim.diagnostic.config({
    underline = false,
    virtual_text = false,
    signs = true,
    float = float_opts,
    severity_sort = true,
    update_in_insert = false,
  })

  vim.lsp.handlers['textDocument/hover'] = vim.lsp.with(vim.lsp.handlers.hover, {
    border = border_chars,
    width = 120,
    max_width = 120,
    wrap = true,
    wrap_at = 119,
  })

  -- show diagnostics on hover
  local aug = vim.api.nvim_create_augroup('nvim-lsp-hover', { clear = true })

  vim.api.nvim_create_autocmd('CursorHold', {
    group = aug,
    pattern = '*',
    callback = function()
      -- only show the diagnostic floating window if there are no other floating windows, otherwise we'll clobber
      -- things like documentation windows
      for _, win in ipairs(vim.api.nvim_list_wins()) do
        local cfg = vim.api.nvim_win_get_config(win)
        if cfg and cfg.relative ~= '' then
          return
        end
      end

      vim.diagnostic.open_float(nil, float_opts)
    end
  })
end

return M
