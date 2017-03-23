" Load plugins first
call plug#begin()

Plug 'fholgado/minibufexpl.vim'
Plug 'scrooloose/nerdcommenter'
Plug 'scrooloose/nerdtree'
Plug 'majutsushi/tagbar'
Plug 'ntpeters/vim-better-whitespace'
Plug 'airblade/vim-gitgutter'
Plug 'nathanaelkane/vim-indent-guides'
Plug 'tpope/vim-surround'
Plug 'vim-scripts/auto-pairs-gentle'
Plug '907th/vim-auto-save'
Plug 'yegappan/mru'
Plug 'junegunn/vim-slash'

" Colorschemes
Plug 'twerth/ir_black'
Plug 'NLKNguyen/papercolor-theme'
Plug 'alem0lars/vim-colorscheme-darcula'

call plug#end()

" Indent settings
set expandtab
set tabstop=4
set softtabstop=4
set shiftwidth=0 " Same as tabstop
set shiftround
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
set wildmode=longest:full,full " Stop on ambiguity, then go through possibilities
set modeline
set backspace=indent,eol,start
set pastetoggle=<F2>
set scrolloff=3
set colorcolumn=120
set shortmess+=I " Remove intro text
set completeopt=menuone,longest " Show menu even if one possibility and stop on ambiguity
set mouse=a

" Set to auto read when a file is changed from the outside
set autoread

" Whitespaces
set listchars=tab:→\ ,trail:~
set list

" Use persistent undo
set undodir=~/.vim/undo
set undofile
set undolevels=1000 " maximum number of changes that can be undone
set undoreload=10000 " maximum number lines to save for undo on a buffer reload

" Key remaps
nnoremap <tab> %
vnoremap <tab> %

" Disable arrow keys
noremap <up>     <nop>
noremap <down>   <nop>
noremap <left>   <nop>
noremap <right>  <nop>
inoremap <up>    <nop>
inoremap <down>  <nop>
inoremap <left>  <nop>
inoremap <right> <nop>

" Move while in insert mode
nnoremap <C-k> <C-w>k
nnoremap <C-j> <C-w>j
nnoremap <C-h> <C-w>h
nnoremap <C-l> <C-w>l

" Switch panes
inoremap <C-k> <up>
inoremap <C-j> <down>
inoremap <C-h> <left>
inoremap <C-l> <right>

" Start/End of line
nnoremap H ^
nnoremap L $

" Disable macro recording or whatever
noremap q <nop>
" Disable going in ex mode
noremap Q <nop>

" Close current buffer but keep window
nmap <leader>d :bp<bar>sp<bar>bn<bar>bd<CR>

" JSON Tidy: Reformat JSON file
nmap <leader>jt :%!python -m json.tool<CR>
" XML Tidy: Reformat XML file
nmap <leader>xt :%!tidy -xml -i -w 2048 2>/dev/null<CR>

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

function DisableStuffForBigFiles()
    syntax off
    set nocursorline
endfunction

au BufReadPre * if getfsize(expand("%")) > 1048576 | :call DisableStuffForBigFiles() | endif

" Colors
if substitute(system('tput colors'), '\n', '', '') == "256"
    if has('nvim')
        set termguicolors
        let $NVIM_TUI_ENABLE_CURSOR_SHAPE=1
    endif

    colorscheme PaperColor
    set bg=dark
else
    colorscheme desert
endif

" vimdiff
if &diff
    set diffopt+=iwhite " Ignore changes in amount of white space.
endif

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

" MRU
nnoremap <Leader>m :MRU<CR>

" vim-better-whitespace
nnoremap <leader>ws :StripWhitespace<CR>

" Indent Guide
let g:indent_guides_guide_size = 1
let g:indent_guides_start_level = 2
let g:indent_guides_enable_on_vim_startup = 1

" vim-easytag
let g:easytags_async = 1
let g:easytags_file = '~/.vim/gtags'
let g:easytags_by_filetype = '~/.vim/tags/'

" vim-auto-save
let g:auto_save = 1  " enable AutoSave on Vim startup
let g:auto_save_in_insert_mode = 0  " do not save while in insert mode
let g:auto_save_silent = 1  " do not display the auto-save notification

" GitGutter
nnoremap <leader>gp :GitGutterPrevHunk<CR>
nnoremap <leader>gn :GitGutterNextHunk<CR>
nnoremap <leader>gr :GitGutterUndoHunk<CR>
