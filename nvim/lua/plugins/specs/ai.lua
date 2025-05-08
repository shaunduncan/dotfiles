--------------------------------------------------------------------------------
--                               AI INTEGRATION                               --
--------------------------------------------------------------------------------

return {
  {
    'yetone/avante.nvim',
    dependencies = {
      'nvim-treesitter/nvim-treesitter',
      'nvim-lua/plenary.nvim',
      'stevearc/dressing.nvim',
      'MunifTanjim/nui.nvim',
      {
        'MeanderingProgrammer/render-markdown.nvim',
        opts = {
          file_types = { 'markdown', 'Avante' },
        },
        ft = { 'markdown', 'Avante' },
      },
    },
    build = ':AvanteBuild',
    event = 'VeryLazy',
    version = false,
    opts = {
      provider = 'gemini',
      gemini = {
        model = 'gemini-2.5-flash-preview-04-17',
        max_tokens = 65536,
      },
    },
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
