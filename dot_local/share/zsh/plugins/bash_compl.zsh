autoload bashcompinit
bashcompinit

files=()

for f in "${files[@]}"; do
    [[ -f "$f" ]] && source "$f"
done
