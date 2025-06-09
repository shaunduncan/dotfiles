--------------------------------------------------------------------------------
--                      FILETYPE SPECIFIC CONFIGURATION                       --
--------------------------------------------------------------------------------

local aug = vim.api.nvim_create_augroup('my-config-filetypes', { clear = true })

vim.filetype.add({
  extension = {
    -- treat *.pyx cython files with python syntax
    pyx = 'python',

    -- treat jsonl like json
    jsonl = 'json',
  },
})

-- modifiable vim help docs shouldn't conceal things while editing because it's confusing,
-- and we're editing
vim.api.nvim_create_autocmd('BufEnter', {
  group = aug,
  pattern = '*.txt',
  callback = function()
    if vim.bo.filetype == 'help' and vim.bo.modifiable then
      vim.bo.filetype = 'text'
    end
  end,
})

-- indentation deviations from 4 spaces
vim.api.nvim_create_autocmd('FileType', {
  group = aug,
  pattern = {
    -- config files
    'haml', 'json', 'toml', 'yaml',

    -- shell scripts and programming languages
    'sh', 'bash', 'zsh', 'lua',

    -- web and markup
    'html', 'xml', 'sass', 'markdown',

    -- misc
    'cucumber', 'proto', 'protobuf',
  },
  callback = function()
    vim.cmd [[setlocal ts=2 sw=2 sts=2]]
  end,
})

-- config files: update view options
vim.api.nvim_create_autocmd('FileType', {
  group = aug,
  pattern = { 'haml', 'json', 'toml', 'yaml' },
  callback = function()
    vim.cmd [[setlocal viewoptions=slash,unix]]
  end,
})

-- makefiles: strictly use tabs, not spaces
vim.api.nvim_create_autocmd('FileType', {
  group = aug,
  pattern = 'make',
  callback = function()
    vim.cmd [[setlocal ts=4 sw=4 sts=4 noet]]
  end,
})

-- commentstring modifications
local function setcms(filetypes, cms)
  vim.api.nvim_create_autocmd('FileType', {
    group = aug,
    pattern = filetypes,
    callback = function()
      vim.bo.commentstring = cms
    end,
  })
end

-- filetypes that should add a space after the comment character
setcms('vim', '" %s')

-- snippets: include a space after the comment character
setcms('snippets', '# %s')

-- LaTeX: the default '%%s' breaks my wrap plugin config, change it
setcms('tex', '% %s')

-- sql: include a space after the comment character
setcms('sql', '-- %s')

-- c/c++ prefer double slash comments
setcms({ 'c', 'cpp' }, '// %s')

-- protobuf
setcms('proto', '// %s')

-- don't override my configuration
vim.api.nvim_create_autocmd('FileType', {
  group = aug,
  pattern = '*',
  callback = function()
    vim.bo.textwidth = 110
    vim.bo.formatoptions = 'crqnj'
  end,
})
