function! lsp#init() abort
  let g:lsp_loaded=1
endfunction

function! lsp#get_progress() abort
  lua vim.b.lsp_progress = vim.lsp.util.get_progress_messages()

  if len(b:lsp_progress) == 0
    return ''
  endif

  let b:lsp_progress[0].server = b:lsp_progress[0].name

  if b:lsp_progress[0].title == 'empty title'
    let b:lsp_progress[0].title = ''
  endif

  if !has_key(b:lsp_progress[0], 'message')
    let b:lsp_progress[0].message = 'Initializing ' . copy(b:lsp_progress[0].name)
  endif

  return b:lsp_progress
endfunction

function! lsp#get_buffer_diagnostics_counts()
lua << EOF
  local diags = vim.diagnostic.get(0)
  local counts = {error = 0, warning = 0, information = 0, hint = 0}
  local sev = vim.diagnostic.severity

  for _, d in ipairs(diags) do
    local grp = ''

    if d.severity == sev.ERROR then grp = 'error'
    elseif d.severity == sev.WARN then grp = 'warning'
    elseif d.severity == sev.INFO then grp = 'information'
    elseif d.severity == sev.HINT then grp = 'hint'
    end

    if grp ~= '' then
      counts[grp] = counts[grp] + 1
    end
  end

  vim.b.lsp_diagnostic_counts = counts
EOF

  return get(b:, 'lsp_diagnostic_counts', {'error': 0, 'warning': 0, 'information': 0, 'hint': 0})
endfunction

function! lsp#get_buffer_first_error_line() abort
endfunction
