#! /bin/bash -eu

fatal()   { printf "\\e[35m[FATAL]\\e[39m   %s\\n" "$*" 1>&2 ; exit 1 ; }

DOTFILES=(
    'SciTEUser.properties'
    'Xmodmap'
    'conkyrc'
    'dircolors'
    'gitconfig'
    'ideavimrc'
    'profile'
    'templates'
    'tmux.conf'
    'tmux.zsh'
    'zsh_aliases'
    'zsh_functions'
    'zshrc'
)

CONFIG_FILES=(
    'cmus'
    'compton.conf'
    'nvim'
    'termite'
    'trizen'
)

APPS=(
    'fzf'
    'rg'
    'tmux'
    'xsel'
)

DOTFILES_DIR="$(readlink -f "$(dirname "${BASH_SOURCE[0]}")")"

function installed() {
    type "$1" &> /dev/null
    return $?
}

function create_link() {
    [[ -L "$1" ]] && rm "$1"
    [[ -e "$1" ]] && mv "$1" "${1}.bak"

    ln -s "$2" "$1"
}

[[ -d "$HOME/.config" ]] || mkdir "$HOME/.config"
[[ -d "$HOME/usr/bin" ]] || mkdir -p "$HOME/usr/bin"
[[ -d "$HOME/usr/lib" ]] || mkdir -p "$HOME/usr/lib"

for file in "${DOTFILES[@]}"; do
    create_link "$HOME/.${file}" "$DOTFILES_DIR/${file}"
done

for file in "${CONFIG_FILES[@]}"; do
    create_link "$HOME/.config/${file}" "$DOTFILES_DIR/${file}"
done

for file in $DOTFILES_DIR/usr/bin/*; do
    create_link "$HOME/usr/bin/$(basename "$file")" "$file"
done

for file in $DOTFILES_DIR/usr/lib/*; do
    create_link "$HOME/usr/lib/$(basename "$file")" "$file"
done

find "$HOME/usr" -xtype l -print0 | xargs --no-run-if-empty -0 rm

[[ -e "$DOTFILES_DIR/zsh.$(hostname)" ]] && ln -sf "$DOTFILES_DIR/zsh.$(hostname)" "$HOME/.zsh.local"

[[ -L "$HOME/.vim" ]] && rm "$HOME/.vim"
ln -s "$HOME/.config/nvim" "$HOME/.vim"

[[ -L "$HOME/.vimrc" ]] && rm "$HOME/.vimrc"
ln -s "$HOME/.config/nvim/init.vim" "$HOME/.vimrc"

if installed vim; then
    if [ ! -e "$HOME/.config/nvim/autoload/plug.vim" ]; then
        curl -fLo ~/.config/nvim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
        # TERM workaround to avoid loading non existing color scheme
        TERM=xterm vim +PlugInstall +qall
    fi
fi

# Regenerate screen and screen-256color terminfo to fix C-h problem with neovim
# https://github.com/christoomey/vim-tmux-navigator/issues/71
TERMS=( 'screen' 'screen-256color' 'tmux' 'tmux-256color' )
for term in "${TERMS[@]}"; do
    infocmp "$term" | sed 's/kbs=^[hH]/kbs=\\177/' > "${term}.ti"
    tic "${term}.ti"
    rm "${term}.ti"
done

installed crontab && crontab "$DOTFILES_DIR/crontab"

MISSING_APPS=""
for app in "${APPS[@]}"; do
    installed "$app" || MISSING_APPS="${MISSING_APPS}${app} "
done

[[ -z "$MISSING_APPS" ]] || printf "Don't forget to install the following:\\n  %s\\n" "$MISSING_APPS"
