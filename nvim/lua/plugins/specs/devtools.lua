--------------------------------------------------------------------------------
--                               MISC DEV TOOLS                               --
--------------------------------------------------------------------------------
return {
  -- git
  { 'tpope/vim-fugitive' },
  { 'shumphrey/fugitive-gitlab.vim' },

  -- snippiets
  {
    'SirVer/ultisnips',
    init = function()
      vim.g.UltiSnipsEditSplit = 'vertical'
      vim.g.UltiSnipsSnippetDirectories = {
        vim.env.HOME .. '/.config/dotfiles/vim/snips',
      }

      --  <c-space> is equivalent to <nul>, at least on mac. <M-M> == <C-CR>
      vim.g.UltiSnipsExpandTrigger = '<M-M>'

      -- auto fill snippets for certain filetypes
      vim.cmd([[
        aug plugin-ultisnips | au!
          au BufNewFile *.h execute "normal ionce\<M-M>\<ESC>"
        aug end
      ]])
    end,
  },
}
