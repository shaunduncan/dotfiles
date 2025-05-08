--------------------------------------------------------------------------------
--                              FOLDING BEHAVIOR                              --
--------------------------------------------------------------------------------

local aug = vim.api.nvim_create_augroup('my-config-folds', { clear = true })

-- standard fold settings:
--
-- * only 1 column for showing fold markers
-- * set initial fold level to 99 to have all folds open
-- * make folds open automatically for some events
vim.o.foldenable = true
vim.o.foldcolumn = '1'
vim.o.foldminlines = 1
vim.o.foldnestmax = 5
vim.o.foldlevel = 99
vim.o.foldlevelstart = 99
vim.opt.foldopen = { 'tag', 'percent', 'search', 'mark', 'quickfix', 'undo', 'insert' }

-- syntax folding is slow, default to manual unless in diff mode
if vim.o.diff then
  vim.o.foldmethod = 'diff'
else
  vim.o.foldmethod = 'manual'
end

-- fold toggle shortcuts
vim.keymap.set('n', '<leader><leader>', 'za', { noremap = true })

-- disable automatic folding when in insert mode. this prevents a problem where adding the
-- start of a new marker fold unfolds everything below it
vim.api.nvim_create_autocmd('InsertEnter', {
  group = aug,
  pattern = '*',
  callback = function()
    -- if vim.w.lastfdm == nil then
    --   print(vim.inspect(vim.bo.foldmethod))
    --   vim.w.lastfdm = vim.bo.foldmethod
    --   vim.bo.foldmethod = 'manual'
    -- end
  end,
})
vim.api.nvim_create_autocmd('InsertLeave', {
  group = aug,
  pattern = '*',
  callback = function()
    -- if vim.w.lastfdm ~= nil then
    --   vim.bo.foldmethod = vim.w.lastfdm
    --   vim.w.lastfdm = nil
    -- end
  end,
})

-- code folding
-- syntax based folding
vim.api.nvim_create_autocmd('FileType', {
  group = aug,
  pattern = 'json',
  callback = function()
    -- vim.bo.foldenable = false
  end,
})

-- marker based folding
vim.api.nvim_create_autocmd('FileType', {
  group = aug,
  pattern = { 'dockerfile', 'tex' },
  callback = function()
    -- vim.bo.foldmethod = 'marker'
  end,
})

-- allow .proto folding based on curl brace and indent 4 spaces
vim.api.nvim_create_autocmd('FileType', {
  group = aug,
  pattern = { 'proto', 'protobuf' },
  callback = function()
    -- vim.bo.foldmethod = 'marker'
    -- vim.bo.foldmarker = '{,}'
  end,
})

-- format options
-- don't let plugins change my preferences (this makes any setl just use the global value)
vim.api.nvim_create_autocmd('FileType', {
  group = aug,
  pattern = { 'vim', 'zsh' },
  callback = function()
    vim.cmd [[setlocal formatoptions<]]
  end,
})

-- enforce markdown textwidth wrapping since it's documentation
vim.api.nvim_create_autocmd('FileType', {
  group = aug,
  pattern = 'markdown',
  callback = function()
    vim.cmd [[setlocal fo+=t2]]
  end,
})
