function kubectl() {
    local args

    aws-refresh-sso

    if [[ -n "${KUBE_NAMESPACE}" ]]; then
        args="--namespace ${KUBE_NAMESPACE} $@"
    else
        echo "WARN: KUBE_NAMESPACE not set"
        args="$@"
    fi

    command kubectl "${=args}"
}

function k9s() {
    aws-refresh-sso

    command k9s
}
