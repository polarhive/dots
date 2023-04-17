-- set-variables
local autocmd = vim.api.nvim_create_autocmd
local cmd = vim.cmd
local g = vim.g
local o = vim.opt

-- tweaks
o.clipboard = "unnamedplus"
o.cursorline = true
o.hlsearch = true
o.incsearch = true
o.number = true
o.smartcase = true
o.swapfile = false
o.termguicolors = true
o.wildmenu = true
o.wrap = false

-- vimscript
cmd [[
autocmd BufWritePre * %s/\s\+$//e
colorscheme lunaperche
]]
