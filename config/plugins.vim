" Plugins
call plug#begin('~/.vim/plugged')
Plug 'tpope/vim-sensible'

" Syntax
Plug 'sheerun/vim-polyglot'

" Javascript
Plug 'yuezk/vim-js'
Plug 'pantharshit00/vim-prisma'
Plug 'jxnblk/vim-mdx-js'

" TypeScript
Plug 'HerringtonDarkholme/yats.vim'
Plug 'maxmellon/vim-jsx-pretty'
Plug 'leafgarland/typescript-vim'


"IDE
Plug 'scrooloose/nerdtree'
Plug 'dense-analysis/ale'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'alvan/vim-closetag'
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'Asheq/close-buffers.vim'
Plug 'easymotion/vim-easymotion'
Plug 'preservim/nerdcommenter'
Plug 'jiangmiao/auto-pairs'
Plug 'AndrewRadev/splitjoin.vim'
Plug 'tpope/vim-obsession'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-unimpaired'
Plug 'Yggdroot/indentLine'
Plug 'jeffkreeftmeijer/vim-numbertoggle'
Plug 'tpope/vim-repeat'
Plug 'leafOfTree/vim-matchtag'
"Plug 'terryma/vim-multiple-cursors'
"Plug 'editorconfig/editorconfig-vim'
"Plug 'MattesGroeger/vim-bookmarks'

" Git
Plug 'mhinz/vim-signify'
Plug 'tpope/vim-fugitive'

" Theme and UI
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'Xuyuanp/nerdtree-git-plugin'
Plug 'chriskempson/base16-vim'
Plug 'ryanoasis/vim-devicons'
Plug 'tiagofumo/vim-nerdtree-syntax-highlight'
Plug 'lifepillar/vim-solarized8'
"Plug 'wincent/terminus'
"Plug 'morhetz/gruvbox'

call plug#end()
