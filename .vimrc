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
set fillchars+=vert:\┊
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
set list listchars=tab:\ \ ,trail:· 				" Highlight tailing whitespace
set signcolumn=yes
set number relativenumber

" Enable 256 term colors for neovim
let $NVIM_TUI_ENABLE_TRUE_COLOR=1
set termguicolors

" Javascript
autocmd BufRead *.js set filetype=javascript.jsx
autocmd BufRead *.jsx set filetype=javascript.jsx
augroup filetype javascript syntax=javascript
autocmd filetype tagbar,nerdtree setlocal signcolumn=no

if has("gui_running")
	autocmd GUIEnter * simalt ~x " Maximize gvim at start
	autocmd GUIEnter * set vb t_vb=
	set guifont=IBM_Plex_Mono:h10:cANSI:qDRAFT
	set guioptions-=m  "menu bar
	set guioptions-=T  "toolbar
	set guioptions-=r  "scrollbar right
	set guioptions-=L  "scrollbar left
endif

" Plugins
call plug#begin('~/.vim/plugged')
" Syntax
Plug 'sheerun/vim-polyglot'
Plug 'HerringtonDarkholme/yats.vim'
Plug 'yuezk/vim-js'
Plug 'maxmellon/vim-jsx-pretty'

" IDE
Plug 'scrooloose/nerdtree'
Plug 'dense-analysis/ale'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'editorconfig/editorconfig-vim'
Plug 'MattesGroeger/vim-bookmarks'
Plug 'alvan/vim-closetag'
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'Asheq/close-buffers.vim'
Plug 'mattn/emmet-vim' 
Plug 'easymotion/vim-easymotion'
Plug 'preservim/nerdcommenter'
Plug 'terryma/vim-multiple-cursors'
Plug 'jiangmiao/auto-pairs'
Plug 'AndrewRadev/splitjoin.vim'
Plug 'tpope/vim-obsession'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-unimpaired'
Plug 'Yggdroot/indentLine'
Plug 'jeffkreeftmeijer/vim-numbertoggle'
Plug 'leafgarland/typescript-vim'

" Git
Plug 'mhinz/vim-signify'
Plug 'tpope/vim-fugitive'

" Theme and UI
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'morhetz/gruvbox'

call plug#end()

silent! colorscheme gruvbox
