--------------------------------------------------------------------------------
--                               DEBUGGING: DAP:                               --
--------------------------------------------------------------------------------
return {
  {
    'rcarriga/nvim-dap-ui',
    dependencies = {
      'mfussenegger/nvim-dap',
      'nvim-neotest/nvim-nio',
      'leoluz/nvim-dap-go',
    },
    config = function()
      local dap = require('dap')
      local dap_ui = require('dapui')
      local dap_go = require('dap-go')

      dap.set_log_level('DEBUG')

      -- custom functions and keymaps
      local function opts(desc)
        return {
          desc = desc,
          noremap = true,
          silent = true,
        }
      end

      local function dap_run()
        dap.continue()
        dap_ui.open()
      end

      local function dap_terminate()
        dap.terminate()
        dap_ui.close()
      end

      local function dap_hover()
        require('dap.ui.widgets').hover()
      end

      local function dap_debug_test()
        dap_go.debug_test()
        dap_ui.open()
      end

      local function dap_debug_last_test()
        dap_go.debug_last_test()
        dap_ui.open()
      end

      vim.keymap.set('n', '<leader>dd', dap_run, opts('DAP: Run'))
      vim.keymap.set('n', '<leader>dq', dap_terminate, opts('DAP: Terminate'))
      vim.keymap.set('n', '<leader>dc', dap.continue, opts('DAP: Continue'))
      vim.keymap.set('n', '<leader>db', dap.toggle_breakpoint, opts('DAP: Toggle Breakpoint'))
      vim.keymap.set('n', '<leader>d<CR>', dap.toggle_breakpoint, opts('DAP: Toggle Breakpoint'))
      vim.keymap.set('n', '<leader>dn', dap.step_over, opts('DAP: Step Over'))
      vim.keymap.set('n', '<leader>di', dap.step_into, opts('DAP: Step Into'))
      vim.keymap.set('n', '<leader>do', dap.step_out, opts('DAP: Step Out'))
      vim.keymap.set('n', '<leader>dr', dap.restart, opts('DAP: Restart'))
      vim.keymap.set('n', '<leader>dh', dap.run_to_cursor, opts('DAP: Run to Cursor'))
      vim.keymap.set('n', '<leader>dI', dap_hover, opts('DAP: Hover'))
      vim.keymap.set('n', '<leader>du', dap.up, opts('DAP: Up'))
      vim.keymap.set('n', '<leader>dU', dap.down, opts('DAP: Down'))
      vim.keymap.set('n', '<leader>dt', dap_debug_test, opts('DAP: Debug Test'))
      vim.keymap.set('n', '<leader>dl', dap_debug_last_test, opts('DAP: Debug Last Test'))

      vim.api.nvim_set_hl(0, 'DapBreakpoint', { link = 'DiagnosticError' })
      vim.api.nvim_set_hl(0, 'DapStopped', { link = 'DiagnosticWarn' })

      vim.fn.sign_define('DapBreakpoint', { text = '⏹', texthl = 'DapBreakpoint', linehl = '', numhl = '' })
      -- vim.diagnostic.config({ numhl = { enabled = true, severity = { error = 'DapBreakpoint' } } })
      vim.fn.sign_define('DapBreakpointRejected', { text = 'R', texthl = 'DapBreakpoint', linehl = '', numhl = '' })
      vim.fn.sign_define('DapLogPoint', { text = 'F', texthl = '', linehl = '', numhl = 'DapLogPoint' })
      vim.fn.sign_define('DapStopped', { text = '▶', texthl = 'DapStopped', linehl = '', numhl = '' })

      -- configure the go adapter
      dap.adapters.go = function(callback, config)
        local stdout = vim.loop.new_pipe(false)
        local handle
        local pid_or_err
        local port = 38697

        -- opts are passed to "executable" dap field
        local opts = {
          stdio = { nil, stdout },
          args = { 'dap', '-l', '127.0.0.1:' .. port },
          detached = true,
        }

        handle, pid_or_err = vim.loop.spawn('dlv', opts, function(code)
          stdout:close()
          handle:close()
          if code ~= 0 then
            print('dlv exited with code', code)
          end
        end)

        assert(handle, 'Error running dlv: ' .. tostring(pid_or_err))

        stdout:read_start(function(err, chunk)
          assert(not err, err)
          if chunk then
            vim.schedule(function()
              require('dap.repl').append(chunk)
            end)
          end
        end)

        vim.defer_fn(
          function()
            callback({
              type = 'server',
              host = '127.0.0.1',
              port = port,
              options = {
                initialize_timeout_sec = 60,
              },
            })
          end,
          100
        )
      end

      dap.configurations.go = {
        setmetatable(
          {
            name = 'analyze local snapshot',
            type = 'go',
            request = 'launch',
            args = {
              'snapshot',
              '--local',
              '--rm',
              '--recreate',
            },
          },
          {
            __call = function(cfg)
              local snapshot_id = vim.g.snapshot_id or vim.fn.input('Snapshot ID: ', '')

              cfg['program'] = vim.lsp.buf.list_workspace_folders()[1] .. '/analyzer'

              local extra = {
                '--snapshot', os.getenv('HOME') .. '/.speedscale/data/snapshots/' .. snapshot_id .. '.json',
                '--output-dir', '/tmp/analyze-snapshot/' .. snapshot_id,
                '--raw', os.getenv('HOME') .. '/.speedscale/data/snapshots/' .. snapshot_id .. '/raw.jsonl',
              }

              for k, v in pairs(extra) do cfg['args'][k + 4] = v end

              return cfg
            end
          }
        ),
        setmetatable(
          {
            name = 'speedctl replay (mysql)',
            type = 'go',
            request = 'launch',
            args = {
              'replay',
              'dc05c597-6956-4c85-8bc1-8f7244fa4699',
              '--create-report=false',
              '--test-config-id=regression',
              '--custom-url=http://localhost:8080',
              '--service=mysql=3306',
              '--mode=mocks-only',
              '--app-url=dev.speedscale.com',
              '--verbose',
            },
          },
          {
            __call = function(cfg)
              cfg['program'] = vim.lsp.buf.list_workspace_folders()[1] .. '/speedctl'
              return cfg
            end
          }
        ),
        setmetatable(
          {
            name = 'proxymock run',
            type = 'go',
            request = 'launch',
            args = { 'run', '--verbose' },
          },
          {
            __call = function(cfg)
              snapshot_id = 'acfd1983-9379-4904-b2be-aa3319a3f878'
              -- local snapshot_id = (
              --   vim.g.snapshot_id or
              --   vim.fn.input('Snapshot ID: ', '') or
              --   'ffffffff-ffff-ffff-ffff-ffffffffffff'
              -- )

              cfg.program = vim.lsp.buf.list_workspace_folders()[1] .. '/speedctl/cmd/proxymock'
              cfg.args = vim.list_extend(cfg.args, { '--snapshot', snapshot_id })
              return cfg
            end
          }
        ),
      }

      -- configure dap-ui
      dap_ui.setup(
        {
          force_buffers = true,
          expand_lines = true,
          icons = {
            expanded = '-',
            collapsed = '+',
            current_frame = '▣',
          },
          layouts = {
            {
              elements = {
                { id = 'breakpoints', size = 0.20 },
                { id = 'stacks',      size = 0.40 },
                { id = 'scopes',      size = 0.40 },
              },
              position = 'left',
              size = 40
            },
            {
              elements = {
                { id = 'repl', size = 0.8 },
              },
              position = 'bottom',
              size = 20
            },
          },
          render = {
            indent = 2,
            max_type_length = 79,
          },
          floating = {
            max_height = 0.5,
            max_width = 0.5,
            border = 'single',
            mappings = {
              close = { 'q', '<Esc>' }
            }
          },
          controls = {
            enabled = false,
            icons = {
              pause = '⏸',
              play = '▶',
              step_into = '↴',
              step_over = '↷',
              step_out = '↱',
              step_back = '↰',
              run_last = '🔄',
              terminate = '🛑',
            },
          },
        })
    end,
  },
  {
    'leoluz/nvim-dap-go',
    ft = { 'go' },
  }
}
