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

remove_old_zsh_compdump() {
    local file
    file="${XDG_CONFIG_HOME}/zsh/.zcompdump"

    if [[ -e "${file}" ]]; then
        info "Removing ${file}"
        rm "${file}"
    fi
}

update_zsh_history_location
remove_old_zsh_compdump

# vi: ft=sh
