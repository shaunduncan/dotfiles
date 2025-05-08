local M = {}

function M.config(default_cfg)
  local cfg = require('dotfiles.lsp.util').deep_copy(default_cfg)

  cfg.settings = {
    Lua = {
      runtime = {
        version = 'LuaJIT'
      },
      format = {
        enable = true,

        -- NOTE: all of these values have to be strings
        defaultConfig = {
          -- general
          indent_style = 'space',
          indent_size = '2',
          quote_style = 'single',
          call_arg_parentheses = 'keep',
          insert_final_newline = 'true',

          -- whitespace
          space_around_table_field_list = 'true',
          space_before_attribute = 'true',

          -- alignment
          align_call_args = 'true',
          align_function_params = 'true',
          -- align_continuous_assign_statement
          align_continuous_rect_table_field = 'true',
          align_if_branch = 'false',
          -- align_array_table
        },
      },
      diagnostics = {
        globals = {
          'vim'
        },
      },
      workspace = {
        checkThirdParty = false,
        library = {
          vim.env.VIMRUNTIME
        }
      }
    }
  }

  return cfg
end

return M
