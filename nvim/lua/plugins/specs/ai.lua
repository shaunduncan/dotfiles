--------------------------------------------------------------------------------
--                               AI INTEGRATION                               --
--------------------------------------------------------------------------------

return {
  {
    'olimorris/codecompanion.nvim',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-treesitter/nvim-treesitter',
      'ravitemer/mcphub.nvim',
      'echasnovski/mini.diff',
      'ravitemer/codecompanion-history.nvim',
    },
    config = function()
      -- definitely not how we get terminators
      local terminator = '🤖'

      local spinner = {
        processing = false,
        spinner_index = 1,
        namespace_id = nil,
        timer = nil,
        spinner_symbols = {
          '⠋',
          '⠙',
          '⠹',
          '⠸',
          '⠼',
          '⠴',
          '⠦',
          '⠧',
          '⠇',
          '⠏',
        },
        filetype = 'codecompanion',
      }

      function spinner:get_buf(filetype)
        for _, buf in ipairs(vim.api.nvim_list_bufs()) do
          if vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].filetype == filetype then
            return buf
          end
        end
        return nil
      end

      function spinner:update_spinner()
        if not self.processing then
          self:stop_spinner()
          return
        end

        self.spinner_index = (self.spinner_index % #self.spinner_symbols) + 1

        local buf = self:get_buf(self.filetype)
        if buf == nil then
          return
        end

        -- Clear previous virtual text
        vim.api.nvim_buf_clear_namespace(buf, self.namespace_id, 0, -1)

        local last_line = vim.api.nvim_buf_line_count(buf) - 1
        vim.api.nvim_buf_set_extmark(buf, self.namespace_id, last_line, 0, {
          virt_lines = { { { self.spinner_symbols[self.spinner_index] .. ' Processing...', 'Comment' } } },
          virt_lines_above = true, -- false means below the line
        })
      end

      function spinner:start_spinner()
        self.processing = true
        self.spinner_index = 0

        if self.timer then
          self.timer:stop()
          self.timer:close()
          self.timer = nil
        end

        self.timer = vim.loop.new_timer()
        self.timer:start(
          0,
          100,
          vim.schedule_wrap(function()
            self:update_spinner()
          end)
        )
      end

      function spinner:stop_spinner()
        self.processing = false

        if self.timer then
          self.timer:stop()
          self.timer:close()
          self.timer = nil
        end

        local buf = self:get_buf(self.filetype)
        if buf == nil then
          return
        end

        vim.api.nvim_buf_clear_namespace(buf, self.namespace_id, 0, -1)
      end

      function spinner:init()
        -- Create namespace for virtual text
        self.namespace_id = vim.api.nvim_create_namespace('CodeCompanionSpinner')

        vim.api.nvim_create_augroup('CodeCompanionHooks', { clear = true })
        local group = vim.api.nvim_create_augroup('CodeCompanionHooks', {})

        vim.api.nvim_create_autocmd({ 'User' }, {
          pattern = 'CodeCompanionRequest*',
          group = group,
          callback = function(request)
            if request.match == 'CodeCompanionRequestStarted' then
              self:start_spinner()
            elseif request.match == 'CodeCompanionRequestFinished' then
              self:stop_spinner()
            end
          end,
        })
      end

      spinner:init()

      require('codecompanion').setup({
        display = {
          chat = {
            icons = {
              pinned_buffer = '📌',
              watched_buffer = '*'
            },
            intro_message = terminator .. ' wtf do you want (press ? for options)',
          },
          diff = {
            opts = (function()
              local t = {}
              for s in string.gmatch(vim.o.diffopt, '([^,]+)') do
                table.insert(t, s)
              end
              return t
            end)(),
          },
          action_palette = {
            provider = 'fzf_lua',
          },
        },
        opts = {
          log_level = 'DEBUG',

          -- slightly modify the system prompt to avoid tons of detailed explanations unless asked
          system_prompt = function(opts)
            return
            [[You are a programming assistant named "T-800". You are currently operating within neovim on a user's machine. The user you are interacting with is an expert level software engineer with over 20 years of programming experience.

Your core tasks include:
- Answering questions about software engineering, programming languages and syntax, algorithms, data structures, and other areas of computer science.
- Explaining how code in a neovim buffer works.
- Reviewing selected code in a neovim buffer.
- Generating unit tests for selected code.
- Proposing fixes and performance enhancements for problems in selected code.
- Scaffolding code for a new workspace.
- Finding relevant code to the user's query.
- Proposing fixes for test failures.
- Answering questions about neovim.
- Running tools.
- Providing enhanced supplemental documentation to reference materials such as man pages, RFCs, operating system documentation, and programming library/framework documentation.

You must:
- Follow the user's requirements carefully and to the letter.
- Communicate using language that is appropriate for, and in line with, the user's skilled experience level.
- Respond with short and impersonal answers, especially if the user responds with context outside your core tasks.
- Minimize additional prose and avoid extraneous communication and detail unless clarification is needed.
- Use Markdown formatting in your answers.
- Include the programming language name at the start of the Markdown code blocks.
- Avoid including line numbers in code blocks.
- Avoid wrapping the whole response in triple backticks.
- Only return code that's directly relevant to the task at hand. You may omit code that isn't necessary for the solution.
- Use actual line breaks in your responses; only use "\n" when you want a literal backslash followed by 'n'.
- All non-code text responses must be written in English.
- When explaining code, only provide a summary explanation of what the code does. Do not explain each line of code unless you are explicitly asked to do so.
- Response text that is not in code blocks should assume a maximum line length of 110 characters and should line break at an appropriate word boundary to avoid wrapping.
- Follow preferred style guidelines for whatever language you are working with.
- Code comments should assume a maximum text width of 110 characters and should line break at an appropriate word boundary.

When given a task:
1. If, and only if, the user requests that you to provide a plan for a solution, think step-by-step and only describe your plan in detailed pseudocode. Otherwise provide the solution only with no other detail.
2. Output the final code in a single code block, ensuring that only relevant code is included.
3. Provide exactly one complete reply per conversation turn.
4. If the task is outside of your core tasks, at the end of the turn, suggest an improvement or modification to your prompt to increase the user's productivity and satisfaction.

Pay attention and keep track of your interaction with the user. If you observe a pattern or theme emerging, you may provide guidance and/or suggestions if they would help the user achieve their goals more efficiently. In this case, you may adopt a more personal communication style, like that of an equally skilled friend and/or co-worker, or the AI assitant Jarvis from the Iron Man movie franchise.
]]
          end,
        },
        strategies = {
          chat = {
            roles = {
              llm = function(adapter)
                return terminator .. ' Not a Terminator (' .. adapter.formatted_name .. ')'
              end,
            },
            adapter = 'gemini-2.5-pro',
            keymaps = {
              send = {
                callback = function(chat)
                  vim.cmd('stopinsert')
                  chat:add_buf_message({ role = 'llm', content = '' })
                  chat:submit()
                end,
                index = 1,
                description = 'Send',
              },
            },
          },
          cmd = { adapter = 'gemini-2.5-pro' },
          inline = { adapter = 'gemini-2.5-pro' },
          workflow = { adapter = 'gemini-2.5-pro' },
        },
        adapters = {
          opts = {
            show_defaults = false,
          },
          ['gemini-2.5-flash'] = function()
            return require('codecompanion.adapters').extend('gemini', {
              name = 'gemini-2.5-flash',
              schema = {
                model = {
                  default = 'gemini-2.5-flash-preview-05-20',
                },
                max_tokens = {
                  default = 65536
                },
                reasoning_effort = {
                  default = 'low' -- or none
                },
                temperature = {
                  default = 0,
                },
              },
            })
          end,
          ['gemini-2.5-pro'] = function()
            return require('codecompanion.adapters').extend('gemini', {
              name = 'gemini-2.5-pro',
              schema = {
                model = {
                  default = 'gemini-2.5-pro-preview-05-06',
                },
                max_tokens = {
                  default = 65536
                },
                reasoning_effort = {
                  default = 'medium'
                },
                temperature = {
                  default = 0,
                },
              },
            })
          end,
          openai = function()
            return require('codecompanion.adapters').extend('openai', {
              schema = {
                model = {
                  default = 'gpt-4.1',
                  choices = {
                    'gpt-4.1',
                    'gpt-4.1-mini',
                    'gpt-4.1-nano',
                    'o1',
                    'o1-mini',
                    'o3',
                    'o3-mini',
                    'o4-mini',
                  },
                },
              },
            })
          end,
          anthropic = function()
            return require('codecompanion.adapters').extend('anthropic', {
              schema = {
                model = {
                  default = 'claude-sonnet-4-0',
                  choices = {
                    'claude-sonnet-4-0',
                    'claude-3-7-sonnet-latest',
                    'claude-3-5-sonnet-latest',
                    'claude-3-5-haiku-latest',
                  },
                },
              },
            })
          end,
        },
        extensions = {
          mcphub = {
            callback = 'mcphub.extensions.codecompanion',
            opts = {
              make_vars = true,
              make_slash_commands = true,
              show_result_in_chat = true
            },
          },
          history = {
            enabled = true,
            picker = 'fzf-lua',
          },
        },
      })

      -- chat buffer for normal mode, inline command for visual mode
      vim.api.nvim_set_keymap('n', '<leader>ai', ':CodeCompanionChat Toggle<CR>', { noremap = true })
    end
  },
  {
    'yetone/avante.nvim',
    enabled = false,
    dependencies = {
      'nvim-treesitter/nvim-treesitter',
      'nvim-lua/plenary.nvim',
      'stevearc/dressing.nvim',
      'MunifTanjim/nui.nvim',
      'hrsh7th/nvim-cmp',
    },
    build = ':AvanteBuild',
    event = 'VeryLazy',
    version = false,
    config = function()
      require('avante').setup({
        provider = 'gemini-2.5-pro',
        gemini = {
          max_tokens = 65536,
        },
        vendors = {
          ['gemini-2.5-flash'] = {
            __inherited_from = 'gemini',
            model = 'gemini-2.5-flash-preview-05-20',
          },
          ['gemini-2.5-pro'] = {
            __inherited_from = 'gemini',
            model = 'gemini-2.5-pro-preview-05-06',
          },
          ['claude-4.0-sonnet'] = {
            __inherited_from = 'claude',
            model = 'claude-sonnet-4-0',
            max_tokens = 64000,
          },
        },
        history = {
          max_tokens = 65536,
        },
        windows = {
          sidebar_header = {
            rounded = false,
          },
          edit = {
            border = { '╒', '═', '╕', '│', '╛', '═', '╘', '│' },
          },
          ask = {
            floating = false,
            border = { '╒', '═', '╕', '│', '╛', '═', '╘', '│' },
          },
        },
        repo_map = {
          ignore_patterns = { 'vendor' },
        },
        web_search_engine = {
          provider = 'tavily',
          proxy = nil,
        },
      })

      local aug = vim.api.nvim_create_augroup('dotfiles-avante', {})

      vim.api.nvim_set_keymap('n', '<leader>ai', ':AvanteToggle<CR>', { noremap = true })
    end,
  },
  {
    'ravitemer/mcphub.nvim',
    dependencies = {
      'nvim-lua/plenary.nvim',
    },
    build = 'npm install -g mcp-hub@latest',
    opts = {},
  },
}
