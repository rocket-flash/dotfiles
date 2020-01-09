[[ -d "${HOME}/.local/share/zsh/themes" ]] || return

# Color shortcuts {{{

let idx=0
let idx_bright=8
for color in black red green yellow blue magenta cyan white; do
    eval $color='${idx}'
    eval bright_$color='${idx_bright}'
    let idx=idx+1
    let idx_bright=idx_bright+1
done
unset idx idx_bright
color_reset="%f%k"

# }}}

function zsh-theme() {
    if [[ -z "${1}" ]]; then
        echo "Theme not specified"
        return
    fi

    local theme
    theme="${HOME}/.local/share/zsh/themes/${1}.zsh"

    if [[ ! -f "${theme}" ]]; then
        echo "Theme not found: ${1}"
        return
    fi

    . "${theme}"
}

load_vcs_info() {
    vcs_info

    if contains "${vcs_info_msg_0_}" "|"; then
        vcs_action_msg="$(cut -d '|' -f1 <<< ${vcs_info_msg_0_})"
        # Hack to remove leading space when there are no changes
        vcs_branch_msg="$(cut -d '|' -f2 <<< ${vcs_info_msg_0_} | awk '{$1=$1};1')"
    else
        vcs_action_msg=""
        # Hack to remove leading space when there are no changes
        vcs_branch_msg="$(awk '{$1=$1};1' <<< ${vcs_info_msg_0_})"
    fi
}

function zle-keymap-select {
    zle reset-prompt
}

zle -N zle-keymap-select

ZSH_THEME="powerline"

if [[ "$TERM" == "linux" ]]; then
    ZSH_THEME="simple"
elif [[ "$PYCHARM_TERM" == "1" ]]; then
    ZSH_THEME="basic"
fi

zsh-theme "${ZSH_THEME}"

# vi: foldmethod=marker

