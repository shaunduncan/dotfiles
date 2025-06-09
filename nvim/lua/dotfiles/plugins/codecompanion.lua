-- codecompanion.nvim
local util = require('dotfiles.util')

-- definitely not how we get terminators
local terminator = '🤖'

local aug = vim.api.nvim_create_augroup('dotfiles-codecompanion', {})

-- setup notifications
local mini = require('dotfiles.plugins.mini')
local active_notify = {}

-- autocmds for fidget progress based on code companion hooks
vim.api.nvim_create_autocmd('User', {
  pattern = 'CodeCompanionRequestStarted',
  group = aug,
  callback = function(req)
    print('CodeCompanionRequestStarted')
    print(vim.inspect(req))
    -- get the lsp client name
    local lsp_name = {}
    table.insert(lsp_name, req.data.adapter.formatted_name)
    if req.data.adapter.model and req.data.adapter.model ~= '' then
      table.insert(lsp_name, '(' .. req.data.adapter.model .. ')')
    end

    local msg = terminator .. ' request started (' .. req.data.strategy .. ')'

    active_notify[req.data.id] = mini.notify.add(msg, 'INFO', 'DiagnosticInfo')
  end,
})

vim.api.nvim_create_autocmd('User', {
  pattern = 'CodeCompanionRequestFinished',
  group = aug,
  callback = function(req)
    local notify_id = active_notify[req.data.id]
    local update = {
      msg = terminator .. ' request ' .. req.data.status .. ' (' .. req.data.strategy .. ')',
    }

    if notify_id then
      vim.defer_fn(function() mini.notify.remove(notify_id) end, 3000)

      if req.data.status == 'success' then
        update.hl_group = 'DiagnosticOk'
      elseif req.data.status == 'error' then
        update.level = 'ERROR'
        update.hl_group = 'DiagnosticError'
      else
        update.level = 'WARN'
        update.hl_group = 'DiagnosticWarn'
      end

      mini.notify.update(notify_id, update)
    end

    active_notify[req.data.id] = nil
  end,
})

-- configure codecompanion
util.require('codecompanion').setup({
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
      -- provider = 'mini_pick',
    },
  },
  adapters = {
    openai = function()
      return require('codecompanion.adapters').extend('openai', {
        schema = {
          model = {
            default = 'o3-mini',
            choices = {
              'gpt-4o',
              'gpt-4o-latest',
              'gpt-4o-mini',
              'o1',
              'o1-mini',
              'o1-preview',
              'o3-mini',
            },
          },
        },
      })
    end,
    gemini = function()
      return require('codecompanion.adapters').extend('gemini', {
        schema = {
          model = {
            default = 'gemini-2.0-flash',
            choices = {
              'gemini-2.0-flash',
              'gemini-2.0-flash-exp',
              'gemini-2.0-flash-lite',
              'gemini-2.0-flash-thinking-exp',
              'gemini-2.0-pro-exp',
              'gemini-2.5-pro-exp-03-25',
            },
          },
        },
      })
    end,
    anthropic = function()
      return require('codecompanion.adapters').extend('anthropic', {
        schema = {
          model = {
            default = 'claude-3-5-haiku-latest',
            choices = {
              'claude-3-7-sonnet-latest',
              'claude-3-5-sonnet-latest',
              'claude-3-5-haiku-latest',
            },
          },
        },
      })
    end
  },
  strategies = {
    chat = {
      roles = {
        llm = function(adapter)
          return terminator .. ' Not a Terminator (' .. adapter.formatted_name .. ')'
        end,
      },
      adapter = 'gemini',
    },
    cmd = { adapter = 'gemini' },
    inline = { adapter = 'gemini' },
    workflow = { adapter = 'gemini' },
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
})

-- chat buffer for normal mode, inline command for visual mode
vim.api.nvim_set_keymap('n', '<leader>ai', ':CodeCompanionChat Toggle<CR>', { noremap = true })
