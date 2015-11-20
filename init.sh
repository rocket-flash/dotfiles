#! /bin/bash

FILES=( 'zshrc' 'zsh_aliases' 'zsh_functions' 'xprofile' 'Xmodmap' 'SciTEUser.properties' 'gitconfig' 'tmux.conf' 'tmux.zsh' 'dircolors' )

DOTFILES_DIR="$(readlink -f "$(dirname ${BASH_SOURCE[0]})")"

for file in ${FILES[@]}; do
    [[ -L "$HOME/.${file}" ]] && rm "$HOME/.${file}"
    [[ -f "$HOME/.${file}" ]] && mv "$HOME/.${file}" "$HOME/.${file}.bak"

    ln -s "$DOTFILES_DIR/${file}" "$HOME/.${file}"
done

[[ -L "$HOME/.config/nvim" ]] && rm "$HOME/.config/nvim"
ln -s "$DOTFILES_DIR/nvim" "$HOME/.config/nvim"

[[ -L "$HOME/.vim" ]] && rm "$HOME/.vim"
ln -s "$HOME/.config/nvim" "$HOME/.vim"

[[ -L "$HOME/.vimrc" ]] && rm "$HOME/.vimrc"
ln -s "$HOME/.config/nvim/init.vim" "$HOME/.vimrc"

[[ -L "$HOME/.templates" ]] && rm "$HOME/.templates"
[[ -d "$HOME/.templates" ]] && mv "$HOME/.templates" "$HOME/.templates.bak"
ln -s "$DOTFILES_DIR/templates" "$HOME/.templates"

[[ -L "$HOME/.config/termite" ]] && rm "$HOME/.config/termite"
[[ -f "$HOME/.config/termite" ]] && mv "$HOME/.config/termite" "$HOME/.config/termite.bak"
ln -s "$DOTFILES_DIR/termite" "$HOME/.config/termite"

if [ ! -d $HOME/.config/nvim/autoload/plug.vim ]; then
    curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    # TERM workaround to avoid loading non existing color scheme
    TERM=xterm vim +PlugInstall +qall
fi

# Regenerate screen and screen-256color terminfo to fix C-h problem with neovim
# https://github.com/christoomey/vim-tmux-navigator/issues/71
TERMS=( 'screen' 'screen-256color' 'tmux' 'tmux-256color' )
for term in ${TERMS[@]}; do
    infocmp $term | sed 's/kbs=^[hH]/kbs=\\177/' > ${term}.ti
    tic ${term}.ti
    rm ${term}.ti
done
