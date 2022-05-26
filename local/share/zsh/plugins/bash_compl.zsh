autoload bashcompinit
bashcompinit

files=(
    "/usr/share/bash-completion/completions/vagrant"
)

for f in "${files[@]}"; do
    [[ -f "$f" ]] && source "$f"
done
