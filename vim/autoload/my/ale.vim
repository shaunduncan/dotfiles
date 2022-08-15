" ALE specific functions

" my#ale#get_popup_opts : get opts for floating preview popup {{{
function! my#ale#get_popup_opts(...) abort
  let [l:info, l:loc]=ale#util#FindItemAtCursor(bufnr(''))

  return {
  \ 'title': ' ALE: ' . (l:loc.linter_name) . ' ',
  \ 'line': 1,
  \ 'col': &columns,
  \ 'pos': 'topright',
  \ 'fixed': 0,
  \ 'padding': [0, 1, 0, 1],
  \ 'minwidth': 40,
  \ 'maxwidth': min([80, &columns]),
  \ 'wrap': 1,
  \ 'border': [1, 1, 1, 1],
  \ 'borderchars': g:my_box_double_tb,
  \ 'moved': 'any',
  \ 'highlight': my#ale#get_highlight_group(l:loc),
  \}
  endif
endfunction
" }}}

" my#ale#get_hightlight_group : floating preview hi group at loc {{{
function! my#ale#get_highlight_group(loc) abort
  let l:hi_name='ALEFloatingPreview'

  " is this a style item
  if get(a:loc, 'sub_type', '') is# 'style'
    let l:hi_name .= 'Style'
  endif

  let l:type=get(a:loc, 'type', 'E')

  if l:type is# 'E'
    let l:hi_name .= 'Error'
  elseif l:type is# 'W'
    let l:hi_name .= 'Warning'
  else
    let l:hi_name .= 'Info'
  endif

  return l:hi_name
endfunction
" }}}

" vi:fdm=marker
