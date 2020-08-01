filetype indent plugin on                   "
syntax on
silent! colorscheme desert
set encoding=utf-8
set backspace=indent,eol,start
set hidden
set background=dark
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
set number
set showmatch


" Switching into buffers
map <C-N> :bnext<CR>
map <C-P> :bprev<CR>
imap <C-N> <Esc>:bnext<CR>i
imap <C-P> <Esc>:bprev<CR>i

let mapleader=","

" Toggle relative number
autocmd InsertEnter * :set relativenumber
autocmd InsertLeave * :set norelativenumber
colorscheme desert
