-- local vim = vim
local utils = require('lsp.utils')
local inspect = require('vim.inspect')

-- TODO:
-- dap
-- ultisnips/luasnip
-- add to git

-- dap {{{
-- local dap = require("dap")
-- require("dap-go").setup()
-- }}}

local lsp_capabilities = vim.lsp.protocol.make_client_capabilities()

local mason = require('mason').setup({
  ui = {
    icons = {
      package_installed = "✓",
      package_pending = "➜",
      package_uninstalled = "✗"
    }
  }
})
local mason_lspconfig = require('mason-lspconfig')

-- default lsp configuration
local default_cfg = {
  capabilities = lsp_capabilities,
  on_attach = utils.on_attach,
}

local lsp_config = {
  dockerls = default_cfg,
  bashls = default_cfg,
  clangd  = default_cfg,
  dockerls  = default_cfg,
  jedi_language_server = default_cfg,
  jsonls  = default_cfg,
  rust_analyzer  = default_cfg,
  solargraph = default_cfg,
  sqlls  = default_cfg,
  tflint = default_cfg,
  tsserver = default_cfg,
  yamlls = {
    capabilities = lsp_capabilities,
    on_attach = on_attach,
    settings = {
      yaml = {
        keyOrdering = false
      }
    }
  },
  terraformls = default_cfg,
}

-- ensure installed
mason_lspconfig.setup({
  ensure_installed = {
    'dockerls',
    'bashls',
    'clangd',
    'dockerls',
    'jedi_language_server',
    'jsonls',
    -- 'jdtls', (java)
    -- 'solargraph', (ruby)
    'sqlls',
    'tflint',
    'tsserver',
    'yamlls',
    'terraformls',
  }
})

-- lspsaga {{{
require('lspsaga').setup({
  callhierarchy = {
    keys = {
      vsplit = 'v',
      split = 's',
      quit = {'q', '<ESC>'},
    },
  },
  diagnostic = {
    extend_relatedInformation = true,
    max_width = 0.75,
  },
  finder = {
    keys = {
      vsplit = 'v',
      split = 's',
      quit = {'q', '<ESC>'},
    },
  },
  hover = {
    keys = {
      quit = {'q', '<ESC>'},
    },
  },
  lightbulb = {
    enable = false, -- ???
  },
  symbol_in_winbar = {
    enable = false,
  },
  ui = {
    devicon = false,
  },
})
-- }}}

-- diagnostics {{{
local border_chars = {'╒', '═', '╕', '│', '╛', '═', '╘', '│'}

local float_opts = {
  focusable = false,
  close_events = {'BufLeave', 'CursorMoved', 'InsertEnter', 'FocusLost'},
  border = border_chars,
  source = false,
  header = false,
  prefix = function(diagnostic, i, total)
    local sev = vim.diagnostic.severity
    local hlgroup = 'Normal'

    if diagnostic.severity == sev.ERROR then hlgroup = 'Error'
    elseif diagnostic.severity == sev.WARN then hlgroup = 'Warn'
    elseif diagnostic.severity == sev.INFO then hlgroup = 'Info'
    elseif diagnostic.severity == sev.HINT then hlgroup = 'Hint'
    end

    local prefix = '[' .. string.sub(hlgroup, 0, 1) .. '] '
    local hlgroup = 'Diagnostic' .. hlgroup

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
  float = float_opts,
  severity_sort = true,
  underline = false,
  virtual_text = false,
})

vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
  border = border_chars,
  max_width = 80,
  focuseable = false,
})

-- show diagnostics on hover
vim.api.nvim_create_autocmd('CursorHold', {
  pattern = '*',
  callback = function()
    vim.diagnostic.open_float(nil, float_opts)
  end
})
-- }}}

-- disable lsp semantic highlighting because it's ... annoying
for _, group in ipairs(vim.fn.getcompletion("@lsp", "highlight")) do
  vim.api.nvim_set_hl(0, group, {})
end

-- set all the signs to a solid block
local sign_icon = '█'
local signs = { Error = sign_icon, Warn = sign_icon, Hint = sign_icon, Info = sign_icon }
for type, icon in pairs(signs) do
  local hl = "DiagnosticSign" .. type
  vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
end

-- trick airline into using native lsp
vim.api.nvim_create_user_command('LspDeclaration', 'echo "nope"', {})

-- language specific settings
require('lsp.golang')
