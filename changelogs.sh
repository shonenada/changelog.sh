#!/bin/bash

_debug() {
    echo "[DEBUG]: $1"
}

UPSTRAEM_REMOTE="origin"
RELEASE_BRANCH="main"

git remote -v | grep 'upstream' >> /dev/null
RC="$?";
if [[ "$RC" == "0" ]]; then
    UPSTRAEM_REMOTE="upstream"
fi

git branch | grep 'release' >> /dev/null
RC="$?";
if [[ "$RC" == "0" ]]; then
    RELEASE_BRANCH="release"
fi

REMOTE_URL=$(git remote get-url $UPSTRAEM_REMOTE)
if [[ $REMOTE_URL == https* ]];
then 
    NAMESPACE=$(echo "$REMOTE_URL" | cut -d'/' -f4)
    REPO_NAME=$(echo "$REMOTE_URL" | cut -d'/' -f5)
else
    PREFIX=$(echo "$REMOTE_URL" | cut -d'/' -f1)
    NAMESPACE=$(echo "$PREFIX" | cut -d':' -f2)
    REPO_NAME=$(echo "$REMOTE_URL" | cut -d'/' -f2)
fi

if [[ $REPO_NAME == *.git ]];then
    REPO_NAME=${REPO_NAME:0:-4}
fi

if [[ "$NAMESPACE" == "" ]]; then
    echo "Invalid remote url: $REMOTE_URL. Failed to extract namespace."
    exit 1
fi

if [[ "$REPO_NAME" == "" ]]; then
    echo "Invalid remote url: $REMOTE_URL. Failed to extract name."
    exit 1
fi

_debug "namespace: $NAMESPACE, repo_name: $REPO_NAME"

REPO_URL="https://github.com/$NAMESPACE/$REPO_NAME"

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
