AWS_PROFILE_CACHE_FILE="$HOME/.cache/zsh/aws-profile"

function aws-switch-profile {
    echo 'Available profiles:'
    grep -oE '\[profile [a-zA-Z.]+\]' ~/.aws/config | sed 's/[][]//g' | awk -F ' ' '{print $2}' | sed 's/^/  /' | sort

    read "profile?New profile: "

    if [ -n "${profile}" ]; then
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

    account="$(aws sts get-caller-identity | jq -r '.Account')"
    arn="arn:aws:iam::${account}:role/CrossAccountAdminRole"

    credentials="$(aws sts assume-role --role-arn "$arn" --role-session-name "$AWS_PROFILE")"
    if [ $? -ne 0 ]; then
        printf "\\e[31m[ERROR]\\e[0m   %s\\n" "Failed to get credentials" >&2
        return
    fi

    export AWS_ACCESS_KEY_ID="$(echo "$credentials" | jq -r '.Credentials.AccessKeyId')"
    export AWS_SECRET_ACCESS_KEY="$(echo "$credentials" | jq -r '.Credentials.SecretAccessKey')"
    export AWS_SESSION_TOKEN="$(echo "$credentials" | jq -r '.Credentials.SessionToken')"
    unset AWS_PROFILE
    set +x
}

[[ -d "$(dirname "${AWS_PROFILE_CACHE_FILE}")" ]] || mkdir -p "$(dirname "${AWS_PROFILE_CACHE_FILE}")"

if [ -e "${AWS_PROFILE_CACHE_FILE}" ]; then
    export AWS_PROFILE="$(cat "${AWS_PROFILE_CACHE_FILE}")"
fi