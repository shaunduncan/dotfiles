local M = {}

local health = require('dotfiles.health')

-- creates a "mock" that can be returned for callers to be able to safely do something like
-- try(module).setup() without needing to check for nil
local function mock()
  local m = {}
  setmetatable(m, {
    __index = function(...) return m end,
    __call = function(...) return m end,
  })
  return m
end

-- attempt to require() a module and report a health event based on the outcome. returns either the required
-- module or a mock
function M.require(module)
  local ok, result = pcall(require, module)

  if ok then
    health.ok('success: loaded module "' .. module .. '"')
    return result
  end

  health.error('error: require("' .. module .. '") failed: ' .. result)
  return mock()
end

return M
