-- ┌─────────────────────────┐
-- │ Plugins outside of MINI │
-- └─────────────────────────┘
-- Make concise helpers for installing/adding plugins in two stages
local add, later = MiniDeps.add, MiniDeps.later
local now_if_args = _G.Config.now_if_args

now_if_args(function()
add({ source = "christoomey/vim-tmux-navigator" })
end)

now_if_args(function()
  add({ source = "oonamo/ef-themes.nvim" })
    require("ef-themes").setup({ transparent = true })
    vim.cmd("colorscheme ef-deuteranopia-dark")
end)

now_if_args(function()
  add({
    source = 'nvim-treesitter/nvim-treesitter',
    checkout = 'main',
    hooks = { post_checkout = function() vim.cmd('TSUpdate') end },
  })
  add({
    source = 'nvim-treesitter/nvim-treesitter-textobjects',
    checkout = 'main',
  })

  local languages = {
    -- These are already pre-installed with Neovim. Used as an example.
    'lua',
    'vimdoc',
    'markdown',
  }
  local isnt_installed = function(lang)
    return #vim.api.nvim_get_runtime_file('parser/' .. lang .. '.*', false) == 0
  end
  local to_install = vim.tbl_filter(isnt_installed, languages)
  if #to_install > 0 then require('nvim-treesitter').install(to_install) end

  local filetypes = {}
  for _, lang in ipairs(languages) do
    for _, ft in ipairs(vim.treesitter.language.get_filetypes(lang)) do
      table.insert(filetypes, ft)
    end
  end
  local ts_start = function(ev) vim.treesitter.start(ev.buf) end
  _G.Config.new_autocmd('FileType', filetypes, ts_start, 'Start tree-sitter')
end)

now_if_args(function()
  add('neovim/nvim-lspconfig')

  -- vim.lsp.enable({
  --   'lua_ls',
  --   'gopls',
  -- })
end)

later(function()
  add('stevearc/conform.nvim')
  require('conform').setup({ })
end)

later(function() add('rafamadriz/friendly-snippets') end)

later(function()
  add('mason-org/mason.nvim')
  require('mason').setup()
end)

later(function()
  add("mason-org/mason-lspconfig.nvim")
    require("mason-lspconfig").setup{ automatic_enable = true }
end)

-- now_if_args(function()
--   add ({
--     source = "nomnivore/ollama.nvim",
--   })
--   add ({ source = "nvim-lua/plenary.nvim" })
--   require("ollama").setup({ model = "codellama" })
--
-- end)

