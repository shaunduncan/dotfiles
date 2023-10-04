local vim = vim

-- TODO:
-- dap
-- ultisnips/luasnip
-- add to git

-- dap {{{
-- local dap = require("dap")
-- require("dap-go").setup()
-- }}}

-- glow {{{
require('glow').setup({
  height_ratio = 0.85,
})
-- }}}

-- shade {{{
-- require('shade').setup()
-- }}}

-- venn.nvim (diagramming) {{{
function _G.Toggle_venn()
  local venn_enabled = vim.inspect(vim.b.venn_enabled)

  if venn_enabled == "nil" then
    vim.b.venn_enabled = true
    vim.cmd[[setlocal ve=all]]

    -- draw a line on HJKL keystokes
    vim.api.nvim_buf_set_keymap(0, "n", "J", "<C-v>j:VBox<CR>", {noremap = true})
    vim.api.nvim_buf_set_keymap(0, "n", "K", "<C-v>k:VBox<CR>", {noremap = true})
    vim.api.nvim_buf_set_keymap(0, "n", "L", "<C-v>l:VBox<CR>", {noremap = true})
    vim.api.nvim_buf_set_keymap(0, "n", "H", "<C-v>h:VBox<CR>", {noremap = true})

    -- draw a box by pressing "b" with visual selection
    vim.api.nvim_buf_set_keymap(0, "v", "b", ":VBox<CR>", {noremap = true})
  else
    vim.cmd[[setlocal ve=]]
    vim.cmd[[mapclear <buffer>]]
    vim.b.venn_enabled = nil
  end
end

vim.api.nvim_set_keymap('n', '<leader>V', ":lua Toggle_venn()<CR>", { noremap = true})
-- }}}
