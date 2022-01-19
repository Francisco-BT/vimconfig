let g:ale_sign_error = '❌'
let g:ale_sign_warning = '🔔'
let g:ale_fix_on_save = 1
let g:ale_linter_aliases = {'typescriptreact': 'typescript', 'javascriptreact': 'javascript'}
let g:ale_linters = {
    \ 'python': ['flake8', 'pylint'],
    \ 'c': ['clang'],
    \ 'javascript': ['eslint', 'prettier'],
    \ 'typescript': ['eslint', 'prettier'],
    \ 'json': ['eslint', 'prettier'],
    \ }
let g:ale_fixers = {
    \ 'python': ['yapf'],
    \ 'c': ['clang-format'],
    \ 'html': ['prettier'],
    \ 'css': ['prettier'],
    \ 'javascript': [ 'eslint', 'prettier'],
    \ 'javascriptreact': [ 'eslint', 'prettier', 'tslint'],
    \ 'typescript': [ 'eslint', 'prettier', 'tslint'],
    \ 'typescriptreact': [ 'eslint', 'prettier', 'tslint'],
    \ 'json': ['prettier'],
    \ 'jsonc': ['prettier'],
    \ }
let g:ale_javascript_prettier_options = '--single-quote'
let g:ale_javascript_prettier_use_local_config = 1


" mapping to move between errors
nmap <silent> [g <Plug>(ale_previous_wrap)
nmap <silent> ]g <Plug>(ale_next_wrap)
