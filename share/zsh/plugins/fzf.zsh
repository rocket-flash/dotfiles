[[ -d /usr/share/fzf ]] || return

. /usr/share/fzf/key-bindings.zsh
. /usr/share/fzf/completion.zsh

# Show prompt on top
export FZF_DEFAULT_OPTS='--reverse -1'
# --files: List files that would be searched but do not search
# --follow: Follow symlinks
export FZF_DEFAULT_COMMAND='rg --files --follow 2>/dev/null'
export FZF_COMPLETION_TRIGGER=';;'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_CTRL_T_OPTS="--tiebreak=end"

# Use ripgrep instead of the default find command for listing path candidates.
# - The first argument to the function ($1) is the base path to start traversal
# - See the source code (completion.{bash,zsh}) for the details.
function _fzf_compgen_path() {
    rg --files --follow --glob '!Library/*' 2>/dev/null "$1" | sed 's@^\./@@'
}
