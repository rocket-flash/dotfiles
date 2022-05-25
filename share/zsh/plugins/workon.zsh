function _get_workon_dir() {
    local srcdir=$1
    local prj=$2

    if hash -d | cut -d '=' -f1 | grep -q "${prj}"; then
        echo ~"${prj}"
    elif [[ -d "${srcdir}/${prj}" ]]; then
        echo "${srcdir}/${prj}"
    elif [[ -d "${srcdir}/direct/${prj}" ]]; then
        echo "${srcdir}/direct/${prj}"
    elif [[ -d "${srcdir}/devops/${prj}" ]]; then
        echo "${srcdir}/devops/${prj}"
    elif [[ -d "${srcdir}/private/${prj}" ]]; then
        echo "${srcdir}/private/${prj}"
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

    prj=$(find ~/src ~/src/direct ~/src/devops ~/src/private -maxdepth 1 -mindepth 1 -print0 | xargs -0 -n1 basename | fzf-tmux "${=FZF_TMUX_OPTS:-}" -q "${@:-}")

    if [[ -z "${prj}" ]]; then
        echo "No project selected" 1>&2
        return 2
    fi

    local workondir="$(_get_workon_dir "${srcdir}" "${prj}")"

    if [[ -n "${workondir}" ]]; then
        cd "${workondir}"
    else
        echo "Invalid environment: ${prj}" 1>&2
        return 1
    fi
}
