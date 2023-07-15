-- set-variables
local autocmd = vim.api.nvim_create_autocmd
local cmd = vim.cmd
local g = vim.g
local o = vim.opt

-- tweaks
o.autoindent = true
o.clipboard = "unnamedplus"
o.cursorline = true
o.expandtab = true
o.hlsearch = false
o.ignorecase = true
o.incsearch = true
o.linebreak = true
o.number = true
o.ruler = true
o.shiftwidth = 4
o.showmatch = true
o.smartcase = true
o.smartindent = true
o.smarttab = true
o.softtabstop= 4
o.swapfile = false
o.termguicolors = true
o.textwidth=72
o.undolevels = 1000
o.visualbell = true
o.wildmenu = true
o.wrap = false
-- o.spell = true

-- vimscript
cmd [[
autocmd BufWritePre * %s/\s\+$//e
colorscheme lunaperche
]]

return require('packer').startup(function(use)
 use 'wbthomason/packer.nvim'
end)

