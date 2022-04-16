" vim stuff
syntax on
set splitbelow splitright
set linebreak
set textwidth=80
set cursorline
set termguicolors
set noswapfile
set incsearch
set encoding=utf-8
set showmatch
set hlsearch

" vimplug
call plug#begin('~/.local/share/nvim/plugged')
Plug 'vim-airline/vim-airline'
Plug 'rainglow/vim'
call plug#end()

" theme
colorscheme codecourse-contrast

