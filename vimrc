" Load plugins first
set nocompatible            " be iMproved, required
filetype off                " required

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

" let Vundle manage Vundle (required!)
Plugin 'gmarik/Vundle.vim'

Plugin 'fholgado/minibufexpl.vim'
Plugin 'scrooloose/nerdcommenter'
Plugin 'scrooloose/nerdtree'
Plugin 'majutsushi/tagbar'
Plugin 'ntpeters/vim-better-whitespace'
Plugin 'airblade/vim-gitgutter'
Plugin 'tpope/vim-tbone'
Plugin 'twerth/ir_black'

call vundle#end()           " required
filetype plugin indent on   " required

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
set nowrap
set showcmd
set cursorline
set wildmenu
set modeline
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
au BufNewFile,BufRead *.sql set filetype=pgsql

" Color / Window size
if has("gui_running")
    set lines=48
    set columns=200
    colorscheme ir_dark
else
    let current_term=$TERM
    if current_term == 'screen-256color'
        set t_Co=256
        colorscheme ir_black
    endif
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
" Tagbar
nmap <leader>l :TagbarToggle<CR>
imap <leader>l <ESC>:TagbarToggle<CR>i

" MiniBufExpl
let g:miniBufExplMapWindowNavVim = 1
let g:miniBufExplMapWindowNavArrows = 1
let g:miniBufExplMapCTabSwitchBufs = 1
let g:miniBufExplModSelTarget = 1
let g:miniBufExplForceSyntaxEnable = 1

" NERDTree
nnoremap <C-n> :NERDTreeToggle<CR>

" tbone
" Write whole buffer
nnoremap <C-c>a :%Twrite last<CR>
" Write current line
nnoremap <C-c>c :Twrite last<CR>
" Write selection
vnoremap <C-c>c :Twrite last<CR>

" vim-better-whitespace
nnoremap <leader>ws :StripWhitespace<CR>
