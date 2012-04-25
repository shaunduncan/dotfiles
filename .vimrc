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
set statusline+=%-4{GitStatusline()}
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
set guioptions-=T

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

let NERDTreeIgnore=['\.vim$', '\~$', '\.pyc$']

" FUNCTIONS
function! ToggleIDE()
    NERDTreeToggle
    TagbarToggle
endfunction

command! IDE call ToggleIDE()

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

" Fugitive Customization
autocmd BufWritePost,BufReadPost,BufNewFile,BufEnter * call s:SetGitModified()

function! s:SetGitModified() abort
  if !exists('b:git_dir')
    return ''
  endif
  let repo_name = RepoHead()
  let modified = GitIsModified() ? '*' : ''
  let b:git_statusline = '['.repo_name.modified.']'
endfunction

function! FindGit(type) abort
    let found = finddir(".git", ".;")
    if (found !~ '.git')
        return ""
    endif
    " Return the actual directory where .coverage is found
    if a:type == "dir"
        return fnamemodify(found, ":h")
    else
        return found
    endif
endfunction

function! GitIsModified() abort
    let rvalue = 0
    " First try to see if we actually have a .git dir
    let has_git = FindGit('dir')
    if (has_git == "")
        return rvalue
    else
        let original_dir = getcwd()
        " change dir to where coverage is
        " and do all the magic we need
        if original_dir
            exe "cd " . has_git
            let cmd = "git status -s 2> /dev/null""
            let out = system(cmd)
            if out != ""
                let rvalue = 1
            endif
            " Finally get back to where we initially where
            exe "cd " . original_dir
            return rvalue
        else
            return ''
    endif
endfunction

function! RepoHead() abort
  let path = FindGit('repo') . '/HEAD'
  if ! filereadable(path)
      return 'NoBranch'
  endif
  let repo_name = ''
  let repo_line =  readfile(path)[0]

  if repo_line =~# '^ref: '
    let repo_name .= substitute(repo_line, '\v^(.*)/','', '')
  elseif repo_line =~# '^\x\{40\}$'
    let repo_name .= repo_line[0:7]
  endif
  return repo_name
endfunction

function! GitStatusline() abort
  " Note: Works just as long as fugitive is installed
  " should remove the depedency
  if exists('b:git_statusline')
      return b:git_statusline
  endif
  if !exists('b:git_dir')
      return ''
  else
      let repo_name = RepoHead()
      return '['.repo_name.']'
  endif
  return ''
endfunction

