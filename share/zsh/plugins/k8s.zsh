function kctl() {
    local args

    aws-sso-login

    kubectl "$@"
}

compdef kctl='kubectl'

function k9s() {
    aws-sso-login

    command k9s
}
