function _get_workon_dir() {
    local srcdir=$1
    local prj=$2

    if hash -d | cut -d '=' -f1 | grep -q "${prj}"; then
        echo ~"${prj}"
    elif [[ -d "${srcdir}/${prj}" ]]; then
        echo "${srcdir}/${prj}"
    fi
}

function w() {
    local srcdir="${SRC_DIR:-${HOME}/src}"

    if [[ -n "${1:-}" ]]; then
        local workondir="$(_get_workon_dir "${srcdir}" "$1")"
        if [[ -n "${workondir}" ]]; then
            cd "${workondir}"
            return 0
        fi
    fi

    prj=$(find ~/src -maxdepth 1 -mindepth 1 -print0 | xargs -0 -n1 basename | fzf -q "${@:-}")

    local workondir="$(_get_workon_dir "${srcdir}" "${prj}")"

    if [[ -n "${workondir}" ]]; then
        cd "${workondir}"
    else
        echo "Invalid environment: ${prj}" 1>&2
        return 1
    fi
}
