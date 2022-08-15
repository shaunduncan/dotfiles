" utility junk drawer

scriptencoding utf-8

" my#utils#zip : like python zip() {{{
function! my#utils#zip(l0, l1) abort
  let l:map={}

  let i=0
  while i < len(a:l0)
    let l:map[a:l0[i]] = a:l1[i]
    let i+=1
  endwhile

  return l:map
endfunction
" }}}

" my#utils#highlight_groups : get hi groups for cursor pos {{{
function! my#utils#highlight_groups() abort
  return map(synstack(line('.'), col('.')), 'synIDattr(v:val, "name")')
endfunction
" }}}

" my#utils#set_marker_surround : update vim-surround for foldmarkers {{{
"
" meant to be used with BufEnter autocommand, this will use the current buffer's foldmarker, if set,
" and update vim-surround settings for chars 'm' and 'M'. these act the following ways:
"
" m : surround the selection with just foldmarker comments
" M : prompt for a label and prepend this to the foldmarker comment
"
function! my#utils#set_marker_surround() abort
  if &commentstring ==# '' || &foldmarker ==# ''
    return
  endif

  let l:markers=split(&foldmarker, ',')
  if len(l:markers) != 2
    return
  endif

  " single % signs will break printf - don't allow any surprises
  let l:cms=substitute(&commentstring, '%\([^%a-zA-Z0-9]\)', '%%\1', 'g')

  let g:surround_{char2nr('m')}=printf(l:cms, l:markers[0]) ."\r" . printf(l:cms, l:markers[1])
  let g:surround_{char2nr('M')}=printf(l:cms, '') . "\1label: \1 " . l:markers[0] . "\r" . printf(l:cms, l:markers[1])
endfunction
" }}}

" my#utils#delete_view() : delete saved view for the current buffer {{{
function! my#utils#delete_view() abort
  let path=fnamemodify(bufname('%'), ':p')
  let path=substitute(path, '=', '==', 'g')

  if !empty($HOME)
    let path=substitute(path, '^'.$HOME, '\~', '')
  endif

  let path=&viewdir . '/' . substitute(path, '/', '=+', 'g') . '='

  call delete(path)

  echo 'deleted view: '.path
endfunction
" }}}

" my#utils#decorated_yank() : annotated v-block yank {{{
" this will copy a visual block and annotate it with the the filename and line number
function! my#utils#decorated_yank() abort
  redir @n | silent! :'<,'>number | redir END
  let filename=expand("%")
  let decoration=repeat('-', len(filename)+1)
  let @*=decoration."\n" . filename . ':' . "\n" . decoration . "\n" . @n
endfunction
" }}}

" my#utils#get_foldtext() {{{
" inspiration from: https://github.com/jrudess/vim-foldtext/blob/master/plugin/foldtext.vim
function! my#utils#get_foldtext(full=1) abort
  " shorthand
  let l:fs=v:foldstart
  let l:fe=v:foldend

  " separator between start/end
  let l:sep='  '

  let l:start=getline(v:foldstart)
  let l:end=getline(v:foldend)

  if a:full == 0
    let l:end=''
    let l:sep=''
  endif

  " special case: if we have folding set on a marker, don't include it
  if &foldmethod == 'marker'
    let l:markers=split(&foldmarker, ',')

    let l:start=substitute(l:start, '[\s\t]*'.l:markers[0].'$', '', 'g')
    let l:end=''
    let l:sep=''
  endif

  " the whitespace patterns
  let l:wsLead='^[\s\t]*'
  let l:wsTrail='[\s\t]*$'

  " get each line with trailing whitespace removed
  let l:start=substitute(l:start l:wsTrail, '', 'g')
  let l:end=substitute(l:end, l:wsTrail, '', 'g')

  " for the start, convert leading tabs to spaces
  let l:lspaces=repeat(' ', &tabstop)
  let l:start=substitute(matchstr(l:start, l:wsLead), '\t', l:lspaces, 'g') . substitute(l:start, l:wsLead, '', 'g')

  " for the end, strip leading whitespace
  let l:end=substitute(l:end, '^[\s\t]*', '', 'g')

  " put them together to create the snippet
  let l:snippet=l:start . l:sep . l:end
  let l:info= '[' . (v:foldend - v:foldstart). ']'

  " fill the empty space
  let l:signwidth=2
  let l:width=winwidth(0) - &numberwidth - &foldcolumn - l:signwidth
  let l:fill=repeat('─', (l:width - len(l:snippet) - len(l:info) - 3))

  return l:snippet . ' ' . l:fill . ' ' . l:info
endfunction
" }}}

" vi:fdm=marker
