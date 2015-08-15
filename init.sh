#! /bin/bash

FILES=( 'zshrc' 'zsh_aliases' 'zsh_functions' 'vim' 'vimrc' 'xprofile' 'Xmodmap' 'SciTEUser.properties' 'gitconfig' 'tmux.conf' 'tmux.zsh' 'i3' )

cd $HOME

for file in ${FILES[@]}; do
    [[ -L ".${file}" ]] && rm ".${file}"
    [[ -f ".${file}" ]] && mv ".${file}" ".${file}.bak"

    ln -s ".dotfiles/${file}" ".${file}"
done

[[ -L ".nvim" ]] && rm ".nvim"
[[ -d ".nvim" ]] && mv ".nvim" ".nvim.bak"
ln -s ".vim" ".nvim"

[[ -L ".nvimrc" ]] && rm ".nvimrc"
[[ -f ".nvimrc" ]] && mv ".nvimrc" ".nvimrc.bak"
ln -s ".vimrc" ".nvimrc"

[[ -L ".templates" ]] && rm ".templates"
[[ -d ".templates" ]] && mv ".templates" ".templates.bak"
ln -s ".dotfiles/templates" ".templates"

[[ -L ".config/termite" ]] && rm ".config/termite"
[[ -f ".config/termite" ]] && mv ".config/termite" ".config/termite.bak"
ln -s "$HOME/.dotfiles/termite" ".config/termite"

if [ ! -d .vim/bundle/Vundle.vim ]; then
    mkdir -p .vim/bundle
    git clone https://github.com/gmarik/Vundle.vim.git .vim/bundle/Vundle.vim
fi

# Regenerate screen and screen-256color terminfo to fix C-h problem with neovim
# https://github.com/christoomey/vim-tmux-navigator/issues/71
TERMS=( 'screen' 'screen-256color' )
for term in ${TERMS[@]}; do
    infocmp $term | sed 's/kbs=^[hH]/kbs=\\177/' > ${term}.ti
    tic ${term}.ti
    rm ${term}.ti
done
