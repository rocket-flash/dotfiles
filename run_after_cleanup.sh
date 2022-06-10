#! /bin/bash

set -euo pipefail

. ~/.local/lib/log.sh

update_zsh_history_location() {
    local src dst temp
    src="${XDG_CONFIG_HOME}/zsh/history"
    dst="${XDG_STATE_HOME}/zsh/history"

    [[ -e "${src}" ]] || return 0

    temp="$(mktemp)"

    info "Moving ${src} -> ${dst}"

    mv "${src}" "${temp}"

    [[ -e "${dst}" ]] && cat "${dst}" >> "${temp}"

    mv "${temp}" "${dst}"
    chmod 600 "${dst}"
}

remove_file() {
    local file
    file="${1:?}"

    [[ -e "${file}" ]] || return 0
    info "Removing ${file}"
    rm "${file}"
}

update_zsh_history_location
remove_file "${XDG_CONFIG_HOME}/zsh/.zcompdump"
remove_file "${HOME}/.tmux.zsh"

# vi: ft=sh
