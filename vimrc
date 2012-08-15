" Remove vi compatibility
set nocompatible

" Indent settings
set expandtab
set tabstop=4
set shiftwidth=4
set autoindent
set smartindent

" Other settings
set backspace=2
set ruler
set number
set nowrap

" Set to auto read when a file is changed from the outside
set autoread

"Key remaps
noremap <Space> <PageDown>
nnoremap <tab> %
vnoremap <tab> %

" Syntaxes
syntax enable
au BufNewFile,BufRead *.bf set filetype=brainfuck

set pastetoggle=<F2>

" Pathogen
call pathogen#infect()
filetype plugin indent on

if has("gui_running")
    set lines=46
    set columns=146
    colorscheme inkpot_gui
else
    set t_Co=256
    colorscheme inkpot
endif

" --- PLUGINS ---
" Tagbar
nmap <leader>l :TagbarToggle<cr>
imap <leader>l <ESC>:TagbarToggle<cr>i

" MiniBufExpl
let g:miniBufExplMapWindowNavVim = 1
let g:miniBufExplMapWindowNavArrows = 1
let g:miniBufExplMapCTabSwitchBufs = 1
let g:miniBufExplModSelTarget = 1
