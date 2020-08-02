filetype indent plugin on                   "
syntax on
silent! colorscheme dim
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
set incsearch
set number 


" Switching into buffers
map <C-N> :bnext<CR>
map <C-P> :bprev<CR>
imap <C-N> <Esc>:bnext<CR>i
imap <C-P> <Esc>:bprev<CR>i

" Toggle relative numbers
autocmd InsertEnter * :set norelativenumber
autocmd InsertLeave * :set relativenumber

let mapleader=","
