" color utilities

scriptencoding utf-8

" opinionated mapping of terminal color codes. for 16 ansi color codes, each character is used
" to find the corresponding gui hex color from a palette
let s:term_palette='08B9DEC318BADEC7'

" opinionated naming for what each key 0-F in a color palette represents. when creating a
" colorscheme here, we'll export a named palette that has these keys
let s:color_names=[
  \ 'bg',
  \ 'bglight',
  \ 'selection',
  \ 'comment',
  \ 'fgdark',
  \ 'fg',
  \ 'unused1',
  \ 'unused2',
  \ 'red',
  \ 'orange',
  \ 'yellow',
  \ 'green',
  \ 'cyan',
  \ 'blue',
  \ 'magenta',
  \ 'deprecated',
  \ ]

" s:termcolor : get the number value for cterm[0-F] {{{
function! <SID>airline_colorset(palette, fgbg) abort
  let l:fg=a:fgbg[0]
  let l:bg=a:fgbg[1]

  " this is a little weird but the fg/bg string would be the hex value of the *position* in the
  " term_palette string. the char at that position is the hex value of the term number to use
  let l:termfg=str2nr(s:term_palette[str2nr(l:fg, 16)], 16)
  let l:termbg=str2nr(s:term_palette[str2nr(l:bg, 16)], 16)

  return [a:palette[l:fg], a:palette[l:bg], l:termfg, l:termbg]
endfunction
" }}}

" my#themes#to_airline : install a palette map as an airline theme {{{
function! my#themes#to_airline(name) abort
  " get the palette as a shorthand var
  let l:theme=g:my#themes#{a:name}#palette

  " configure the palette
  let l:palette={}

  " shorthand partial
  let l:Air=function('<SID>airline_colorset', [l:theme])

  " ones we use repetitively
  let l:x=l:Air('42')
  let l:y=l:Air('41')
  let l:z=l:Air('71')

  " standard colors
  let l:palette.normal=airline#themes#generate_color_map(l:Air('0B'), l:x, l:y)
  let l:palette.insert=airline#themes#generate_color_map(l:Air('0D'), l:x, l:y)
  let l:palette.replace=airline#themes#generate_color_map(l:Air('08'), l:x, l:y)
  let l:palette.visual=airline#themes#generate_color_map(l:Air('0E'), l:x, l:y)
  let l:palette.inactive=airline#themes#generate_color_map(l:Air('31'), l:Air('31'), l:Air('31'))

  " modified colors
  let l:palette.normal_modified={'airline_c': l:z}
  let l:palette.insert_modified={'airline_c': l:z}
  let l:palette.replace_modified={'airline_c': l:z}
  let l:palette.visual_modified={'airline_c': l:z}

  " export the palette
  let g:airline#themes#{a:name}#palette=l:palette

endfunction
" }}}

