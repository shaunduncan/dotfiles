-- debug adapter configuration
local vim = vim

local dap = require("dap")
local dapUI = require('dapui')
local dapGo = require("dap-go")

dapGo.setup()

dap.adapters.go = function(callback, config)
  local stdout = vim.loop.new_pipe(false)
  local handle
  local pid_or_err
  local port = 38697
  -- opts are passed to "executable" dap field
  local opts = {
    stdio = { nil, stdout },
    args = { "dap", "-l", "127.0.0.1:" .. port },
    detached = true,
  }
  handle, pid_or_err = vim.loop.spawn("dlv", opts, function(code)
    stdout:close()
    handle:close()
    if code ~= 0 then
      print("dlv exited with code", code)
    end
  end)
  assert(handle, "Error running dlv: " .. tostring(pid_or_err))
  stdout:read_start(function(err, chunk)
    assert(not err, err)
    if chunk then
      vim.schedule(function()
        require("dap.repl").append(chunk)
      end)
    end
  end)
  vim.defer_fn(function()
    callback({
      type = "server",
      host = "127.0.0.1",
      port = port,
      options = {
        initialize_timeout_sec = 60,
      },
    })
  end, 100)
end

local tenantBucket = os.getenv("TENANT_BUCKET") or ""
local analyzerReportID = os.getenv("ANALYZER_REPORT_ID") or ""
local snapshotID = os.getenv("SNAPSHOT_ID") or ""

dap.configurations.go = {
  {
    name = "analyzer - report - from raw - s3",
    type = "go",
    request = "launch",
    program = vim.fn.getcwd() .. "/analyzer/",
    args = {
      "report", "analyze",
      "--app-url", os.getenv("SPEEDSCALE_APP_URL"),
      "--api-key", os.getenv("SPEEDSCALE_API_KEY"),
      "--report", "s3://" .. tenantBucket .. "/default/reports/" .. analyzerReportID .. ".json",
      "--artifact-src", "s3://" .. tenantBucket .. "/default",
      "--output-dir", ".",
    },
  },
  {
    name = "analyzer - report - from raw - local",
    type = "go",
    request = "launch",
    program = vim.fn.getcwd() .. "/analyzer/",
    args = {
      "report", "analyze",
      "--app-url", os.getenv("SPEEDSCALE_APP_URL"),
      "--api-key", os.getenv("SPEEDSCALE_API_KEY"),
      "--report", "/Users/josh/.speedscale/data/reports/" .. analyzerReportID .. ".json",
      "--output-dir", ".",
    },
  },
  {
    name = "analyzer - report - recreate",
    type = "go",
    request = "launch",
    program = vim.fn.getcwd() .. "/analyzer/",
    args = {
      "report", "analyze",
      "--app-url", os.getenv("SPEEDSCALE_APP_URL"),
      "--api-key", os.getenv("SPEEDSCALE_API_KEY"),
      "--report", "s3://" .. tenantBucket .. "/default/reports/" .. analyzerReportID .. ".json",
      "--output-dir", ".",
      "--recreate",
    },
  },
  {
    name = "analyzer - snapshot",
    type = "go",
    request = "launch",
    program = vim.fn.getcwd() .. "/analyzer/",
    args = {
      "snapshot",
      "--snapshot", "s3://" .. tenantBucket .. "/default/scenarios/" .. snapshotID .. ".json",
      "--output-dir", "./snapshot",
      -- "--raw", "s3select://" .. tenantBucket .. "/default/"
      "--app-url", "dev.speedscale.com",
      "--api-key", "$SPEEDSCALE_API_KEY",
      "--ignore-in-svc", "frontend:8080",
    }
  },
  {
    name = "analyzer - snapshot - local",
    type = "go",
    request = "launch",
    program = vim.fn.getcwd() .. "/analyzer/",
    args = {
      "snapshot",
      "--snapshot", "/Users/josh/.speedscale/data/snapshots/" .. snapshotID .. ".json",
      "--output-dir", "./snapshot",
      "--raw", "/Users/josh/.speedscale/data/snapshots/" .. snapshotID .. "/raw.jsonl"
    }
  },
  {
    name = "api-gateway",
    type = "go",
    request = "launch",
    program = vim.fn.getcwd() .. "/api-gateway/",
  },
  {
    name = "generator",
    type = "go",
    request = "launch",
    program = vim.fn.getcwd() .. "/generator/",
  },
  {
    name = "goproxy",
    type = "go",
    request = "launch",
    program = vim.fn.getcwd() .. "/goproxy/",
  },
  {
    name = "inspector",
    type = "go",
    request = "launch",
    program = vim.fn.getcwd() .. "/inspector/",
  },
  {
    name = "operator",
    type = "go",
    request = "launch",
    program = vim.fn.getcwd() .. "/operator/",
  },
  {
    name = "responder",
    type = "go",
    request = "launch",
    program = vim.fn.getcwd() .. "/responder/",
  },
  {
    name = "speedctl",
    type = "go",
    request = "launch",
    program = vim.fn.getcwd() .. "/speedctl/",
    args = {
      -- "replay", "3d03f3c8-f7f3-41be-8147-b367b5d96e50", "--test-config-id", "regression", "--mode", "generator-only", "--custom-url", "127.0.0.1:9000",
      -- "infra", "replay", "--cluster", "jmt-dev", "-n", "beta-services", "notifications", "--snapshot-id", "e04bb776-89f0-42b7-afb7-9bb9a56bb3e1"
    }
  },
  {
    name = "current file",
    type = "go",
    request = "launch",
    program = "${file}",
  },
}

