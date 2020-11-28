set nocompatible

" All the plugins
call plug#begin()

Plug 'alfredodeza/jacinto.vim'
Plug 'alfredodeza/khuno.vim'
Plug 'alfredodeza/pytest.vim'
Plug 'bling/vim-airline'
Plug 'chriskempson/base16-vim'
Plug 'fatih/vim-go', { 'do': ':GoUpdateBinaries' }
Plug 'godlygeek/tabular'
Plug 'hashivim/vim-terraform'
Plug 'inside/vim-search-pulse'
Plug 'mbbill/undotree'
Plug 'rust-lang/rust.vim'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-vinegar'
Plug 'vim-python/python-syntax'

call plug#end()

" I hate backups and swaps
set nowritebackup
set noswapfile
set nosmartindent
set ffs=unix

" Speeeeeeed
set lazyredraw
set ttyfast

" Clipboard, only use unnamed+ on linux
if system('uname -s') == 'Linux'
    set clipboard=unnamedplus
endif

" Leader key
let mapleader = "\<Space>"

" write shortcut
nn <Leader>w :w<CR>

" System clipboard
vmap <Leader>y "+y
vmap <Leader>d "+d
nmap <Leader>p "+p
nmap <Leader>P "+P
vmap <Leader>p "+p
vmap <Leader>P "+P

" Visual line
nmap <Leader><Leader> V

" Easier navigation
nmap <Leader>h <C-W>h
nmap <Leader>j <C-W>j
nmap <Leader>k <C-W>k
nmap <Leader>l <C-W>l

" tabs
nmap <Leader>tn :tabnew<CR>
nmap <Leader>tl :tabnext<CR>
nmap <Leader>th :tabprev<CR>
nmap <leader>tq :tabclose<CR>

inoremap # X<BS>#

" disable macro recording
map q <Nop>

set nowrap  " Don't wrap
set number  " Line numbers dammit

" Coloring and a hack for tmux. t_ut= will not override the background color
set t_Co=256
set t_ut=

" Syntax highlighting please
syntax on
filetype on
filetype plugin on
filetype indent on

" preferred color scheme
set background=dark

" yell if there is trailing whitespace
hi ExtraWhitespace ctermbg=red guibg=red
match ExtraWhitespace /\s\+$/

set scrolloff=5
set backspace=indent,eol,start
set visualbell
set history=10000

if has("gui_running")
    set guioptions-=T  " Nix the toolbar
    highlight SpellBad term=underline gui=undercurl guisp=Red
else
    " I should be able to see it
    highlight SpellBad term=standout ctermfg=white term=underline cterm=underline
    set mouse=c  " It's the terminal pal
endif

" add persistent undo
if has('persistent_undo')
    set undodir=$HOME/.vim/undo
    set undolevels=10000
    set undofile
endif

" Status Line
set laststatus=2
set encoding=utf-8
set showcmd

" Do searching how i prefer
set ignorecase
set smartcase
set hlsearch
set incsearch

set showmatch

" Leave it as the filename
set title

" Because zsh-like
set wildmode=list:longest,full
set wildmenu
set completeopt=menuone,longest,preview
set pumheight=5

set nocursorline  " Be careful...
set nocursorcolumn
set path=$PWD/**

" JSON should highlight as javascript
autocmd BufNewFile,BufRead *.json setlocal ft=javascript
autocmd BufNewFile,BufRead *.rb setlocal ft=ruby
autocmd BufNewFile,BufRead *.erb setlocal ft=eruby

" Cython code
" autocmd BufNewFile,BufRead *.pyx setlocal ft=python

" Code folding
set foldmethod=indent
set nofoldenable

" Autoindent python
autocmd BufRead,BufNewFile *.py set ai
autocmd BufRead,BufNewFile *.pyx set ai
autocmd BufRead *.py set smartindent cinwords=if,elif,else,for,while,with,try,except,finally,def,class
autocmd BufRead *.pyx set smartindent cinwords=if,elif,else,for,while,with,try,except,finally,def,class

" by default, expand tabs to 4 spaces
set tabstop=4 expandtab shiftwidth=4 softtabstop=4

" Ruby, etc -> indent 2 spaces
autocmd FileType ruby,haml,eruby,yaml,sass,cucumber,javascript,html set ai sw=2 sts=2 et

" Go uses tabs, not spaces
autocmd FileType go setlocal noexpandtab

" ---------------
" PLUGIN SETTINGS
" ---------------

" airline
let g:airline_powerline_fonts=1
let g:airline_detect_modified=1
let g:airline_section_z = '%3l/%L:%2c'
let g:airline_section_warning = "%{khuno#Status('X')}"

" khuno
let g:khuno_ignore='E731,E402'
let g:khuno_flake_cmd_options='--max-complexity 10'
let g:khuno_max_line_length=120

" netrw
let g:netrw_banner = 1
let g:netrw_liststyle = 3
let g:netrw_browse_split = 4
let g:netrw_altv = 1
let g:netrw_winsize = 25

" terraform
let g:terraform_align=1
let g:terraform_fmt_on_save=1
