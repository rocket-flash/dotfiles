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

remove() {
    local path
    path="${1:?}"

    [[ -e "${path}" ]] || return 0
    info "Removing ${path}"
    rm -rf "${path}"
}

update_zsh_history_location
remove "${XDG_CONFIG_HOME}/zsh/.zcompdump"
remove "${HOME}/.tmux.zsh"
remove "${HOME}/.inputrc"
remove "${HOME}/.java"
remove "${HOME}/.ideavimrc"

# vi: ft=sh
