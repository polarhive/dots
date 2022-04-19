" vim stuff

set cursorline
set encoding=utf-8
set hlsearch
set incsearch
set linebreak
set noswapfile
set number
set showmatch
set splitbelow splitright
set termguicolors
syntax on
" vimplug
call plug#begin('~/.local/share/nvim/plugged')
Plug 'vim-airline/vim-airline'
Plug 'rainglow/vim'
call plug#end()

" theme
colorscheme codecourse-contrast

