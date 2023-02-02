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

  if delete(path) != 0
    echo 'failed to delete view'
  else
    echo 'deleted view: '.path
  endif
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

" my#utils#goto_mark {{{
" exposed as :M and :M! - lets you vsplit and split (respectively) jumping to a global file mark.
" example: `:M V` would vsplit to ~/.vimrc, `:M! Z` would split to ~/.zshrc
function! my#utils#goto_mark(mark, hsplit) abort
  exe (a:hsplit ? 'split' : 'vsplit') . " | norm '" . a:mark
endfunction
" }}}

" vi:fdm=marker
