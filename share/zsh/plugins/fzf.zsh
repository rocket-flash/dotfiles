[[ -d /usr/share/fzf ]] || return

. /usr/share/fzf/key-bindings.zsh
[[ $- == *i* ]] && . "/usr/share/fzf/completion.zsh" 2> /dev/null

preview_window_opts="--preview-window hidden --bind '?:toggle-preview'"

# Show prompt on top
export FZF_DEFAULT_OPTS="--reverse -1"
# --files: List files that would be searched but do not search
# --follow: Follow symlinks
export FZF_DEFAULT_COMMAND="rg --files --follow 2>/dev/null"
export FZF_COMPLETION_TRIGGER=";;"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_CTRL_T_OPTS="--tiebreak=end --preview '(bat --color=always {} || cat {}) 2>/dev/null | head -200' ${=preview_window_opts}"
export FZF_ALT_C_COMMAND="fd --type=d"
export FZF_ALT_C_OPTS="--tiebreak=end --preview 'tree -C {} | head -200' ${=preview_window_opts}"
export FZF_TMUX_OPTS="-p 75%,75%"

unset preview_window_opts

# Use ripgrep instead of the default find command for listing path candidates.
# - The first argument to the function ($1) is the base path to start traversal
# - See the source code (completion.{bash,zsh}) for the details.
function _fzf_compgen_path() {
    rg --files --follow --glob '!Library/*' 2>/dev/null "$1" | sed 's@^\./@@'
}
