" Remove vi compatibility
set nocompatible

" Indent settings
set expandtab
set tabstop=4
set shiftwidth=4
set autoindent
set smartindent

" Search settings
set ignorecase
set smartcase
set incsearch

" Other settings
set backspace=2
set ruler
set number
set nowrap
set pastetoggle=<F2>
set showcmd
set scrolloff=3

" Set to auto read when a file is changed from the outside
set autoread

"Key remaps
noremap <Space> <PageDown>
nnoremap <tab> %
vnoremap <tab> %

noremap <up> <nop>
noremap <down> <nop>
noremap <left> <nop>
noremap <right> <nop>
inoremap <up> <nop>
inoremap <down> <nop>
inoremap <left> <nop>
inoremap <right> <nop>

" Syntaxes
syntax enable
au BufNewFile,BufRead *.bf set filetype=brainfuck
au BufWritePost *.c,*.cpp,*.h silent! !ctags -R &

" Pathogen
call pathogen#infect()
filetype plugin indent on

if has("gui_running")
    set lines=46
    set columns=146
    colorscheme ir_dark
else
    set t_Co=256
    colorscheme ir_black
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
let g:miniBufExplForceSyntaxEnable = 1

" NERDTree
nnoremap <C-n> :NERDTreeToggle<cr>
