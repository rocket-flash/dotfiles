function docker-grep-rmi() {
    if [[ $# -ne 1 ]]; then
        echo "$0: pattern not specified"
        return 1
    fi

    local images

    images=$(docker images | grep -- "$1" | awk -F ' ' '{print $1 ":" $2}')

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
    ask-yes-no "Prune containers" "y" && docker container prune -f
    ask-yes-no "Prune images" "y" && docker image prune -f
    ask-yes-no "Prune volumes" "y" && docker volume prune -f
}
