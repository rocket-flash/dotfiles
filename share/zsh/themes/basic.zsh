printc() {
    if [ $# -gt 1 ]; then
        c="%F{${1}}"
        shift
    else
        c="%f"
    fi

    echo -n "${c}$1"
}

prompt_vi_mode() {
    case "${KEYMAP:-main}" in
        main|viins)
            printc ${green} "[I] "
            ;;
        vicmd)
            printc ${red} "[N] "
            ;;
        *)
            printc ${yellow} "[?] "
            ;;
    esac
}

prompt_venv() {
    # Strip out the path and just leave the env name
    [[ -n "$VIRTUAL_ENV" ]] && printc ${cyan} "[${VIRTUAL_ENV##*/}] "
}

prompt_status() {
    local -a _status
    [[ $RETVAL -ne 0 ]] && _status+="(!) "

    [[ -n "${_status}" ]] && printc ${red} "${_status}"
}

prompt_host() {
    if [[ -n "$SSH_CLIENT" ]]; then
        fg="${yellow}"
    else
        fg="%(!.${red}.${green})"
    fi

    printc ${fg} "%n@%m"
}

prompt_dir() {
    printc ":"
    printc ${blue} "%1~"
}

prompt_end() {
    printc "$ "
}

build_ps1() {
    RETVAL=$?

    prompt_vi_mode
    prompt_venv
    prompt_status
    prompt_host
    prompt_dir
    prompt_end
}

PS1='$(build_ps1)'
PS2='> '
RPROMPT=''
