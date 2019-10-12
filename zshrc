# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# Profiling {{{

# https://kev.inburke.com/kevin/profiling-zsh-startup-time/
PROFILE_STARTUP=false
if [[ "$PROFILE_STARTUP" == true ]]; then
    # http://zsh.sourceforge.net/Doc/Release/Prompt-Expansion.html
    PS4=$'%D{%M.%S%.} %N:%i> '
    exec 3>&2 2>/tmp/startlog.$$
    setopt xtrace prompt_subst
fi

# }}}

# Modules Initializing {{{

fpath=("$HOME/.zcompl" $fpath)

autoload -U compinit promptinit
autoload -Uz vcs_info

compinit
promptinit

[[ -e $HOME/.tmux.zsh ]] && source $HOME/.tmux.zsh

# }}}

# Options {{{

setopt prompt_subst      # Enable parameter expansion for prompts
setopt correct           # Enable autocorrect
setopt auto_pushd        # Make cd push the old directory onto the directory stack
setopt pushd_ignore_dups # Ignore duplicates when pushing directory on the stack

# }}}

# Helper functions {{{

installed() {
    type "$1" &> /dev/null
    return $?
}

contains() {
    string="$1"
    substring="$2"
    if test "${string#*$substring}" != "$string"
    then
        return 0    # $substring is in $string
    else
        return 1    # $substring is not in $string
    fi
}

# }}}

# Key Bindings {{{

# Use VI mode
bindkey -v

# Reduce ESC delay to 0.1s
export KEYTIMEOUT=1

# bind special keys according to readline configuration
[ -f /etc/inputrc ] && eval "$(sed -n 's/^/bindkey /; s/: / /p' /etc/inputrc)" > /dev/null

bindkey "^[[A" history-search-backward
bindkey "^[[B" history-search-forward
bindkey "^[OA" history-search-backward
bindkey "^[OB" history-search-forward
bindkey "^W" backward-kill-word
bindkey "^R" history-incremental-search-backward

# Make backspace and ^h work after returning from normal mode
bindkey '^?' backward-delete-char
bindkey '^h' backward-delete-char

# }}}

# ZStyle options {{{

# Add completion for cd ..
zstyle ':completion:*' special-dirs true
# Case insensitive completion
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'

# Version Control System
zstyle ':vcs_info:*' enable git svn
zstyle ':vcs_info:*' check-for-changes true

# }}}

# Source extra files {{{

[[ -f ~/.zsh_aliases ]] && . ~/.zsh_aliases
[[ -f ~/.zsh_functions ]] && . ~/.zsh_functions
[[ -f /usr/bin/virtualenvwrapper_lazy.sh ]] && . /usr/bin/virtualenvwrapper_lazy.sh
[[ -f /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]] && . /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
[[ -f /usr/share/doc/pkgfile/command-not-found.zsh ]] && . /usr/share/doc/pkgfile/command-not-found.zsh

# Source machine specific config
[[ -f ~/.zsh.local ]] && source ~/.zsh.local

# }}}

# Plugins {{{

for f in "${HOME}/.local/share/zsh/plugins"/*; do
    . "$f"
done

# }}}

# Misc configs and env vars {{{

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

if installed dircolors; then
    [ -r ~/.dircolors ] && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
fi

# Enable core dumps
ulimit -c unlimited

# Setup default apps
if installed nvim; then
    export EDITOR="nvim"
else
    export EDITOR="vim"
fi

# Default cflags
export CFLAGS="-O2 -march=native -fstack-protector-strong"

# Remove / from WORDCHARS, ie. make / a word delimiter
export WORDCHARS=${WORDCHARS/\//}

# Don't prepend virtual env name to PS1
export VIRTUAL_ENV_DISABLE_PROMPT=1

# }}}

# Setup a few PATHs {{{

# Personal usr folder
[[ -d "$HOME/usr/bin" ]] && export PATH="$HOME/usr/bin:$PATH"
[[ -d "$HOME/usr/lib" ]] && export LD_LIBRARY_PATH="$HOME/usr/lib:$LD_LIBRARY_PATH"
[[ -d "$HOME/usr/lib/pkgconfig" ]] && export PKG_CONFIG_PATH="$HOME/usr/lib/pkgconfig:$PKG_CONFIG_PATH"

# Go path
export GOPATH="$HOME/usr/go"

# Rust's cargo path
export CARGO_HOME="$HOME/usr/cargo"
[[ -d "$CARGO_HOME/bin" ]] && export PATH="$CARGO_HOME/bin:$PATH"

# Android
ANDROID_SDK_ROOT="$HOME/Android/Sdk"
if [ -d "$ANDROID_SDK_ROOT" ]; then
    export ANDROID_SDK_ROOT
    export PATH="$ANDROID_SDK_ROOT/tools:$ANDROID_SDK_ROOT/platform-tools:$PATH"
fi

# Python
[[ -f "$HOME/.pythonrc" ]] && export PYTHONSTARTUP="$HOME/.pythonrc"

# }}}

# Cleanup {{{

unset -f installed

if [[ "$PROFILE_STARTUP" == true ]]; then
    unsetopt xtrace
    exec 2>&3 3>&-
fi

# }}}

# vi: foldmethod=marker
