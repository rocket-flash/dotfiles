#! /bin/bash

FILES=( 'zshrc' 'zsh_aliases' 'zsh_functions' 'vim' 'vimrc' 'xprofile' 'Xmodmap' 'SciTEUser.properties' 'gitconfig' 'templates' 'tmux.conf' 'tmux.zsh' 'i3' )

cd $HOME

for file in ${FILES[@]}; do
    [[ -L ".${file}" ]] && rm ".${file}"
    [[ -f ".${file}" ]] && mv ".${file}" ".${file}.bak"

    ln -s ".dotfiles/${file}" ".${file}"
done

if [ ! -d .vim/bundle/Vundle.vim ]; then
    mkdir -p .vim/bundle
    git clone https://github.com/gmarik/Vundle.vim.git .vim/bundle/Vundle.vim
fi
