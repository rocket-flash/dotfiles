function docker-grep-rmi() {
    select_pattern="${1:?Pattern not specified}"
    ignore_pattern="${2:-}"

    local images

    images=$(docker images | grep -- "${select_pattern}")
    if [ -n "${ignore_pattern}" ]; then
        images=$(echo "${images}" | grep -v -- "${ignore_pattern}")
    fi
    images=$(echo "${images}" | awk -F ' ' '{print $1 ":" $2}')

    if [[ -z "${images}" ]]; then
        echo "Nothing to delete"
        return 0
    fi

    echo "Images:"
    for i in "${=images}"; do
        echo "  $i"
    done

    echo -n "Delete images? [Y/n] "
    read -s -k response
    echo ""

    response="$(echo "${response}" | tr '[:upper:]' '[:lower:]')"

    if [[ ${response:-y} == "y" ]]; then
        echo "${images}" | xargs docker rmi
    fi
}

function docker-cleanup() {
    docker container prune "$@"
    docker image prune "$@"
    docker volume prune "$@"
}

function dps() {
    docker ps --format "table {{.Names}}\t{{.Command}}\t{{.Status}}\t{{printf \"%.65s\" .Image }}" $@
}

# Fix completion when optional arguments are combined (`-i -t` -> `-it`)
# https://github.com/docker/cli/issues/993
zstyle ':completion:*:*:docker:*' option-stacking yes
zstyle ':completion:*:*:docker-*:*' option-stacking yes
