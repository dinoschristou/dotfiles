local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system { 'git', 'clone', '--filter=blob:none', '--branch=stable',
    'https://github.com/folke/lazy.nvim.git', lazypath }
end
vim.opt.rtp:prepend(lazypath)

vim.g.mapleader = ' '
vim.g.maplocalleader = '\\'

require('lazy').setup({
  { 'catppuccin/nvim', name = 'catppuccin', priority = 1000,
    opts = { flavour = 'macchiato' } },

  { 'nvim-telescope/telescope.nvim',
    dependencies = { 'nvim-lua/plenary.nvim' },
    keys = {
      { '<leader>ff', '<cmd>Telescope find_files<cr>' },
      { '<leader>fg', '<cmd>Telescope live_grep<cr>' },
      { '<leader>fb', '<cmd>Telescope buffers<cr>' },
    },
  },

  { 'nvim-treesitter/nvim-treesitter', build = ':TSUpdate',
    lazy = false,
    config = function()
      local ok, configs = pcall(require, 'nvim-treesitter.configs')
      if not ok then return end
      configs.setup {
        highlight = { enable = true },
        indent   = { enable = true },
      }
    end,
  },

  { 'nvim-lualine/lualine.nvim',
    opts = { options = { theme = 'catppuccin-macchiato' } } },

  { 'lewis6991/gitsigns.nvim', opts = {} },

  'tpope/vim-commentary',
  'tpope/vim-surround',
  'tpope/vim-fugitive',
}, {
  install = { colorscheme = { 'catppuccin', 'habamax' } },
  checker = { enabled = false },
})

vim.cmd.colorscheme 'catppuccin-macchiato'

local o = vim.opt
o.number         = true
o.relativenumber = true
o.cursorline     = true
o.scrolloff      = 8
o.sidescrolloff  = 8
o.signcolumn     = 'yes'
o.termguicolors  = true
o.wrap           = false
o.expandtab      = true
o.shiftwidth     = 2
o.tabstop        = 2
o.softtabstop    = 2
o.smartindent    = true
o.ignorecase     = true
o.smartcase      = true
o.hlsearch       = true
o.clipboard      = 'unnamedplus'
o.undofile       = true
o.hidden         = true
o.mouse          = 'a'

local map = vim.keymap.set
map('n', '<leader>/',  '<cmd>nohlsearch<cr>')
map('n', '<leader>w',  '<cmd>w<cr>')
map('n', '<leader>q',  '<cmd>q<cr>')
map('n', '<C-h>', '<C-w>h')
map('n', '<C-j>', '<C-w>j')
map('n', '<C-k>', '<C-w>k')
map('n', '<C-l>', '<C-w>l')
map('n', '<leader>bn', '<cmd>bnext<cr>')
map('n', '<leader>bp', '<cmd>bprevious<cr>')
map('n', '<leader>bd', '<cmd>bdelete<cr>')

vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'javascript', 'typescript', 'json', 'html', 'css', 'yaml', 'lua' },
  callback = function() vim.opt_local.shiftwidth = 2; vim.opt_local.tabstop = 2 end,
})
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'go',
  callback = function()
    vim.opt_local.expandtab = false
    vim.opt_local.shiftwidth = 4
    vim.opt_local.tabstop = 4
  end,
})
