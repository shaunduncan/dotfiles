" golang specific functions

" my#go#set_format_mode : configure how auto formatting works {{{
"
" full: auto format code and imports with gopls
" simple: only format code with gofmt
" none: perform no auto formatting
function! my#go#set_format_mode(mode) abort
  if a:mode ==? 'none'
    let g:go_fmt_autosave=0
    let g:go_imports_autosave=0
  elseif a:mode ==? 'simple'
    let g:go_fmt_autosave=1
    let g:go_fmt_command='gofmt'
    let g:go_imports_autosave=0
  elseif a:mode ==? 'full'
    let g:go_fmt_autosave=1
    let g:go_fmt_command='gopls'
    let g:go_imports_autosave=1
  endif
endfunction
" }}}

" my#go#set_gopls_local : set the gopls local package prefix {{{
" NOTE: this is likely unnecessary - the gopls setting in vim-go can accept a string
function! my#go#set_gopls_local() abort
  let g:go_gopls_local=trim(system('{cd '. shellescape(expand('%:h')) .' && go list -m;}'))
endfunction
" }}}

" vi:fdm=marker
