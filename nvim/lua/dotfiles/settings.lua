-- any custom vim-related settings

-- color mappings/overrides
--
-- TODO: create named colors and link to them
local theme = {
  blue        = { fg = vim.g.srcery_blue or '#36a3d9' },
  cyan        = { fg = vim.g.srcery_cyan or '#95e6cb' },
  green       = { fg = vim.g.srcery_green or '#aad94c' },
  lightblue   = { fg = vim.g.srcery_bright_blue or '#8fbcbb' },
  lightgreen  = { fg = vim.g.srcery_bright_green or '#b8cc52' },
  lightred    = { fg = vim.g.srcery_bright_red or '#db4b4b' },
  lightyellow = { fg = vim.g.srcery_bright_yellow or '#ebcb8b' },
  lightorange = { fg = vim.g.srcery_bright_orange or '#ffefd5' },
  magenta     = { fg = vim.g.srcery_magenta or '#e799ff' },
  orange      = { fg = vim.g.srcery_orange or '#ffb454' },
  purple      = { fg = vim.g.srcery_bright_magenta or '#b48ead' },
  red         = { fg = vim.g.srcery_red or '#ff3333' },
  white       = { fg = '#ffffff' },
  yellow      = { fg = vim.g.srcery_yellow or '#ffee99' },
}

for name, opts in pairs(theme) do
  vim.api.nvim_set_hl(0, '@theme.' .. name, opts)
end

vim.api.nvim_set_hl(0, 'DiagnosticError', { link = '@theme.red' })
vim.api.nvim_set_hl(0, 'DiagnosticOk', { link = '@theme.green' })
vim.api.nvim_set_hl(0, 'DiagnosticInfo', { link = '@theme.blue' })
vim.api.nvim_set_hl(0, 'DiagnosticWarn', { link = '@theme.orange' })
vim.api.nvim_set_hl(0, 'DiagnosticHint', { link = '@theme.purple' })

vim.api.nvim_set_hl(0, 'Visual', { bg = vim.g.srcery_xgray3 or '#253340' })
vim.api.nvim_set_hl(0, 'ColorColumn', { bg = vim.g.srcery_hard_black or '#151a1e' })

vim.api.nvim_set_hl(0, 'Search', { fg = '#000000', bg = vim.g.srcery_bright_yellow or '#ebcb8b' })
