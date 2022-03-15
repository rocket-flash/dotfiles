function ask-yes-no() {
    if [[ $# -lt 1 ]]; then
        echo "Usage: $0 prompt [default]" >&2
        return 1
    fi

    local prompt defans
    prompt="$1"
    defans="${2:-n}"
    defans="${defans:l}"

    if [[ "${defans}" == "y" ]]; then
        prompt="${prompt} [Y/n]? "
    else
        prompt="${prompt} [y/N]? "
    fi

    echo -n "${prompt}"
    read -s -k response
    echo ""

    response="$(echo "${response:l}")"

    if [[ "${response:-${defans}}" == "y" ]]; then
        return 0
    fi

    return 1
}

if command -v dotenv &> /dev/null; then
    function dotenv() {
        case "$1" in
            load)
                . <(dotenv list | sed -E 's/^([^=]+)=(.*)/export \1="\2"/')
                ;;
            *)
                command dotenv "$@"
                ;;
        esac
    }
fi
