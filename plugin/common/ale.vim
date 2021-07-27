let g:ale_sign_error = '❌'
let g:ale_sign_warning = '🔔'
let g:ale_fix_on_save = 1
let g:ale_linter_aliases = {'typescriptreact': 'typescript'}
let g:ale_linters = {
    \ 'python': ['flake8', 'pylint'],
    \ 'c': ['clang'],
    \ 'javascript': ['eslint'],
    \ 'typescript': ['eslint', 'prettier'],
    \ }
let g:ale_fixers = {
    \ 'python': ['yapf'],
    \ 'c': ['clang-format'],
    \ 'javascript': [ 'eslint', 'prettier'],
    \ 'typescript': [ 'eslint', 'prettier', 'tslint'],
    \ 'typescriptreact': [ 'eslint', 'prettier', 'tslint'],
    \ }
let g:ale_javascript_prettier_options = '--single-quote'
