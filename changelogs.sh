#!/bin/bash

_debug() {
    echo "[DEBUG]: $1"
}

NAMESPACE="shonenada"
REPO_NAME="changelogs.sh"

REPO_URL="https://github.com/$NAMESPACE/$REPO_NAME"

UPSTRAEM_REMOTE="origin"
RELEASE_BRANCH="release"

git remote -v | grep 'upstream' >> /dev/null
RC="$?";

if [ "$RC" == "0" ]; then
    UPSTRAEM_REMOTE="upstream"
fi

CURRENT_BRANCH="$(git branch | grep '*' | awk '{print $2}')"

_debug "Upstream Remote: $UPSTRAEM_REMOTE"
_debug "Release Branch: $RELEASE_BRANCH"

git checkout $RELEASE_BRANCH >> /dev/null 2>&1

_debug "git pull $UPSTRAEM_REMOTE $RELEASE_BRANCH --tags"

git checkout $RELEASE_BRANCH >> /dev/null 2>&1
git pull $UPSTRAEM_REMOTE $RELEASE_BRANCH

_debug "git fetch $UPSTRAEM_REMOTE --tags"

git fetch $UPSTRAEM_REMOTE --tags >> /dev/null 2>&1

LATEST_TAG="$(git describe --tags --abbrev=0)" >> /dev/null

_debug "Lastest Tag: $LATEST_TAG"

NEW_TAG="$(date "+%Y%m%d")"

echo ''
echo '=================================='
echo "NEW TAG: $NEW_TAG"
echo '=================================='
echo ''
git log --pretty=format:"- [%h] %s @%an" --abbrev-commit $LATEST_TAG..$UPSTRAEM_REMOTE/$RELEASE_BRANCH | grep -v 'Merge branch'
TC=$(git log --pretty=format:"- [%h] %s @%an" --abbrev-commit $LATEST_TAG..$UPSTRAEM_REMOTE/$RELEASE_BRANCH | grep -v 'Merge branch' | wc -l)
echo ''
echo "Total commits: $TC"
echo ''
echo "Dont forget to create your tag/release: $REPO_URL/releases/new"
echo ''
git checkout $CURRENT_BRANCH >> /dev/null 2>&1
