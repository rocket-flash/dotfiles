#! /bin/bash

FILES=( 'zshrc' 'zsh_aliases' 'zsh_functions' 'vim' 'vimrc' 'xprofile' 'Xmodmap' 'SciTEUser.properties' 'gitconfig' 'tmux.conf' 'tmux.zsh' 'i3' )

cd $HOME

for file in ${FILES[@]}; do
    [[ -L ".${file}" ]] && rm ".${file}"
    [[ -f ".${file}" ]] && mv ".${file}" ".${file}.bak"

    ln -s ".dotfiles/${file}" ".${file}"
done

[[ -L ".templates" ]] && rm ".templates"
[[ -d ".templates" ]] && mv ".templates" ".templates.bak"
ln -s "$HOME/.dotfiles/templates" ".templates"

[[ -L ".config/termite" ]] && rm ".config/termite"
[[ -d ".config/termite" ]] && mv ".config/termite" ".config/termite.bak"
ln -s "$HOME/.dotfiles/termite" ".config/termite"

if [ ! -d .vim/bundle/Vundle.vim ]; then
    mkdir -p .vim/bundle
    git clone https://github.com/gmarik/Vundle.vim.git .vim/bundle/Vundle.vim
fi
