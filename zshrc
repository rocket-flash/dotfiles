# If not running interactively, don't do anything
[[ $- != *i* ]] && return

autoload -U compinit promptinit colors
autoload -Uz vcs_info

compinit
promptinit
colors

[[ ! -z "$SSH_CLIENT" ]] && export ZSH_TMUX_AUTOSTART=false
[[ -e $HOME/.tmux.zsh ]] && source $HOME/.tmux.zsh

# bind special keys according to readline configuration
[[ -f /etc/inputrc ]] && eval "$(sed -n 's/^/bindkey /; s/: / /p' /etc/inputrc)" > /dev/null

bindkey "^[[A" history-search-backward
bindkey "^[[B" history-search-forward
bindkey "^[OA" history-search-backward
bindkey "^[OB" history-search-forward

setopt APPEND_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt prompt_subst
setopt correct

HISTFILE=~/.zsh_history
HISTSIZE=5000
SAVEHIST=5000

# Add completion for cd ..
zstyle ':completion:*' special-dirs true

# Version Control System
zstyle ':vcs_info:*' actionformats \
    '%F{5}(%f%s%F{5})%F{3}-%F{5}[%F{2}%b%F{3}|%F{1}%a%F{5}]%f '
zstyle ':vcs_info:*' formats       \
    '%F{5}(%f%s%F{5})%F{3}-%F{5}[%F{2}%b%F{5}]%f '
zstyle ':vcs_info:(sv[nk]|bzr):*' branchformat '%b%F{1}:%F{3}%r'

zstyle ':vcs_info:*' enable git svn

# or use pre_cmd, see man zshcontrib
vcs_info_wrapper() {
    vcs_info
    if [ -n "$vcs_info_msg_0_" ]; then
        echo "%{$fg[grey]%}${vcs_info_msg_0_}%{$reset_color%}$del"
    fi
}

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# Color shortcuts
for COLOR in BLACK RED GREEN YELLOW BLUE MAGENTA CYAN WHITE; do
    eval FG_$COLOR='%{$fg_no_bold[${(L)COLOR}]%}'
    eval FG_BRIGHT_$COLOR='%{$fg_bold[${(L)COLOR}]%}'
    eval BG_$COLOR='%{$bg[${(L)COLOR}]%}'
done
COLOR_RESET="%{$reset_color%}"

PS1="%(!.${FG_BRIGHT_RED}.${FG_BRIGHT_GREEN})%n@%m"
[[ ! -z "$SSH_CLIENT" ]] && PS1="${PS1}${FG_BRIGHT_RED}[ssh]"
PS1="${PS1}${COLOR_RESET}:${FG_BRIGHT_BLUE}%1~${COLOR_RESET}%(!.#.$) "
PS2='> '
RPROMPT=$'$(vcs_info_wrapper)'"%(1j.[%jbg].)[%D{%T}]%(?.${FG_BRIGHT_GREEN}.${FG_BRIGHT_RED})[%?]${COLOR_RESET}"

if [ -x /usr/bin/dircolors ]; then
    [ -r ~/.dircolors ] && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
fi

# SSH Agent detection
if [ -z "$SSH_AUTH_SOCK" -a -f ~/.ssh-find-agent.sh ]; then
    source ~/.ssh-find-agent.sh

    # Script doesn't work well with zsh.. lazy fix
    emulate sh
    ssh-find-agent -a
    emulate zsh

    if [ -z "$SSH_AUTH_SOCK" ]; then
        eval $(ssh-agent) > /dev/null
    fi
fi

if [ -n "$SSH_AUTH_SOCK" ]; then
    ssh-add -l > /dev/null || ssh-add
fi

[[ -f ~/.zsh_aliases ]] && . ~/.zsh_aliases
[[ -f ~/.zsh_functions ]] && . ~/.zsh_functions
[[ -f /usr/bin/virtualenvwrapper.sh ]] && . /usr/bin/virtualenvwrapper.sh
[[ -f /usr/share/doc/pkgfile/command-not-found.zsh ]] && . /usr/share/doc/pkgfile/command-not-found.zsh

if which nvim > /dev/null; then
    export EDITOR="nvim"
else
    export EDITOR="vim"
fi
export PAGER="less"
export MEDIA="/run/media/$USER"

# Enable core dumps
ulimit -c unlimited

# Default cflags
export CFLAGS="-O2 -march=native -fstack-protector-strong"

# Personal usr folder
if [ -d $HOME/usr ]; then
    export PATH="$HOME/usr/bin:$PATH"
    export LD_LIBRARY_PATH="$HOME/usr/lib:$LD_LIBRARY_PATH"
fi

if [ -f "$HOME/.pythonrc" ]; then
    export PYTHONSTARTUP="$HOME/.pythonrc"
fi

# Put pacaur git clones back in /tmp
export AURDEST="/tmp/pacaur-mathieu"
