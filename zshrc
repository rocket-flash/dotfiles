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

fpath=("$HOME/.local/share/zsh/completions" $fpath)

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

# History {{{

HISTFILE=~/.zsh_history
HISTSIZE=5000
SAVEHIST=5000

setopt INC_APPEND_HISTORY   # Write to the history file immediately, not when the shell exits.
#setopt SHARE_HISTORY       # Share history between all sessions.
setopt HIST_IGNORE_DUPS     # Don't record an entry that was just recorded again.
setopt HIST_IGNORE_ALL_DUPS # Delete old recorded entry if new entry is a duplicate.
setopt HIST_IGNORE_SPACE    # Don't record an entry starting with a space.
setopt HIST_SAVE_NO_DUPS    # Don't write duplicate entries in the history file.
setopt HIST_REDUCE_BLANKS   # Remove superfluous blanks before recording entry.

# }}}

# Helper functions {{{

installed() {
    type "$1" &> /dev/null
    return $?
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

# }}}

# Prompt {{{

# Color shortcuts
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

# Version Control System
zstyle ':vcs_info:*' actionformats '%F{5}[%F{2}%b%F{3}|%F{1}%a%F{5}]%f'
zstyle ':vcs_info:*' formats '%F{5}[%F{2}%b%F{5}]%f'
branch_fmt="%F{${bright_green}}%F{${black}}%K{${bright_green}} %b  %f"
action_fmt="%F{${red}}%F{${black}}%K{${red}} %a "

zstyle ':vcs_info:*' formats "${branch_fmt}"
zstyle ':vcs_info:*' actionformats "${action_fmt}${branch_fmt}"
zstyle ':vcs_info:(sv[nk]|bzr):*' branchformat '%b%F{1}:%F{3}%r'

unset branch_fmt action_fmt

vcs_info_wrapper() {
    vcs_info
    if [ -n "$vcs_info_msg_0_" ]; then
        echo "${vcs_info_msg_0_}"
    fi
}

nvm_info() {
    if [ -n "$NVM_BIN" ]; then
        echo "[node $(basename $(dirname $NVM_BIN))] "
    fi
}

vi_mode_info() {
    case "${KEYMAP:-main}" in
        main|viins)
            echo "%F{${black}}%K{${bright_green}} I %K{${black}}%F{${bright_green}}"
            ;;
        vicmd)
            echo "%F{${black}}%K{${bright_red}} N %K{${black}}%F{${bright_red}}"
            ;;
        *)
            echo "N/A"
            ;;
    esac
}

build_ps1() {
    if [[ -n "$SSH_CLIENT" ]]; then
        c_host="${bright_magenta}"
    else
        c_host="${bright_green}"
    fi

    #p_exit_code="%(?.%F{${bright_green}}✔.%F{${bright_red}}✘) "
    p_exit_code="%(?..%F{${red}}✘ )"
    p_root_warning="%(!.%F{${bright_yellow}}⚡ .)"

    p_host="%K{${black}}%F{${c_host}}%n@%m "
    p_sep1="%K{${bright_green}}%F{${black}} "
    p_directory="%1~ "
    p_sep2="%k%F{${bright_green}} "

    echo "%K{${black}}"'$(vi_mode_info)'" ${p_exit_code}${p_host}${p_root_warning}${p_sep1}${p_directory}${p_sep2}${color_reset}"
}

PS1="$(build_ps1)"
PS2='> '
RPROMPT='$(nvm_info)$(vcs_info_wrapper)'

function zle-keymap-select {
    zle reset-prompt
}

zle -N zle-keymap-select

# }}}

# SSH Agent {{{

export SSH_AUTH_SOCK="/tmp/ssh-agent.${EUID}.socket"
[[ -S "${SSH_AUTH_SOCK}" ]] || ssh-agent -s -a "${SSH_AUTH_SOCK}" > /dev/null
ssh-add -l > /dev/null || ssh-add

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

# FZF Config {{{

if [[ -d /usr/share/fzf ]]; then
    . /usr/share/fzf/key-bindings.zsh
    . /usr/share/fzf/completion.zsh

    # Show prompt on top
    export FZF_DEFAULT_OPTS='--reverse'
    # --files: List files that would be searched but do not search
    # --follow: Follow symlinks
    export FZF_DEFAULT_COMMAND='rg --files --follow 2>/dev/null'
    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
    export FZF_CTRL_T_OPTS="--tiebreak=end"

    # Use ripgrep instead of the default find command for listing path candidates.
    # - The first argument to the function ($1) is the base path to start traversal
    # - See the source code (completion.{bash,zsh}) for the details.
    function _fzf_compgen_path() {
        rg --files --follow --glob '!Library/*' 2>/dev/null "$1" | sed 's@^\./@@'
    }
fi

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
