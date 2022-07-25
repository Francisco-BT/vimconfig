" Javascript
autocmd BufRead *.js set filetype=javascript.jsx
autocmd BufRead *.jsx set filetype=javascript.jsx
augroup filetype javascript syntax=javascript
autocmd filetype tagbar,nerdtree setlocal signcolumn=no

if has("gui_running")
	autocmd GUIEnter * simalt ~x " Maximize gvim at start
	autocmd GUIEnter * set vb t_vb=
	set guioptions-=m  "menu bar
	set guioptions-=T  "toolbar
	set guioptions-=r  "scrollbar right
	set guioptions-=L  "scrollbar left
endif
