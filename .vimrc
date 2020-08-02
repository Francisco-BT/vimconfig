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

" Switching into buffers
map <C-N> :bnext<CR>
map <C-P> :bprev<CR>
imap <C-N> <Esc>:bnext<CR>i
imap <C-P> <Esc>:bprev<CR>i

" Toggle relative numbers
autocmd InsertEnter * :set norelativenumber
autocmd InsertLeave * :set relativenumber

let mapleader=","

if has("gui_running")
	autocmd GUIEnter * simalt ~x " Naximize gvim at start
	autocmd GUIEnter * set vb t_vb=
endif


" Plugins
call plug#begin('~/.vim/plugged')
Plug 'scrooloose/nerdtree'
Plug 'sheerun/vim-polyglot'
Plug 'dense-analysis/ale'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'Townk/vim-autoclose'
Plug 'editorconfig/editorconfig-vim'
Plug 'MattesGroeger/vim-bookmarks'
Plug 'alvan/vim-closetag'
Plug 'airblade/vim-gitgutter'
Plug 'neoclide/coc.nvim'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'jeffkreeftmeijer/vim-dim'
Plug 'Asheq/close-buffers.vim'
Plug 'mattn/emmet-vim' 
Plug 'tmsvg/pear-tree'
Plug 'AndrewRadev/splitjoin.vim'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-obsession'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-unimpaired'
Plug 'morhetz/gruvbox'
call plug#end()

silent! colorscheme gruvbox
