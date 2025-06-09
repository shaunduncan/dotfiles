--------------------------------------------------------------------------------
--                               CORE SETTINGS                                --
--------------------------------------------------------------------------------

local aug = vim.api.nvim_create_augroup('my-config-core', { clear = true })

-- no fsync on write
vim.o.fsync = false

vim.o.fileformats = 'unix'
vim.opt.backspace = { 'indent', 'eol', 'start' }
vim.o.history = 1000

vim.o.laststatus = 2

-- enable setting window titles
vim.o.title = true

-- disable bells
vim.o.errorbells = false
vim.o.visualbell = false
vim.o.belloff = 'all'

-- disable spellcheck
vim.o.spell = false

-- syntax highlighting/pattern matching for large data (32MiB)
vim.o.maxmempattern = 32768

-- indent behavior
-- https://vim.fandom.com/wiki/Restoring_indent_after_typing_hash
vim.o.cindent = true
vim.opt.cinkeys:remove('0#')
vim.opt.indentkeys:remove('0#')

-- default to 4 space tabs with auto tab expansion
vim.o.tabstop = 4
vim.o.shiftwidth = 4
vim.o.softtabstop = 4
vim.o.expandtab = true

vim.o.concealcursor = ''
vim.o.conceallevel = 0

-- enable filetype specific behaviors
vim.cmd.filetype({ args = { 'plugin', 'indent', 'on' } })

vim.o.display = 'lastline'

-- show matching bracket on insert
vim.o.showmatch = true

-- no wordwrap, but don't just break at the last character
vim.o.wrap = false
vim.o.linebreak = true

-- line numbering
vim.o.number = true
vim.o.relativenumber = true

-- a little extra context on scroll
vim.o.scrolloff = 5

-- position id behavior
vim.o.cursorline = true
vim.o.cursorcolumn = false

-- no mouse, no arrow keys
vim.o.mouse = ''
vim.keymap.set({ 'n', 'i', 'v' }, '<up>', '<nop>', { noremap = true })
vim.keymap.set({ 'n', 'i', 'v' }, '<down>', '<nop>', { noremap = true })
vim.keymap.set({ 'n', 'i', 'v' }, '<left>', '<nop>', { noremap = true })
vim.keymap.set({ 'n', 'i', 'v' }, '<right>', '<nop>', { noremap = true })

-- for line wraps (when enabled), prefix with something
vim.o.showbreak = '❯ '

-- potentially add 'popup' for extra info
vim.opt.completeopt = { 'menu', 'menuone', 'noselect' }

-- tab completion for opening files and what not: <Tab>shows the list of matches, <Tab> a second
-- time to go through the options. skip commonly ignored files
vim.opt.wildmode = { 'list:longest', 'full' }
vim.opt.wildignore = {
  -- object files
  '*.o', '*.a', '*.obj',

  -- backups
  '*~', '*.bak',

  -- python
  '*.pyc', '__pycache__',

  -- node junk
  'node_modules',

  -- version control
  '*/.git/*', '*/.hg/*', '*/.svn/*',

  -- mac archive
  '*/.DS_Store',
}

-- stop syntax highlights for really long lines
vim.o.synmaxcol = 1024

-- Notes:
-- syntax sync minlines=64 maxlines=256
-- syntax sync ccomment goComment
--
-- add minlines=100 to scan back at least these many lines for a comment start which might give
-- better context information
--
-- add maxlines=500 to stop scanning this many lines back

-- search settings
vim.o.ignorecase = true
vim.o.smartcase = true

-- diff options
vim.opt.diffopt = {
  'internal',
  'filler',
  'closeoff',
  'vertical',
  'iwhite',
  'context:999999',
  'algorithm:histogram',
  'indent-heuristic',
  'linematch:60',
}

-- empty space fill behavior
-- stl:       space - statusline
-- stlnc:     space - statusline in other windows
-- vert:      ┃     - vsplit separator
-- fold:      - (or: ·)
-- foldopen:  ◇
-- foldclose: ◆
-- foldsep:   │     - fold span
-- diff:      space - vimdiff removed filler
-- eob: empty lines at buffer end
vim.o.fillchars = 'stl: ,stlnc: ,vert:┃,fold:-,foldopen:◇,foldclose:◆,foldsep:│,diff: ,eob:~'

vim.o.modeline = true
vim.o.modelines = 5

-- keep signcolumn enabled so plugins the ui doesn't constantly switch back and forth
vim.o.signcolumn = 'yes'

-- things to save with views
vim.opt.viewoptions = { 'folds', 'slash', 'unix' }

-- views can get messed up with cursor position when folds are open or closed so reset the cursor
-- position to the beginning of the file after loaded
vim.api.nvim_create_autocmd('SessionLoadPost', {
  group = aug,
  pattern = '*',
  callback = function()
    vim.cmd('0')
  end,
})

-- maximum textwidth, but only automatically wrap comment strings
vim.o.textwidth = 110
vim.o.formatoptions = 'crqnj'

-- don't use 2 spaces between joined sentences
vim.o.joinspaces = false

-- no hidden buffers, actually close a file
vim.o.hidden = false

-- disable swap and backups (we're using persistent undo)
vim.o.swapfile = false
vim.o.backup = false

-- on mac, the default locations to skip for backups don't work because of symlinks and don't cover enough
-- bases. make sure it works as expected
if vim.fn.has('mac') then
  vim.o.backupskip = vim.o.backupskip .. ',/private/var/*,/tmp/*'
end

-- use the system clipboard. apparently it's better for nvim to delay setting this because sync with the
-- system clipboard can delay startup
vim.schedule(function()
  if vim.fn.has('linux') then
    vim.o.clipboard = 'unnamedplus'
  else
    vim.o.clipboard = 'unnamed'
  end
end)

-- persistent undo (unknown if the feature check is necessary now)
if vim.fn.has('persistent_undo') then
  -- save undo history (:help clear-undo)
  vim.o.undofile = true
  vim.o.undolevels = 1000
  -- don't create an undofile for skipped backup files (e.g. /tmp)
  vim.api.nvim_create_autocmd({ 'BufNewFile', 'BufReadPost', 'BufWritePre' }, {
    group = aug,
    pattern = vim.o.backupskip,
    callback = function()
      vim.bo.undofile = false
    end,
  })
end
