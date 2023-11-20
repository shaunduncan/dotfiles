local vim  = vim
local utils = {}

-- on_attach to ensure that keymappings are only set with an active lsp buffer
function utils.on_attach(client, bufnr)
    local function mapkey(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end

    -- Mappings.
    local opts = { noremap=true, silent=true }

    -- See `:help vim.lsp.*` for documentation on any of the below functions
    -- these should map to an equivalent keymapping set for vim-go in .vimrc

    -- goto def/typedef (and with split/vsplit variants)
    local goto_def = '<cmd>lua vim.lsp.buf.definition()<CR>'
    local goto_typedef = '<cmd>lua vim.lsp.buf.type_definition()<CR>'

    mapkey('n', '<leader>gd', goto_def, opts)
    mapkey('n', '<leader>gsd', ':sp<CR>' .. goto_def, opts)
    mapkey('n', '<leader>gvd', ':vsp<CR>' .. goto_def, opts)

    mapkey('n', '<leader>gD', goto_typedef, opts)
    mapkey('n', '<leader>gsD', ':sp<CR>' .. goto_typedef, opts)
    mapkey('n', '<leader>gvD', ':vsp<CR>' .. goto_typedef, opts)

    -- Lspsaga peek_definition and peek_type_definition?

    -- info (godoc)
    mapkey('n', '<leader>gx', '<cmd>lua vim.lsp.buf.hover()<CR>', opts)
    mapkey('n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', opts)

    -- TODO: color HoverNormal and HoverBorder

    -- lspsaga specific
    mapkey('n', '<leader>lx', ':Lspsaga hover_doc<CR>', opts)

    mapkey('n', '<leader>gr', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)

    -- show who implements an interface (function call shows quicklist, command is fzf)
    mapkey('n', '<leader>gi', ':Implementations<CR>', opts)
    mapkey('n', '<leader>gil', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)

    -- show var usage (function call shows quicklist, command is fzf)
    mapkey('n', '<leader>gu', ':References<CR>', opts)
    mapkey('n', '<leader>gu?', '<cmd>lua vim.lsp.buf.references()<CR>', opts)

    -- what do these do?
    mapkey('n', '<leader>gcaf', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
    mapkey('n', '<leader>gcac', ':CodeActions<CR>', opts)

    -- loclist shows current file, all shows any in workspace (in fzf)
    mapkey('n', '<leader>gp', '<cmd>lua vim.diagnostic.setloclist()<CR>', opts)
    mapkey('n', '<leader>gpa', ':DiagnosticsAll<CR>', opts)

    -- popup function signature when requested
    mapkey('i', '<C-H>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)

    -- callers/callees
    mapkey('n', '<leader>gci', '<cmd>lua vim.lsp.buf.incoming_calls()<CR>', opts)
    mapkey('n', '<leader>gco', '<cmd>lua vim.lsp.buf.outgoing_calls()<CR>', opts)

    mapkey('n', '<leader>gCi', ':Lspsaga incoming_calls<CR>', opts)
    mapkey('n', '<leader>gCo', ':Lspsaga outgoing_calls<CR>', opts)

    -- workspace --
    mapkey('n', '<leader>gwa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', opts)
    mapkey('n', '<leader>gwr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', opts)
    mapkey('n', '<leader>gwl', '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>', opts)

    -- dap = require('dap')
    -- dap.adapters.go = function(callback, config)
    --   local stdout = vim.loop.new_pipe(false)
    --   local handle
    --   local pid_or_err
    --   local port = 38697
    --   -- opts are passed to "executable" dap field
    --   local opts = {
    --     stdio = { nil, stdout },
    --     args = { "dap", "-l", "127.0.0.1:" .. port },
    --     detached = true,
    --   }
    --   handle, pid_or_err = vim.loop.spawn("dlv", opts, function(code)
    --     stdout:close()
    --     handle:close()
    --     if code ~= 0 then
    --       print("dlv exited with code", code)
    --     end
    --   end)
    --   assert(handle, "Error running dlv: " .. tostring(pid_or_err))
    --   stdout:read_start(function(err, chunk)
    --     assert(not err, err)
    --     if chunk then
    --       vim.schedule(function()
    --         require("dap.repl").append(chunk)
    --       end)
    --     end
    --   end)
    --   vim.defer_fn(function()
    --     callback({
    --       type = "server",
    --       host = "127.0.0.1",
    --       port = port,
    --       options = {
    --         initialize_timeout_sec = 20,
    --   },
    --     })
    --   end, 100)
    -- end

    -- dap.configurations.go = {
    --   {
    --     type = "go",
    --     name = "Debug",
    --     request = "launch",
    --     program = "${file}",
    --   },
    --   {
    --     type = "go",
    --     name = "Debug test",
    --     request = "launch",
    --     mode = "test",
    --     program = "${file}",
    --   },
    --   {
    --     type = "go",
    --     name = "Debug test (go.mod)",
    --     request = "launch",
    --     mode = "test",
    --     program = "./${relativeFileDirname}",
    --   },
    --   {
    --     type = "go",
    --     name = "goproxy",
    --     request = "launch",
    --     program = "/Users/josh/code/speedscale/goproxy/main.go",
    --   },
    --   {
    --     type = "go",
    --     name = "generator",
    --     request = "launch",
    --     program = "/Users/josh/code/speedscale/generator/main.go",
    --   },
    -- }

    -- dapui = require('dapui')
    -- function dapRun()
    --   dap.continue()
    --   dapui.setup()
    --   dapui.open()
    -- end
    -- mapkey('n', '<leader>dd', '<cmd>lua dapRun()<CR>', opts)
    -- function dapTerminate()
    --   dap.terminate()
    --   dapui.close()
    -- end
    -- mapkey('n', '<leader>dq', '<cmd>lua dapTerminate()<CR>', opts)
    -- mapkey('n', '<leader>d<space>', '<cmd>lua require("dap").continue()<CR>', opts)
    -- mapkey('n', '<leader>db', '<cmd>lua require("dap").toggle_breakpoint()<CR>', opts)
    -- mapkey('n', '<leader>dn', '<cmd>lua require("dap").step_over()<CR>', opts)
    -- mapkey('n', '<leader>di', '<cmd>lua require("dap").step_in()<CR>', opts)
    -- mapkey('n', '<leader>do', '<cmd>lua require("dap").step_out()<CR>', opts)
    -- mapkey('n', '<leader>dr', '<cmd>lua require("dap").restart()<CR>', opts)
    -- mapkey('n', '<leader>dh', '<cmd>lua require("dap").run_to_cursor()<CR>', opts)
    -- mapkey('n', '<leader>dI', '<cmd>lua require("dap.ui.widgets").hover()<CR>', opts)
    -- mapkey('n', '<leader>di', '<cmd>lua require("dap").step_into()<CR>', opts)
end

return utils
