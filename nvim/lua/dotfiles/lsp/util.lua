local M = {}

-- on_attach to ensure that keymappings are only set with an active lsp buffer
function M.on_attach(_, bufnr)
  -- Mappings.
  local opts = {
    buffer = bufnr,
    noremap = true,
    silent = true,
  }

  -- See `:help vim.lsp.*` for documentation on any of the below functions
  -- these should map to an equivalent keymapping set for vim-go in .vimrc

  -- jump to definition (current buffer, split, and vsplit)
  vim.keymap.set('n', '<leader>gd', vim.lsp.buf.definition, opts)
  vim.keymap.set(
    'n', '<leader>gsd',
    function()
      vim.cmd('split')
      vim.lsp.buf.definition()
    end,
    opts
  )
  vim.keymap.set(
    'n', '<leader>gvd',
    function()
      vim.cmd('vsplit')
      vim.lsp.buf.definition()
    end,
    opts
  )

  -- jump to type definition (current buffer, split, and vsplit)
  vim.keymap.set('n', '<leader>gD', vim.lsp.buf.type_definition, opts)
  vim.keymap.set(
    'n', '<leader>gsD',
    function()
      vim.cmd('split')
      vim.lsp.buf.type_definition()
    end,
    opts
  )
  vim.keymap.set(
    'n', '<leader>gvD',
    function()
      vim.cmd('vsplit')
      vim.lsp.buf.definition()
    end,
    opts
  )

  -- info (godoc, etc)
  vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)

  -- TODO: color HoverNormal and HoverBorder

  -- lspsaga specific
  -- mapkey('n', '<leader>gpd', ':Lspsaga peek_definition<CR>', opts)
  -- mapkey('n', '<leader>gpD', ':Lspsaga peek_type_definition<CR>', opts)
  -- mapkey('n', '<leader>go', ':Lspsaga outline<CR>', opts)

  vim.keymap.set('n', '<leader>gr', vim.lsp.buf.rename, opts)

  -- show who implements an interface (function call shows quicklist, command is fzf)
  vim.keymap.set('n', '<leader>gi', ':Implementations<CR>', opts)
  -- vim.keymap.set('n', '<leader>gi', vim.lsp.buf.implementation, opts)

  -- show var usage (function call shows quicklist, command is fzf)
  -- mapkey('n', '<leader>gu', ':Lspsaga finder<CR>', opts)
  vim.keymap.set('n', '<leader>gu', ':References<CR>', opts)

  -- code actions
  vim.keymap.set('n', '<leader>gca', ':CodeActions<CR>', opts)
  -- vim.keymap.set('n', '<leader>gca', vim.lsp.buf.code_action, opts)

  -- show diagnostics
  -- mapkey('n', '<leader>gx', ':Lspsaga show_buf_diagnostics<CR>', opts)
  -- mapkey('n', '<leader>gxa', ':Lspsaga show_workspace_diagnostics<CR>', opts)
  -- mapkey('n', '<leader>gxl', '<cmd>lua vim.diagnostic.setloclist()<CR>', opts)

  -- popup function signature when requested
  vim.keymap.set('i', '<C-H>', vim.lsp.buf.signature_help, opts)

  -- callers/callees
  -- mapkey('n', '<leader>gci', ':Lspsaga incoming_calls<CR>', opts)
  -- mapkey('n', '<leader>gco', ':Lspsaga outgoing_calls<CR>', opts)

  -- workspace --
  -- mapkey('n', '<leader>gwa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', opts)
  -- mapkey('n', '<leader>gwr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', opts)
  -- mapkey('n', '<leader>gwl', '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>', opts)
end

-- deep copy table to a new one
function M.deep_copy(from)
  local to = {}

  for k, v in pairs(from) do
    if type(v) == 'table' then
      to[k] = M.deep_copy(v)
    else
      to[k] = v
    end
  end

  return to
end

return M
