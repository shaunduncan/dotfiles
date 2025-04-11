--------------------------------------------------------------------------------
--                                 TREESITTER                                 --
--------------------------------------------------------------------------------

return {
  {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    config = function()
      -- filetypes that should use treesitter folding
      local aug = vim.api.nvim_create_augroup('my-treesitter-config', { clear = true })
      vim.api.nvim_create_autocmd('FileType', {
        group = aug,
        pattern = {
          'c', 'cpp', 'gitconfig', 'go', 'gotmpl', 'java', 'javascript', 'lua', 'make',
          'markdown', 'proto', 'python', 'query', 'sshconfig', 'terraform', 'toml',
          'typescript', 'yaml',
        },
        callback = function()
          vim.cmd [[setlocal foldmethod=expr foldexpr=nvim_treesitter#foldexpr()]]
        end,
      })

      require('nvim-treesitter.configs').setup({
        ensure_installed = {
          'c',
          'cpp',
          'dockerfile',
          'git_config',
          'gitattributes',
          'gitcommit',
          'go',
          'gomod',
          'gosum',
          'gotmpl',
          'gowork',
          'java',
          'javascript',
          'lua',
          'make',
          'markdown',
          'markdown_inline',
          'proto',
          'python',
          'query',
          'ssh_config',
          'strace',
          'terraform',
          'tmux',
          'toml',
          'typescript',
          'vim',
          'vimdoc',
          'yaml',
        },

        highlight = {
          enable = true,
          additional_vim_regex_highlighting = false,
        },

        indent = {
          enable = true,
          disable = { 'yaml' },
        },

        incremental_selection = {
          enable = true,
          keymaps = {
            init_selection = 'gnn',
            node_incremental = 'grn',
            scope_incremental = 'grc',
            node_decremental = 'grm',
          },
        },

        textobjects = {
          enable = true,
          -- lsp_interop = {
          --   enable = true,
          --   peek_definition_code = {
          --     ['DF'] = '@function.outer',
          --     ['DF'] = '@class.outer',
          --   },
          -- },

          select = {
            enable = true,
            lookahead = true,
            keymaps = {
              ['aa'] = '@parameter.outer',
              ['ia'] = '@parameter.inner',
              ['af'] = '@function.outer',
              ['if'] = '@function.inner',
              ['ac'] = '@class.outer',
              ['ic'] = '@class.inner',
            },
          },

          move = {
            enable = true,
            set_jumps = true,
            goto_next_start = {
              [']]'] = '@function.outer',
              [']m'] = '@class.outer',
            },
            goto_next_end = {
              [']['] = '@function.outer',
              [']M'] = '@class.outer',
            },
            goto_previous_start = {
              ['[['] = '@function.outer',
              ['[m'] = '@class.outer',
            },
            goto_previous_end = {
              ['[]'] = '@function.outer',
              ['[M'] = '@class.outer',
            }
          },

          swap = {
            enable = true,
            swap_next = {
              ['<leader>mn'] = '@parameter.inner',
            },
            swap_previous = {
              ['<leader>mp'] = '@parameter.inner',
            },
          },

          keymaps = {
            ['af'] = '@function.outer',
            ['if'] = '@function.inner',
            ['aC'] = '@class.outer',
            ['iC'] = '@class.inner',
            ['ac'] = '@conditional.outer',
            ['ic'] = '@conditional.inner',
            ['ae'] = '@block.outer',
            ['ie'] = '@block.inner',
            ['al'] = '@loop.outer',
            ['il'] = '@loop.inner',
            ['is'] = '@statement.inner',
            ['as'] = '@statement.outer',
            ['ad'] = '@comment.outer',
            ['am'] = '@call.outer',
            ['im'] = '@call.inner',
          },
        },
      })
    end,
  },

  {
    'nvim-treesitter/nvim-treesitter-textobjects',
    dependencies = {
      'nvim-treesitter/nvim-treesitter',
    }
  },
}
