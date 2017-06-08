set nocompatible

" All the plugins
silent! call pathogen#infect()

" I hate backups and swaps
set nowritebackup
set noswapfile
set nosmartindent
set ffs=unix

" Speeeeeeed
set lazyredraw
set ttyfast

" Clipboard
set clipboard=unnamedplus

" Leader
let mapleader = "\<Space>"

" Write quickness
nnoremap <Leader>w :w<CR>

" System clipboard
vmap <Leader>y "+y
vmap <Leader>d "+d
nmap <Leader>p "+p
nmap <Leader>P "+P
vmap <Leader>p "+p
vmap <Leader>P "+P

" Visual line
nmap <Leader><Leader> V

inoremap # X<BS>#

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

set background=dark
colorscheme Tomorrow-Night-Bright

" X(name, fg, bg, attr, lcfg, lcbg
" hi <name> ctermfg=<lcfg> ctermbg=<lcbg>

hi ExtraWhitespace ctermbg=red guibg=red
match ExtraWhitespace /\s\+$/

set scrolloff=5
set backspace=indent,eol,start
set visualbell
set history=10000

" I can haz gui?
if has("gui_running")
    set guioptions-=T  " Nix the toolbar
    highlight SpellBad term=underline gui=undercurl guisp=Red
else
    " I should be able to see it
    highlight SpellBad term=standout ctermfg=white term=underline cterm=underline
    set mouse=c  " It's the terminal pal
endif

if has('persistent_undo')
    set undodir=$HOME/.vim/undo
    set undolevels=10000
    set undofile
endif

" Status Line
set laststatus=2
set encoding=utf-8
set showcmd

"set statusline=
"set statusline+=%*
"set statusline+=%-4{VenvName()}              " Where the hell am I working?
"set statusline+=%*
"set statusline+=%-4{bondsman#Bail()}         " Show the git state
"set statusline+=%*
"set statusline+=%{Collapse(expand('%:p'))}   " Trancated path
"set statusline+=%*%m%r%h%w
"set statusline+=%=                           " right align
"set statusline+=\ \ \ \ %y                   " the type of file
"set statusline+=[
"set statusline+=%3l/                         " Line number with padding
"set statusline+=%L                           " Total lines in the file
"set statusline+=:%2c                         " column number
"set statusline+=]
"
"" " Highlight flake errors
"set statusline+=%#ErrorMsg#
"set statusline+=%{khuno#Status('X')}%*
"set statusline+=%*

let g:airline_powerline_fonts=1
let g:airline_detect_modified=1
let g:airline_section_z = '%3l/%L:%2c'
let g:airline_section_warning = "%{khuno#Status('X')}"

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

set tabstop=4 expandtab shiftwidth=4 softtabstop=4

" Ruby, etc -> indent 2 spaces
autocmd FileType ruby,haml,eruby,yaml,sass,cucumber,javascript,html set ai sw=2 sts=2 et

" Go uses tabs, not spaces
autocmd FileType go setlocal noexpandtab

" Use ag not ack for searching
if executable('ag')
    command Ag Ack
    let g:ackprg = 'ag --nogroup --nocolor --column'
endif

" PLUGIN SETTINGS
let g:khuno_ignore='E731,E402'
let g:khuno_flake_cmd_options='--max-complexity 10'
let g:khuno_max_line_length=120
let g:coveragepy_rcfile='~/.coveragerc'
let g:gist_clip_command='xclip -selection clipboard'
let g:gist_detect_filetype=1
let g:gist_open_browser_after_post=1
let g:gist_browser_command='chromium %URL% &'
let g:gist_show_privates=1
let g:gist_post_private=1

" FUNCTIONS
function! Collapse(string)
    let threshold = 30
    let total_length = len(a:string)
    if total_length > threshold
        let difference = total_length - threshold
        return ' ...' . strpart(a:string, difference)
    else
        return a:string
    endif
endfunction

function! VenvName() abort
    let full_path = expand("%:p")
    if strpart(full_path,0,12) == '/Volumes/HDD'
        let full_path = strpart(full_path,12)
    endif

    let path_elems = split(full_path,'/')
    let venv_name = ''
    if len(path_elems) > 2
        if path_elems[0] == 'opt' && (path_elems[1] == 'devel' || path_elems[1] == 'forks')
            let venv_name = path_elems[2]
            if strpart(venv_name,0,4) == 'cms_'
                let venv_name = strpart(venv_name,4)
            endif
            return '['.toupper(venv_name).']'
        endif
        return ''
    endif
    return ''
endfunction
