#! /bin/bash -eu

fatal()        { printf "\\e[35m[FATAL]\\e[39m   %s\\n" "$*" 1>&2 ; exit 1 ; }
prompt_no_nl() { printf "\\e[36m[PROMPT]\\e[0m  %s" "$*" >&2; read -r -n1 resp; echo "$resp" ; }

DOTFILES=(
    'SciTEUser.properties'
    'Xmodmap'
    'conkyrc'
    'dircolors'
    'gitconfig'
    'ideavimrc'
    'profile'
    'templates'
    'tmux.zsh'
    'zsh_aliases'
    'zsh_functions'
    'zshrc'
)

DIRS=(
    '.config'
    '.fonts'
    '.local/share'
    'usr/bin'
    'usr/lib'
)

APPS=(
    'bat'
    'cargo'
    'colordiff'
    'fd'
    'fzf'
    'node'
    'npm'
    'rg'
    'tmux'
    'xsel'
    'yarn'
)

DOTFILES_DIR="$(readlink -f "$(dirname "${BASH_SOURCE[0]}")")"

unattended=0

if [[ $# -ge 1 ]] && [[ "$1" == "-u" ]]; then
    unattended=1
fi

function installed() {
    type "$1" &> /dev/null
    return $?
}

function ask_yes_no {
    if [[ "${unattended}" != 1 ]]; then
        resp=$(prompt_no_nl "$1")

        [[ -z "$resp" ]] && resp="$2" || echo
    else
        resp="$2"
    fi

    if [[ "$resp" = "y" ]] || [[ "$resp" = "Y" ]]; then
        return 0
    else
        return 1
    fi
}

function create_link() {
    [[ -L "$1" ]] && rm "$1"
    [[ -e "$1" ]] && mv "$1" "${1}.bak"

    ln -s "$2" "$1"
}

function copy_file() {
    [[ -L "$1" ]] && rm "$1"
    [[ -e "$1" ]] && mv "$1" "${1}.bak"

    cp "$2" "$1"
}

for dir in "${DIRS[@]}"; do
    [[ -d "$HOME/${dir}" ]] || mkdir -p "$HOME/${dir}"
done

for file in "${DOTFILES[@]}"; do
    create_link "$HOME/.${file}" "$DOTFILES_DIR/${file}"
done

for file in "${DOTFILES_DIR}"/config/*; do
    create_link "$HOME/.config/$(basename "$file")" "$file"
done

for file in "${DOTFILES_DIR}"/share/*; do
    create_link "$HOME/.local/share/$(basename "$file")" "$file"
done

for file in "${DOTFILES_DIR}"/fonts/*; do
    copy_file "$HOME/.fonts/$(basename "$file")" "$file"
done

for file in "${DOTFILES_DIR}"/usr/bin/*; do
    create_link "$HOME/usr/bin/$(basename "$file")" "$file"
done

for file in "${DOTFILES_DIR}"/usr/lib/*; do
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
    fi

    # TERM workaround to avoid loading non existing color scheme

    if ask_yes_no "Install vim plugins [y/N]? " "n"; then
        TERM=xterm vim -S "$DOTFILES_DIR/vimplug.lock" +qall
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

if installed tmux; then
    if [ ! -e "$HOME/.local/share/tmux/tpm" ]; then
        mkdir -p "$HOME/.local/share/tmux"
        git clone https://github.com/tmux-plugins/tpm ~/.local/share/tmux/tpm
    else
        pushd "$HOME/.local/share/tmux/tpm"
        git pull
        popd
    fi
fi

if installed cargo; then
    if ask_yes_no "Install cmus-notify [y/N]? " "n"; then
        pushd /tmp
        git clone https://github.com/mathieu-lemay/cmus-notify.git

        pushd cmus-notify
        cargo build --release
        mv target/release/cmus-notify "$HOME/usr/bin"
        popd

        rm -rf cmus-notify
        popd
    fi
fi

if installed pyenv; then
    pyenv_plugin_root="$(pyenv root)/plugins"

    if [ -e "${pyenv_plugin_root}/xxenv-latest" ]; then
        pushd "${pyenv_plugin_root}/xxenv-latest"
        git pull
        popd
    else
        [[ -d "$pyenv_plugin_root" ]] || mkdir -p "$pyenv_plugin_root"
        git clone https://github.com/momo-lab/xxenv-latest.git "${pyenv_plugin_root}/xxenv-latest"
    fi
fi

installed crontab && crontab "$DOTFILES_DIR/crontab"

installed bat && bat cache --build

MISSING_APPS=""
for app in "${APPS[@]}"; do
    installed "$app" || MISSING_APPS="${MISSING_APPS}${app} "
done

[[ -z "$MISSING_APPS" ]] || printf "Don't forget to install the following:\\n  %s\\n" "$MISSING_APPS"
