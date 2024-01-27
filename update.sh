#!/bin/bash

. /etc/os-release

ORG_NAME=alt-autorepacked
BASE_REMOTE_URL=https://github.com/$ORG_NAME

_get_suffix() {
    if [ -n "$ALT_BRANCH_ID" ]; then
        suffix=".$ALT_BRANCH_ID"
    else
        suffix=".$(epm print info -r)"
    fi
    echo ".$(epm print info -a)$suffix.rpm"
}

####

packages=(
    "vk-messenger"
)

if [ -n "$ALT_BRANCH_ID" ]; then
    reponame="$ALT_BRANCH_ID"
else
    reponame="$(epm print info -r)"
fi

for element in "${packages[@]}"; do
    pattern="*$(_get_suffix)"
    epm tool eget --latest $BASE_REMOTE_URL/$element/releases "$pattern"
    epm repo pkgadd $reponame $pattern
    rm $pattern
done

epm repo index $reponame