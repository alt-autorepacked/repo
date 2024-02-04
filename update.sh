#!/bin/bash

epm tool eget https://raw.githubusercontent.com/alt-autorepacked/common/v0.1.0/common.sh
. ./common.sh

packages=(
    "vk-messenger"
    "discord"
    "code"
    "yandexmusic"
    "google-chrome-stable"
    "Telegram"
)

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
