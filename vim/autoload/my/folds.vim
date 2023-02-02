" functions supporting fold behaviors

" my#folds#foldtext() {{{
" inspiration from: https://github.com/jrudess/vim-foldtext/blob/master/plugin/foldtext.vim
function! my#folds#foldtext(full=1, ltrim='', rtrim='') abort
  " shorthand
  let l:fs = v:foldstart
  let l:fe = v:foldend

  " separator between start/end
  let l:sep = '  '

  let l:start = getline(l:fs)
  let l:end = getline(l:fe)

  if a:full == 0
    let l:end = ''
    let l:sep = ''
  endif

  " special case: if we have folding set on a marker, don't include it
  if &foldmethod == 'marker'
    let l:markers = split(&foldmarker, ',')

    let l:start = substitute(l:start, '[\s\t]*'.l:markers[0].'$', '', 'g')
    let l:end = ''
    let l:sep = ''
  endif

  " the whitespace patterns
  let l:ws_lead = '^[\s\t]*'
  let l:ws_trail = '[\s\t]*$'

  " get each line with trailing whitespace removed
  let l:start = substitute(l:start l:ws_trail, '', 'g')
  let l:end = substitute(l:end, l:ws_trail, '', 'g')

  " for the start, convert leading tabs to spaces
  let l:lspaces = repeat(' ', &tabstop)
  let l:start = substitute(matchstr(l:start, l:ws_lead), '\t', l:lspaces, 'g') . substitute(l:start, l:ws_lead, '', 'g')

  " for the end, strip leading whitespace
  let l:end = substitute(l:end, '^[\s\t]*', '', 'g')

  " put them together to create the snippet
  let l:snippet = l:start . l:sep . l:end
  let l:snippet = trim(l:snippet, a:ltrim, 1)
  let l:snippet = trim(l:snippet, a:rtrim, 2)
  let l:info = '[' . (v:foldend - v:foldstart). ']'

  " fill the empty space
  let l:signwidth=2
  let l:width = winwidth(0) - &numberwidth - &foldcolumn - l:signwidth
  let l:fill = repeat('─', (l:width - len(l:snippet) - len(l:info) - 3))

  return l:snippet . ' ' . l:fill . ' ' . l:info
endfunction
" }}}

" vi:fdm=marker
