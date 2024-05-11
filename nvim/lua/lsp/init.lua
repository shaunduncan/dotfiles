local vim = vim
local utils = require('lsp.utils')

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
local lspconfig = require('lspconfig')
local mason_lspconfig = require('mason-lspconfig')

-- default lsp configuration
local default_cfg = {
  capabilities = lsp_capabilities,
  on_attach = utils.on_attach,
}

local server_cfg = {
  dockerls = default_cfg,
  bashls = default_cfg,
  bufls = default_cfg,
  clangd  = {
    capabilities = lsp_capabilities,
    on_attach = utils.on_attach,
    cmd = {
      'clangd',
      '--offset-encoding=utf-16',
    },
  },
  dockerls  = default_cfg,
  jedi_language_server = default_cfg,
  jsonls  = default_cfg,
  rust_analyzer  = default_cfg,
  jdtls = default_cfg,
  solargraph = default_cfg,
  sqlls  = default_cfg,
  tflint = default_cfg,
  tsserver = default_cfg,
  -- yamlls = {
  --   capabilities = lsp_capabilities,
  --   on_attach = utils.on_attach,
  --   settings = {
  --     yaml = {
  --       keyOrdering = false
  --     }
  --   }
  -- },
  terraformls = default_cfg,
  lua_ls = default_cfg,
}

-- ensure installed
mason_lspconfig.setup({
  ensure_installed = {
    'dockerls',
    'bashls',
    'bufls',
    -- 'clangd',
    'dockerls',
    'jedi_language_server',
    'jsonls',
    'jdtls',
    -- 'solargraph', (ruby)
    'rust_analyzer',
    'sqlls',
    'tflint',
    'tsserver',
    -- 'yamlls',
    'terraformls',
    'lua_ls',
  }
})

mason_lspconfig.setup_handlers({
  function(server)
    lspconfig[server].setup(server_cfg[server])
  end,
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
  definition = {
    width = 0.5,
  },
  diagnostic = {
    extend_relatedInformation = true,
    max_width = 0.5,
    max_show_width = 0.5,
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
    max_width = 0.5,
    open_cmd = '!firefox',
  },
  lightbulb = {
    enable = false, -- ???
  },
  symbol_in_winbar = {
    enable = false,
  },
  ui = {
    border = 'single', -- single, double, rounded, shadow, solid
    devicon = true,
    foldericon = false,
    expand = '+',
    collapse = '-',
    code_action = '⚑',
    actionfix = '💡',
    imp_sign = '⦿',
    kind = {
      File = { '📄 ', 'Tag' },
      Module = { '▣ ', 'Exception' }, -- or ¶ or ⌘
      Namespace = { '§ ', 'Include' },
      Package = { '❒ ', 'Label' }, -- or ⊞ or ¶
      Class = { 'ℂ ', 'Include' },
      Method = { '⨍ ', 'Function' },
      Property = { '@ ', '@property' },
      Field = { '@ ', '@field' },
      Constructor = { '🛠 ', '@constructor' }, -- or ⚙
      Enum = { '∈ ', '@number' },
      Interface = { '⮻ ', 'Type' },
      Function = {'⨍ ', 'Function'},
      Variable = { '𝒳 ', '@variable' },
      Constant = { '🔒 ', 'Constant' },
      String = { 'S ', 'String' },
      Number = { '# ', 'Number' }, -- or №
      Boolean = { '◧ ', 'Boolean' }, -- or ◐ or ⏻
      Array = { '[]', 'Type' },
      Object = { '🄾 ', 'Type' }, -- Ⓞ or ¤ or ⓞ
      Key = { '🔑 ', 'Constant' },
      Null = { '∅ ', 'Constant' },
      EnumMember = { '∋ ', 'Number' },
      Struct = { '{}', 'Type' },
      Event = { '⚠ ', 'Constant' },
      Operator = { '± ', 'Operator' },
      TypeParameter = { '⦂ ', 'Type' },
    },
  },
})
-- }}}

-- diagnostics {{{
local border_chars = {'╒', '═', '╕', '│', '╛', '═', '╘', '│'}

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
  underline = false,
  virtual_text = false,
  signs = true,
  float = float_opts,
  severity_sort = true,
  update_in_insert = false,
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

-- debugging
require('lsp.dap')

-- general lsp keybinds
vim.keymap.set('n', 'd]', vim.diagnostic.goto_next)
vim.keymap.set('n', 'd[', vim.diagnostic.goto_prev)

-- codeaction hints
require('nvim-lightbulb').setup({
  autocmd = {
    enabled = true,
    updatetime = 10,
  },
  sign = {
    enabled = false,
  },
  status_text = {
    enabled = true,
  },
})
