-- special handling for setting up lsp config for clangd
local M = {}

local nproc = string.gsub(vim.fn.system('nproc'), '\n', '')

function M.setup()
  local util = require('dotfiles.util')
  local lsputil = require('dotfiles.lsp.util')

  local caps = util.require('cmp_nvim_lsp').default_capabilities()
  caps.offsetEncoding = { 'utf-16' }

  util.require('lspconfig').clangd.setup({
    on_attach = lsputil.on_attach,
    filetypes = { 'c', 'cpp' },
    capabilities = caps,
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
end

return M
