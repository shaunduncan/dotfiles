-- lazy.nvim boilerplate: https://lazy.folke.io/installation

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
  local out = vim.fn.system({ 'git', 'clone', '--filter=blob:none', '--branch=stable', lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo(
      { { 'lazy.nvim clone failed: ' .. out .. '\n', 'ErrorMsg' } }, true, {}
    )
  end
end
vim.opt.rtp:prepend(lazypath)

-- Setup lazy.nvim
require('lazy').setup({
  install = {
    colorscheme = { 'srcery' },
  },

  spec = {
    { import = 'plugins.specs' },
  },

  -- automatically check for plugin updates, but at most once per day
  checker = {
    enabled = false,
    frequency = (3600 * 24),
  },

  performance = {
    rtp = {
      -- things in $VIMRUNTIME/plugin
      disabled_plugins = {
        'gzip',
        'tarPlugin',
        'tohtml',
        'tutor',
        'zipPlugin',
        -- TODO: maybe revisit enabling spellcheck?
        -- 'spellfile',
      },
    }
  },

  -- experiment with this: don't auto reload on config changes
  change_detection = { enabled = false }

  -- OTHER OPTIONS
  -- https://lazy.folke.io/configuration

  -- ui = {
  --   icons = { ... }

  -- setup for local plugin projects
  -- path: string, path to local projects
  -- patterns: table, list of preferred local plugins or forks (i.e. shaunduncan)
  -- fallback: true/false go back to git if the plugin isn't there
  -- dev = {}
})
