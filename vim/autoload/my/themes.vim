" color utilities

scriptencoding utf-8

" opinionated mapping of terminal color codes. for 16 ansi color codes, each character is used
" to find the corresponding gui hex color from a palette
let s:term_palette='08B9DFC318BADFC7'

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
  \ 'purple',
  \ 'magenta',
  \ ]

" s:termcolor : get the number value for cterm[0-F] {{{
function! <SID>termcolor(color) abort
  return str2nr(s:term_palette[str2nr(a:color, 16)], 16)
endfunction
" }}}


" hlget is a vim/neovim compatible way to get a highlight group {{{
function! <SID>hlget(...) abort
  if !has('nvim')
    " vim
    return call('hlget', a:000)
  else
    " neovim
    return [nvim_get_hl(0, {'name': a:1, 'link': get(a:000, 1, v:true)})]
  endif
endfunction
" }}}

" hlset is a vim/neovim compatible way to set a highlight group {{{
function! <SID>hlset(...) abort
  if !has('nvim')
    " vim
    return call('hlset', a:000)
  else
    " neovim
    for cfg in a:1
      " remove incompatible keys
      let l:name = remove(cfg, 'name')

      " invalid
      if has_key(cfg, 'gui')
        call remove(cfg, 'gui')
      endif

      " convert
      for key in ['guifg', 'guibg']
        if has_key(cfg, key)
          let cfg[substitute(key, 'gui', '', '')] = remove(cfg, key)
        endif
      endfor

      call nvim_set_hl(0, l:name, cfg)
    endfor
  endif
endfunction
" }}}

" s:airline_colorset: get the colorset list of term numbers for airline themes {{{
function! <SID>airline_colorset(palette, fgbg) abort
  let l:fg = a:fgbg[0]
  let l:bg = a:fgbg[1]

  let l:guifg = ''
  let l:termfg = ''

  let l:guibg = ''
  let l:termbg = ''

  " this is a little weird but the fg/bg string would be the hex value of the *position* in the
  " term_palette string. the char at that position is the hex value of the term number to use
  if has_key(a:palette, l:fg)
    let l:guifg = a:palette[l:fg]
    let l:termfg = <SID>termcolor(l:fg)
  endif

  if has_key(a:palette, l:bg)
    let l:guibg = a:palette[l:bg]
    let l:termbg = <SID>termcolor(l:bg)
  endif

  return [l:guifg, l:guibg, l:termfg, l:termbg]
endfunction
" }}}

