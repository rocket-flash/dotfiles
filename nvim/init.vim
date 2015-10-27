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
Plugin 'nathanaelkane/vim-indent-guides'
Plugin 'tpope/vim-surround'
Plugin 'xolox/vim-misc'
Plugin 'xolox/vim-easytags'
Plugin 'vim-scripts/auto-pairs-gentle'

" Colorschemes
Plugin 'twerth/ir_black'
Plugin 'ciaranm/inkpot'
Plugin 'altercation/vim-colors-solarized'
Plugin 'Wutzara/vim-materialtheme'
Plugin 'NLKNguyen/papercolor-theme'
Plugin 'alem0lars/vim-colorscheme-darcula'
Plugin 'gosukiwi/vim-atom-dark'

Plugin 'benmills/vimux'

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
" turn off search highlight
noremap <leader><space> :nohlsearch<CR>

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
set backupdir=.

" Set to auto read when a file is changed from the outside
set autoread

" Whitespaces
set listchars=tab:>-,trail:~
set list

" Key remaps
noremap <Space> <PageDown>
nnoremap <tab> %
vnoremap <tab> %

noremap <up>     <nop>
noremap <down>   <nop>
noremap <left>   <nop>
noremap <right>  <nop>
inoremap <up>    <nop>
inoremap <down>  <nop>
inoremap <left>  <nop>
inoremap <right> <nop>

noremap <C-j> <C-w>j
noremap <C-k> <C-w>k
noremap <C-h> <C-w>h
noremap <C-l> <C-w>l

" Close current buffer but keep window
nmap <leader>d :bp<bar>sp<bar>bn<bar>bd<CR>

if has('nvim')
    " Send all/line to terminal
    nnoremap <leader>sa ggyG<C-w>wpi<CR><C-\><C-n><C-w>p``
    nnoremap <leader>sl yy<C-w>wpi<CR><C-\><C-n><C-w>p
    inoremap <leader>sa <ESC>ggyG<C-w>wpi<CR><C-\><C-n><C-w>p``a
    inoremap <leader>sl <ESC>yy<C-w>wpi<CR><C-\><C-n><C-w>pa

    " Send current selection to terminal
    vnoremap <leader>ss y<C-w>wpi<CR><C-\><C-n><C-w>p

    tnoremap <ESC><ESC> <C-\><C-n>
endif

" Syntaxes
syntax enable
au BufNewFile,BufRead *.bf set filetype=brainfuck
au BufNewFile,BufRead *.asm set filetype=nasm
au BufNewFile,BufRead *.sql set filetype=pgsql

" Color / Window size
if has("gui_running")
    set lines=48
    set columns=200
    set guifont=Source\ Code\ Pro\ Semi-Light\ 10
    colorscheme ir_dark
else
    if substitute(system('tput colors'), '\n', '', '') == "256"
        let $NVIM_TUI_ENABLE_TRUE_COLOR=1

        if &diff
            colorscheme ir_dark
        else
            colorscheme PaperColor
        endif

        set bg=dark
    else
        colorscheme desert
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
imap <leader>l <ESC>:TagbarToggle<CR>a

" MiniBufExpl
let g:miniBufExplMapWindowNavVim = 1
let g:miniBufExplMapWindowNavArrows = 1
let g:miniBufExplMapCTabSwitchBufs = 1
let g:miniBufExplModSelTarget = 1
let g:miniBufExplForceSyntaxEnable = 1

" NERDTree
nnoremap <C-n> :NERDTreeToggle<CR>
nnoremap <leader>nn :NERDTreeToggle<CR>
nnoremap <leader>nc :NERDTreeCWD<CR>
nnoremap <leader>nf :NERDTreeFind<CR>

" vim-better-whitespace
nnoremap <leader>ws :StripWhitespace<CR>

" Indent Guide
let g:indent_guides_guide_size = 1
let g:indent_guides_start_level = 2
let g:indent_guides_enable_on_vim_startup = 1

" vim-easytag
let g:easytags_async = 1

" vimux
nnoremap <leader>r :VimuxRunLastCommand<CR>