set nocompatible
behave mswin

silent! call pathogen#infect()
set nowritebackup
set noswapfile
set nosmartindent
inoremap # X<BS>#

set nowrap

syntax on
filetype on
filetype plugin on
filetype indent on

set scrolloff=5
set backspace=indent,eol,start
set vb

if has("gui_running")
    set guifont=Consolas:h11
    highlight SpellBad term=underline gui=undercurl guisp=Red
else
    set mouse=n
endif

set laststatus=2
set encoding=utf-8
set nofoldenable

set statusline=
set statusline+=%1*
set statusline+=%-4{fugitive#statusline()}
set statusline+=%*
set statusline+=%{Collapse(expand('%:p'))}   " absolute path truncated
set statusline+=%*%m%r%h%w
"set statusline+=\ \ \ %{Collapse(getcwd())}  " current working dir truncated
set statusline+=%=                           " right align
set statusline+=\ \ \ \ %y                   " what the file type
set statusline+=[
set statusline+=%3l/                         " Line number with padding
set statusline+=%L                           " Total lines in the file
set statusline+=:%2c                         " column number
set statusline+=]

set ignorecase
set smartcase
map N Nzz
map n nzz
set title
set hlsearch
set incsearch
set showmatch

set wildmode=list:longest,full
set wildmenu

set completeopt=menuone,longest,preview
set pumheight=6

set showcmd
set cul
set number
set path=$PWD/**

let g:molokai_original=1
colorscheme molokai

set listchars=trail:-
highlight SpecialKey term=standout ctermbg=white guibg=black

autocmd FileType html,xhtml,xml setlocal expandtab shiftwidth=2 tabstop=2 softtabstop=2
autocmd FileType make setlocal shiftwidth=4 tabstop=4 softtabstop=4
autocmd BufNewFile,BufRead *.mako,*.mak setlocal ft=html
autocmd BufNewFile,BufRead *.json setlocal ft=javascript

autocmd BufRead,BufNewFile *.py syntax on
autocmd BufRead,BufNewFile *.py set ai
autocmd BufRead *.py set smartindent cinwords=if,elif,else,for,while,with,try,except,finally,def,class
set tabstop=4 expandtab shiftwidth=4 softtabstop=4
let g:netrw_list_hide='^\.,.\(pyc\|pyo\|o\)$'

hi Cursor guifg=black guibg=magenta
" #a0ee40 guifg=#000000
hi User1 guibg=#A6E22E guifg=#222222
" hi User1 guibg=#FF9933 guifg=#222222


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

function! Getcwd()
    let current_dir = getcwd()
    let current_path = expand("%:p:h")
    if current_dir == current_path
        return ""
    else
        return "cwd: " .current_dir
    endif
endfunction
