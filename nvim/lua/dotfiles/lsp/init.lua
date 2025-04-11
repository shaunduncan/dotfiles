vim.lsp.set_log_level('error')

local util = require('dotfiles.util')
local lsputil = require('dotfiles.lsp.util')

-- core library for managing LSPs
util.require('mason').setup({
  -- registries = {
  --   "github:mason-org/mason-registry",
  --   "github:lawrenceho/mason-registry", -- for arm64 lua-language-server
  -- },
  ui = {
    border = 'single',
    icons = {
      package_installed = '✓',
      package_pending = '➜',
      package_uninstalled = '✗'
    }
  }
})

local lspconfig = util.require('lspconfig')
local mason_lspconfig = util.require('mason-lspconfig')

-- default lsp configuration
local default_caps = require('cmp_nvim_lsp').default_capabilities()

local default_cfg = {
  capabilities = default_caps,
  on_attach = lsputil.on_attach,
}

local server_cfg = {
  bashls               = default_cfg,
  buf_ls               = default_cfg,
  dockerls             = default_cfg,
  jdtls                = default_cfg,
  jedi_language_server = default_cfg,
  lua_ls               = require('dotfiles.lsp.lua').config(default_cfg),
  rust_analyzer        = default_cfg,
  solargraph           = default_cfg,
  sqlls                = default_cfg,
  terraformls          = default_cfg,
  tflint               = default_cfg,
  ts_ls                = default_cfg,
  starlark_rust        = default_cfg,

  -- special snowflake
  omnisharp            = {
    capabilities = default_caps,
    on_attach = lsputil.on_attach,
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
  }
}

-- ensure installed
mason_lspconfig.setup({
  ensure_installed = {
    'bashls',
    'buf_ls',
    'dockerls',
    'jdtls',
    'jedi_language_server',
    'lua_ls',
    'rust_analyzer',
    'sqlls',
    'terraformls',
    'tflint',
    'ts_ls',
    'omnisharp',
    'starlark_rust'
  }
})

mason_lspconfig.setup_handlers({
  function(server)
    lspconfig[server].setup(server_cfg[server])
  end,
})

-- setup for clangd
require('dotfiles.lsp.clangd').setup()

-- auto formatting on save. note: go is NOT in here because it also sets up organizaing imports
local lsp_fmt_group = vim.api.nvim_create_augroup('nvim-lsp-format', { clear = true })

vim.api.nvim_create_autocmd('BufWritePre', {
  group = lsp_fmt_group,
  pattern = {
    -- c/c++
    -- FIXME: figure out better auto formatting for c
    -- '*.c', '*.cpp', '*.h', '*.hpp',

    -- protobuf
    '*.proto',

    -- lua
    '*.lua',

    -- java
    '*.java',
  },
  callback = function()
    vim.lsp.buf.format()
  end
})

-- lspsaga {{{
-- require('lspsaga').setup({
--   callhierarchy = {
--     keys = {
--       vsplit = 'v',
--       split = 's',
--       quit = { 'q', '<ESC>' },
--     },
--   },
--   definition = {
--     width = 0.5,
--   },
--   diagnostic = {
--     extend_relatedInformation = true,
--     max_width = 0.5,
--     max_show_width = 0.5,
--   },
--   finder = {
--     keys = {
--       vsplit = 'v',
--       split = 's',
--       quit = { 'q', '<ESC>' },
--     },
--   },
--   hover = {
--     keys = {
--       quit = { 'q', '<ESC>' },
--     },
--     max_width = 0.75,
--     max_height = 0.5,
--   },
--   scroll_preview = {
--     scroll_down = '<C-b>',
--     scroll_up = '<C-f>',
--   },
--   lightbulb = {
--     enable = false, -- ???
--   },
--   symbol_in_winbar = {
--     enable = false,
--   },
--   ui = {
--     border = 'single', -- single, double, rounded, shadow, solid
--     devicon = true,
--     foldericon = false,
--     expand = '+',
--     collapse = '-',
--     code_action = '⚑',
--     actionfix = '💡',
--     imp_sign = '⦿',
--     kind = {
--       File = { '📄 ', 'Tag' },
--       Module = { '▣ ', 'Exception' }, -- or ¶ or ⌘
--       Namespace = { '§ ', 'Include' },
--       Package = { '❒ ', 'Label' }, -- or ⊞ or ¶
--       Class = { 'ℂ ', 'Include' },
--       Method = { '⨍ ', 'Function' },
--       Property = { '@ ', '@property' },
--       Field = { '@ ', '@field' },
--       Constructor = { '🛠 ', '@constructor' }, -- or ⚙
--       Enum = { '∈ ', '@number' },
--       Interface = { '⮻ ', 'Type' },
--       Function = { '⨍ ', 'Function' },
--       Variable = { '𝒳 ', '@variable' },
--       Constant = { '🔒 ', 'Constant' },
--       String = { 'S ', 'String' },
--       Number = { '# ', 'Number' }, -- or №
--       Boolean = { '◧ ', 'Boolean' }, -- or ◐ or ⏻
--       Array = { '[]', 'Type' },
--       Object = { '🄾 ', 'Type' }, -- Ⓞ or ¤ or ⓞ
--       Key = { '🔑 ', 'Constant' },
--       Null = { '∅ ', 'Constant' },
--       EnumMember = { '∋ ', 'Number' },
--       Struct = { '{}', 'Type' },
--       Event = { '⚠ ', 'Constant' },
--       Operator = { '± ', 'Operator' },
--       TypeParameter = { '⦂ ', 'Type' },
--     },
--   },
-- })
-- }}}

-- diagnostics {{{
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
vim.api.nvim_create_autocmd('CursorHold', {
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
-- }}}

-- disable lsp semantic highlighting because it's ... annoying
-- for _, group in ipairs(vim.fn.getcompletion('@lsp', 'highlight')) do
--   vim.api.nvim_set_hl(0, group, {})
-- end

-- set all the signs to a solid block
local sign_icon = '█'
local signs = { Error = sign_icon, Warn = sign_icon, Hint = sign_icon, Info = sign_icon }
for type, icon in pairs(signs) do
  local hl = 'DiagnosticSign' .. type
  vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
end

-- trick airline into using native lsp
vim.api.nvim_create_user_command('LspDeclaration', 'echo "nope"', {})

-- language specific settings
require('dotfiles.lsp.golang')

-- debugging
require('dotfiles.lsp.dap')

-- general lsp keybinds
vim.keymap.set('n', 'd]', vim.diagnostic.goto_next)
vim.keymap.set('n', 'd[', vim.diagnostic.goto_prev)
