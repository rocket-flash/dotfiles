type pyenv &> /dev/null || return

export PATH="/home/mathieu/.pyenv/shims:${PATH}"
export PYENV_SHELL=zsh

# PyEnv doesn't play well with virtualenvwrapper
export VIRTUALENVWRAPPER_PYTHON=/usr/bin/python

function pyenv() {
    local cmd
    cmd="${1:-}"
    if [ "$#" -gt 0 ]; then
        shift
    fi

    case "$cmd" in
    rehash|shell)
        eval "$(pyenv "sh-$cmd" "$@")"
        ;;
    install)
        CONFIGURE_OPTS=--enable-shared command pyenv "$cmd" "$@"
        pyenv rehash
        ;;
    uninstall)
        command pyenv "$cmd" "$@"
        pyenv rehash
        ;;
    *)
        command pyenv "$cmd" "$@"
        ;;
    esac
}

source /usr/share/zsh/site-functions/_pyenv