-- dapUI.setup(
--   {
--     force_buffers = true,
--     layouts = { {
--       elements = {
--         { id = "breakpoints", size = 0.25 },
--         { id = "stacks", size = 0.25 },
--         { id = "watches", size = 0.25 },
--         { id = "scopes", size = 0.25 },
--       },
--       position = "left",
--       size = 40
--     },
--       {
--         elements = { { id = "repl", size = 0.9 } },
--         position = "bottom",
--         size = 20
--       },
--     },
--     render = {
--       indent = 1,
--       max_value_lines = 1000
--     },
-- })

dapUI.setup(
  {
    force_buffers = true,
    layouts = { {
      elements = {
        { id = "breakpoints", size = 0.25 },
        { id = "stacks", size = 0.25 },
        { id = "watches", size = 0.25 },
        { id = "scopes", size = 0.25 },
      },
      position = "left",
      size = 40
    },
      {
        elements = { { id = "repl", size = 0.9 } },
        position = "bottom",
        size = 20
      },
    },
    render = {
      indent = 1,
      max_value_lines = 1000
    },
})

local mapkey = vim.keymap.set
local opts = { noremap=true, silent=true }

function DAPRun()
  dap.continue()
  dapUI.open()
end

function DAPTerminate()
  dap.terminate()
  dapUI.close()
end

mapkey('n', '<leader>dd', '<cmd>lua DAPRun()<CR>', opts)
mapkey('n', '<leader>dq', '<cmd>lua DAPTerminate()<CR>', opts)
mapkey('n', '<leader>dc', '<cmd>lua require("dap").continue()<CR>', opts)
mapkey('n', '<leader>db', '<cmd>lua require("dap").toggle_breakpoint()<CR>', opts)
mapkey('n', '<leader>d<CR>', '<cmd>lua require("dap").toggle_breakpoint()<CR>', opts)
mapkey('n', '<leader>dn', '<cmd>lua require("dap").step_over()<CR>', opts)
mapkey('n', '<leader>di', '<cmd>lua require("dap").step_in()<CR>', opts)
mapkey('n', '<leader>do', '<cmd>lua require("dap").step_out()<CR>', opts)
mapkey('n', '<leader>dr', '<cmd>lua require("dap").restart()<CR>', opts)
mapkey('n', '<leader>dh', '<cmd>lua require("dap").run_to_cursor()<CR>', opts)
mapkey('n', '<leader>dI', '<cmd>lua require("dap.ui.widgets").hover()<CR>', opts)
mapkey('n', '<leader>di', '<cmd>lua require("dap").step_into()<CR>', opts)
mapkey('n', '<leader>du', '<cmd>lua require("dap").up()<CR>', opts)
mapkey('n', '<leader>dU', '<cmd>lua require("dap").down()<CR>', opts)

vim.api.nvim_set_hl(0, 'DapBreakpoint', { link = 'DiagnosticError' })
vim.api.nvim_set_hl(0, 'DapStopped', { link = 'DiagnosticWarn' })

vim.fn.sign_define('DapBreakpoint', { text='⏹', texthl='DapBreakpoint', linehl='', numhl='' })
vim.fn.sign_define('DapBreakpointRejected', { text='R', texthl='DapBreakpoint', linehl='', numhl= '' })
vim.fn.sign_define('DapLogPoint', { text='F', texthl='', linehl='', numhl= 'DapLogPoint' })
vim.fn.sign_define('DapStopped', { text='▶', texthl='DapStopped', linehl='', numhl= '' })
