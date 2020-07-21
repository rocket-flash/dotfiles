function w() {
    local srcdir="${SRC_DIR:-${HOME}/src}"
    local venvdir="${WORKON_HOME:-${HOME}/.virtualenvs}"
    if [[ $# < 1 ]]; then
        echo "Usage: $0 env [-s]"
        return 1
    fi

    local envname="$1"

    if [[ -d "${venvdir}/${envname}" ]]; then
        workon "${envname}"
        return 0
    fi

    local dir

    if hash -d | cut -d '=' -f1 | grep -q "${envname}"; then
        cd ~"${envname}"
    elif [[ -d "${srcdir}/${envname}" ]]; then
        cd "${srcdir}/${envname}"
    else
        echo "Invalid environment: ${envname}" 1>&2
        return 1
    fi

    if [[ -e "pyproject.toml" ]] && [[ "${2:-}" == "-s" ]]; then
        poetry shell
    fi
}
