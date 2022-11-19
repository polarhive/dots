" vimplug
call plug#begin('~/.local/share/nvim/plugged')
Plug 'vim-airline/vim-airline'
Plug 'rainglow/vim'
Plug 'ap/vim-css-color'
call plug#end()

" settings
set clipboard+=unnamedplus
set encoding=utf-8
set hlsearch
set incsearch
set linebreak
set noswapfile
set number
set showmatch
set splitbelow splitright
set termguicolors
set wrap
syntax on

" theme
colorscheme peacock-contrast

" file stuff
autocmd FileType html set nowrap
autocmd FileType text setlocal tw=80
autocmd FileType markdown setlocal spell spelllang=en_gb

