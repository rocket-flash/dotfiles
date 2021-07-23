function kubectl() {
    local args

    aws-sso-login

    if [[ -n "${KUBE_NAMESPACE}" ]]; then
        args="--namespace ${KUBE_NAMESPACE} $@"
    else
        echo "WARN: KUBE_NAMESPACE not set" >&2
        args="$@"
    fi

    command kubectl "${=args}"
}

function k9s() {
    aws-sso-login

    command k9s
}