" my#themes#to_airline : install a palette map as an airline theme {{{
function! my#themes#to_airline(name) abort
  " get the palette as a shorthand var
  let l:theme = g:my#themes#{a:name}#palette

  " configure the palette
  let l:palette = {}

  " shorthand partial
  let l:Air = function('<SID>airline_colorset', [l:theme])

  " ones we use repetitively
  let l:x = l:Air('42')
  let l:y = l:Air('41')
  let l:z = l:Air('71')

  let l:err = l:Air('08')
  let l:warn = l:Air('09')

  " standard mode colors:
  " normal    black on green
  " insert    black on blue
  " replace   black on red
  " command   black on orange
  " visual    black on yellow
  " terminal  black on magenta
  " inactive  gray on darkgray
  let l:palette.normal = airline#themes#generate_color_map(l:Air('0B'), l:x, l:y)
  let l:palette.insert = airline#themes#generate_color_map(l:Air('0D'), l:x, l:y)
  let l:palette.replace = airline#themes#generate_color_map(l:Air('08'), l:x, l:y)
  let l:palette.commandline = airline#themes#generate_color_map(l:Air('09'), l:x, l:y)
  let l:palette.visual = airline#themes#generate_color_map(l:Air('0A'), l:x, l:y)
  let l:palette.terminal = airline#themes#generate_color_map(l:Air('0F'), l:x, l:y)
  let l:palette.inactive = airline#themes#generate_color_map(l:Air('31'), l:Air('31'), l:Air('31'))

  " modified and error/warning colors
  " FIXME: there is also one called airline_term, what does it do
  for mode in ['normal', 'commandline', 'insert', 'replace', 'visual', 'terminal']
    let l:palette[mode.'_modified'] = {
      \ 'airline_c': l:z,
      \ 'airline_error': l:err,
      \ 'airline_warning': l:warn
      \ }

    let l:palette[mode]['airline_error'] = l:err
    let l:palette[mode]['airline_warning'] = l:warn
  endfor

  " accents: ensure they match our palette
  let l:palette.accents = {
      \ 'red': l:Air('8.'),
      \ 'orange': l:Air('9.'),
      \ 'yellow': l:Air('A.'),
      \ 'green': l:Air('B.'),
      \ 'blue': l:Air('D.'),
      \ 'purple': l:Air('E.'),
    \ }

  " export the palette
  let g:airline#themes#{a:name}#palette = l:palette

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
  call l:Hi('20', 'VertSplit')
  call l:Hi('19', 'IncSearch')
  call l:Hi('1A', 'Search', 'Substitute')
  call l:Hi('20', 'Folded')
  call l:Hi('3.', 'SpecialKey', 'NonText', 'Whitespace')
  call l:Hi('30', 'LineNr', 'SignColumn')
  call l:Hi('31', 'StatusLineNC', 'TabLine', 'TabLineFill')
  call l:Hi('32', 'FoldColumn')
  call l:Hi('41', 'StatusLine', 'CursorLineNr')
  call l:Hi('50', 'Normal', 'WildMenu', 'Cursor')
  call l:Hi('60', 'Pmenu', 'PmenuSel')
  call l:Hi('8.', 'Debug', 'Macro', 'Exception', 'TooLong', 'VisualNOS', 'WarningMsg')
  call l:Hi('9.', 'Underlined')
  call l:Hi('A0', 'MatchParen')
  call l:Hi('B.', 'ModeMsg', 'MoreMsg')
  call l:Hi('B1', 'TabLineSel')
  call l:Hi('D.', 'Directory', 'Question', 'Title')
  call l:Hi('D0', 'Conceal')

  if has('nvim')
    call l:Hi('40', 'FloatBorder', 'FloatTitle')
  endif

  " because i forget about it all the time: make vim9 style comments loud
  call l:Hi('08', 'vim9Comment')

  " highlight trailing whitespace
  hi link ExtraWhitespace Error
  match ExtraWhitespace /\s\+$/

  call <SID>hi_attr('bold', 'Bold', 'CursorLineNr')
  call <SID>hi_attr('italic', 'Italic')
  call <SID>hi_attr('reverse', 'ErrorMsg', 'WildMenu', 'MatchParen')
  call <SID>hi_attr('underline', 'Underlined')
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
    exec 'hi Folded guibg=' . g:my_theme_palette_named.bg . ' guifg=' . g:my_theme_fold
  endif

  " should we sync the color of FoldColumn with whatever Folded is
  if get(g:, 'my_theme_sync_fold_color', 1) == 1
    call <SID>hi_link('Folded', 'FoldColumn')
  endif

	" minimal cursorline info
  if get(g:, 'my_theme_minimal_cursorline', 1) == 1
    hi clear CursorLine
    exec 'hi CursorLineNr guifg=' . g:my_theme_palette_named.orange
  endif

  " make the current line number stand out
  if get(g:, 'my_theme_cursorline_color', '') !=# ''
    exec 'hi CursorLineNr guifg=' . g:my_theme_palette_named[g:theme_cursorline_color]
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

  " common highlights {{{
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

  " fzf {{{
  " fzf1: ctermfg=161 ctermbg=238 guifg=#E12672 guibg=#565656
  " fzf2: ctermfg=151 ctermbg=238 guifg=#BCDDBD guibg=#565656
  " fzf3: ctermfg=252 ctermbg=238 guifg=#D9D9D9 guibg=#565656
  " call l:Hi('08', 'fzf1')
  " call <SID>hi_attr('reverse', 'fzf1', 'fzf2', 'fzf3')
  " }}}

  " vimwiki {{{
  call l:Hi('2.', 'VimwikiCheckBoxDone')
  call <SID>hi_attr('italic,strikethrough', 'VimwikiCheckBoxDone')
  " }}}
endfunction
" }}}

" func s:hi() {{{
function! <SID>hi(palette, category, fgbg, ...) abort
  let l:fg=a:fgbg[0]
  let l:bg=a:fgbg[1]

  " translated
  let l:tr_fg=get(a:palette, l:fg, '')
  let l:tr_bg=get(a:palette, l:bg, '')

  if a:category !=# 'gui'
    let l:tr_fg=<SID>termcolor(l:fg)
    let l:tr_bg=<SID>termcolor(l:bg)
  endif

  let l:params=''

  if l:fg !=# '' && l:fg !=# '.'
    let l:params=printf("%s %sfg='%s'", l:params, a:category, l:tr_fg)
  endif

  if l:bg !=# '' && l:bg !=# '.'
    let l:params=printf("%s %sbg='%s'", l:params, a:category, l:tr_bg)
  endif

  for name in a:000
    try
      exec 'hi ' . name . ' ' . l:params
    catch
      echom 'ERROR: hi '.name.' '.l:params.': '.a:fgbg
    endtry
  endfor
