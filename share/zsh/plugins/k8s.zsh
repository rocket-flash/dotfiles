if command -v kubectl &>/dev/null; then
    function kctl() {
        local args

        aws-sso-login

        kubectl "$@"
    }

    compdef kctl='kubectl'
fi

if command -v k9s &>/dev/null; then
    function k9s() {
        aws-sso-login

        command k9s
    }
fi
