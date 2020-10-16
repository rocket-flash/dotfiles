AWS_PROFILE_CACHE_FILE="$HOME/.cache/zsh/aws-profile"

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

function aws-list-profiles() {
    grep -oE '\[profile [a-zA-Z0-9.-]+\]' "${AWS_CONFIG_FILE}" | sed 's/[][]//g' | awk -F ' ' '{print $2}' | sed 's/^/  /'
}

function aws-switch-profile {
    local profile="${1:-}"

    if [ -z "${profile}" ]; then
        echo 'Available profiles:'
        aws-list-profiles | sort

        read "profile?New profile: "
    fi

    if [ -n "${profile}" ]; then
        if ! aws-list-profiles | grep "${profile}" > /dev/null; then
            echo "Invalid profile: ${profile}"
            return
        fi

        echo -n "${profile}" > "${AWS_PROFILE_CACHE_FILE}"
        export AWS_PROFILE=${profile}
    else
        rm "${AWS_PROFILE_CACHE_FILE}"
        unset AWS_PROFILE
    fi
}

function aws-assume-role {
    if [ -z "$AWS_PROFILE" ]; then
        printf "\\e[31m[ERROR]\\e[0m   %s\\n" "AWS_PROFILE not set" >&2
        return
    fi

    account="$(aws-get-account-id)"
    arn="arn:aws:iam::${account}:role/CrossAccountAdminRole"

    credentials="$(aws sts assume-role --role-arn "$arn" --role-session-name "$AWS_PROFILE")"
    if [ $? -ne 0 ]; then
        printf "\\e[31m[ERROR]\\e[0m   %s\\n" "Failed to get credentials" >&2
        return
    fi

    export AWS_ACCESS_KEY_ID="$(echo "$credentials" | jq -r '.Credentials.AccessKeyId')"
    export AWS_SECRET_ACCESS_KEY="$(echo "$credentials" | jq -r '.Credentials.SecretAccessKey')"
    export AWS_SESSION_TOKEN="$(echo "$credentials" | jq -r '.Credentials.SessionToken')"
    set +x
}

function aws-ecr-login() {
    local accountid region passwd
    accountid="$(aws-get-account-id)"
    region="$(aws-get-current-region)"
    passwd="$(aws ecr get-login-password)"

    echo "$passwd" | docker login --username AWS --password-stdin "${accountid}.dkr.ecr.${region}.amazonaws.com"
}

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

[[ -d "$(dirname "${AWS_PROFILE_CACHE_FILE}")" ]] || mkdir -p "$(dirname "${AWS_PROFILE_CACHE_FILE}")"

if [ -e "${AWS_PROFILE_CACHE_FILE}" ]; then
    export AWS_PROFILE="$(\cat "${AWS_PROFILE_CACHE_FILE}")"
fi