endfunction
" }}}

" func s:hi_attr() {{{
function! <SID>hi_attr(attr, ...) abort
  for name in a:000
    exec printf("hi %s gui='%s' cterm='%s'", name, a:attr, a:attr)
  endfor
endfunction
" }}}

" func s:hi_link {{{
function! <SID>hi_link(target, ...) abort
  for name in a:000
    exec 'hi! link ' . name . ' ' . a:target
  endfor
endfunction
" }}}

function! s:maybe(src, dst, attr) abort
  let l:src_group = <SID>hlget(a:src)

  if len(l:src_group) < 1
    return
  endif

  if has_key(l:src_group, a:attr)
    exec printf('hi %s %s=%s', a:dst, a:attr, l:src_group[0][a:attr])
  endif
endfunction

function! my#themes#apply_theme_overrides() abort
  " apply any specific overrides
  if !has_key(g:, 'my_theme_overrides')
    return
  endif

  for cfg in g:my_theme_overrides
    " build the config we will apply
    let l:spec=copy(cfg)
    let l:groups=remove(l:spec, 'group')

    if has_key(l:spec, 'from')
      " copy the colors from somewhere else
      let l:spec=extend(get(<SID>hlget(l:spec.from, v:true), 0, {}), l:spec)
      unlet l:spec['from']

      " fix: we need to remove the 'cleared' key if it's there otherwise the colors won't take
      if has_key(l:spec, 'cleared')
        unlet l:spec.cleared
      endif
    endif

    " attrs just need to apply to cterm/gui directly. handle this differently for neovim though
    if has_key(l:spec, 'attrs')
      let l:attr_string=remove(l:spec, 'attrs')
      let l:attrs={}

      " special case for NONE, leave empty
      if l:attr_string != 'NONE'
        let l:attr_list=split(l:attr_string, ',')

        for attr in l:attr_list
          let l:attrs[trim(attr)]=v:true
        endfor
      else
        " neovim special case: NONE means explicitly turn off all attributes
        if has('nvim')
          let l:spec = extend(copy(l:spec),
          \ {
            \ 'bold': v:false,
            \ 'standout': v:false,
            \ 'underline': v:false,
            \ 'undercurl': v:false,
            \ 'underdouble': v:false,
            \ 'underdotted': v:false,
            \ 'underdashed': v:false,
            \ 'strikethrough': v:false,
            \ 'italic': v:false,
            \ 'reverse': v:false
          \ })
        endif
      endif

      let l:spec['gui']=l:attrs
      let l:spec['cterm']=l:attrs
    endif

    " what strategy are we using here? merge or replace (default merge)
    if has_key(l:spec, 'strategy')
      let l:strategy=remove(l:spec, 'strategy')
    else
      let l:strategy='merge'
    endif

    " if we're performing a link, make sure we force it
    if has_key(l:spec, 'linksto')
      " neovim uses 'link' not 'linksto'
      if has('nvim')
        let l:spec['link'] = remove(l:spec, 'linksto')
      else
        let l:spec['force']=v:true
      endif
    endif

    " apply the spec to each group
    let l:hlcfg=[]
    for group in l:groups
      let l:groupcfg=copy(l:spec)
      let l:groupcfg.name=group

      if l:strategy == 'replace'
        exec 'hi clear '.group
      else
        let l:cur=get(<SID>hlget(group, v:true), 0, {})

        if has_key(l:cur, 'cleared')
          unlet l:cur.cleared
        endif

        " are we supposed to merge into whatever the original colors are? this is a little tricky (maybe i'm
        " doing this wrong), i want to merge the overrides to whatever a colorscheme or plugin sets it to, but
        " if this runs multiple times, the 'original' value will be what we set on the previous run. that's
        " important if we're merging with a group that is set with a default. so instead, add a step to clear
        " the group, then check if hlget() gives you back the thing with default set

        " clear and check for any default style (don't resolve the group)
        exec 'hi clear '.group
        let l:check=get(<SID>hlget(group), 0, {})

        " start with this, merge the previous original
        if has_key(l:check, 'default') && l:check.default
          let l:cur=extend(get(<SID>hlget(group, v:true), 0, {}), l:cur, 'force')
        endif

        let l:groupcfg=extend(l:cur, l:groupcfg, 'force')
      endif

      call add(l:hlcfg, l:groupcfg)
    endfor

    call <SID>hlset(l:hlcfg)
  endfor
endfunction

" vi:fdm=marker
