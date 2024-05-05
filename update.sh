#!/bin/bash

COMMON_VERSION="0.4.0"

epm tool eget https://raw.githubusercontent.com/alt-autorepacked/common/v$COMMON_VERSION/common.sh
. ./common.sh

packages=(
    "vk-messenger"
    "discord"
    "code"
    "yandex-music"
    "google-chrome-stable"
    "Telegram"
    "draw.io"
    "Trezor-Suite"
    "singularityapp"
)

# Define an array of the required programs
required_programs=("gh" "epm")

for program in "${required_programs[@]}"; do
    if ! command -v "$program" >/dev/null; then
        echo "$program not found, please install it"
        return 1
    fi
done


if [ -n "$ALT_BRANCH_ID" ]; then
    reponame="$ALT_BRANCH_ID"
else
    reponame="$(epm print info -r)"
fi

epm repo create $reponame

for element in "${packages[@]}"; do
    pattern="*$(_get_suffix)"
    epm tool eget --latest $BASE_REMOTE_URL/$element/releases "$pattern"
    epm repo pkgadd $reponame $pattern
    rm $pattern
done

epm repo index $reponame

for folder in "$reponame"/*/; do
    folder_name="${folder%/}"
    TAG="${folder_name//\//-}"
    gh release create $TAG --notes "[CI] automatic release"
    gh release upload $TAG $folder_name/base/* --clobber
done 
