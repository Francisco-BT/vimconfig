" Plugins
call plug#begin('~/.vim/plugged')
Plug 'tpope/vim-sensible'

" Syntax
Plug 'sheerun/vim-polyglot'

" Javascript
Plug 'jxnblk/vim-mdx-js'
Plug 'pantharshit00/vim-prisma'
Plug 'yuezk/vim-js'

" TypeScript
Plug 'HerringtonDarkholme/yats.vim'
Plug 'leafgarland/typescript-vim'
Plug 'maxmellon/vim-jsx-pretty'


"IDE
Plug 'AndrewRadev/splitjoin.vim'
Plug 'Asheq/close-buffers.vim'
Plug 'Yggdroot/indentLine'
Plug 'alvan/vim-closetag'
Plug 'dense-analysis/ale'
Plug 'easymotion/vim-easymotion'
Plug 'jeffkreeftmeijer/vim-numbertoggle'
Plug 'jiangmiao/auto-pairs'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'leafOfTree/vim-matchtag'
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'preservim/nerdcommenter'
Plug 'scrooloose/nerdtree'
Plug 'tpope/vim-obsession'
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-unimpaired'
"Plug 'terryma/vim-multiple-cursors'
"Plug 'editorconfig/editorconfig-vim'
"Plug 'MattesGroeger/vim-bookmarks'

" Git
Plug 'mhinz/vim-signify'
Plug 'tpope/vim-fugitive'

" Theme and UI
Plug 'morhetz/gruvbox'
Plug 'chriskempson/base16-vim'
Plug 'lifepillar/vim-solarized8'
Plug 'Sammyalhashe/random_colorscheme.vim'
Plug 'Xuyuanp/nerdtree-git-plugin'
Plug 'ryanoasis/vim-devicons'
Plug 'tiagofumo/vim-nerdtree-syntax-highlight'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
"Plug 'wincent/terminus'

call plug#end()
