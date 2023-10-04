" my autoloads

scriptencoding utf-8

" box borderchars (top, right, bottom, left, top L, top R, bot R, bot L) {{{
let g:my_box_normal    = ['─', '│', '─', '│', '┌', '┐', '┘', '└']
let g:my_box_rounded   = ['─', '│', '─', '│', '╭', '╮', '╯', '╰']
let g:my_box_dashed    = ['╌', '╎', '╌', '╎', '┌', '┐', '┘', '└']
let g:my_box_dotted    = ['┈', '┊', '┈', '┊', '┌', '┐', '┘', '└']
let g:my_box_heavy     = ['━', '┃', '━', '┃', '┏', '┓', '┛', '┗']
let g:my_box_heavy_tb  = ['━', '│', '━', '│', '┍', '┑', '┙', '┕']
let g:my_box_double_tb = ['═', '│', '═', '│', '╒', '╕', '╛', '╘']

let g:my_nbox_normal    = ['─', '│', '─', '│', '┌', '┐', '┘', '└']
let g:my_nbox_rounded   = ['─', '│', '─', '│', '╭', '╮', '╯', '╰']
let g:my_nbox_dashed    = ['╌', '╎', '╌', '╎', '┌', '┐', '┘', '└']
let g:my_nbox_dotted    = ['┈', '┊', '┈', '┊', '┌', '┐', '┘', '└']
let g:my_nbox_heavy     = ['━', '┃', '━', '┃', '┏', '┓', '┛', '┗']
let g:my_nbox_heavy_tb  = ['━', '│', '━', '│', '┍', '┑', '┙', '┕']
let g:my_nbox_double_tb = ['╒', '═', '╕', '│', '╛', '═', '╘', '│']
" }}}

" shorthand: split and vsplit global file marks
command! -nargs=1 -bang M call my#utils#goto_mark(<f-args>, <bang>0)

" vi:fdm=marker
