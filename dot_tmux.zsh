# Only run if tmux is actually installed
if ! which tmux &> /dev/null; then
    return
fi

# xfce4-terminal sets TERM to "xterm"
[[ "$COLORTERM" == "xfce4-terminal" ]] && export TERM=screen-256color

# Disable autostart from ssh connections or from virtual terminal
# Disable also for root as it's probably from sudo, which would result in nested tmux
if [[ -n "$SSH_CLIENT" || "$TERMINAL_EMULATOR" = *JetBrains* || "$TERM" = "linux" || $EUID -eq 0 ]]; then
    export ZSH_TMUX_AUTOSTART=false
fi

# Configuration variables
#
# Automatically start tmux
[[ -n "$ZSH_TMUX_AUTOSTART" ]] || ZSH_TMUX_AUTOSTART=true

# Only autostart once. If set to false, tmux will attempt to
# autostart every time your zsh configs are reloaded.
[[ -n "$ZSH_TMUX_AUTOSTART_ONCE" ]] || ZSH_TMUX_AUTOSTART_ONCE=true

# Automatically connect to a previous session if it exists
[[ -n "$ZSH_TMUX_AUTOCONNECT" ]] || ZSH_TMUX_AUTOCONNECT=false

# Automatically close the terminal when tmux exits
[[ -n "$ZSH_TMUX_AUTOQUIT" ]] || ZSH_TMUX_AUTOQUIT=$ZSH_TMUX_AUTOSTART

# Name of the tmux socket
[[ -n "$ZSH_TMUX_SOCKET_NAME" ]] || ZSH_TMUX_SOCKET_NAME="default"

# The TERM to use for non-256 color terminals.
# Tmux states this should be screen, but you may need to change it on
# systems without the proper terminfo
[[ -n "$ZSH_TMUX_FIXTERM_WITHOUT_256COLOR" ]] || ZSH_TMUX_FIXTERM_WITHOUT_256COLOR="tmux"

# The TERM to use for 256 color terminals.
# Tmux states this should be screen-256color, but you may need to change it on
# systems without the proper terminfo
[[ -n "$ZSH_TMUX_FIXTERM_WITH_256COLOR" ]] || ZSH_TMUX_FIXTERM_WITH_256COLOR="tmux-256color"

# Change TPM install path
export TMUX_PLUGIN_MANAGER_PATH="$HOME/.local/share/tmux/plugins/"

function _zsh_tmux_setup_term() {
    # Determine if the terminal supports 256 colors
    if [ $(tput colors) -eq 256 ]; then
        export ZSH_TMUX_TERM=$ZSH_TMUX_FIXTERM_WITH_256COLOR
        export ZSH_TRUE_COLOR=1
    else
        export ZSH_TMUX_TERM=$ZSH_TMUX_FIXTERM_WITHOUT_256COLOR
        export ZSH_TRUE_COLOR=0
    fi
}

function _zsh_tmux_is_autoquit() {
    if [[ "$ZSH_TMUX_AUTOQUIT" == "true" ]]; then
        return 0
    else
        return 1
    fi
}

function _zsh_tmux_cleanup() {
    unset ZSH_TMUX_AUTOSTARTED
    unset ZSH_TMUX_TERM
    unset ZSH_TRUE_COLOR
}

# Wrapper function for tmux.
function _zsh_tmux_plugin_run() {
    _zsh_tmux_setup_term

    # We have other arguments, just run them
    if [[ -n "$@" ]]; then
        \tmux -L "$ZSH_TMUX_SOCKET_NAME" $@
        ret=$?
        _zsh_tmux_cleanup
        return $ret
    # Try to connect to an existing session.
    elif [[ "$ZSH_TMUX_AUTOCONNECT" == "true" ]]; then
        \tmux -L "$ZSH_TMUX_SOCKET_NAME" attach || \tmux -L "$ZSH_TMUX_SOCKET_NAME" new-session
        ret=$?
        _zsh_tmux_cleanup
        _zsh_tmux_is_autoquit && exit
        return $ret
    # Just run tmux, fixing the TERM variable if requested.
    else
        \tmux -L "$ZSH_TMUX_SOCKET_NAME"
        ret=$?
        _zsh_tmux_cleanup
        _zsh_tmux_is_autoquit && exit
        return $ret
    fi
}

# Use the completions for tmux for our function
compdef _tmux _zsh_tmux_plugin_run

# Alias tmux to our wrapper function.
alias tmux=_zsh_tmux_plugin_run

# Alias to for one-time disable of autoquit
alias tq="(ZSH_TMUX_AUTOSTART=false ${TERMINAL} &>/dev/null &)"

# Autostart if not already in tmux and enabled.
if [[ ! -n "$TMUX" && "$ZSH_TMUX_AUTOSTART" == "true" ]]; then
    # Actually don't autostart if we already did and multiple autostarts are disabled.
    if [[ "$ZSH_TMUX_AUTOSTART_ONCE" == "false" || "$ZSH_TMUX_AUTOSTARTED" != "true" ]]; then
        export ZSH_TMUX_AUTOSTARTED=true
        _zsh_tmux_plugin_run
    fi
fi

# vim: et
