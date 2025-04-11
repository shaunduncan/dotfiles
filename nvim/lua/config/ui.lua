--------------------------------------------------------------------------------
--                             UI AND APPEARANCE                              --
--------------------------------------------------------------------------------

local aug = vim.api.nvim_create_augroup('my-config-ui', { clear = true })

vim.o.background = 'dark'

-- enable 24 bit RGB, using gui highlight attributes instead of cterm
-- NOTE: nvim ignores t_XXX options, so there is no need to set them
vim.o.termguicolors = true

-- reset everything on colorscheme change
vim.api.nvim_create_autocmd('ColorSchemePre', {
  group = aug,
  pattern = '*',
  callback = function()
    vim.cmd.hi('clear')
    vim.cmd.syntax('reset')
  end,
})

-- color overrides
vim.api.nvim_create_autocmd('ColorScheme', {
  group = aug,
  pattern = '*',
  callback = function()
    local function update(name, attrs)
      local src = vim.api.nvim_get_hl(0, { name = name })
      vim.api.nvim_set_hl(0, name, vim.tbl_deep_extend('force', src, attrs))
    end

    vim.cmd.hi('normal guibg=black')

    -- minimal cursorline
    vim.cmd.hi('clear CursorLine')

    update('CursorLineNr', { bold = true })
    update('Error', { fg = 'black', ctermfg = 'black' })

    -- errormsg is reverse error
    vim.api.nvim_set_hl(0, 'ErrorMsg', vim.api.nvim_get_hl(0, { name = 'Error' }))
    update('ErrorMsg', { reverse = true })

    -- folded, foldcolumn
    local src = { fg = 'cyan', bg = 'NONE' }
    vim.api.nvim_set_hl(0, 'Folded', src)
    vim.api.nvim_set_hl(0, 'FoldColumn', src)

    vim.api.nvim_set_hl(0, 'IncSearch', { link = 'Search' })
    vim.api.nvim_set_hl(0, 'MatchParen', { fg = 'magenta' })

    -- add undercurl
    for _, name in ipairs({ 'SpellBad', 'SpellLocal', 'SpellCap', 'SpellRare' }) do
      update(name, { undercurl = true })
    end

    vim.cmd.hi('clear SignColumn')

    update('DiffAdd', { reverse = true })
    vim.api.nvim_set_hl(0, 'DiffDelete', { link = 'ErrorMsg' })
    vim.api.nvim_set_hl(0, 'Pmenu', { fg = '#ffffff', bg = '#0f0f0f' })
    vim.api.nvim_set_hl(0, 'NormalFloat', { link = 'Pmenu' })
  end,
})

-- ensure that borders show up and look consistent
vim.cmd [[hi clear FloatBorder | hi link FloatBorder Pmenu]]

-- no cursorline, solid black background
vim.cmd [[hi normal guibg=black]]
vim.cmd [[hi clear cursorline]]

-- prevent unwanted underlines from showing up in diff views
vim.o.cursorlineopt = 'number'
