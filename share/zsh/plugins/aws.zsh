AWS_PROFILE_CACHE_FILE="$HOME/.cache/zsh/aws-profile"

[[ -d "$(dirname "${AWS_PROFILE_CACHE_FILE}")" ]] || mkdir -p "$(dirname "${AWS_PROFILE_CACHE_FILE}")"

if [ -e "${AWS_PROFILE_CACHE_FILE}" ]; then
    export AWS_PROFILE="$(< "${AWS_PROFILE_CACHE_FILE}")"
fi

# Profiles {{{

function aws-current-profile {
    if [[ -n "${AWS_PROFILE}" ]]; then
        echo "Current Profile: ${AWS_PROFILE}"
    else
        echo "Profile not set"
    fi
}

function aws-list-profiles() {
    grep -oE '\[profile .*?\]' "${AWS_CONFIG_FILE}" | sed -E 's/\[profile (.*?)\]/\1/g'
}

function aws-switch-profile {
    local profile=$(aws-list-profiles | fzf -q "$*")

    [[ -n "${profile}" ]] || return

    echo "Switching to profile: ${profile}"
    echo -n "${profile}" > "${AWS_PROFILE_CACHE_FILE}"
    export AWS_PROFILE="${profile}"
}

function aws-unset-profile {
    [[ -e "${AWS_PROFILE_CACHE_FILE}" ]] && rm "${AWS_PROFILE_CACHE_FILE}"
    unset AWS_PROFILE
}

# }}}

# Account Info {{{

function aws-get-account-id() {
    aws sts get-caller-identity | jq -r '.Account'
}

function aws-get-current-region() {
    if [ -n "${AWS_PROFILE}" ]; then
        aws configure get --profile "${AWS_PROFILE}" region
    else
        aws configure get region
    fi
}

# }}}

# Credentials {{{

function aws-mfa {
    local mfa_code="$(ykman oath code -s broadsign-aws)"
    echo -n "$mfa_code" | xsel -b
    echo "$mfa_code"
}

function aws-assume-role {
    if [ -z "$AWS_PROFILE" ]; then
        printf "\\e[31m[ERROR]\\e[0m   %s\\n" "AWS_PROFILE not set" >&2
        return
    fi

    role_arn="$(aws configure get role_arn)"
    if [ $? -ne 0 ]; then
        printf "\\e[31m[ERROR]\\e[0m   %s\\n" "Unable to get role arn" >&2
        return
    fi

    credentials="$(aws sts assume-role --role-arn "${role_arn}" --role-session-name "admin@${AWS_PROFILE}")"
    if [ $? -ne 0 ]; then
        printf "\\e[31m[ERROR]\\e[0m   %s\\n" "Failed to get credentials" >&2
        return
    fi

    export AWS_ACCESS_KEY_ID="$(echo "$credentials" | jq -r '.Credentials.AccessKeyId')"
    export AWS_SECRET_ACCESS_KEY="$(echo "$credentials" | jq -r '.Credentials.SecretAccessKey')"
    export AWS_SESSION_TOKEN="$(echo "$credentials" | jq -r '.Credentials.SessionToken')"
    expiry="$(echo "$credentials" | jq -r '.Credentials.Expiration')"
    echo "Session expires on ${expiry}"
}

function aws-clear-session {
    unset AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_SESSION_TOKEN
}

function aws-ecr-login() {
    local accountid region passwd
    accountid="$(aws-get-account-id)"
    region="$(aws-get-current-region)"
    passwd="$(aws ecr get-login-password)"

    echo "$passwd" | docker login --username AWS --password-stdin "${accountid}.dkr.ecr.${region}.amazonaws.com"
}

function aws-eks-get-token() {
    if [[ $# -ne 1 ]]; then
        echo "Usage: $0 <cluster-name>" >&2
        return 1
    fi

    aws eks get-token --cluster-name preprod | jq -r '.status.token'
}

function aws-refresh-sso() {
    local last_check_file="${XDG_CACHE_HOME:-${HOME}/.cache}/aws/last_sso_check"

    if [ -e "${last_check_file}" ] && [ -z "$(find "${last_check_file}" -mmin +720 2>/dev/null)" ]; then
        return
    fi

    if aws sso login; then
        mkdir -p "$(dirname "${last_check_file}")"
        touch "${last_check_file}"
    fi
}

# }}}

# Cloud Formation {{{

function aws-cf-get-stack-status() {
    local stack="$1"
    if [[ -z "${stack}" ]]; then
        echo "Stack not specified"
        return 1
    fi

    aws cloudformation describe-stacks --stack-name "${stack}" | jq -r '.Stacks[] | select(.StackId == "'"${stack}"'") | .StackStatus'
}

function aws-cf-delete-stack() {
    local stack="$1" st
    if [[ -z "${stack}" ]]; then
        echo "Stack not specified"
        return 1
    fi

    st="$(aws-cf-get-stack-status "${stack}")"

    if [[ -z "${st}" ]] || [[ "${st}" == "DELETE_IN_PROGRESS" ]] || [[ "${st}" == "DELETE_COMPLETE" ]]; then
        return
    fi

    aws cloudformation delete-stack --stack-name "${stack}"

    while true; do
        st="$(aws-cf-get-stack-status "${stack}")"
        echo "${stack}: ${st}"

        case "${st}" in
            DELETE_COMPLETE|DELETE_FAILED)
                break
                ;;
            CREATE_COMPLETE|DELETE_IN_PROGRESS)
                sleep 2
                ;;
            *)
                echo "Unknown status"
                ;;
        esac
    done
}

function aws-cf-delete-stacks() {
    local pattern="$1" stacks
    if [[ -z "${pattern}" ]]; then
        echo "Pattern not specified"
        return 1
    fi

    stacks=($(aws cloudformation list-stacks | jq -r '.StackSummaries[] | select(.StackName | contains("'"${pattern}"'")) | select(.StackStatus != "DELETE_COMPLETE") | .StackId'))

    if [[ -z "${stacks}" ]]; then
        echo "No stacks to delete"
        return 0
    fi

    echo "Stacks:"
    echo ${stacks} | xargs -n1 echo "  "

    echo -n "Delete stacks? [y/N] "
    read -s -k response
    echo ""

    response="$(echo "$response" | tr '[:upper:]' '[:lower:]')"

    if [[ "${response}" != "y" ]]; then
        return 2
    fi

    for s in ${stacks}; do
        aws-cf-delete-stack "${s}"
    done
}

# }}}

# Misc {{{

function aws-get-ipgranges {
    curl "https://ip-ranges.amazonaws.com/ip-ranges.json" | jq '.prefixes'
}

# }}}

# vim: foldmethod=marker
