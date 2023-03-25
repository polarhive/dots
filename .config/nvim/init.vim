" vimplug
call plug#begin('~/.local/share/nvim/plugged')
Plug 'vim-airline/vim-airline'
Plug 'ap/vim-css-color'
call plug#end()

" settings
set clipboard+=unnamedplus
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
set wrap
syntax on

" theme
colorscheme codecourse-contrast

" file stuff
autocmd FileType html set nowrap
autocmd FileType text set spell spelllang=en_gb tw=80 wrap
autocmd FileType markdown set spell spelllang=en_gb tw=80 wrap
:highlight ExtraWhitespace ctermbg=red guibg=red
:autocmd Syntax * syn match ExtraWhitespace /\s\+$\| \+\ze\t/
