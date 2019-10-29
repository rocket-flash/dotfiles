type pyenv &> /dev/null || return

export PATH="/home/mathieu/.pyenv/shims:${PATH}"
export PYENV_SHELL=zsh

# PyEnv doesn't play well with virtualenvwrapper
export VIRTUALENVWRAPPER_PYTHON=/usr/bin/python

pyenv() {
    local command
    command="${1:-}"
    if [ "$#" -gt 0 ]; then
        shift
    fi

    case "$command" in
    rehash|shell)
        eval "$(pyenv "sh-$command" "$@")"
        ;;
    install|uninstall)
        command pyenv "$command" "$@"
        pyenv rehash
        ;;
    *)
        command pyenv "$command" "$@"
        ;;
    esac
}
