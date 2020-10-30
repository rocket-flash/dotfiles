function w() {
    local srcdir="${SRC_DIR:-${HOME}/src}"
    local prj="$1"

    if [[ -z "${prj}" ]]; then
        prj=$(find ~/src -maxdepth 1 -mindepth 1 -print0 | xargs -0 -n1 basename | fzf)
    fi

    if hash -d | cut -d '=' -f1 | grep -q "${prj}"; then
        cd ~"${prj}"
    elif [[ -d "${srcdir}/${prj}" ]]; then
        cd "${srcdir}/${prj}"
    else
        echo "Invalid environment: ${prj}" 1>&2
        return 1
    fi
}
