--------------------------------------------------------------------------------
--                      PORT OF ARCHIVED ivyl/vim-bling                       --
--------------------------------------------------------------------------------

-- TODO: FIXME

local M = {}

-- Default values
local bling_no_expr = vim.g.bling_no_expr or 0
local bling_no_map = vim.g.bling_no_map or 0
local bling_count = vim.g.bling_count or 2
local bling_time = vim.g.bling_time or 35
local bling_color_fg = vim.g.bling_color_fg or 'red'
local bling_color_bg = vim.g.bling_color_bg or 'black'
local bling_color_gui_fg = vim.g.bling_color_gui_fg or 'red'
local bling_color_gui_bg = vim.g.bling_color_gui_bg or 'black'
local bling_color_cterm = vim.g.bling_color_cterm or 'reverse'
local bling_color_term = vim.g.bling_color_term or 'reverse'

local bling_disabled = false

-- Define highlight group
vim.cmd(string.format(
  [[
highlight BlingHilight ctermbg=%s ctermfg=%s guibg=%s guifg=%s cterm=%s term=%s
]],
  bling_color_bg,
  bling_color_fg,
  bling_color_gui_bg,
  bling_color_gui_fg,
  bling_color_cterm,
  bling_color_term
))

---Disable the bling highlight.
M.disable = function()
  bling_disabled = true
end

---Enable the bling highlight.
M.enable = function()
  bling_disabled = false
end

---Toggle the bling highlight.
M.toggle = function()
  if bling_disabled then
    M.enable()
  else
    M.disable()
  end
end

---Highlight the last search.
M.highlight = function()
  if vim.fn.reg_executing() ~= '' then
    return
  end

  if bling_disabled then
    return
  end

  local blink_count = bling_count
  local sleep_command = 'sleep ' .. bling_time .. 'ms'

  local param = vim.fn.getreg('/')

  -- Find the start and end columns of the current match
  local match_start_pos = vim.fn.getcurpos()
  vim.cmd('silent! :search(' .. vim.fn.escape(param, '/') .. ', "ceW")')
  local match_end_pos = vim.fn.getcurpos()
  vim.fn.cursor(match_start_pos[2], match_start_pos[3])

  -- Open folds
  vim.cmd('normal! zv')

  while blink_count > 0 do
    blink_count = blink_count - 1

    local ring = vim.fn.matchaddpos(
      'BlingHilight',
      { { match_start_pos[2], match_start_pos[3], match_end_pos[3] - match_start_pos[3] + 1 } }
    )
    vim.cmd('redraw')

    vim.cmd('call timer_start(' ..
      bling_time .. ', function() vim.cmd("silent! matchdelete " .. ring) vim.cmd("redraw") end)')

    if blink_count > 0 then
      vim.cmd(sleep_command)
    end
  end
end

---Conditionally calls the BlingHighight function.
M.expression_highlight = function()
  local cmd_type = vim.fn.getcmdtype()
  local current_mode = vim.fn.mode()
  local in_visual_mode = current_mode == 'v' or current_mode == 'V' or current_mode == ''

  if (cmd_type == '/' or cmd_type == '?') and not in_visual_mode then
    return '\\<CR>:call BlingHighight()\\<CR>'
  end

  return '\\<CR>'
end

if bling_no_map == 0 then
  vim.keymap.set('n', 'n', 'n:call BlingHighight()<CR>', { silent = true })
  vim.keymap.set('n', 'N', 'N:call BlingHighight()<CR>', { silent = true })
  vim.keymap.set('n', '*', '*:call BlingHighight()<CR>', { silent = true })
  vim.keymap.set('n', '#', '#:call BlingHighight()<CR>', { silent = true })

  if bling_no_expr == 0 then
    vim.keymap.set('c', '<enter>', 'BlingExpressionHighlight()', { silent = true, expr = true })
  end
end

return M
