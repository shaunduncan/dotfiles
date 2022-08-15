" vim-airline specific functions

" FIXME: (sduncan) figure out if this is still useful?
" my#airline#patch_theme: ensure palette matches colorscheme {{{
function! my#airline#patch_theme(palette) abort
  " patch the palette with colors that are more to my liking. there are several modes that
  " are part of the palette but file changes aren't being tracked so we just need to
  " modify the main ones: normal, visual, insert, replace, inactive
  let l:theme=g:my_theme_palette_named

  " all modes: add airline_warning and airline_error
  for mode in keys(a:palette)
    " accents: match the color name and that's it
    if mode ==# 'accents'
      for color in keys(a:palette[mode])
        if has_key(l:theme, color)
          let a:palette[mode][color][0] = l:theme[color]
        endif
      endfor

      continue
    endif

    " make sure to set error/warning colors so they match the theme
    let a:palette[mode]['airline_warning'][:1] = [l:theme.bg, l:theme.orange]
    let a:palette[mode]['airline_error'][:1] = [l:theme.bg, l:theme.red]
  endfor
endfunction
" }}}

" vi:fdm=marker
