-- dotfiles wrapper for vim.health
local M = {
  _reports = {},
}

function M.check()
  vim.health.start('dotfiles')

  for _, report in ipairs(M._reports) do
    local health_fn, msg = report[1], report[2]
    health_fn(msg)
  end
end

-- add a health report
local function report(health_fn, msg)
  table.insert(M._reports, { health_fn, msg })
end

function M.ok(msg)
  report(vim.health.ok, msg)
end

function M.warn(msg)
  report(vim.health.warn, msg)
end

function M.error(msg)
  report(vim.health.error, msg)
end

return M
