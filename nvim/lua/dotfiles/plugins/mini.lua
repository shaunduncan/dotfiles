-- mini.* configs
--
-- NOTE: this isn't imported by default in default/plugins/init.lua - it's meant to be imported by things that
-- need explicitly need it

local util = require('dotfiles.util')

local M = {
  _is_setup = false,
}

local function setup()
  if M._is_setup then
    return M
  end

  -- mini.notify
  M.notify = util.require('mini.notify')
  M.notify.setup({
    lsp_progress = {
      enable = false,
    },
    window = {
      -- config = {
      --   width = 79,
      --   border = 'none',
      -- },
      config = function()
        return {
          anchor = 'NE',
          col = vim.o.columns - 1,
          row = 0,
          focusable = false,
          zindex = 999,
          style = 'minimal',
          border = 'none',
        }
      end,
      winblend = 0,
    },
  })

  -- mini.hipatterns
  local hipat = util.require('mini.hipatterns')
  hipat.setup({
    highlighters = {
      -- fixme = { pattern = 'FIXME', group = 'MiniHipatternsFixme' },
      -- hack = { pattern = 'HACK', group = 'MiniHipatternsHack' },
      -- todo = { pattern = 'TODO', group = 'MiniHipatternsTodo' },
      -- note = { pattern = 'NOTE', group = 'MiniHipatternsNote' },
      -- xxx = { pattern = 'XXX', group = 'MiniHipatternsNote' },
      hex_color = hipat.gen_highlighter.hex_color(),
    },
  })

  -- mini.pick
  util.require('mini.pick')

  M._is_setup = true

  return M
end

return setup()