" my#themes#to_colorscheme : install a palette map as a theme {{{
function! my#themes#to_colorscheme(name) abort
  " get the palette
  let l:palette=g:my#themes#{a:name}#palette

  " track these values globally
  let g:my_theme=a:name
  let g:my_theme_palette=l:palette
  let g:my_theme_palette_named={}

  " update the named mapping
  let i=0
  while i < len(s:color_names)
    let g:my_theme_palette_named[s:color_names[i]] = l:palette[printf("%X", i)]
    let i+=1
  endwhile

  " terminal color configuration
  if has('terminal')
    let g:terminal_ansi_colors=[]
    for lookup in s:term_palette
      call add(g:terminal_ansi_colors, l:palette[lookup])
    endfor
  endif

  " neovim terminal colors {{{
  if has('nvim')
    for i in range(0, 15)
      let g:terminal_color_{i}=l:palette[s:term_palette[i]]
    endfor

    let g:terminal_color_background = g:terminal_color_0
    let g:terminal_color_foreground = g:terminal_color_5

    if &background == "light"
      let g:terminal_color_background = g:terminal_color_7
      let g:terminal_color_foreground = g:terminal_color_2
    endif
  endif
  " }}}

  " clear syntax and set the theme
  hi clear
  syntax reset
  let g:colors_name = a:name

  if has('termguicolors') && &termguicolors
    let l:category='gui'
  else
    let l:category='cterm'
  endif

  " shorthand function partial to highlight the requested category with the palette
  let l:Hi=function('<SID>hi', [l:palette, l:category])

  " editor colors {{{
  call l:Hi('.1', 'ColorColumn', 'CursorColumn', 'CursorLine', 'QuickFixLine')
  call l:Hi('.2', 'Visual')
  call l:Hi('.3', 'PMenuSbar')
  call l:Hi('.4', 'PMenuThumb')
  call l:Hi('08', 'Error', 'ErrorMsg')
  call l:Hi('10', 'VertSplit')
  call l:Hi('19', 'IncSearch')
  call l:Hi('1A', 'Search', 'Substitute')
  call l:Hi('20', 'Folded')
  call l:Hi('3.', 'MatchParen', 'SpecialKey', 'NonText', 'Whitespace')
  call l:Hi('30', 'LineNr', 'SignColumn')
  call l:Hi('31', 'StatusLineNC', 'TabLine', 'TabLineFill')
  call l:Hi('32', 'FoldColumn')
  call l:Hi('41', 'StatusLine', 'CursorLineNr')
  call l:Hi('50', 'Normal', 'WildMenu', 'Cursor')
  call l:Hi('62', 'PMenu')
  call l:Hi('62', 'PMenuSel')
  call l:Hi('8.', 'Debug', 'Macro', 'Exception', 'TooLong', 'Underlined', 'VisualNOS', 'WarningMsg')
  call l:Hi('B.', 'ModeMsg', 'MoreMsg')
  call l:Hi('B1', 'TabLineSel')
  call l:Hi('D.', 'Directory', 'Question', 'Title')
  call l:Hi('D0', 'Conceal')

  " because i forget about it all the time: make vim9 style comments loud
  call l:Hi('08', 'vim9Comment')

  " highlight trailing whitespace
  hi link ExtraWhitespace Error
  match ExtraWhitespace /\s\+$/

  call <SID>hi_attr('bold', 'Bold', 'CursorLineNr')
  call <SID>hi_attr('italic', 'Italic')
  call <SID>hi_attr('reverse', 'ErrorMsg', 'WildMenu')
  call <SID>hi_attr('NONE',
    \ 'Substitute',
    \ 'CursorColumn',
    \ 'ColorColumn',
    \ 'CursorLine',
    \ 'QuickFixLine',
    \ 'StatusLineNC',
    \ 'TabLine',
    \ 'TabLineFill',
    \ 'Title',
    \ 'IncSearch',
    \ 'StatusLine',
    \ 'VertSplit',
    \ 'PMenu',
    \ 'TabLineSel',
    \)
  " }}}

  " customization options {{{
  " what color should be used for Folded
  if has_key(g:, 'my_theme_fold')
    exe 'hi Folded guibg=' . g:my_theme_palette_named.bg . ' guifg=' . g:my_theme_fold
  endif

  " should we sync the color of FoldColumn with whatever Folded is
  if get(g:, 'my_theme_sync_fold_color', 1) == 1
    call <SID>hi_link('Folded', 'FoldColumn')
  endif

	" minimal cursorline info
  if get(g:, 'my_theme_minimal_cursorline', 1) == 1
    hi clear CursorLine
    exe 'hi CursorLineNr guifg=' . g:my_theme_palette_named.orange
  endif

  " make the current line number stand out
  if get(g:, 'my_theme_cursorline_color', '') !=# ''
    exe 'hi CursorLineNr guifg=' . g:my_theme_palette_named[g:theme_cursorline_color]
  endif
  " }}}

  " core syntax {{{
  call l:Hi('3.', 'Comment')
  call l:Hi('5.', 'Delimiter', 'Operator')
  call l:Hi('8.', 'Character', 'Identifier', 'Statement')
  call l:Hi('9.', 'Boolean', 'Constant', 'Number', 'Float')
  call l:Hi('A.', 'Label', 'PreProc', 'StorageClass', 'Tag', 'Type', 'Typedef')
  call l:Hi('A1', 'Todo')
  call l:Hi('B.', 'String')
  call l:Hi('C.', 'Special', 'SpecialChar')
  call l:Hi('D.', 'Function', 'Include')
  call l:Hi('E.', 'Conditional', 'Define', 'Keyword', 'Repeat', 'Structure')

  call <SID>hi_attr('NONE', 'Identifier', 'Define', 'Operator', 'Type')
  " }}}

  " highlights for common plugins {{{
  call l:Hi('08', 'ErrorHighlight', 'SpellBad')
  call l:Hi('09', 'WarningHighlight')
  call l:Hi('0C', 'HintHighlight', 'SpellLocal')
  call l:Hi('0D', 'InfoHighlight', 'SpellCap')
  call l:Hi('0E', 'SpellRare')
  call l:Hi('18', 'ReferenceWrite')
  call l:Hi('1A', 'ReferenceText')
  call l:Hi('1B', 'ReferenceRead')
  call l:Hi('4.', 'GitChangeSign', 'GitChangeDeleteSign')
  call l:Hi('8.', 'ErrorSign', 'GitDeleteSign')
  call l:Hi('81', 'ErrorFloat')
  call l:Hi('9.', 'WarningSign')
  call l:Hi('91', 'WarningFloat')
  call l:Hi('B.', 'GitAddSign')
  call l:Hi('C.', 'HintSign', 'SearchMatch')
  call l:Hi('C1', 'HintFloat')
  call l:Hi('D.', 'InfoSign')
  call l:Hi('D1', 'InfoFloat')

  call <SID>hi_attr('strikethrough', 'Deprecated')
  call <SID>hi_attr('underline', 'ErrorHighlight', 'WarningHighlight', 'InfoHighlight', 'HintHighlight')
  call <SID>hi_attr('undercurl', 'SpellBad', 'SpellLocal', 'SpellCap', 'SpellRare')
  " }}}

  " diff {{{
  call l:Hi('20', 'DiffDelete')
  call l:Hi('51', 'DiffChange')
  call l:Hi('80', 'DiffFile', 'DiffRemoved')
  call l:Hi('B0', 'DiffAdded', 'DiffNewFile')
  call l:Hi('B1', 'DiffAdd')
  call l:Hi('D0', 'DiffLine')
  call l:Hi('D1', 'DiffText')
  " }}}

  " markdown {{{
  " builtin markdown
  call l:Hi('3.', 'markdownCode', 'markdownCodeBlock')
  call l:Hi('50', 'markdownError')
  call l:Hi('D.', 'markdownHeadingDelimiter')
  call l:Hi('3.', 'markdownCodeDelimiter')

  " vim-markdown
  call <SID>hi_link('Title', 'mkdHeading')
  call <SID>hi_link('Comment', 'mkdCode', 'mkdCodeStart', 'mkdCodeEnd', 'mkdCodeDelimiter')
  call l:Hi('9.', 'mkdLink')
  call l:Hi('C.', 'mkdURL')
  call <SID>hi_attr('reverse', 'htmlBold', 'mkdBold')
  " }}}

  " ALE {{{
  " keep error signs the same (red bg, black fg) but change warnings to effectively reverse (yellow bg, black fg)
  call l:Hi('08', 'ALEErrorSign', 'ALEFloatingPreviewError', 'ALEFloatingPreviewStyleError')
  call l:Hi('09', 'ALEWarningSign', 'ALEFloatingPreviewWarning', 'ALEFloatingPreviewStyleWarning')
  call <SID>hi_attr('reverse',
    \ 'ALEFloatingPreviewError',
    \ 'ALEFloatingPreviewStyleError',
    \ 'ALEFloatingPreviewWarning',
    \ 'ALEFloatingPreviewStyleWarning')
  " }}}
endfunction
" }}}

" func s:hi() {{{
function! <SID>hi(palette, category, fgbg, ...)
  let l:fg=a:fgbg[0]
  let l:bg=a:fgbg[1]

  let l:params=''

  if has_key(a:palette, l:fg)
    let l:params=printf("%s %sfg='%s'", l:params, a:category, a:palette[l:fg])
  endif

  if has_key(a:palette, l:bg)
    let l:params=printf("%s %sbg='%s'", l:params, a:category, a:palette[l:bg])
  endif

  for name in a:000
    exe 'hi ' . name . ' ' . l:params
  endfor
endfunction
" }}}

" func s:hi_attr() {{{
function! <SID>hi_attr(attr, ...)
  for name in a:000
    exe printf("hi %s gui='%s' cterm='%s'", name, a:attr, a:attr)
  endfor
endfunction
" }}}

" func s:hi_link {{{
function! <SID>hi_link(target, ...)
  for name in a:000
    exe 'hi! link ' . name . ' ' . a:target
  endfor
endfunction
" }}}

" vi:fdm=marker
