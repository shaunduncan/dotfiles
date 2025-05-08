local M = {}

M.setup = function()
  local util = require('dotfiles.util')

  util.require('dotfiles.settings')
  require('dotfiles.lsp')
  util.require('dotfiles.plugins')

  -- TODO: use/configure Shatur/neovim-ayu
  -- TODO: <leader>XXX -> delete(expand('%'))
end

return M
