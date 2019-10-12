HISTFILE=~/.zsh_history
HISTSIZE=25000
SAVEHIST=25000

setopt INC_APPEND_HISTORY   # Write to the history file immediately, not when the shell exits.
#setopt SHARE_HISTORY       # Share history between all sessions.
setopt HIST_IGNORE_DUPS     # Don't record an entry that was just recorded again.
setopt HIST_IGNORE_ALL_DUPS # Delete old recorded entry if new entry is a duplicate.
setopt HIST_IGNORE_SPACE    # Don't record an entry starting with a space.
setopt HIST_SAVE_NO_DUPS    # Don't write duplicate entries in the history file.
setopt HIST_REDUCE_BLANKS   # Remove superfluous blanks before recording entry.
