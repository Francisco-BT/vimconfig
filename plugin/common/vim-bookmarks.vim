let g:bookmark_no_default_key_mappings=1
nmap <Leader>mt <Plug>BookmarkToggle
nmap <Leader>mi <Plug>BookmarkAnnotate
nmap <Leader>ma <Plug>BookmarkShowAll
nmap <Leader>mn <Plug>BookmarkNext
nmap <Leader>mp <Plug>BookmarkPrev
nmap <Leader>md <Plug>BookmarkClear

" Settings
let g:bookmark_auto_save_file = $HOME . "/.vim/bookmarks"
let g:bookmark_center=1
