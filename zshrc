# If not running interactively, don't do anything
[[ $- != *i* ]] && return

autoload -U compinit promptinit colors
autoload -Uz vcs_info

compinit
promptinit
colors

# bind special keys according to readline configuration
eval "$(sed -n 's/^/bindkey /; s/: / /p' /etc/inputrc)"

bindkey "^[[A" history-search-backward
bindkey "^[[B" history-search-forward

# set zsh in emacs mode
bindkey -e

setopt APPEND_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt prompt_subst

HISTFILE=~/.zsh_history
HISTSIZE=5000
SAVEHIST=5000

# Version Control System
zstyle ':vcs_info:*' actionformats \
    '%F{5}(%f%s%F{5})%F{3}-%F{5}[%F{2}%b%F{3}|%F{1}%a%F{5}]%f '
zstyle ':vcs_info:*' formats       \
    '%F{5}(%f%s%F{5})%F{3}-%F{5}[%F{2}%b%F{5}]%f '
zstyle ':vcs_info:(sv[nk]|bzr):*' branchformat '%b%F{1}:%F{3}%r'

zstyle ':vcs_info:*' enable git cvs svn

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
    eval FG_$COLOR='%{$fg[${(L)COLOR}]%}'
    eval FG_BRIGHT_$COLOR='%{$fg_bold[${(L)COLOR}]%}'
    eval BG_$COLOR='%{$bg[${(L)COLOR}]%}'
done
COLOR_RESET="%{$reset_color%}"

PS1="%(!.${FG_BRIGHT_RED}.${FG_BRIGHT_GREEN})%n@%m${COLOR_RESET}:${FG_BRIGHT_BLUE}%(!.%1~.%~)${COLOR_RESET}%(!.#.$) "
PS2='> '
RPROMPT=$'$(vcs_info_wrapper)'"%(?.${FG_BRIGHT_GREEN}.${FG_BRIGHT_RED})[%?]${COLOR_RESET}"

[[ -f ~/.zsh_aliases ]] && source ~/.zsh_aliases

export EDITOR="/usr/bin/vim"
export PAGER="/usr/bin/most"
export MEDIA="/run/media/$USER"

# Enable core dumps
ulimit -c unlimited

# Personal bin folder
if [ -d $HOME/.bin ]; then
	export PATH=$HOME/.bin:$PATH
fi

# Android SDK tools
if [ -d $HOME/android/sdk ]; then
	export PATH=$PATH:$HOME/android/sdk/tools
	export PATH=$PATH:$HOME/android/sdk/platform-tools
fi

#PSPToolChain
if [ -d /opt/sdk/psp ]; then
    export PSPDEV=/opt/sdk/psp
    export PSPSDK=$PSPDEV/psp/sdk
    export PATH=$PATH:$PSPDEV/bin:$PSPSDK/bin
fi

#PS3ToolChain
if [ -d /opt/sdk/ps3 ]; then
    export PS3DEV=/opt/sdk/ps3
    export PATH=$PATH:$PS3DEV/bin
    export PATH=$PATH:$PS3DEV/ppu/bin
    export PATH=$PATH:$PS3DEV/spu/bin
fi

#PSL1GTH
if [ -d /opt/sdk/ps3/psl1ght ]; then
    export PSL1GHT=/opt/sdk/ps3/psl1ght
fi

#DevKitPRO
if [ -d /opt/sdk/devkitpro ]; then
    export DEVKITPRO=/opt/sdk/devkitpro
    export DEVKITARM=${DEVKITPRO}/devkitARM
    export DEVKITPPC=${DEVKITPRO}/devkitPPC
    export PATH="$PATH:$DEVKITARM/bin:$DEVKITPPC/bin"
fi
