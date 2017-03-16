# Only run if tmux is actually installed
if ! which tmux &> /dev/null; then
    return
fi

# xfce4-terminal sets TERM to "xterm"
[[ "$COLORTERM" == "xfce4-terminal" ]] && export TERM=screen-256color

# Disable autostart from ssh connections or from virtual terminal
# Disable also for root as it's probably from sudo, which would result in nested tmux
[[ -n "$SSH_CLIENT" || "$TERM" = "linux" || $EUID -eq 0 ]] && export ZSH_TMUX_AUTOSTART=false

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

# Temporary file to disable autoquit
ZSH_TMUX_NO_AUTOQUIT_FILE="/tmp/zsh_tmux_no_autoquit.${USER}"

# Determine if the terminal supports 256 colors
if [ $(tput colors) -eq 256 ]; then
    export ZSH_TMUX_TERM=$ZSH_TMUX_FIXTERM_WITH_256COLOR
else
    export ZSH_TMUX_TERM=$ZSH_TMUX_FIXTERM_WITHOUT_256COLOR
fi

function _zsh_tmux_is_autoquit() {
    if [[ "$ZSH_TMUX_AUTOQUIT" == "true" ]]; then
        if [ -e "$ZSH_TMUX_NO_AUTOQUIT_FILE" ]; then
            rm "$ZSH_TMUX_NO_AUTOQUIT_FILE"
            return 1
        else
            return 0
        fi
    else
        return 1
    fi
}
alias tq="[[ -n \"$TMUX\" ]] && touch $ZSH_TMUX_NO_AUTOQUIT_FILE && exit"

# Wrapper function for tmux.
function _zsh_tmux_plugin_run() {
    # For some reason, launching tmux when TERM is xterm-termite, true color won't work properly
    prev_term=$TERM
    if [ $(tput colors) -eq 256 ]; then
        export TERM=xterm-256color
        export ZSH_TRUE_COLOR=1
    fi

    # We have other arguments, just run them
    if [[ -n "$@" ]]; then
        \tmux -L "$ZSH_TMUX_SOCKET_NAME" $@
        export TERM=$prev_term
    # Try to connect to an existing session.
    elif [[ "$ZSH_TMUX_AUTOCONNECT" == "true" ]]; then
        \tmux -L "$ZSH_TMUX_SOCKET_NAME" attach || \tmux -L "$ZSH_TMUX_SOCKET_NAME" new-session
        export TERM=$prev_term
        _zsh_tmux_is_autoquit && exit
    # Just run tmux, fixing the TERM variable if requested.
    else
        \tmux -L "$ZSH_TMUX_SOCKET_NAME"
        export TERM=$prev_term
        _zsh_tmux_is_autoquit && exit
    fi
}

# Use the completions for tmux for our function
compdef _tmux _zsh_tmux_plugin_run

# Alias tmux to our wrapper function.
alias tmux=_zsh_tmux_plugin_run

# Autostart if not already in tmux and enabled.
if [[ ! -n "$TMUX" && "$ZSH_TMUX_AUTOSTART" == "true" ]]; then
    # Actually don't autostart if we already did and multiple autostarts are disabled.
    if [[ "$ZSH_TMUX_AUTOSTART_ONCE" == "false" || "$ZSH_TMUX_AUTOSTARTED" != "true" ]]; then
        export ZSH_TMUX_AUTOSTARTED=true
        _zsh_tmux_plugin_run
    fi
fi
