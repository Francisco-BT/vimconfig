filetype indent plugin on                   "
syntax on
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
set number 
set clipboard+=unnamed,unnamedplus
set autoread
set cursorline
set ruler
set list listchars=tab:\ \ ,trail:· 				" Highlight tailing whitespace
set signcolumn=yes

" Toggle relative numbers
autocmd InsertEnter * :set norelativenumber
autocmd InsertLeave * :set relativenumber
autocmd filetype tagbar,nerdtree setlocal signcolumn=no

let mapleader=","

if has("gui_running")
	autocmd GUIEnter * simalt ~x " Naximize gvim at start
	autocmd GUIEnter * set vb t_vb=
	set guifont=Fantasque_Sans_Mono:h10:b:cANSI:qDRAFT
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
Plug 'neoclide/coc.nvim'
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
"Plug 'tmsvg/pear-tree'

" Git
Plug 'mhinz/vim-signify'
Plug 'tpope/vim-fugitive'

" Theme and UI
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'morhetz/gruvbox'

call plug#end()

silent! colorscheme gruvbox
