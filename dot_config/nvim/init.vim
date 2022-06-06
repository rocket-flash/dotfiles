" Load plugins first
call plug#begin()

Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'christoomey/vim-tmux-navigator'
Plug 'scrooloose/nerdcommenter'
Plug 'ntpeters/vim-better-whitespace'
Plug 'mhinz/vim-signify'
Plug 'nathanaelkane/vim-indent-guides'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-repeat'
Plug 'jiangmiao/auto-pairs'
Plug '907th/vim-auto-save'
Plug 'junegunn/vim-slash'
Plug 'junegunn/vim-easy-align'
Plug 'junegunn/fzf'
Plug 'junegunn/fzf.vim'
Plug 'easymotion/vim-easymotion'
Plug 'ryanoasis/vim-devicons'
Plug 'cespare/vim-toml', { 'branch': 'main' }
Plug 'NoahTheDuke/vim-just'
Plug 'Glench/Vim-Jinja2-Syntax'

if !&diff
    Plug 'junegunn/vim-peekaboo'

    if has('nvim') || has('patch-8.0-1453')
        Plug 'neoclide/coc.nvim', {'branch': 'release'}
    endif
endif

" Colorschemes
let g:zenburn_italic_Comment=1
Plug 'jnurmine/Zenburn'

call plug#end()

filetype plugin indent on

" Indent settings
set expandtab
set tabstop=4
set softtabstop=4
set shiftwidth=0 " Same as tabstop
set shiftround
set autoindent

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

" Start/End of line
nnoremap H ^
nnoremap L $

" Disable going in ex mode
noremap Q <nop>

" Insert at beginning / end of selected lines
vnoremap i <C-V>^I
vnoremap a <C-V>$A

" Cause we all do these mistakes
command! W w
command! Wq wq
command! WQ wq
command! Q q
command! Qa qa
command! QA qa

" Close current buffer but keep window
nnoremap <leader>d :bp<bar>sp<bar>bn<bar>bd<CR>

" JSON Tidy: Reformat JSON file
nnoremap <leader>jt :%!jq<CR>
" XML Tidy: Reformat XML file
nnoremap <leader>xt :%!tidy -xml -i -w 2048 2>/dev/null<CR>

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

" Type specific configs
autocmd FileType python setlocal foldmethod=indent foldnestmax=2 foldlevelstart=99
autocmd FileType yaml setlocal tabstop=2 shiftwidth=2

" Disable stuff that slow down vim when working with big files
function! DisableStuffForBigFiles() abort
    syntax off
    set nocursorline
endfunction

" Manually set file encodings
function! SetFileEncodings(encodings) abort
    let b:fileencodingsbak=&fileencodings
    let &fileencodings=a:encodings
endfunction

" Restore previous file encodings
function! RestoreFileEncodings() abort
    let &fileencodings=b:fileencodingsbak
    unlet b:fileencodingsbak
endfunction

" Prevent slow downs when opening files bigger than 1MiB
au BufReadPre * if getfsize(expand("%")) > 1048576 | :call DisableStuffForBigFiles() | endif

" Make NFOs nice!
au BufReadPre *.nfo call SetFileEncodings('cp437')|set ambiwidth=single
au BufReadPost *.nfo call RestoreFileEncodings()

" Colors
if exists('$TMUX')
    " Colors in tmux
    let &t_8f = "<Esc>[38;2;%lu;%lu;%lum"
    let &t_8b = "<Esc>[48;2;%lu;%lu;%lum"
endif

if substitute(system('tput colors'), '\n', '', '') == "256"
    if has('nvim')
        set termguicolors
        set guicursor=n-v-c-sm:block,i-ci-ve:ver25,r-cr-o:hor20
    endif

    set bg=dark
    colorscheme zenburn
else
    colorscheme desert
endif

" vimdiff
if &diff
    set diffopt+=iwhite " Ignore changes in amount of white space.
endif

" Plugin Configurations {{{

" Tagbar {{{
nnoremap <leader>l :TagbarToggle<CR>
inoremap <leader>l <ESC>:TagbarToggle<CR>a
" }}}

" MiniBufExpl {{{
let g:miniBufExplMapWindowNavVim = 1
let g:miniBufExplMapWindowNavArrows = 1
let g:miniBufExplMapCTabSwitchBufs = 1
let g:miniBufExplModSelTarget = 1
let g:miniBufExplForceSyntaxEnable = 1
" }}}

" CHADTree {{{
nnoremap <C-n> <cmd>CHADopen<cr>
"}}}

" vim-better-whitespace {{{
nnoremap <leader>ws :StripWhitespace<CR>
" }}}

" Indent Guide {{{
let g:indent_guides_guide_size = 1
let g:indent_guides_start_level = 2
let g:indent_guides_enable_on_vim_startup = 1
" }}}

" vim-auto-save {{{
let g:auto_save = 1  " enable AutoSave on Vim startup
let g:auto_save_in_insert_mode = 0  " do not save while in insert mode
let g:auto_save_silent = 1  " do not display the auto-save notification
" }}}

