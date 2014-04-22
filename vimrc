" Indent settings
set expandtab
set tabstop=4
set softtabstop=4
set shiftwidth=4
set autoindent
set smartindent

" Search settings
set ignorecase
set smartcase
set incsearch

" Other settings
set ruler
set number
set relativenumber
set nowrap
set showcmd
set cursorline
set wildmenu
set backspace=2
set pastetoggle=<F2>
set scrolloff=3

" Set to auto read when a file is changed from the outside
set autoread

" Whitespaces
set listchars=eol:$,tab:>-,trail:~,extends:>,precedes:<
set list

" Key remaps
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

noremap <C-J>     <C-W>j
noremap <C-K>     <C-W>k
noremap <C-H>     <C-W>h
noremap <C-L>     <C-W>l

" Close current buffer but keep window
nmap <leader>d :bp<bar>sp<bar>bn<bar>bd<CR>

" Syntaxes
syntax enable
au BufNewFile,BufRead *.bf set filetype=brainfuck
au BufNewFile,BufRead *.asm set filetype=nasm

" Color / Window size
if has("gui_running")
    set lines=48
    set columns=200
    colorscheme ir_dark
else
    set t_Co=256
    colorscheme ir_black
endif

noremap <F8> :call HexMe()<CR>

let $in_hex=0
function HexMe()
    set binary
    set noeol
if $in_hex>0
    :%!xxd -r
    let $in_hex=0
else
    :%!xxd
    let $in_hex=1
endif
endfunction

" --- PLUGINS ---
" Pathogen
call pathogen#infect()
filetype plugin indent on

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
