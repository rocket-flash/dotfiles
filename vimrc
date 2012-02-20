set expandtab
set tabstop=4
set shiftwidth=4
set autoindent
set smartindent
set backspace=2
set ruler
set nocompatible

syntax enable

set pastetoggle=<F2>

if has("gui_running")
    set lines=46
    set columns=146
    colorscheme inkpot_gui
else
    set t_Co=256
    colorscheme inkpot
"    set background=dark
endif