" EasyAlign {{{
" Start interactive EasyAlign in visual mode (e.g. vipga)
xmap ga <Plug>(EasyAlign)
xmap gs :EasyAlign *\ <CR>

" Start interactive EasyAlign for a motion/text object (e.g. gaip)
nmap ga <Plug>(EasyAlign)
" }}}

" FZF {{{
nnoremap <leader>fh :FZF ~<CR>
nnoremap <leader>f. :FZF <CR>
nnoremap <leader>ft :Tags <CR>
nnoremap <leader>fl :Lines <CR>
nnoremap <leader>fg :Rg <CR>
nnoremap <leader>fb :Buffers <CR>
nnoremap <leader>m :History<CR>
nnoremap <C-f> :FZF <CR>

let g:fzf_layout = { 'window': 'enew' }

" Match vim colorscheme
let g:fzf_colors =
\ { 'fg':      ['fg', 'Normal'],
  \ 'bg':      ['bg', 'Normal'],
  \ 'hl':      ['fg', 'Comment'],
  \ 'fg+':     ['fg', 'CursorLine', 'CursorColumn', 'Normal'],
  \ 'bg+':     ['bg', 'CursorLine', 'CursorColumn'],
  \ 'hl+':     ['fg', 'Statement'],
  \ 'info':    ['fg', 'PreProc'],
  \ 'border':  ['fg', 'Ignore'],
  \ 'prompt':  ['fg', 'Conditional'],
  \ 'pointer': ['fg', 'Exception'],
  \ 'marker':  ['fg', 'Keyword'],
  \ 'spinner': ['fg', 'Label'],
  \ 'header':  ['fg', 'Comment'] }
" }}}

" Airline {{{
set noshowmode
set laststatus=2
let g:airline_theme='zenburn'
let g:airline_skip_empty_sections = 1
let g:airline#extensions#branch#enabled = 1

let g:airline_left_sep = ''
let g:airline_right_sep = ''
let g:airline_left_alt_sep= '>'
let g:airline_right_alt_sep = '<'

let g:airline_section_z="%#__accent_bold#%4l/%L%#__restore__# :%3v"

" }}}

" Peekaboo {{{
let g:peekaboo_window='topleft new'
" }}}

" Coc.nvim {{{
let g:coc_global_extensions = [
  \ 'coc-diagnostic',
  \ 'coc-emoji',
  \ 'coc-git',
  \ 'coc-docker',
  \ 'coc-json',
  \ 'coc-pyright',
  \ 'coc-rust-analyzer',
  \ 'coc-sh',
  \ 'coc-yaml'
\ ]

" Better display for messages
set cmdheight=2
" Smaller updatetime for CursorHold & CursorHoldI
set updatetime=300
" don't give |ins-completion-menu| messages.
set shortmess+=c
" always show signcolumns
set signcolumn=yes

nnoremap <C-p> :CocCommand<CR>

" Use `lp` and `ln` for navigate diagnostics
nmap <silent> <C-Up> <Plug>(coc-diagnostic-prev)
nmap <silent> <C-Down> <Plug>(coc-diagnostic-next)

" Remap keys for gotos
nmap <silent> <leader>ld <Plug>(coc-definition)
nmap <silent> <leader>lt <Plug>(coc-type-definition)
nmap <silent> <leader>li <Plug>(coc-implementation)
nmap <silent> <leader>lg <Plug>(coc-references)
nmap <silent> <leader>lf <Plug>(coc-format)

nnoremap <silent> <leader>gb :CocCommand git.showCommit<CR>
nnoremap <silent> <leader>gi :CocCommand git.chunkInfo<CR>
nnoremap <silent> <leader>gd :CocCommand git.diffCached<CR>
nnoremap <silent> <leader>ga :CocCommand git.chunkStage<CR>
nnoremap <silent> <leader>gr :CocCommand git.chunkUndo<CR>

" Remap for rename current word
nmap <leader>lr <Plug>(coc-rename)

" Use K for show documentation in preview window
nnoremap <silent> K :call <SID>show_documentation()<CR>

function! s:show_documentation() abort
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  else
    call CocAction('doHover')
  endif
endfunction

inoremap <silent><expr> <TAB>
     \ pumvisible() ? "\<C-n>" :
     \ <SID>check_back_space() ? "\<TAB>" :
     \ coc#refresh()
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" Use <c-space> to trigger completion.
if has('nvim')
  inoremap <silent><expr> <c-space> coc#refresh()
else
  inoremap <silent><expr> <c-@> coc#refresh()
endif

" Use <cr> to confirm completion, `<C-g>u` means break undo chain at current
" position. Coc only does snippet and additional edit on confirm.
" <cr> could be remapped by other vim plugin, try `:verbose imap <CR>`.
if exists('*complete_info')
  inoremap <expr> <cr> complete_info()["selected"] != "-1" ? "\<C-y>" : "\<C-g>u\<CR>"
else
  inoremap <expr> <cr> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"
endif

" }}}

" }}}

" vim: foldmethod=marker
