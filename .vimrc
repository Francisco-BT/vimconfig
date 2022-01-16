let mapleader=","
filetype indent plugin on
syntax on
set mouse=a
set background=dark
set encoding=utf-8
set backspace=indent,eol,start
set hidden
set nocompatible                            " Disable vi compatibility mode
set history=1000
set nobackup
set noswapfile
set undofile 
set undodir=~/.vim/undodir
set autoindent
set colorcolumn=80
set fillchars+=vert:\'
set noshowmode
set laststatus=1
set wildmenu
set nowrap
set showmatch
set noerrorbells
set novisualbell
set incsearch
set clipboard+=unnamed,unnamedplus
set autoread
set cursorline
set ruler
set list listchars=tab:▸\ ,trail:· 				" Highlight tailing whitespace
set signcolumn=yes
set number relativenumber

" Enable 256 term colors for neovim
let $NVIM_TUI_ENABLE_TRUE_COLOR=1
set termguicolors

hi htmlEndTag  guifg=#90b0d1 gui=NONE


if has("win64") || has("win32") || has("win16")
	source ~/vimfiles/config/autocomands.vim
	source ~/vimfiles/config/maps.vim
	source ~/vimfiles/config/plugins.vim
else
	source ~/.vim/config/autocomands.vim
	source ~/.vim/config/maps.vim
	source ~/.vim/config/plugins.vim
endif

let base16colorspace=256

silent! colorscheme base16-dracula
